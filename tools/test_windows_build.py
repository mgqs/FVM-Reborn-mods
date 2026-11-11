"""Windows staging must preserve BC7, source assets, and the shared memory layout."""

import json
from pathlib import Path
import tempfile
import unittest
import zipfile

import build_windows
from desktop_resources import prepare_project, read_yy


class WindowsProjectTests(unittest.TestCase):
    def setUp(self):
        self.temporary = tempfile.TemporaryDirectory()
        self.addCleanup(self.temporary.cleanup)
        self.root = Path(self.temporary.name)
        self.work = self.root / ".windows-build"
        self.work.mkdir()
        for folder in (".private", "bots", "out", "dist", "FvmNativeSupport"):
            (self.root / folder).mkdir()
            (self.root / folder / "excluded.txt").write_text("must not enter project staging")
        resources = []
        examples = [
            ("sprites", "spr_ly_enemy", {"frames": [0, 1], "textureGroupId": {"name": "Default"}}),
            ("sprites", "spr_card_icon", {"frames": [0], "textureGroupId": {"name": "cards"}}),
            ("sounds", "music_example", {"compression": 0, "audioGroupId": {"name": "music"}}),
            ("sounds", "short_sound", {"compression": 0, "audioGroupId": {"name": "sound"}}),
        ]
        for kind, name, fields in examples:
            folder = self.root / kind / name
            folder.mkdir(parents=True)
            path = folder / (name + ".yy")
            path.write_text(json.dumps({"name": name, **fields}))
            (folder / "source.bin").write_bytes(b"original asset")
            resources.append({"id": {"path": path.relative_to(self.root).as_posix()}})
        groups = [{"name": name, "loadType": "default", "customOptions": "BCN -u4",
                   "ConfigValues": {"macOS": {"customOptions": "BCN -3 -u4"}}}
                  for name in ("Default", "UI", "cards", "enemy_tower")]
        (self.root / "FVM_Reborn_makk.yyp").write_text(json.dumps({"resources": resources, "TextureGroups": groups}))

    def test_windows_streams_music_and_keeps_bc7_with_shared_animation_layout(self):
        staged = prepare_project(self.root, self.work, "Windows")
        data = read_yy(staged)
        groups = {g["name"]: g for g in data["TextureGroups"]}
        for name in ("cards", "enemy_tower", "enemy_longyuan", "battle_misc", "cards_ui"):
            self.assertEqual(groups[name]["loadType"], "dynamicpages")
            self.assertEqual(groups[name]["customOptions"], "BCN -u4")
        self.assertEqual(groups["Default"]["loadType"], "default")
        self.assertEqual(groups["UI"]["loadType"], "default")
        music = read_yy(staged.parent / "sounds/music_example/music_example.yy")
        effect = read_yy(staged.parent / "sounds/short_sound/short_sound.yy")
        self.assertEqual((music["compression"], music["audioGroupId"]["name"]), (3, "audiogroup_default"))
        self.assertEqual((effect["compression"], effect["audioGroupId"]["name"]), (0, "sound"))
        enemy = read_yy(staged.parent / "sprites/spr_ly_enemy/spr_ly_enemy.yy")
        icon = read_yy(staged.parent / "sprites/spr_card_icon/spr_card_icon.yy")
        self.assertEqual(enemy["textureGroupId"]["name"], "enemy_longyuan")
        self.assertEqual(enemy["frames"], [0, 1])
        self.assertEqual(icon["textureGroupId"]["name"], "cards_ui")

    def test_native_windows_copy_mode_needs_no_symlinks_and_keeps_sources(self):
        before = {p: p.read_bytes() for p in self.root.rglob("*") if p.is_file()}
        prepare_project(self.root, self.work, "Windows", copy_assets=True)
        staged = prepare_project(self.root, self.work, "Windows", copy_assets=True).parent
        self.assertFalse(any(p.is_symlink() for p in staged.rglob("*")))
        self.assertEqual((staged / "sounds/music_example/source.bin").read_bytes(), b"original asset")
        for path, content in before.items():
            self.assertEqual(path.read_bytes(), content)
        for folder in (".private", "bots", "dist", "out", "FvmNativeSupport", ".windows-build"):
            self.assertFalse((staged / folder).exists())

    def test_staging_does_not_change_mac_texture_compression(self):
        mac = read_yy(prepare_project(self.root, self.work, "macOS"))
        win = read_yy(prepare_project(self.root, self.work, "Windows"))
        self.assertEqual({g["name"] for g in mac["TextureGroups"]}, {g["name"] for g in win["TextureGroups"]})
        self.assertTrue(all(g["customOptions"] == "BCN -3 -u4" for g in mac["TextureGroups"]))
        self.assertTrue(all(g["customOptions"] == "BCN -u4" for g in win["TextureGroups"]))

    def test_packaging_rejects_a_missing_native_extension(self):
        archive = self.work / "broken.zip"
        with zipfile.ZipFile(archive, "w") as z:
            z.writestr("data.win", b"incomplete")
            z.writestr("FVM_Reborn_makk.exe", b"incomplete")
        with self.assertRaisesRegex(RuntimeError, "FvmNativeSupport.dll"):
            build_windows.assemble(archive, self.root / "dist/windows")


if __name__ == "__main__":
    unittest.main()
