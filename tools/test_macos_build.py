#!/usr/bin/env python3
"""Regressions for macOS metadata staging without changing the source project."""

import json
from pathlib import Path
import tempfile
import unittest
from unittest.mock import patch

import build_macos


class MacProjectTests(unittest.TestCase):
    def setUp(self):
        self.temporary = tempfile.TemporaryDirectory()
        self.addCleanup(self.temporary.cleanup)
        self.root = Path(self.temporary.name)
        self.work = self.root / ".macos-build"
        self.work.mkdir()
        self.patch_root = patch.object(build_macos, "ROOT", self.root)
        self.patch_root.start()
        self.addCleanup(self.patch_root.stop)
        (self.root / ".private").mkdir()
        (self.root / "sprites").mkdir()
        self.resources = []
        for name, group, overrides in (
            ("music_example", "music", {"macOS": {"compression": "3"}}),
            ("sound_example", "sound", {}),
        ):
            folder = self.root / "sounds" / name
            folder.mkdir(parents=True)
            path = folder / (name + ".yy")
            data = {"name": name, "compression": 0,
                    "audioGroupId": {"name": group, "path": "audiogroups/" + group}}
            if overrides:
                data["ConfigValues"] = overrides
            path.write_text(json.dumps(data))
            (folder / (name + ".wav")).write_bytes(b"source-audio")
            self.resources.append({"id": {"name": name, "path": str(path.relative_to(self.root))}})
        self.project = self.root / "FVM_Reborn_makk.yyp"
        self.project.write_text(json.dumps({"resources": self.resources, "TextureGroups": [
            {"name": "enemy", "loadType": "default", "customOptions": "BCN -u4",
             "ConfigValues": {"macOS": {"loadType": "dynamicpages", "customOptions": "BCN -3 -u4"}}},
            {"name": "UI", "loadType": "default"},
        ]}))

    def test_compiler_gets_dynamic_textures_and_streamed_music(self):
        staged = build_macos.prepare_macos_project(self.work)
        data = build_macos.read_yy(staged)
        self.assertEqual(data["TextureGroups"][0]["loadType"], "dynamicpages")
        self.assertEqual(data["TextureGroups"][0]["customOptions"], "BCN -3 -u4")
        self.assertEqual(data["TextureGroups"][1]["loadType"], "default")
        music = build_macos.read_yy(staged.parent / "sounds/music_example/music_example.yy")
        self.assertEqual(music["compression"], 3)
        self.assertEqual(music["audioGroupId"]["name"], "audiogroup_default")

    def test_source_metadata_stays_unchanged(self):
        paths = [self.project, self.root / "sounds/music_example/music_example.yy"]
        before = [p.read_bytes() for p in paths]
        build_macos.prepare_macos_project(self.work)
        self.assertEqual(before, [p.read_bytes() for p in paths])

    def test_large_sources_are_shared_but_private_and_build_folders_are_not(self):
        staged = build_macos.prepare_macos_project(self.work).parent
        self.assertTrue((staged / "sprites").is_symlink())
        self.assertTrue((staged / "sounds/music_example/music_example.wav").is_symlink())
        self.assertTrue((staged / "sounds/sound_example").is_symlink())
        self.assertFalse((staged / ".private").exists())
        self.assertFalse((staged / ".macos-build").exists())

    def test_rebuild_does_not_remove_symlink_targets(self):
        build_macos.prepare_macos_project(self.work)
        build_macos.prepare_macos_project(self.work)
        self.assertTrue((self.root / "sprites").is_dir())
        self.assertEqual((self.root / "sounds/music_example/music_example.wav").read_bytes(), b"source-audio")

    def test_configuration_values_keep_strings_and_decode_scalars(self):
        data = build_macos.macos_configuration({"name": "asset", "ConfigValues": {"macOS": {
            "loadType": "dynamicpages", "compression": "3", "preload": "false"}}})
        self.assertEqual(data, {"name": "asset", "loadType": "dynamicpages", "compression": 3, "preload": False})

    def test_yy_reader_handles_bom_and_commas_inside_strings(self):
        path = self.root / "bom.yy"
        path.write_text('\ufeff{"name":"text,}","value":2,}')
        self.assertEqual(build_macos.read_yy(path), {"name": "text,}", "value": 2})


if __name__ == "__main__":
    unittest.main()
