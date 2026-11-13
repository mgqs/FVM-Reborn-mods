#!/usr/bin/env python3
"""Run the production draw/spawn hooks in a disposable native GameMaker app."""

import copy
import json
import os
from pathlib import Path
import plistlib
import re
import shutil
import struct
import subprocess
import zipfile
import zlib

import build_macos
from desktop_resources import read_yy
from gm_arity_check import strip_noise

ROOT = Path(__file__).resolve().parents[1]


def write_yy(path, data):
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(data, ensure_ascii=False, indent=2) + "\n")


def validate_object_references(project, code):
    """Only resources in the real YYP are constants in the shipped game.

    A stray object YY on disk is insufficient. Never let probe stubs silently
    register it and conceal a production 'variable not set' startup failure.
    """
    registered = {item["id"]["name"] for item in project["resources"]
                  if item["id"]["path"].startswith("objects/")}
    referenced = set(re.findall(r"(?<![\w.])obj_\w+", strip_noise(code)))
    missing = sorted(referenced - registered)
    if missing:
        raise ValueError("Object references absent from FVM_Reborn_makk.yyp: " + ", ".join(missing))
    return referenced


def check():
    real_project = read_yy(ROOT / "FVM_Reborn_makk.yyp")
    opacity_code = (ROOT / "scripts/friendly_attack_visuals/friendly_attack_visuals.gml").read_text()
    names = validate_object_references(real_project, opacity_code)
    names.update(validate_object_references(real_project, (ROOT / "tools/test_attack_opacity.gml").read_text()))
    work = ROOT / ".macos-build/attack-opacity-check"
    source = work / "source"
    if source.exists():
        shutil.rmtree(source)
    source.mkdir(parents=True)
    project = copy.deepcopy(real_project)
    project.update({"name": "FVMAttackOpacityCheck", "%Name": "FVMAttackOpacityCheck",
                    "resources": [], "IncludedFiles": [], "Folders": [], "RoomOrderNodes": []})
    group = copy.deepcopy(project["TextureGroups"][0])
    group.update({"name": "Default", "%Name": "Default", "loadType": "default",
                  "compressFormat": "bz2", "customOptions": ""})
    group.pop("ConfigValues", None)
    project["TextureGroups"] = [group]
    shutil.copytree(ROOT / "options", source / "options")
    options = read_yy(source / "options/mac/options_mac.yy")
    options.update({"option_mac_app_id": "io.github.mgqs.fvm.attack-opacity-check",
                    "option_mac_display_name": "FVM Attack Opacity Check", "option_mac_vsync": False})
    write_yy(source / "options/mac/options_mac.yy", options)

    def resource(kind, name, data):
        relative = f"{kind}/{name}/{name}.yy"
        data.update({"name": name, "%Name": name, "parent": None})
        write_yy(source / relative, data)
        project["resources"].append({"id": {"name": name, "path": relative}})
        return source / relative

    # A compiled default sprite also exercises the Runner's native draw_self
    # path, which uses object sprite metadata in addition to runtime properties.
    original_sprite = ROOT / "sprites/spr_hex_mark"
    sprite_dir = source / "sprites/spr_opacity_probe"
    shutil.copytree(original_sprite, sprite_dir)
    sprite = read_yy(sprite_dir / "spr_hex_mark.yy")
    sprite = json.loads(json.dumps(sprite).replace("sprites/spr_hex_mark/spr_hex_mark.yy",
                                                   "sprites/spr_opacity_probe/spr_opacity_probe.yy"))
    sprite.pop("ConfigValues", None)
    sprite.update({"width": 8, "height": 8, "origin": 0, "bbox_left": 0, "bbox_top": 0,
                   "bbox_right": 7, "bbox_bottom": 7, "textureGroupId": {"name": "Default", "path": "texturegroups/Default"}})
    sprite["sequence"].update({"name": "spr_opacity_probe", "%Name": "spr_opacity_probe", "xorigin": 0, "yorigin": 0})
    (sprite_dir / "spr_hex_mark.yy").unlink()
    resource("sprites", "spr_opacity_probe", sprite)

    def png_chunk(kind, data):
        return struct.pack(">I", len(data)) + kind + data + struct.pack(">I", zlib.crc32(kind + data))

    png = (b"\x89PNG\r\n\x1a\n" + png_chunk(b"IHDR", struct.pack(">IIBBBBB", 8, 8, 8, 6, 0, 0, 0))
           + png_chunk(b"IDAT", zlib.compress((b"\0" + b"\xff" * 32) * 8)) + png_chunk(b"IEND", b""))
    for path in sprite_dir.rglob("*.png"):
        path.write_bytes(png)
    sprite_ref = {"name": "spr_opacity_probe", "path": "sprites/spr_opacity_probe/spr_opacity_probe.yy"}

    script_template = read_yy(ROOT / "scripts/friendly_attack_visuals/friendly_attack_visuals.yy")
    sources = {}
    for name in ("friendly_attack_visuals", "obj_pool", "src_hook_function"):
        sources[name] = (ROOT / f"scripts/{name}/{name}.gml").read_text(encoding="utf-8-sig")
    hooks = (ROOT / "scripts/external_animation_mod/external_animation_mod.gml").read_text()
    sources["draw_hooks"] = hooks[hooks.index("function external_animation_draw_self()"):] + """
global.external_animation_active = false;
function external_animation_sample(inst, spr = undefined, frame = undefined) {
    return {sprite: global.probe_replacement, frame: 0};
}
"""
    sources["opacity_probe"] = (ROOT / "tools/test_attack_opacity.gml").read_text()
    for name, code in sources.items():
        resource("scripts", name, copy.deepcopy(script_template)).with_suffix(".gml").write_text(code)

    # Stub gameplay events/assets only. Production opacity, drawing, spawn and
    # object-pool code above executes unchanged, with actual native rendering.
    names.update({"obj_pool_holder", "obj_platform", "obj_engineer_bullet", "obj_xiaolongbao_bullet"})
    for name in sorted(names):
        if name == "obj_spicypot_bullet":
            continue
        original = read_yy(ROOT / f"objects/{name}/{name}.yy")
        obj = copy.deepcopy(original)
        obj.update({"eventList": [], "spriteId": sprite_ref, "spriteMaskId": None, "parentObjectId": None,
                    "properties": [], "overriddenProperties": [], "persistent": False})
        if name == "obj_xiaolongbao_bullet":
            obj["parentObjectId"] = original["parentObjectId"]
        resource("objects", name, obj)

    obj = read_yy(ROOT / "objects/obj_notice_controller/obj_notice_controller.yy")
    obj.update({"persistent": False, "visible": True, "spriteId": sprite_ref, "parentObjectId": None,
                "eventList": [{"$GMEvent": "v1", "%Name": "", "collisionObjectId": None,
                               "eventNum": 0, "eventType": kind, "isDnD": False, "name": "",
                               "resourceType": "GMEvent", "resourceVersion": "2.0"} for kind in (0, 8)]})
    path = resource("objects", "obj_spicypot_bullet", obj)
    (path.parent / "Create_0.gml").write_text("probe_done = 0; x = 0; y = 0; game_set_speed(60, gamespeed_fps);\n")
    (path.parent / "Draw_0.gml").write_text("opacity_probe_draw();\n")
    room = read_yy(ROOT / "rooms/room_init/room_init.yy")
    layer = next(layer for layer in room["layers"] if layer.get("resourceType") == "GMRInstanceLayer")
    inst = layer["instances"][0]
    inst.update({"objectId": {"name": "obj_spicypot_bullet", "path": "objects/obj_spicypot_bullet/obj_spicypot_bullet.yy"}})
    layer["instances"] = [inst]
    room.update({"creationCodeFile": "", "layers": [layer],
                 "instanceCreationOrder": [{"name": inst["name"], "path": "rooms/opacity_room/opacity_room.yy"}],
                 "roomSettings": {"Width": 320, "Height": 180, "inheritRoomSettings": False, "persistent": False}})
    path = resource("rooms", "opacity_room", room)
    project["RoomOrderNodes"] = [{"roomId": {"name": "opacity_room", "path": path.relative_to(source).as_posix()}}]
    write_yy(source / "FVMAttackOpacityCheck.yyp", project)
    runtime = build_macos.runtime_path(None)
    stage = work / "stage"
    stage.mkdir(exist_ok=True)
    command = [*build_macos.igor_command(runtime), f"--project={source / 'FVMAttackOpacityCheck.yyp'}",
               f"--rp={runtime}", f"--uf={build_macos.user_path(None)}", f"--cache={work / 'cache'}",
               f"--temp={work / 'temp'}", f"--of={stage / 'game.zip'}", f"--tf={stage / 'game.zip'}",
               "--runtime=VM", "--config=macOS", "-j=1", "--", "Mac", "Compile"]
    with (work / "build.log").open("w") as log:
        subprocess.run(list(map(str, command)), env={**os.environ, "COMPlus_ZapDisable": "1"},
                       stdout=log, stderr=subprocess.STDOUT, check=True)
    app = work / "FVMAttackOpacityCheck.app"
    if app.exists():
        shutil.rmtree(app)
    subprocess.run(["ditto", "--noqtn", str(runtime / "mac/YoYo Runner.app"), str(app)], check=True)
    resources = app / "Contents/Resources"
    (resources / "yoyorunner.config").unlink(missing_ok=True)
    with zipfile.ZipFile(stage / "game.zip") as package:
        for entry in package.infolist():
            if entry.filename.startswith("assets/") and not entry.is_dir():
                relative = Path(entry.filename[len("assets/"):])
                if relative.is_absolute() or ".." in relative.parts:
                    raise RuntimeError("Unsafe compiler output")
                target = resources / relative
                target.parent.mkdir(parents=True, exist_ok=True)
                target.write_bytes(package.read(entry))
    info = app / "Contents/Info.plist"
    metadata = plistlib.loads(info.read_bytes())
    metadata.update({"CFBundleIdentifier": "io.github.mgqs.fvm.attack-opacity-check", "CFBundleName": "FVMAttackOpacityCheck"})
    info.write_bytes(plistlib.dumps(metadata))
    build_macos.sign_app(app, "-", work)
    with (work / "runtime.log").open("w") as log:
        result = subprocess.run([str(app / "Contents/MacOS" / metadata["CFBundleExecutable"])],
                                cwd=resources, stdout=log, stderr=subprocess.STDOUT, timeout=45)
    output = (work / "runtime.log").read_text(errors="replace")
    if result.returncode or "ATTACK_OPACITY_FAIL" in output or "ATTACK_OPACITY_PASS" not in output:
        raise RuntimeError("Opacity probe failed; see " + str(work / "runtime.log"))
    print("ATTACK_OPACITY_PASS: native pixels, animation overrides, preserved state, shared effects, pool reuse and config")


if __name__ == "__main__":
    check()
