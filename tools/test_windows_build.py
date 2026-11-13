"""Windows staging must preserve BC7, source assets, and the shared memory layout."""

import json
from pathlib import Path
import tempfile
import struct
import unittest
from unittest.mock import patch
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

    def test_copied_assets_are_incremental_and_removed_assets_do_not_linger(self):
        staged = prepare_project(self.root, self.work, "Windows", copy_assets=True)
        asset = staged.parent / "sounds/music_example/source.bin"
        before = (asset.stat().st_ino, asset.stat().st_mtime_ns)
        prepare_project(self.root, self.work, "Windows", copy_assets=True)
        self.assertEqual((asset.stat().st_ino, asset.stat().st_mtime_ns), before)
        source = self.root / "sounds/music_example/source.bin"
        source.write_bytes(b"updated audio")
        prepare_project(self.root, self.work, "Windows", copy_assets=True)
        self.assertEqual(asset.read_bytes(), b"updated audio")
        source.unlink()
        prepare_project(self.root, self.work, "Windows", copy_assets=True)
        self.assertFalse(asset.exists())

    def test_switching_copy_and_link_modes_preserves_original_assets(self):
        for copy_assets in (False, True, False, True):
            staged = prepare_project(self.root, self.work, "Windows", copy_assets=copy_assets)
            for name in ("music_example", "short_sound"):
                self.assertEqual((self.root / f"sounds/{name}/source.bin").read_bytes(), b"original asset")
                self.assertEqual((staged.parent / f"sounds/{name}/source.bin").read_bytes(), b"original asset")

    def test_windows_streams_music_and_keeps_bc7_with_shared_animation_layout(self):
        staged = prepare_project(self.root, self.work, "Windows")
        data = read_yy(staged)
        groups = {g["name"]: g for g in data["TextureGroups"]}
        for name in ("cards", "enemy_tower", "enemy_longyuan", "battle_misc", "cards_ui"):
            self.assertEqual(groups[name]["loadType"], "dynamicpages")
            self.assertEqual(groups[name]["directory"], "assets/textures")
            self.assertEqual(groups[name]["customOptions"], "BCN -u4")
        self.assertEqual(groups["Default"]["loadType"], "default")
        self.assertEqual(groups["UI"]["loadType"], "default")
        music = read_yy(staged.parent / "sounds/music_example/music_example.yy")
        effect = read_yy(staged.parent / "sounds/short_sound/short_sound.yy")
        self.assertEqual((music["compression"], music["audioGroupId"]["name"]), (3, "audiogroup_default"))
        self.assertEqual(music["exportDir"], "assets/music")
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

    def test_extraction_detects_corrupt_crc_and_preserves_previous_distribution(self):
        archive = self.work / "corrupt.zip"
        with zipfile.ZipFile(archive, "w", compression=zipfile.ZIP_STORED) as package:
            package.writestr("data.win", b"compiled-game")
        with zipfile.ZipFile(archive) as package:
            header_offset = package.getinfo("data.win").header_offset
        content = bytearray(archive.read_bytes())
        name_length, extra_length = struct.unpack_from("<HH", content, header_offset + 26)
        content[header_offset + 30 + name_length + extra_length] ^= 1
        archive.write_bytes(content)
        output = self.root / "dist/windows"
        previous = output / "FVM_Reborn_makk/data.win"
        previous.parent.mkdir(parents=True)
        previous.write_bytes(b"previous-working-game")
        old_zip = output / "FVM_Reborn_makk-Windows-x64.zip"
        old_zip.write_bytes(b"previous-working-zip")
        with self.assertRaisesRegex(RuntimeError, "Corrupt ZIP member"):
            build_windows.assemble(archive, output)
        self.assertEqual(previous.read_bytes(), b"previous-working-game")
        self.assertEqual(old_zip.read_bytes(), b"previous-working-zip")

    def test_portable_zip_matches_the_organized_application_tree(self):
        archive = self.work / "compiler.zip"
        pe = bytearray(134)
        pe[:2] = b"MZ"
        struct.pack_into("<I", pe, 0x3C, 128)
        pe[128:132] = b"PE\x00\x00"
        struct.pack_into("<H", pe, 132, 0x8664)
        entries = {name: pe for name in ("FVM_Reborn_makk.exe", "FvmNativeSupport.dll", "7z.dll")}
        entries.update({"data.win": b"compiled-game", "assets/music/music_example.ogg": b"OggS-music",
                        "assets/textures/cards_0.yytex": b"texture",
                        "boss_music_pack/自选音乐.ogg": b"OggS-custom"})
        with zipfile.ZipFile(archive, "w") as package:
            for name, data in entries.items():
                package.writestr(name, data)
        output = self.root / "dist/windows"
        def validate_layout(resources, target):
            self.assertEqual(target, "Windows")
            self.assertEqual((resources / "assets/music/music_example.ogg").read_bytes(), b"OggS-music")
            self.assertFalse((resources / "music_example.ogg").exists())
            return {"checked": True}
        with patch.object(build_windows, "ROOT", self.root), \
             patch.object(build_windows, "validate", side_effect=validate_layout) as validate:
            self.assertEqual(build_windows.assemble(archive, output), {"checked": True})
            validate.assert_called_once()
        app = output / "FVM_Reborn_makk"
        self.assertFalse((app / "music_example.ogg").exists())
        self.assertEqual((app / "assets/music/music_example.ogg").read_bytes(), b"OggS-music")
        with zipfile.ZipFile(output / "FVM_Reborn_makk-Windows-x64.zip") as package:
            actual = {p.relative_to(app).as_posix() for p in app.rglob("*") if p.is_file()}
            self.assertEqual(set(package.namelist()), actual)
            self.assertEqual(package.read("assets/music/music_example.ogg"), b"OggS-music")
            self.assertEqual(package.read("boss_music_pack/自选音乐.ogg"), b"OggS-custom")


if __name__ == "__main__":
    unittest.main()
