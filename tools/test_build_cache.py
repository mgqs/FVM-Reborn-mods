"""Incremental native builds must invalidate correctly, without running a compiler."""

from contextlib import redirect_stdout
import io
from pathlib import Path
import subprocess
import tempfile
from types import SimpleNamespace
import unittest
from unittest.mock import patch

import build_macos
from build_cache import build_if_changed


class BuildCacheTests(unittest.TestCase):
    def setUp(self):
        self.temporary = tempfile.TemporaryDirectory()
        self.addCleanup(self.temporary.cleanup)
        self.root = Path(self.temporary.name)
        self.source = self.root / "source.c"
        self.source.write_bytes(b"original")
        self.output = self.root / "object.o"
        self.builds = 0

    def build(self):
        self.builds += 1
        self.output.write_bytes(b"built " + self.source.read_bytes())

    def cached(self, settings=None):
        return build_if_changed(self.output, [self.source], settings or {"flags": ["-O2"]}, self.build)

    def test_unchanged_inputs_reuse_output_without_touching_it(self):
        self.assertTrue(self.cached())
        before = (self.output.stat().st_ino, self.output.stat().st_mtime_ns)
        self.assertFalse(self.cached())
        self.assertEqual(self.builds, 1)
        self.assertEqual((self.output.stat().st_ino, self.output.stat().st_mtime_ns), before)

    def test_content_changes_invalidate_even_when_size_and_timestamp_are_preserved(self):
        import os
        self.cached()
        stat = self.source.stat()
        self.source.write_bytes(b"modified")
        os.utime(self.source, ns=(stat.st_atime_ns, stat.st_mtime_ns))
        self.assertTrue(self.cached())

    def test_flags_missing_outputs_corruption_and_permissions_invalidate(self):
        self.cached()
        self.assertTrue(self.cached({"flags": ["-O0"]}))
        self.output.unlink()
        self.assertTrue(self.cached())
        self.output.write_bytes(b"damaged")
        self.assertTrue(self.cached())
        self.output.chmod(0o700)
        self.assertTrue(self.cached())
        self.output.with_name(self.output.name + ".build.json").write_text("broken JSON")
        self.assertTrue(self.cached())

    def test_failed_build_cannot_be_reused(self):
        self.cached()
        self.source.write_bytes(b"updated")

        def fail():
            self.output.write_bytes(b"partial output")
            raise RuntimeError("compiler failed")

        with self.assertRaisesRegex(RuntimeError, "compiler failed"):
            build_if_changed(self.output, [self.source], {"flags": ["-O2"]}, fail)
        self.assertTrue(self.cached())

    def test_stamp_can_stay_in_build_directory_for_an_installed_output(self):
        stamp = self.root / "cache/installed.build.json"
        self.assertTrue(build_if_changed(self.output, [self.source], {}, self.build, stamp=stamp))
        self.assertFalse(build_if_changed(self.output, [self.source], {}, self.build, stamp=stamp))
        self.assertTrue(stamp.is_file())
        self.assertFalse(self.output.with_name(self.output.name + ".build.json").exists())
        self.output.write_bytes(b"external replacement")
        self.assertTrue(build_if_changed(self.output, [self.source], {}, self.build, stamp=stamp))


class NativeIncrementalTests(unittest.TestCase):
    def setUp(self):
        self.temporary = tempfile.TemporaryDirectory()
        self.addCleanup(self.temporary.cleanup)
        self.root = Path(self.temporary.name)
        self.work = self.root / ".macos-build"
        self.work.mkdir()
        files = ["FvmNativeSupport/third_party/lua-5.4.8/src/lapi.c",
                 "FvmNativeSupport/third_party/lua-5.4.8/src/lstate.c",
                 "FvmNativeSupport/third_party/lua-5.4.8/src/lua.h",
                 "FvmNativeSupport/macos/native_support.mm", "FvmNativeSupport/macos/text_input.mm",
                 "FvmNativeSupport/macos/text_input.h", "FvmNativeSupport/FvmNativeSupport/mod_lua.cpp",
                 "tools/test_macos_text_input.mm", "extensions/TextureEncode/bc7enc",
                 "extensions/TextureEncode/astcenc", "sprites/spr_hex_mark/frame.png"]
        for relative in files:
            path = self.root / relative
            path.parent.mkdir(parents=True, exist_ok=True)
            path.write_bytes(relative.encode())
        (self.root / "extensions/WindowsNative").mkdir()
        self.commands = []
        for name, replacement in (("ROOT", self.root), ("run", self.fake_run),
                                  ("thin_to_arm64", lambda path: None),
                                  ("clear_build_quarantine", lambda path: None)):
            mock = patch.object(build_macos, name, replacement)
            mock.start()
            self.addCleanup(mock.stop)
        mock = patch.object(build_macos.subprocess, "check_output", side_effect=self.fake_check_output)
        mock.start()
        self.addCleanup(mock.stop)

    def fake_check_output(self, command, **kwargs):
        return str(self.root / "SDK") if "--show-sdk-path" in command else "Apple clang test toolchain"

    def fake_run(self, args, **kwargs):
        args = list(map(str, args))
        self.commands.append(args)
        if "-o" in args:
            path = Path(args[args.index("-o") + 1])
            inputs = [Path(arg) for arg in args if arg.endswith((".c", ".mm", ".cpp", ".o")) and Path(arg).is_file()]
            headers = sorted((self.root / "FvmNativeSupport").rglob("*.h"))
            path.write_bytes(b"compiled:" + b"|".join(item.read_bytes() for item in [*inputs, *headers]))
        elif args[0] == "codesign" and "--sign" in args:
            path = Path(args[-1])
            path.write_bytes(path.read_bytes() + b":signed:" + args[args.index("--sign") + 1].encode())
        elif Path(args[0]).name == "bc7enc":
            Path(args[-1]).write_bytes(b"DDS fake pixels")

    def build(self, identity="-"):
        with redirect_stdout(io.StringIO()):
            return build_macos.build_native(self.work, 2, identity)

    def compilers(self):
        return [command for command in self.commands if "-o" in command]

    def test_warm_native_build_preserves_library_and_tools_and_still_runs_checks(self):
        library = self.build()
        tool = self.work / "texture-tools/bc7enc"
        before = [(path.stat().st_ino, path.stat().st_mtime_ns) for path in (library, tool)]
        self.commands.clear()
        self.build()
        self.assertFalse(self.compilers())
        self.assertEqual(before, [(path.stat().st_ino, path.stat().st_mtime_ns) for path in (library, tool)])
        self.assertTrue(any("test_macos_native.py" in command[1] for command in self.commands if len(command) > 1))
        self.assertIn([str(self.work / "test-macos-text-input")], self.commands)

    def test_one_lua_source_rebuilds_only_its_object_and_library(self):
        self.build()
        source = self.root / "FvmNativeSupport/third_party/lua-5.4.8/src/lapi.c"
        source.write_bytes(b"changed source")
        self.commands.clear()
        self.build()
        compilers = self.compilers()
        self.assertEqual(len(compilers), 2)
        self.assertTrue(any(str(source) in command for command in compilers))
        self.assertFalse(any(any(arg.endswith("lstate.c") for arg in command) for command in compilers))

    def test_lua_header_rebuilds_dependent_objects(self):
        self.build()
        (self.root / "FvmNativeSupport/third_party/lua-5.4.8/src/lua.h").write_bytes(b"changed header")
        self.commands.clear()
        self.build()
        self.assertEqual(len(self.compilers()), 3)

    def test_native_header_signing_identity_and_replaced_install_are_detected(self):
        library = self.build()
        (self.root / "FvmNativeSupport/macos/text_input.h").write_bytes(b"changed native header")
        self.commands.clear()
        self.build()
        self.assertEqual(len(self.compilers()), 1)
        self.commands.clear()
        self.build("test-identity")
        self.assertFalse(self.compilers())
        self.assertTrue(library.read_bytes().endswith(b":signed:test-identity"))
        library.write_bytes(b"replaced library")
        self.build("test-identity")
        self.assertNotEqual(library.read_bytes(), b"replaced library")

    def test_texture_verification_failure_is_retried(self):
        def fail_encoder(args, **kwargs):
            if Path(str(args[0])).name == "bc7enc":
                raise subprocess.CalledProcessError(1, args)
            self.fake_run(args, **kwargs)

        with patch.object(build_macos, "run", fail_encoder):
            with self.assertRaises(subprocess.CalledProcessError):
                self.build()
        self.commands.clear()
        self.build()
        self.assertTrue(any(Path(command[0]).name == "bc7enc" for command in self.commands))


class DevelopmentBuildTests(unittest.TestCase):
    def test_no_zip_still_assembles_and_validates_app_and_preserves_existing_zip(self):
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)
            work = root / "work"
            output = root / "dist"
            work.mkdir()
            output.mkdir()
            archive = output / "FVM_Reborn_makk-macOS.zip"
            archive.write_bytes(b"previous distribution")
            args = SimpleNamespace(output=output, jobs=1, sign_identity="-", no_zip=True)
            with patch.object(build_macos, "ROOT", root), \
                 patch.object(build_macos, "prepare_macos_project", return_value=work / "project.yyp"), \
                 patch.object(build_macos, "igor_command", return_value=["Igor"]), \
                 patch.object(build_macos.subprocess, "run", return_value=SimpleNamespace(returncode=0)), \
                 patch.object(build_macos, "assemble_app", return_value=output / "game.app") as assemble, \
                 patch.object(build_macos, "run") as run, redirect_stdout(io.StringIO()):
                build_macos.build_game(args, work, root / "runtime/Cache/runtimes/current", root / "user")
            assemble.assert_called_once()
            self.assertEqual(len(run.call_args_list), 1)
            self.assertEqual(Path(run.call_args.args[0][1]).name, "test_macos_resources.py")
            self.assertEqual(archive.read_bytes(), b"previous distribution")


if __name__ == "__main__":
    unittest.main()
