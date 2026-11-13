#!/usr/bin/env python3
"""Check launcher path normalization and argument forwarding using a CLI stub."""

import argparse
import json
import os
from pathlib import Path
import shutil
import subprocess
import tempfile


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("launcher", type=Path)
    args = parser.parse_args()
    with tempfile.TemporaryDirectory(prefix="FVM 启动 test ") as temporary:
        # Resolve to /private/var so this also exercises NSString's /var alias.
        app = Path(temporary).resolve() / "游戏 with spaces.app"
        macos = app / "Contents/MacOS"
        resources = app / "Contents/Resources"
        macos.mkdir(parents=True)
        resources.mkdir()
        launcher = macos / "FVM_Launcher"
        shutil.copy2(args.launcher, launcher)
        runner = macos / "Mac_Runner"
        runner.write_text("#!/usr/bin/env python3\nimport json, os, sys\n"
                          "print(json.dumps({'cwd':os.getcwd(), 'args':sys.argv[1:]}))\n")
        runner.chmod(0o755)
        (resources / "game.ios").touch()
        ini = resources / "options.ini"
        ini.write_text("[Mac]\n")
        architectures = subprocess.check_output(["xcrun", "lipo", "-archs", str(launcher)], text=True).split()
        assert architectures == ["arm64"], architectures
        command = ["arch", "-arm64", str(launcher)]
        subprocess.run([*command, "--fvm-validate"], cwd="/", check=True)
        result = subprocess.run([*command, "--probe", "a b", "中文"], cwd="/",
                                check=True, text=True, capture_output=True)
        observed = json.loads(result.stdout)
        assert os.path.samefile(observed["cwd"], resources)
        assert observed["args"][0] == "-game"
        assert os.path.samefile(observed["args"][1], resources / "game.ios")
        assert not observed["args"][1].startswith("/private/var/")
        assert observed["args"][2:] == ["--probe", "a b", "中文"]
        ini.rename(resources / "options.ini.disabled")
        missing = subprocess.run([*command, "--fvm-validate"], cwd="/", capture_output=True)
        assert missing.returncode == 78, missing.returncode
        (resources / "options.ini.disabled").rename(ini)
        print("arm64: architecture, normalized paths, Unicode/spaces, arguments and missing-config checks passed")


if __name__ == "__main__":
    main()
