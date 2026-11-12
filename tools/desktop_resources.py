"""Shared desktop memory layout; stage metadata without rewriting source assets."""

from __future__ import annotations

import copy
import json
from pathlib import Path
import re
import shutil


DYNAMIC_GROUPS = {
    "cards", "player", "maps", "bullet", "effects", "time_god",
    "enemy_delicious", "enemy_volcanic", "enemy_floating", "enemy_tower",
    "pack_undersea_vortex", "pack_explore_camp", "enemy_longyuan", "battle_misc", "cards_ui",
}
TEXTURE_DIRECTORY = "assets/textures"
MUSIC_DIRECTORY = "assets/music"


def read_yy(path: Path) -> dict:
    # YY JSON permits trailing commas, including after strings containing commas.
    text = re.sub(r'("(?:\\.|[^"\\])*")|,(\s*[}\]])',
                  lambda m: m[1] if m[1] is not None else m[2], path.read_text(encoding="utf-8-sig"))
    return json.loads(text)


def configuration(resource: dict, target: str) -> dict:
    """Materialize overrides: the LTS asset compiler can silently ignore them."""
    resource = dict(resource)
    overrides = resource.pop("ConfigValues", {}).get(target, {})
    for key, value in overrides.items():
        if isinstance(value, str):
            try:
                value = json.loads(value)
            except json.JSONDecodeError:
                pass
        resource[key] = value
    return resource


def texture_groups(project: dict, target: str) -> list[dict]:
    groups = [configuration(group, target) for group in project["TextureGroups"]]
    by_name = {group["name"]: group for group in groups}
    for name, parent in (("enemy_longyuan", "enemy_tower"),
                         ("battle_misc", "Default"), ("cards_ui", "cards")):
        if name in by_name or parent not in by_name:
            continue
        group = copy.deepcopy(by_name[parent])
        group.update({"name": name, "%Name": name})
        groups.append(group)
    for group in groups:
        if group["name"] in DYNAMIC_GROUPS:
            group["loadType"] = "dynamicpages"
        if group.get("loadType") == "dynamicpages":
            group["directory"] = TEXTURE_DIRECTORY
    return groups


def music_names(root: Path) -> list[str]:
    project = read_yy(root / "FVM_Reborn_makk.yyp")
    names = []
    for entry in project["resources"]:
        relative = Path(entry["id"]["path"])
        if relative.parts[0] == "sounds":
            sound = read_yy(root / relative)
            if sound.get("audioGroupId", {}).get("name") == "music":
                names.append(sound["name"])
    return names


def sprite_group(sprite: dict) -> str:
    group = sprite.get("textureGroupId", {}).get("name", "")
    name = sprite["name"]
    frames = len(sprite.get("frames", []))
    if name.startswith("spr_ly_") and group in {"Default", "enemy_tower"}:
        return "enemy_longyuan"
    if group == "cards" and frames == 1:
        return "cards_ui"
    if group == "Default":
        if frames == 1 and sprite.get("width", 0) >= 900 and sprite.get("height", 0) >= 500:
            return "maps"
        if frames > 1 and not name.startswith(("spr_option_", "spr_mod_cs_", "spr_levelselect_")):
            return "battle_misc"
    return group


def stage_resource(original: Path, target: Path, metadata: dict | None, copy_assets: bool) -> None:
    if metadata is None:
        if copy_assets:
            shutil.copytree(original.parent, target.parent)
        else:
            target.parent.symlink_to(original.parent, target_is_directory=True)
        return
    target.parent.mkdir()
    for asset in original.parent.iterdir():
        if asset == original:
            continue
        destination = target.parent / asset.name
        if copy_assets:
            if asset.is_dir():
                shutil.copytree(asset, destination)
            else:
                shutil.copy2(asset, destination)
        else:
            destination.symlink_to(asset, target_is_directory=asset.is_dir())
    target.write_text(json.dumps(metadata, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")


def prepare_project(root: Path, work: Path, target: str, *, copy_assets: bool = False) -> Path:
    if target not in {"macOS", "Windows"}:
        raise ValueError("Unsupported desktop target: " + target)
    stage = work / (target + "-project")
    if stage.exists():
        shutil.rmtree(stage)
    stage.mkdir(parents=True)
    project = configuration(read_yy(root / "FVM_Reborn_makk.yyp"), target)
    project["TextureGroups"] = texture_groups(project, target)
    # Only project assets belong in the staging tree. Never traverse private,
    # output, bot configuration, repository, or unrelated native-source folders.
    folders = {Path(entry["id"]["path"]).parts[0] for entry in project["resources"]}
    folders.update({"options", "folders", "datafiles"})
    for name in sorted(folders - {"sprites", "sounds"}):
        original = root / name
        if not original.is_dir():
            continue
        if copy_assets:
            shutil.copytree(original, stage / name)
        else:
            (stage / name).symlink_to(original, target_is_directory=True)
    (stage / "sounds").mkdir()
    (stage / "sprites").mkdir()
    for entry in project["resources"]:
        relative = Path(entry["id"]["path"])
        if relative.parts[0] not in {"sounds", "sprites"}:
            continue
        original = root / relative
        source = read_yy(original)
        metadata = configuration(source, target)
        if relative.parts[0] == "sprites":
            group = sprite_group(metadata)
            if group != metadata.get("textureGroupId", {}).get("name"):
                metadata["textureGroupId"] = {"name": group, "path": "texturegroups/" + group}
        elif metadata.get("audioGroupId", {}).get("name") == "music":
            metadata["compression"] = 3  # CompressedStreamed, not decompress-on-load.
            metadata["audioGroupId"] = {"name": "audiogroup_default", "path": "audiogroups/audiogroup_default"}
            metadata["exportDir"] = MUSIC_DIRECTORY
        stage_resource(original, stage / relative, metadata if metadata != source else None, copy_assets)
    destination = stage / "FVM_Reborn_makk.yyp"
    destination.write_text(json.dumps(project, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    return destination
