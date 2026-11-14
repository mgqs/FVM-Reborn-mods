#!/usr/bin/env python3
"""Build the Apple Silicon macOS extension and a locally signed GameMaker VM app."""

from __future__ import annotations

import argparse
from concurrent.futures import ThreadPoolExecutor
from contextlib import contextmanager
import os
from pathlib import Path
import platform
import plistlib
import re
import shutil
import subprocess
import sys
import tempfile
import time
import zipfile

from build_cache import build_if_changed
from desktop_resources import configuration, prepare_project, read_yy, sprite_group, texture_groups

ROOT = Path(__file__).resolve().parents[1]
LIBRARY_NAME = "libFvmNativeSupport.dylib"
LAUNCHER_NAME = "FVM_Launcher"
MAC_ARCH = "arm64"


@contextmanager
def timed_phase(label: str):
    started = time.perf_counter()
    try:
        yield
    finally:
        print(f"[time] {label}: {time.perf_counter() - started:.2f}s", flush=True)


def run(args: list[str | Path], **kwargs) -> None:
    subprocess.run([str(arg) for arg in args], check=True, **kwargs)


def sign(path: Path, identity: str) -> None:
    run(["codesign", "--force", "--sign", identity, "--timestamp=none", path])


def thin_to_arm64(path: Path) -> None:
    architectures = subprocess.check_output(["xcrun", "lipo", "-archs", path], text=True).split()
    if architectures == [MAC_ARCH]:
        return
    if MAC_ARCH not in architectures:
        raise RuntimeError(f"No {MAC_ARCH} slice in {path}")
    with tempfile.TemporaryDirectory(prefix=".fvm-arm64-", dir=path.parent) as temp:
        thin = Path(temp) / path.name
        run(["xcrun", "lipo", path, "-thin", MAC_ARCH, "-output", thin])
        shutil.copystat(path, thin)
        os.replace(thin, path)


def clear_build_quarantine(path: Path) -> None:
    quarantine = subprocess.run(["xattr", "-p", "com.apple.quarantine", str(path)], capture_output=True)
    if quarantine.returncode == 0:
        run(["xattr", "-d", "com.apple.quarantine", path])


def build_native(work: Path, jobs: int, identity: str) -> Path:
    sdk = subprocess.check_output(
        ["xcrun", "--sdk", "macosx", "--show-sdk-path"], text=True).strip()
    source = ROOT / "FvmNativeSupport"
    lua = source / "third_party/lua-5.4.8/src"
    lua_sources = sorted(p for p in lua.glob("*.c") if p.name not in {"lua.c", "luac.c"})
    if not lua_sources:
        raise RuntimeError(f"Bundled Lua sources not found: {lua}")
    print(f"Building native extension ({MAC_ARCH})...", flush=True)
    objects_dir = work / "native" / MAC_ARCH
    objects_dir.mkdir(parents=True, exist_ok=True)
    common = ["-arch", MAC_ARCH, "-isysroot", sdk, "-mmacosx-version-min=11.0",
              "-O2", "-fPIC", "-fvisibility=hidden"]
    compiler = subprocess.check_output(["xcrun", "clang", "--version"], text=True).strip()
    # Headers and toolchain changes invalidate objects even when .c files do not.
    build_sources = [Path(__file__), Path(__file__).with_name("build_cache.py")]
    sdk_settings = Path(sdk) / "SDKSettings.json"
    if sdk_settings.is_file():
        build_sources.append(sdk_settings)
    lua_inputs = [*lua.glob("*.h"), *build_sources]

    def compile_lua(path: Path) -> tuple[Path, bool]:
        output = objects_dir / (path.stem + ".o")
        command = ["xcrun", "clang", *common, "-DLUA_USE_MACOSX", "-c", path, "-o", output]
        changed = build_if_changed(output, [path, *lua_inputs],
                                   {"compiler": compiler, "command": list(map(str, command))},
                                   lambda: run(command))
        return output, changed

    with ThreadPoolExecutor(max_workers=jobs) as executor:
        compiled = list(executor.map(compile_lua, lua_sources))
    objects = [path for path, changed in compiled]
    print(f"Lua objects: {sum(changed for path, changed in compiled)} rebuilt, "
          f"{sum(not changed for path, changed in compiled)} cached", flush=True)
    library = objects_dir / LIBRARY_NAME
    native_sources = [source / "macos/native_support.mm", source / "macos/text_input.mm",
                      source / "FvmNativeSupport/mod_lua.cpp", source / "FvmNativeSupport/archive_jobs.cpp"]
    native_headers = [*source.glob("macos/*.h"), *source.glob("macos/*.hpp"),
                      *source.glob("FvmNativeSupport/*.h"), *source.glob("FvmNativeSupport/*.hpp")]
    command = ["xcrun", "clang++", *common, "-std=c++17", "-fobjc-arc", "-dynamiclib",
               *native_sources, *objects, "-framework", "AppKit", "-framework", "UniformTypeIdentifiers",
               "-larchive", "-Wl,-install_name,@rpath/" + LIBRARY_NAME, "-o", library]
    linked = build_if_changed(library, [*native_sources, *native_headers, *lua_inputs, *objects],
                             {"compiler": compiler, "command": list(map(str, command))},
                             lambda: run(command))
    print("Native library: " + ("rebuilt" if linked else "cached"), flush=True)
    destination = ROOT / "extensions/WindowsNative" / LIBRARY_NAME

    def install_native() -> None:
        with tempfile.TemporaryDirectory(prefix="native-", dir=work) as temp:
            fresh = Path(temp) / LIBRARY_NAME
            shutil.copy2(library, fresh)
            sign(fresh, identity)
            run(["codesign", "--verify", "--strict", fresh])
            os.replace(fresh, destination)

    # Keep stamps under .macos-build, and preserve the extension's source-tree
    # mtime on a hit: rewriting it would also invalidate GameMaker's cache.
    build_if_changed(destination, [library, *build_sources], {"identity": identity}, install_native,
                     stamp=objects_dir / ("installed-" + LIBRARY_NAME + ".build.json"))
    run([sys.executable, ROOT / "tools/test_macos_native.py", destination])
    text_test = work / "test-macos-text-input"
    text_source = ROOT / "tools/test_macos_text_input.mm"
    command = ["xcrun", "clang++", "-std=c++17", "-fobjc-arc", "-arch", MAC_ARCH,
               "-mmacosx-version-min=11.0", "-framework", "AppKit", text_source, "-o", text_test]
    build_if_changed(text_test, [text_source, *build_sources],
                     {"compiler": compiler, "command": list(map(str, command))}, lambda: run(command))
    run([text_test])
    prepare_texture_tools(work)
    return destination


def prepare_texture_tools(work: Path) -> Path:
    # Keep signatures out of the third-party binaries tracked in Git.
    destination = work / "texture-tools"
    destination.mkdir(parents=True, exist_ok=True)
    rebuilt = False
    for name in ("bc7enc", "astcenc"):
        def install_tool() -> None:
            # When rebuilding, sign a fresh inode to avoid macOS retaining its
            # validation of an earlier unsigned executable. Hits keep that inode.
            with tempfile.TemporaryDirectory(prefix="texture-tools-", dir=work) as temp:
                path = Path(temp) / name
                shutil.copyfile(ROOT / "extensions/TextureEncode" / name, path)
                path.chmod(0o755)
                clear_build_quarantine(path)
                thin_to_arm64(path)
                sign(path, "-")
                run(["codesign", "--verify", "--all-architectures", "--strict", path])
                os.replace(path, destination / name)

        rebuilt |= build_if_changed(destination / name,
                                    [ROOT / "extensions/TextureEncode" / name, Path(__file__)],
                                    {"arch": MAC_ARCH, "identity": "-"}, install_tool)
    if rebuilt:
        try:
            with tempfile.TemporaryDirectory(prefix="texture-test-", dir=work) as temp:
                image = next((ROOT / "sprites/spr_hex_mark").glob("*.png"))
                encoded = Path(temp) / "test.dds"
                run([destination / "bc7enc", "-g", "-3", "-u4", image, encoded],
                    stdin=subprocess.DEVNULL, stdout=subprocess.DEVNULL, timeout=30)
                if not encoded.is_file() or encoded.read_bytes()[:4] != b"DDS ":
                    raise RuntimeError("The locally signed BC3 texture encoder did not produce a DDS file.")
        except BaseException:
            # A failed/interrupted execution check must be retried next time.
            for name in ("bc7enc", "astcenc"):
                (destination / (name + ".build.json")).unlink(missing_ok=True)
            raise
    return destination


def runtime_path(explicit: str | None) -> Path:
    if explicit:
        root = Path(explicit).expanduser().resolve()
    else:
        candidates = list(Path("/Users/Shared").glob("GameMakerStudio2*/Cache/runtimes/runtime-*"))
        if not candidates:
            raise RuntimeError("Install a GameMaker macOS runtime, or pass --runtime-path.")
        root = max(candidates, key=lambda p: tuple(map(int, re.findall(r"\d+", p.name))))
    if not (root / "mac/YoYo Runner.app").is_dir():
        raise RuntimeError(f"The macOS runtime module is not installed in {root}")
    return root


def user_path(explicit: str | None) -> Path:
    if explicit:
        root = Path(explicit).expanduser().resolve()
    else:
        base = Path.home() / "Library/Application Support"
        licences = list(base.glob("GameMakerStudio2*/*/licence.plist"))
        if not licences:
            raise RuntimeError("Log in to GameMaker once, or pass --user-dir (folder containing licence.plist).")
        root = max(licences, key=lambda p: p.stat().st_mtime).parent
    if not (root / "licence.plist").is_file():
        raise RuntimeError(f"No GameMaker licence.plist in {root}")
    return root


def igor_command(runtime: Path) -> list[str | Path]:
    folder = runtime / "bin/igor/osx" / MAC_ARCH
    if (folder / "Igor").is_file():
        return [folder / "Igor"]
    if (folder / "Igor.dll").is_file() and shutil.which("dotnet"):
        return ["dotnet", folder / "Igor.dll"]
    raise RuntimeError(f"Cannot find Igor for this Mac in {folder}")


def sign_app(app: Path, identity: str, work: Path) -> None:
    magic = {b"\xfe\xed\xfa\xce", b"\xce\xfa\xed\xfe", b"\xfe\xed\xfa\xcf",
             b"\xcf\xfa\xed\xfe", b"\xca\xfe\xba\xbe", b"\xbe\xba\xfe\xca",
             b"\xca\xfe\xba\xbf", b"\xbf\xba\xfe\xca"}
    for path in sorted(app.rglob("*")):
        if path.is_file() and not path.is_symlink():
            with path.open("rb") as stream:
                is_macho = stream.read(4) in magic
            if is_macho:
                clear_build_quarantine(path)
                thin_to_arm64(path)
                sign(path, identity)
    bundles = [p for p in app.rglob("*") if p.is_dir() and p.suffix in {".framework", ".app", ".xpc"}]
    for bundle in sorted(bundles, key=lambda p: len(p.parts), reverse=True):
        sign(bundle, identity)
    clear_build_quarantine(app)
    # A local VM build does not need App Store sandbox/team/provisioning
    # entitlements inherited from the stock Runner.
    entitlements = work / "local-entitlements.plist"
    entitlements.write_bytes(plistlib.dumps({}))
    run(["codesign", "--force", "--sign", identity, "--timestamp=none",
         "--entitlements", entitlements, app])
    run(["codesign", "--verify", "--deep", "--strict", "--verbose=2", app])


def option_asset(value: str) -> Path:
    return Path(value.replace("${options_dir}", str(ROOT / "options"))).expanduser()


def build_launcher(app: Path) -> Path:
    destination = app / "Contents/MacOS" / LAUNCHER_NAME
    run(["xcrun", "clang", "-O2", "-fobjc-arc", "-arch", MAC_ARCH,
         "-mmacosx-version-min=11.0", "-framework", "Foundation", "-framework", "CoreFoundation",
         Path(__file__).with_name("macos_launcher.m"), "-o", destination])
    return destination


def assemble_app(stage: Path, runtime: Path, output: Path, identity: str, work: Path) -> Path:
    options = read_yy(ROOT / "options/mac/options_mac.yy")
    game = stage / "game.zip"
    if not game.is_file():
        raise RuntimeError(f"GameMaker did not produce {game}")
    destination = output / "FVM_Reborn_makk.app"
    with tempfile.TemporaryDirectory(prefix=".fvm-bundle-", dir=output) as temp:
        app = Path(temp) / destination.name
        run(["ditto", "--noqtn", runtime / "mac/YoYo Runner.app", app])
        resources = app / "Contents/Resources"
        # Disable the stock Runner's IDE-connection mode.
        (resources / "yoyorunner.config").unlink(missing_ok=True)
        with zipfile.ZipFile(game) as archive:
            if "assets/game.ios" not in archive.namelist():
                raise RuntimeError("GameMaker output has no assets/game.ios")
            for entry in archive.infolist():
                if not entry.filename.startswith("assets/"):
                    continue
                relative = Path(entry.filename[len("assets/"):])
                if relative.is_absolute() or ".." in relative.parts:
                    raise RuntimeError("Invalid path in GameMaker output")
                target = resources / relative
                if entry.is_dir():
                    target.mkdir(parents=True, exist_ok=True)
                else:
                    target.parent.mkdir(parents=True, exist_ok=True)
                    with archive.open(entry) as source, target.open("wb") as target_file:
                        shutil.copyfileobj(source, target_file, 1024 * 1024)
        # Separate audio groups are written after the main game archive.
        for audio in stage.glob("*.dat"):
            shutil.copyfile(audio, resources / audio.name)
        shutil.copyfile(ROOT / "extensions/WindowsNative" / LIBRARY_NAME, resources / LIBRARY_NAME)

        info_path = app / "Contents/Info.plist"
        with info_path.open("rb") as stream:
            info = plistlib.load(stream)
        version = ".".join(options["option_mac_version"].split(".")[:3])
        info.update({
            "CFBundleExecutable": LAUNCHER_NAME,
            "CFBundleIdentifier": options["option_mac_app_id"],
            "CFBundleName": "FVM_Reborn_makk",
            "CFBundleDisplayName": options["option_mac_display_name"],
            "CFBundleShortVersionString": version,
            "CFBundleVersion": version,
            "CFBundleIconFile": "icon.icns",
            "LSMinimumSystemVersion": options["option_mac_min_version"],
            "LSApplicationCategoryType": "public.app-category.games",
            "NSHighResolutionCapable": options["option_mac_enable_retina"],
            "NSHumanReadableCopyright": options["option_mac_copyright"],
        })
        info_path.write_bytes(plistlib.dumps(info))
        build_launcher(app)
        iconset = Path(temp) / "Icon.iconset"
        iconset.mkdir()
        icon = option_asset(options["option_mac_icon_png"])
        for size in (16, 32, 128, 256, 512):
            for scale in (1, 2):
                name = f"icon_{size}x{size}" + ("@2x" if scale == 2 else "") + ".png"
                run(["sips", "-z", size * scale, size * scale, icon, "--out", iconset / name],
                    stdout=subprocess.DEVNULL)
        run(["iconutil", "-c", "icns", "-o", resources / "icon.icns", iconset])
        splash = option_asset(options["option_mac_splash_png"])
        if splash.is_file():
            shutil.copyfile(splash, resources / "splash.png")
        sign_app(app, identity, work)
        if destination.exists():
            shutil.rmtree(destination)
        os.replace(app, destination)
    return destination


def macos_configuration(resource: dict) -> dict:
    return configuration(resource, "macOS")


def macos_texture_groups(project: dict) -> list[dict]:
    return texture_groups(project, "macOS")


def macos_sprite_group(sprite: dict) -> str:
    return sprite_group(sprite)


def prepare_macos_project(work: Path) -> Path:
    return prepare_project(ROOT, work, "macOS")


def build_game(args, work: Path, runtime: Path, user: Path) -> None:
    output = args.output.expanduser().resolve()
    output.mkdir(parents=True, exist_ok=True)
    stage = Path(tempfile.mkdtemp(prefix="package-", dir=work))
    log_path = work / "build.log"
    with timed_phase("Project staging"):
        project = prepare_macos_project(work)
    command = [*igor_command(runtime), f"--project={project}",
               f"--rp={runtime}", f"--uf={user}", f"--cache={work / 'cache'}",
               f"--temp={work / 'temp'}",
               f"--of={stage / 'FVM_Reborn_makk.zip'}", f"--tf={stage / 'FVM_Reborn_makk.zip'}",
               "--runtime=VM", "--config=macOS", f"-j={args.jobs}"]
    prefabs = runtime.parents[2] / "Prefabs"
    if prefabs.is_dir():
        command.append(f"--pf={prefabs}")
    # Compile only. GameMaker's Application Oven requires Apple provisioning
    # profiles even for '-' identities; assemble and sign our local app below.
    command += ["--", "Mac", "Compile"]
    print(f"Building GameMaker app. Log: {log_path}", flush=True)
    environment = os.environ.copy()
    # Official workaround for macOS Igor/AssetCompiler AccessViolationException:
    # https://github.com/YoYoGames/GameMaker-Bugs/issues/15357
    environment["COMPlus_ZapDisable"] = "1"
    environment["FVM_TEXTURE_TOOLS_DIR"] = str(work / "texture-tools")
    with timed_phase("GameMaker compile"), log_path.open("w") as log:
        result = subprocess.run([str(arg) for arg in command], cwd=ROOT, env=environment,
                                stdout=log, stderr=subprocess.STDOUT)
    if result.returncode:
        print("\n".join(log_path.read_text(errors="replace").splitlines()[-60:]), file=sys.stderr)
        raise RuntimeError(f"GameMaker build failed ({result.returncode}); see {log_path}")
    with timed_phase("App assembly and signing"):
        destination = assemble_app(stage, runtime, output, args.sign_identity, work)
    with timed_phase("Bundle validation"):
        run([sys.executable, ROOT / "tools/test_macos_resources.py", destination])
    archive = output / "FVM_Reborn_makk-macOS.zip"
    if not getattr(args, "no_zip", False):
        with timed_phase("ZIP packaging"):
            if archive.exists():
                archive.unlink()
            run(["ditto", "-c", "-k", "--sequesterRsrc", "--keepParent", destination, archive])
    shutil.rmtree(stage)
    print(f"App: {destination}", flush=True)
    print("ZIP: skipped (--no-zip)" if getattr(args, "no_zip", False) else f"ZIP: {archive}", flush=True)


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--native-only", action="store_true", help="build and test only the macOS native extension")
    parser.add_argument("--no-zip", action="store_true", help="build and validate the app without creating a distribution ZIP")
    parser.add_argument("--runtime-path", default=os.environ.get("GAMEMAKER_RUNTIME"))
    parser.add_argument("--user-dir", default=os.environ.get("GAMEMAKER_USER_DIR"))
    parser.add_argument("--output", type=Path, default=ROOT / "dist/macos")
    parser.add_argument("--sign-identity", default="-", help="codesign identity; '-' uses a local ad-hoc signature")
    parser.add_argument("--jobs", type=int, default=1,
                        help="asset/native compiler workers; default 1 avoids macOS custom-texture deadlocks")
    args = parser.parse_args()
    if platform.system() != "Darwin":
        parser.error("Run this build on macOS with Xcode installed.")
    if platform.machine() != MAC_ARCH:
        parser.error("Run this build on an Apple Silicon Mac (arm64).")
    if args.jobs < 1:
        parser.error("--jobs must be positive")
    work = ROOT / ".macos-build"
    work.mkdir(exist_ok=True)
    try:
        runtime = user = None
        if not args.native_only:
            runtime = runtime_path(args.runtime_path)
            user = user_path(args.user_dir)
        with timed_phase("Native build and checks"):
            library = build_native(work, args.jobs, args.sign_identity)
        print(f"Native extension: {library}", flush=True)
        if not args.native_only:
            build_game(args, work, runtime, user)
    except (RuntimeError, OSError, subprocess.SubprocessError) as error:
        print(f"Build failed: {error}", file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
