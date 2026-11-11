#!/usr/bin/env python3
"""Exercise the real compiled macOS C ABI using disposable saves and Mod files."""

import ctypes
import json
from pathlib import Path
import stat
import sys
import tempfile
import unittest
import zipfile


class NativeTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.lib = ctypes.CDLL(str(Path(sys.argv[1]).resolve()))
        string = ctypes.c_char_p
        real = ctypes.c_double
        functions = {
            "SetNativeLogFilePath": [string], "OpenFolder": [string],
            "FolderExists": [string], "FileExists": [string],
            "CopyFolder": [string, string], "DeleteFolder": [string],
            "StartBackup": [string], "StartBackupWithTargetFile": [string, string],
            "RestoreBackup": [string, string], "RestoreBackupWithTargetFile": [string, string],
            "UnzipMapFile": [string, string], "DisableIme": [real], "EnableIme": [real],
            "StartMouseLimit": [real, real], "StopMouseLimit": [], "MouseLimitStats": [real],
            "ModLuaDestroy": [real],
        }
        for name, args in functions.items():
            getattr(cls.lib, name).argtypes = args
            getattr(cls.lib, name).restype = real
        cls.lib.ModLuaCreate.argtypes = [string]
        cls.lib.ModLuaCreate.restype = string
        cls.lib.ModLuaCall.argtypes = [real, string, string]
        cls.lib.ModLuaCall.restype = string

    def setUp(self):
        self.temp = tempfile.TemporaryDirectory(prefix="fvm-macos-test-")
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        self.assertEqual(self.call("SetNativeLogFilePath", self.root / "native/latest.log"), 0)

    def call(self, name, *args):
        return getattr(self.lib, name)(*(str(arg).encode() if isinstance(arg, (str, Path)) else arg for arg in args))

    def zip(self, name, entries):
        path = self.root / name
        with zipfile.ZipFile(path, "w", zipfile.ZIP_DEFLATED) as output:
            for key, content in entries.items():
                output.writestr(key, content)
        return path

    def test_unicode_files_copy_merge_and_delete(self):
        source = self.root / "玩家存档/saves"
        source.mkdir(parents=True)
        (source / "玩家.json").write_text('{"关卡": 3}\n')
        (source / "nested").mkdir()
        (source / "nested/data.bin").write_bytes(b"\x00\xff")
        target = self.root / "迁移目录"
        self.assertEqual(self.call("FolderExists", source), 1)
        self.assertEqual(self.call("FileExists", source / "玩家.json"), 1)
        self.assertEqual(self.call("CopyFolder", str(source) + "/", target), 0)
        (target / "saves/kept.txt").write_text("keep")
        (source / "玩家.json").write_text("updated")
        self.assertEqual(self.call("CopyFolder", source, target), 0)
        self.assertEqual((target / "saves/玩家.json").read_text(), "updated")
        self.assertEqual((target / "saves/nested/data.bin").read_bytes(), b"\x00\xff")
        self.assertTrue((target / "saves/kept.txt").is_file())
        self.assertEqual(self.call("DeleteFolder", target), 0)
        self.assertFalse(target.exists())

    def test_backup_restore_windows_compatible_format(self):
        saves = self.root / "saves"
        saves.mkdir()
        content = '{"name":"玩家", "level":42}\n'
        (saves / "存档.json").write_text(content)
        (saves / "ignored.txt").write_text("not a save")
        backup = self.root / "backup.json"
        self.assertEqual(self.call("StartBackupWithTargetFile", saves, backup), 0)
        self.assertEqual(json.loads(backup.read_text()), {"files": [{"name": "存档.json", "content": content}]})
        restored = self.root / "restored"
        self.assertEqual(self.call("RestoreBackupWithTargetFile", restored, backup), 0)
        self.assertEqual((restored / "存档.json").read_text(), content)
        self.assertFalse((restored / "ignored.txt").exists())

    def test_empty_backup_and_bad_arguments(self):
        backup = self.root / "backup.json"
        self.assertEqual(self.call("StartBackupWithTargetFile", self.root / "new-saves", backup), 0)
        self.assertEqual(json.loads(backup.read_text()), {"files": []})
        self.assertEqual(self.call("RestoreBackupWithTargetFile", self.root / "restored", backup), 0)
        self.assertEqual(self.call("StartBackupWithTargetFile", "", backup), -1)
        self.assertEqual(self.call("RestoreBackupWithTargetFile", self.root, self.root / "missing"), 2)
        backup.write_text("invalid JSON")
        self.assertEqual(self.call("RestoreBackupWithTargetFile", self.root, backup), -2)
        self.assertIn("error_code=-2", (self.root / "native/latest.log").read_text())

    def test_backup_rejects_escape_before_writing(self):
        backup = self.root / "bad.json"
        backup.write_text(json.dumps({"files": [{"name": "safe.json", "content": "{}"},
                                                {"name": "../escape.json", "content": "{}"}]}))
        destination = self.root / "restored"
        self.assertEqual(self.call("RestoreBackupWithTargetFile", destination, backup), -13)
        self.assertFalse((destination / "safe.json").exists())
        self.assertFalse((self.root / "escape.json").exists())

    def test_extract_unicode_and_windows_separators(self):
        archive = self.zip("mod.zip", {"卡片/manifest.json": "{}", "卡片\\frames\\1.png": b"image"})
        target = self.root / "mods"
        self.assertEqual(self.call("UnzipMapFile", archive, target), 0)
        self.assertEqual((target / "卡片/manifest.json").read_text(), "{}")
        self.assertEqual((target / "卡片/frames/1.png").read_bytes(), b"image")

    def test_extract_rejects_traversal_and_absolute_paths(self):
        for name in ("../escaped.txt", "..\\escaped.txt", str(self.root / "escaped.txt"), "C:\\escaped.txt"):
            with self.subTest(name=name):
                archive = self.zip("bad.zip", {name: "bad"})
                self.assertEqual(self.call("UnzipMapFile", archive, self.root / "mod"), -13)
                self.assertFalse((self.root / "escaped.txt").exists())

    def test_extract_rejects_symlinks(self):
        info = zipfile.ZipInfo("link")
        info.create_system = 3
        info.external_attr = (stat.S_IFLNK | 0o777) << 16
        archive = self.root / "link.zip"
        with zipfile.ZipFile(archive, "w") as output:
            output.writestr(info, "../outside")
        self.assertEqual(self.call("UnzipMapFile", archive, self.root / "mod"), -13)
        outside = self.root / "outside"
        outside.mkdir()
        destination = self.root / "existing"
        destination.mkdir()
        (destination / "link").symlink_to(outside, target_is_directory=True)
        archive = self.zip("nested.zip", {"link/escaped.txt": "bad"})
        self.assertEqual(self.call("UnzipMapFile", archive, destination), -13)
        self.assertFalse((outside / "escaped.txt").exists())

    def test_bad_archive(self):
        archive = self.root / "broken.zip"
        archive.write_bytes(b"not an archive")
        self.assertEqual(self.call("UnzipMapFile", archive, self.root / "mod"), -11)
        self.assertEqual(self.call("UnzipMapFile", self.root / "missing.zip", self.root / "mod"), -16)

    def create_lua(self, source):
        response = json.loads(self.call("ModLuaCreate", source))
        self.assertTrue(response["ok"], response)
        self.addCleanup(self.call, "ModLuaDestroy", response["handle"])
        return response["handle"]

    def test_lua_bridge_state_commands_and_sandbox(self):
        handle = self.create_lua("""
            return {on_tick = function(ctx, state)
                assert(io == nil and os == nil and package == nil and loadfile == nil)
                state.count = (state.count or 0) + 1
                api.damage({amount = ctx.power + state.count})
            end}
        """)
        for value in (3, 4):
            response = json.loads(self.call("ModLuaCall", handle, "on_tick", '{"power":2}'))
            self.assertEqual(response, {"ok": True, "commands": [{"op": "damage", "amount": value}]})
        self.assertEqual(self.call("ModLuaDestroy", handle), 0)
        self.assertFalse(json.loads(self.call("ModLuaCall", handle, "on_tick", "{}"))["ok"])

    def test_lua_execution_and_memory_limits(self):
        for source in ("return {on_tick=function() while true do end end}",
                       'return {on_tick=function() local x=string.rep("x", 16*1024*1024) end}'):
            handle = self.create_lua(source)
            self.assertFalse(json.loads(self.call("ModLuaCall", handle, "on_tick", "{}"))["ok"])
        self.assertFalse(json.loads(self.call("ModLuaCreate", "this is invalid lua"))["ok"])


if __name__ == "__main__":
    if len(sys.argv) < 2:
        raise SystemExit("Usage: python3 tools/test_macos_native.py /path/to/libFvmNativeSupport.dylib")
    # Keep the library argument available to setUpClass, but hide it from unittest.
    unittest.main(argv=[sys.argv[0]], verbosity=2)
