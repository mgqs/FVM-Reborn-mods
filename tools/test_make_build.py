"""Exercise Makefile command routing without starting compilers or network calls."""

from pathlib import Path
import shutil
import subprocess
import unittest


ROOT = Path(__file__).resolve().parents[1]


@unittest.skipUnless(shutil.which("make"), "GNU Make is not installed")
class MakeBuildTests(unittest.TestCase):
    def make(self, *arguments):
        return subprocess.check_output(["make", "--no-print-directory", *arguments], cwd=ROOT, text=True)

    def test_default_target_only_shows_help(self):
        help_text = self.make()
        self.assertIn("make macos", help_text)
        self.assertIn("make windows", help_text)
        self.assertNotIn("tools/build_macos.py --jobs", help_text)

    def test_macos_modes_keep_safe_default_jobs_and_skip_zip_only_for_development(self):
        command = self.make("-n", "macos")
        self.assertIn("tools/build_macos.py --jobs 1 --no-zip", command)
        release = self.make("-n", "macos-release")
        self.assertNotIn("--no-zip", release)
        self.assertIn("--native-only", self.make("-n", "macos-native"))

    def test_windows_target_uses_local_script_and_supports_overrides(self):
        command = self.make("-n", "windows", "PYTHON=python", "WINDOWS_JOBS=4",
                            "WINDOWS_ARGS=--output dist/custom-windows")
        self.assertIn("python tools/build_windows.py --jobs 4 --output dist/custom-windows", command)
        self.assertNotIn(".private", command)
        self.assertNotIn("--sync", command)
        self.assertNotIn("--build", command)


if __name__ == "__main__":
    unittest.main()
