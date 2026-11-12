#!/usr/bin/env python3
"""Validate the compiled bundle, not just its requested memory settings."""

import argparse
import json
from pathlib import Path, PurePosixPath
import struct

from desktop_resources import MUSIC_DIRECTORY, TEXTURE_DIRECTORY, music_names, read_yy, texture_groups

ROOT = Path(__file__).resolve().parents[1]


def validate(app: Path, target: str = "macOS") -> dict:
    resources = app / "Contents/Resources" if target == "macOS" else app
    game = resources / ("game.ios" if target == "macOS" else "data.win")
    chunks = {}
    with game.open("rb") as stream:
        assert stream.read(4) == b"FORM", "Unknown GameMaker data format"
        stream.read(4)
        while stream.tell() + 8 <= game.stat().st_size:
            tag, size = struct.unpack("<4sI", stream.read(8))
            start = stream.tell()
            assert start + size <= game.stat().st_size, "Truncated GameMaker chunk"
            chunks[tag] = (start, size)
            stream.seek(start + size)

        def text_at(pointer):
            stream.seek(pointer - 4)
            length = struct.unpack("<I", stream.read(4))[0]
            assert length < 4096, "Invalid sound metadata string"
            return stream.read(length).decode("utf-8")

        stream.seek(chunks[b"SOND"][0])
        count = struct.unpack("<I", stream.read(4))[0]
        pointers = struct.unpack("<" + "I" * count, stream.read(count * 4))
        sounds = {}
        for pointer in pointers:
            stream.seek(pointer)
            fields = struct.unpack("<9I", stream.read(36))
            sounds[text_at(fields[0])] = {"group": fields[7], "flags": fields[1], "audio": fields[8],
                                         "file": text_at(fields[3]).replace("\\", "/")}

    expected_music = music_names(ROOT)
    assert expected_music, "No built-in music assets found"
    for name in expected_music:
        assert name in sounds, f"Music asset missing from compiled sound table: {name}"
        assert sounds[name]["group"] == 0, f"Music still uses a resident audio group: {name}"
        assert sounds[name]["flags"] & 3 == 0 and sounds[name]["audio"] == 0xFFFFFFFF, \
            f"Music is embedded instead of streamed: {name}"
        relative = PurePosixPath(sounds[name]["file"])
        assert relative.parent == PurePosixPath(MUSIC_DIRECTORY) and relative.suffix.lower() == ".ogg", \
            f"Compiled music still points outside {MUSIC_DIRECTORY}: {name}"
        path = resources / relative
        assert path.is_file(), f"Stream file was not packaged in {MUSIC_DIRECTORY}: {name}"
        assert not (resources / relative.name).exists(), f"Music still clutters the root: {name}"
        with path.open("rb") as source:
            assert source.read(4) == b"OggS", f"Invalid stream file: {name}"
    music_group = resources / "music.dat"
    assert not music_group.exists() or music_group.stat().st_size < 1024 * 1024, "Whole music library is still embedded"

    project = read_yy(ROOT / "FVM_Reborn_makk.yyp")
    dynamic = [group["name"] for group in texture_groups(project, target)
               if group.get("loadType") == "dynamicpages"]
    assert dynamic, "No dynamic texture groups configured"
    assert not list(resources.glob("*.yytex")), "Dynamic textures still clutter the resource root"
    textures = [p for p in (resources / TEXTURE_DIRECTORY).glob("*.yytex") if p.is_file()]
    for page in textures:
        with page.open("rb") as source:
            header = source.read(148)
        assert header[:4] == b"DDS ", f"Invalid external texture: {page.name}"
        height, width = struct.unpack_from("<II", header, 12)
        assert width > 0 and height > 0, f"Empty external texture: {page.name}"
        if target == "Windows":
            assert header[84:88] == b"DX10" and struct.unpack_from("<I", header, 128)[0] == 98, \
                f"Expected BC7 texture: {page.name}"
            header_size = 148
        else:
            assert header[84:88] == b"DXT5", f"Expected BC3 texture: {page.name}"
            header_size = 128
        expected_size = header_size + ((width + 3) // 4) * ((height + 3) // 4) * 16
        assert page.stat().st_size == expected_size, f"Truncated texture pixels: {page.name}"
    external_groups = {p.stem.rsplit("_", 1)[0].casefold() for p in textures
                       if p.stem.rsplit("_", 1)[-1].isdigit()}
    for name in dynamic:
        assert name.casefold() in external_groups, \
            f"Dynamic texture files were not packaged: {name}"
    assert chunks[b"TXTR"][1] < 128 * 1024 ** 2, "Resident texture data exceeds the 128 MiB budget"
    return {"streamed_music": len(expected_music), "dynamic_groups": len(dynamic),
            "external_texture_pages": len(textures), "resident_texture_mib": round(chunks[b"TXTR"][1] / 1024 ** 2, 2)}


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("app", type=Path)
    parser.add_argument("--target", choices=["macOS", "Windows"], default="macOS")
    args = parser.parse_args()
    print(json.dumps(validate(args.app, args.target), ensure_ascii=False))
