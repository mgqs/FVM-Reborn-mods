"""Validate compiled resource paths, not only the presence of moved files."""

import json
from pathlib import Path
import struct
import tempfile
import unittest
from unittest.mock import patch

import test_macos_resources as resources_check


def game_data(filenames: list[str]) -> bytes:
    names = ["mus_town", "mus_menu"]
    strings = names + filenames
    # SOND entries refer to strings by absolute file offsets, just like GameMaker.
    sond_size = 4 + len(names) * 4 + len(names) * 36
    string_start = 8 + 8 + sond_size + 8
    string_data = bytearray()
    pointers = []
    for value in strings:
        encoded = value.encode()
        pointers.append(string_start + len(string_data) + 4)
        string_data.extend(struct.pack("<I", len(encoded)) + encoded + b"\0")
    records = bytearray(struct.pack("<I", len(names)))
    for i in range(len(names)):
        records.extend(struct.pack("<I", 16 + 4 + len(names) * 4 + i * 36))
    for i in range(len(names)):
        records.extend(struct.pack("<9I", pointers[i], 0, 0, pointers[i + len(names)], 0, 0, 0, 0, 0xFFFFFFFF))
    chunks = b"SOND" + struct.pack("<I", len(records)) + records
    chunks += b"STRG" + struct.pack("<I", len(string_data)) + string_data
    chunks += b"TXTR" + struct.pack("<I", 4) + b"\0" * 4
    return b"FORM" + struct.pack("<I", len(chunks)) + chunks


class CompiledResourceTests(unittest.TestCase):
    def setUp(self):
        self.temporary = tempfile.TemporaryDirectory()
        self.addCleanup(self.temporary.cleanup)
        self.root = Path(self.temporary.name)
        self.source = self.root / "source"
        project = {"resources": [], "TextureGroups": [{"name": n} for n in ("cards", "enemy_longyuan")]}
        for name in ("mus_town", "mus_menu"):
            relative = f"sounds/{name}/{name}.yy"
            path = self.source / relative
            path.parent.mkdir(parents=True)
            path.write_text(json.dumps({"name": name, "audioGroupId": {"name": "music"}}))
            project["resources"].append({"id": {"path": relative}})
        (self.source / "FVM_Reborn_makk.yyp").write_text(json.dumps(project))
        self.patch_root = patch.object(resources_check, "ROOT", self.source)
        self.patch_root.start()
        self.addCleanup(self.patch_root.stop)

    def package(self, target, filenames=None):
        app = self.root / target
        resources = app / "Contents/Resources" if target == "macOS" else app
        (resources / "assets/music").mkdir(parents=True)
        textures = resources / "assets/textures"
        textures.mkdir()
        for name in ("mus_town.ogg", "renamed_menu.ogg"):
            (resources / "assets/music" / name).write_bytes(b"OggS-fixture")
        header = bytearray(148 if target == "Windows" else 128)
        header[:4] = b"DDS "
        struct.pack_into("<I", header, 4, 124)
        struct.pack_into("<II", header, 12, 1, 1)
        header[84:88] = b"DX10" if target == "Windows" else b"DXT5"
        if target == "Windows":
            struct.pack_into("<I", header, 128, 98)
        for name in ("cards", "cards_ui", "enemy_longyuan"):
            (textures / (name + "_0.yytex")).write_bytes(header + b"\0" * 16)
        files = filenames or ["assets/music/mus_town.ogg", "assets/music/renamed_menu.ogg"]
        if target == "Windows":
            files = [name.replace("/", "\\") for name in files]
        (resources / ("game.ios" if target == "macOS" else "data.win")).write_bytes(game_data(files))
        return app, resources

    def test_both_platforms_validate_the_compiled_music_filename(self):
        for target in ("macOS", "Windows"):
            with self.subTest(target=target):
                app, _ = self.package(target)
                report = resources_check.validate(app, target)
                self.assertEqual(report["streamed_music"], 2)
                self.assertEqual(report["external_texture_pages"], 3)

    def test_moving_files_without_updating_compiled_paths_is_rejected(self):
        app, _ = self.package("macOS", ["mus_town.ogg", "assets/music/renamed_menu.ogg"])
        with self.assertRaisesRegex(AssertionError, "Compiled music still points outside"):
            resources_check.validate(app)

    def test_flat_texture_duplicates_are_rejected(self):
        app, resources = self.package("macOS")
        (resources / "cards_0.yytex").write_bytes(b"old-root-copy")
        with self.assertRaisesRegex(AssertionError, "textures still clutter"):
            resources_check.validate(app)

    def test_missing_music_in_the_grouped_directory_is_rejected(self):
        app, resources = self.package("macOS")
        (resources / "assets/music/mus_town.ogg").rename(resources / "mus_town.ogg")
        with self.assertRaisesRegex(AssertionError, "not packaged in assets/music"):
            resources_check.validate(app)


if __name__ == "__main__":
    unittest.main()
