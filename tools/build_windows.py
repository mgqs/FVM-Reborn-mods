#!/usr/bin/env python3
"""Build a memory-optimized Windows x64 ZIP on a Windows build machine."""

from __future__ import annotations

import argparse
from contextlib import contextmanager
import json
import os
from pathlib import Path
import platform
import shutil
import struct
import subprocess
import sys
import tempfile
import time
import zipfile

from desktop_resources import prepare_project
from test_macos_resources import validate

ROOT = Path(__file__).resolve().parents[1]


@contextmanager
def timed_phase(label: str):
    started = time.perf_counter()
    try:
        yield
    finally:
        print(f"[time] {label}: {time.perf_counter() - started:.2f}s", flush=True)


def assemble(archive: Path, output: Path) -> dict:
    output.mkdir(parents=True, exist_ok=True)
    with tempfile.TemporaryDirectory(prefix=".fvm-windows-", dir=output) as temporary:
        stage = Path(temporary)
        with zipfile.ZipFile(archive) as package:
            for item in package.infolist():
                relative = Path(item.filename.replace("\\", "/"))
                if relative.is_absolute() or ".." in relative.parts:
                    raise RuntimeError("Unsafe path in GameMaker package")
            # Reading each entry to EOF during extraction already verifies CRC.
            # testzip() beforehand would decompress the whole game twice.
            try:
                package.extractall(stage)
            except zipfile.BadZipFile as error:
                raise RuntimeError("Corrupt ZIP member: " + str(error)) from error
        candidates = list(stage.rglob("data.win"))
        if len(candidates) != 1:
            raise RuntimeError("Expected exactly one data.win in Windows package")
        resources = candidates[0].parent
        binaries = ("FVM_Reborn_makk.exe", "FvmNativeSupport.dll", "7z.dll")
        for name in binaries:
            if not (resources / name).is_file():
                raise RuntimeError("Required Windows binary is missing: " + name)
        for name in binaries:
            with (resources / name).open("rb") as binary:
                if binary.read(2) != b"MZ":
                    raise RuntimeError("Invalid Windows binary: " + name)
                binary.seek(0x3C)
                binary.seek(struct.unpack("<I", binary.read(4))[0])
                if binary.read(4) != b"PE\x00\x00" or struct.unpack("<H", binary.read(2))[0] != 0x8664:
                    raise RuntimeError("Expected Windows x64 binary: " + name)
        report = validate(resources, "Windows")
        destination = output / "FVM_Reborn_makk"
        if destination.exists():
            shutil.rmtree(destination)
        shutil.move(str(resources), destination)
    shutil.copy2(archive, output / "FVM_Reborn_makk-Windows-x64.zip")
    return report


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--runtime-path", default=os.environ.get("GAMEMAKER_RUNTIME"),
                        help="Windows path to the installed GameMaker runtime")
    parser.add_argument("--user-dir", default=os.environ.get("GAMEMAKER_USER_DIR"),
                        help="existing GameMaker licence folder; never copied into packages")
    parser.add_argument("--output", type=Path, default=ROOT / "dist/windows")
    parser.add_argument("--jobs", type=int, default=1)
    args = parser.parse_args()
    if args.jobs < 1 or args.jobs > 64:
        parser.error("--jobs must be between 1 and 64")
    if platform.system() != "Windows":
        parser.error("Run this build on Windows with the GameMaker Windows runtime installed.")
    work = ROOT / ".windows-build"
    work.mkdir(exist_ok=True)
    archive = work / "FVM_Reborn_makk-Windows-x64.zip"
    try:
        with timed_phase("Windows project staging"):
            project = prepare_project(ROOT, work, "Windows", copy_assets=True)
        command = ["powershell.exe", "-NoProfile", "-NonInteractive", "-ExecutionPolicy", "Bypass", "-File",
                   str(ROOT / "tools/build_windows.ps1"), "-Project", str(project),
                   "-Work", str(work), "-Output", str(archive), "-Jobs", str(args.jobs)]
        if args.runtime_path:
            command += ["-RuntimePath", args.runtime_path]
        if args.user_dir:
            command += ["-UserDir", args.user_dir]
        with timed_phase("GameMaker Windows package"):
            subprocess.run(command, check=True)
        with timed_phase("Package extraction and validation"):
            report = assemble(archive, args.output.expanduser().resolve())
        (work / "resources.json").write_text(json.dumps(report, indent=2) + "\n", encoding="utf-8")
        print(json.dumps(report), flush=True)
        print(f"App: {args.output / 'FVM_Reborn_makk/FVM_Reborn_makk.exe'}\n"
              f"ZIP: {args.output / 'FVM_Reborn_makk-Windows-x64.zip'}", flush=True)
    except (RuntimeError, OSError, subprocess.SubprocessError, ValueError, zipfile.BadZipFile) as error:
        print(f"Build failed: {error}", file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
