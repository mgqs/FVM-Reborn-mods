#!/usr/bin/env python3
"""Compile and run a disposable macOS probe of the desktop resource layout."""

from __future__ import annotations

import argparse
import copy
import json
import os
from pathlib import Path
import shutil
import subprocess
import sys
import wave
import zipfile

import build_macos
from desktop_resources import music_names, prepare_project, read_yy

ROOT = Path(__file__).resolve().parents[1]


def write_yy(path: Path, data: dict) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(data, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")


def make_project(root: Path) -> Path:
    project = read_yy(ROOT / "FVM_Reborn_makk.yyp")
    project.update({"name": "FVMAssetLayoutCheck", "%Name": "FVMAssetLayoutCheck",
                    "resources": [], "IncludedFiles": [], "Folders": [], "RoomOrderNodes": []})

    def resource(kind: str, name: str, data: dict) -> Path:
        relative = f"{kind}/{name}/{name}.yy"
        data.update({"name": name, "%Name": name, "parent": None})
        write_yy(root / relative, data)
        project["resources"].append({"id": {"name": name, "path": relative}})
        return root / relative

    shutil.copytree(ROOT / "options", root / "options")
    options = read_yy(root / "options/mac/options_mac.yy")
    options.update({"option_mac_app_id": "io.github.mgqs.fvm.asset-layout-check",
                    "option_mac_display_name": "FVM Asset Layout Check", "option_mac_vsync": False})
    write_yy(root / "options/mac/options_mac.yy", options)
    sound_template = read_yy(ROOT / "sounds/mus_town/mus_town.yy")
    for name in ("mus_town", "mus_menu", "snd_layout_effect"):
        sound = copy.deepcopy(sound_template)
        sound.pop("ConfigValues", None)
        sound.update({"soundFile": name + ".wav", "duration": 2.5, "volume": 0.01,
                      "audioGroupId": {"name": "music" if name.startswith("mus_") else "audiogroup_default",
                                       "path": "audiogroups/music" if name.startswith("mus_") else "audiogroups/audiogroup_default"}})
        path = resource("sounds", name, sound)
        with wave.open(str(path.parent / (name + ".wav")), "wb") as audio:
            audio.setparams((1, 2, 22050, 0, "NONE", "not compressed"))
            audio.writeframes(b"\0\0" * 55125)  # Silent but valid decoder input.

    for name, source_name, group in (("spr_layout_card", "spr_option_mute_btn", "cards"),
                                      ("spr_layout_enemy", "spr_hex_mark", "enemy_longyuan"),
                                      ("spr_layout_icon", "spr_hex_mark", "cards")):
        original = ROOT / "sprites" / source_name
        destination = root / "sprites" / name
        shutil.copytree(original, destination)
        sprite = read_yy(destination / (source_name + ".yy"))
        # Sprite keyframes contain paths back to the resource itself.
        sprite = json.loads(json.dumps(sprite).replace(f"sprites/{source_name}/{source_name}.yy",
                                                       f"sprites/{name}/{name}.yy"))
        sprite["textureGroupId"] = {"name": group, "path": "texturegroups/" + group}
        sprite["sequence"].update({"name": name, "%Name": name})
        (destination / (source_name + ".yy")).unlink()
        resource("sprites", name, sprite)
    group_template = read_yy(ROOT / "FVM_Reborn_makk.yyp")["TextureGroups"][0]
    project["TextureGroups"] = []
    for name in ("cards", "enemy_longyuan"):
        group = copy.deepcopy(group_template)
        group.pop("ConfigValues", None)
        group.update({"name": name, "%Name": name, "compressFormat": "bz2", "customOptions": ""})
        project["TextureGroups"].append(group)

    script = read_yy(ROOT / "scripts/ResourceResidency/ResourceResidency.yy")
    path = resource("scripts", "layout_probe", script)
    detection = (ROOT / "scripts/ResourceResidency/ResourceResidency.gml").read_text().split(
        "\nfunction resource_dynamic_groups", 1)[0]
    path.with_suffix(".gml").write_text(detection + "\n" +
        (ROOT / "tools/test_desktop_layout.gml").read_text(), encoding="utf-8")

    obj = read_yy(ROOT / "objects/obj_notice_controller/obj_notice_controller.yy")
    obj.update({"persistent": False, "visible": False,
                "eventList": [event for event in obj["eventList"] if event["eventType"] in (0, 3)]})
    path = resource("objects", "obj_layout_probe", obj)
    (path.parent / "Create_0.gml").write_text("frame_number = 0; game_set_speed(60, gamespeed_fps);\n")
    (path.parent / "Step_0.gml").write_text("layout_probe_step();\n")
    room = read_yy(ROOT / "rooms/room_init/room_init.yy")
    layer = next(layer for layer in room["layers"] if layer.get("resourceType") == "GMRInstanceLayer")
    instance = layer["instances"][0]
    instance.update({"objectId": {"name": "obj_layout_probe", "path": "objects/obj_layout_probe/obj_layout_probe.yy"}})
    layer["instances"] = [instance]
    room.update({"creationCodeFile": "", "layers": [layer],
                 "instanceCreationOrder": [{"name": instance["name"], "path": "rooms/layout_room/layout_room.yy"}],
                 "roomSettings": {"Width": 320, "Height": 180, "inheritRoomSettings": False, "persistent": False}})
    room_path = resource("rooms", "layout_room", room)
    project["RoomOrderNodes"] = [{"roomId": {"name": "layout_room", "path": room_path.relative_to(root).as_posix()}}]
    write_yy(root / "FVM_Reborn_makk.yyp", project)
    return root / "FVM_Reborn_makk.yyp"


def check(runtime: Path, user: Path, work: Path) -> None:
    source = work / "source"
    if source.exists():
        shutil.rmtree(source)
    source.mkdir(parents=True)
    make_project(source)
    project = prepare_project(source, work, "macOS")
    stage = work / "stage"
    if stage.exists():
        shutil.rmtree(stage)
    stage.mkdir()
    command = [*build_macos.igor_command(runtime), f"--project={project}", f"--rp={runtime}",
               f"--uf={user}", f"--cache={work / 'cache'}", f"--temp={work / 'temp'}",
               f"--of={stage / 'game.zip'}", f"--tf={stage / 'game.zip'}",
               "--runtime=VM", "--config=macOS", "-j=1", "--", "Mac", "Compile"]
    environment = {**os.environ, "COMPlus_ZapDisable": "1"}
    with (work / "build.log").open("w") as log:
        subprocess.run(list(map(str, command)), env=environment, stdout=log, stderr=subprocess.STDOUT, check=True)
    app = work / "FVMAssetLayoutCheck.app"
    if app.exists():
        shutil.rmtree(app)
    subprocess.run(["ditto", "--noqtn", str(runtime / "mac/YoYo Runner.app"), str(app)], check=True)
    resources = app / "Contents/Resources"
    (resources / "yoyorunner.config").unlink(missing_ok=True)
    with zipfile.ZipFile(stage / "game.zip") as package:
        for member in package.infolist():
            if member.filename.startswith("assets/") and not member.is_dir():
                relative = Path(member.filename[len("assets/"):])
                if relative.is_absolute() or ".." in relative.parts:
                    raise RuntimeError("Unsafe compiler output")
                target = resources / relative
                target.parent.mkdir(parents=True, exist_ok=True)
                target.write_bytes(package.read(member))
    for path in stage.glob("*.dat"):
        shutil.copy2(path, resources / path.name)
    for name in music_names(source):
        assert (resources / "assets/music" / (name + ".ogg")).is_file(), name
        assert not (resources / (name + ".ogg")).exists(), name
    assert not list(resources.glob("*.yytex"))
    assert (resources / "assets/textures/cards_0.yytex").is_file()
    custom = resources / "boss_music_pack"
    custom.mkdir(exist_ok=True)
    shutil.copy2(resources / "assets/music/mus_town.ogg", custom / "custom.ogg")
    import plistlib
    info = app / "Contents/Info.plist"
    metadata = plistlib.loads(info.read_bytes())
    metadata.update({"CFBundleIdentifier": "io.github.mgqs.fvm.asset-layout-check", "CFBundleName": "FVMAssetLayoutCheck"})
    info.write_bytes(plistlib.dumps(metadata))
    build_macos.sign_app(app, "-", work)
    with (work / "runtime.log").open("w") as log:
        result = subprocess.run([str(app / "Contents/MacOS" / metadata["CFBundleExecutable"])],
                                cwd=resources, stdout=log, stderr=subprocess.STDOUT, timeout=45)
    output = (work / "runtime.log").read_text(errors="replace")
    if result.returncode or "DESKTOP_ASSETS_FAIL" in output or "DESKTOP_ASSETS_PASS" not in output:
        raise RuntimeError("Native asset layout probe failed; see " + str(work / "runtime.log"))
    print("DESKTOP_ASSETS_PASS: grouped textures, native music playback, pause/resume, volume and custom streams")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--runtime-path")
    parser.add_argument("--user-dir")
    args = parser.parse_args()
    check(build_macos.runtime_path(args.runtime_path), build_macos.user_path(args.user_dir),
          ROOT / ".macos-build/desktop-assets-check")
