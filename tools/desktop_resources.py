"""Shared desktop memory layout; stage metadata without rewriting source assets."""

from __future__ import annotations

import copy
import filecmp
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


def remove_staged(path: Path) -> None:
    # A staged directory can be a link into the source tree. Never traverse it.
    if path.is_symlink() or path.is_file():
        path.unlink()
    elif path.exists():
        shutil.rmtree(path)


def staged_directory(path: Path) -> None:
    if path.is_symlink() or (path.exists() and not path.is_dir()):
        remove_staged(path)
    path.mkdir(parents=True, exist_ok=True)


def prune_staged(directory: Path, expected: set[str]) -> None:
    for child in directory.iterdir():
        if child.name not in expected:
            remove_staged(child)


def write_metadata(path: Path, metadata: dict) -> None:
    content = (json.dumps(metadata, ensure_ascii=False, indent=2) + "\n").encode("utf-8")
    if not path.is_symlink() and path.is_file() and path.read_bytes() == content:
        return  # Stable mtimes let GameMaker reuse its audio/texture caches.
    remove_staged(path)
    path.write_bytes(content)


def sync_asset(original: Path, target: Path, copy_assets: bool) -> None:
    if not copy_assets:
        if target.is_symlink() and target.readlink() == original:
            return
        remove_staged(target)
        target.symlink_to(original, target_is_directory=original.is_dir())
    elif original.is_dir():
        staged_directory(target)
        children = list(original.iterdir())
        for child in children:
            sync_asset(child, target / child.name, True)
        prune_staged(target, {child.name for child in children})
    else:
        if not target.is_symlink() and target.is_file() and filecmp.cmp(original, target, shallow=False):
            return
        remove_staged(target)
        shutil.copy2(original, target)


def stage_resource(original: Path, target: Path, metadata: dict | None, copy_assets: bool) -> None:
    if metadata is None:
        sync_asset(original.parent, target.parent, copy_assets)
        return
    staged_directory(target.parent)
    children = list(original.parent.iterdir())
    for asset in children:
        if asset != original:
            sync_asset(asset, target.parent / asset.name, copy_assets)
    write_metadata(target, metadata)
    prune_staged(target.parent, {asset.name for asset in children})


def prepare_project(root: Path, work: Path, target: str, *, copy_assets: bool = False) -> Path:
    if target not in {"macOS", "Windows"}:
        raise ValueError("Unsupported desktop target: " + target)
    stage = work / (target + "-project")
    staged_directory(stage)
    project = configuration(read_yy(root / "FVM_Reborn_makk.yyp"), target)
    project["TextureGroups"] = texture_groups(project, target)
    # Only project assets belong in the staging tree. Never traverse private,
    # output, bot configuration, repository, or unrelated native-source folders.
    folders = {Path(entry["id"]["path"]).parts[0] for entry in project["resources"]}
    folders.update({"options", "folders", "datafiles"})
    staged_folders = set()
    for name in sorted(folders - {"sprites", "sounds"}):
        original = root / name
        if not original.is_dir():
            continue
        sync_asset(original, stage / name, copy_assets)
        staged_folders.add(name)
    for kind in ("sounds", "sprites"):
        staged_directory(stage / kind)
    expected_resources = {"sounds": set(), "sprites": set()}
    for entry in project["resources"]:
        relative = Path(entry["id"]["path"])
        if relative.parts[0] not in {"sounds", "sprites"}:
            continue
        expected_resources[relative.parts[0]].add(relative.parts[1])
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
    write_metadata(destination, project)
    for kind, expected in expected_resources.items():
        prune_staged(stage / kind, expected)
    prune_staged(stage, staged_folders | {"sounds", "sprites", destination.name})
    return destination
