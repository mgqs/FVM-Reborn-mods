#!/usr/bin/env python3
"""Validate the compiled bundle, not just its requested memory settings."""

import argparse
import json
from pathlib import Path
import struct

from build_macos import ROOT, macos_configuration, read_yy


def validate(app: Path) -> dict:
    resources = app / "Contents/Resources"
    game = resources / "game.ios"
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
            sounds[text_at(fields[0])] = {"group": fields[7], "flags": fields[1]}

    expected_music = [read_yy(p)["name"] for p in (ROOT / "sounds").glob("*/*.yy")
                      if read_yy(p)["audioGroupId"]["name"] == "music"]
    assert expected_music, "No built-in music assets found"
    files = {p.name.casefold(): p for p in resources.rglob("*") if p.is_file()}
    for name in expected_music:
        assert name in sounds, f"Music asset missing from compiled sound table: {name}"
        assert sounds[name]["group"] == 0, f"Music still uses a resident audio group: {name}"
        path = files.get((name + ".ogg").casefold())
        assert path is not None, f"Stream file was not packaged: {name}"
        with path.open("rb") as source:
            assert source.read(4) == b"OggS", f"Invalid stream file: {name}"
    music_group = resources / "music.dat"
    assert not music_group.exists() or music_group.stat().st_size < 1024 * 1024, "Whole music library is still embedded"

    project = read_yy(ROOT / "FVM_Reborn_makk.yyp")
    dynamic = [group["name"] for group in project["TextureGroups"]
               if macos_configuration(group).get("loadType") == "dynamicpages"]
    assert dynamic, "No dynamic texture groups configured"
    textures = [p for p in resources.rglob("*.yytex") if p.is_file()]
    for name in dynamic:
        assert any(p.name.casefold().startswith(name.casefold() + "_") for p in textures), \
            f"Dynamic texture files were not packaged: {name}"
    assert chunks[b"TXTR"][1] < 1024 ** 3, "Large texture groups are still embedded in the main data file"
    return {"streamed_music": len(expected_music), "dynamic_groups": len(dynamic),
            "external_texture_pages": len(textures), "resident_texture_mib": round(chunks[b"TXTR"][1] / 1024 ** 2, 2)}


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("app", type=Path)
    print(json.dumps(validate(parser.parse_args().app), ensure_ascii=False))
