# -*- coding: utf-8 -*-
"""导出「合成屋 · 神器进化 / 宝石进化」HTML 预览所需的精灵帧到 output/craft_evolution_preview/assets/。

规则：sprites/<名>/<名>.yy 的 frames[] 顺序 = 帧号顺序；帧图 = sprites/<名>/<帧GUID>.png
输出文件名：<短名>[_<帧号>].png（帧 0 不带后缀，多帧才带）

用法: python tools/export_craft_preview_assets.py
"""
import json
import os
import re
import shutil

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
OUT = os.path.join(ROOT, "output", "craft_evolution_preview", "assets")

# 短名 -> (精灵名, 需要的帧号列表)
SPRITES = {
    "bg_base": ("spr_craft_bg_base", [0]),
    "bg_left": ("spr_craft_bg_left", [0]),
    "bg_right": ("spr_craft_bg_right", [0]),
    "bg_bar": ("spr_craft_bg_bar", [0]),
    "tab_cardgem": ("spr_craft_tab_cardgem", [0, 1]),
    "tab_evo": ("spr_craft_tab_evo", [0, 1]),
    "tab_fusion": ("spr_craft_tab_fusion", [0, 1]),
    "left_on": ("spr_evo_left_on", [0]),
    "slot_card": ("spr_evo_slot_card", [0]),
    "slot_prop": ("spr_evo_slot_prop", [0]),
    "slot_result": ("spr_evo_slot_result", [0]),
    "arrow": ("spr_evo_arrow", [0]),
    "btn": ("spr_evo_btn", [0, 1, 2]),
    "question": ("spr_evo_question", [0]),
    "credit_bg": ("spr_evo_credit_bg", [0]),
    "btnsel": ("spr_craft_select_btn", [0, 1]),
}

# 武器 / 宝石图标（短名 = 去 spr_ 前缀）
ICONS = [
    "spr_poseidon_dart_gun_icon", "spr_zeus_bolt_icon", "spr_star_wand_icon",
    "spr_gods_shield_icon", "spr_master_shield_icon", "spr_rose_shield_icon",
    "spr_death_scythe_icon", "spr_hades_scythe_icon", "spr_aladdin_lamp_icon",
    "spr_poseidon_dart_gun_gem_1", "spr_poseidon_dart_gun_gem_2",
    "spr_poseidon_dart_gun_gem_3", "spr_poseidon_dart_gun_gem_4",
    "spr_zeus_shadow_gem_icon", "spr_zeus_power_gem_icon", "spr_zeus_anger_gem_icon",
    "spr_zeus_ren_gem_icon",
    "spr_star_wand_gem_1", "spr_star_wand_gem_2", "spr_star_wand_gem_3",
    "spr_star_wand_gem_4", "spr_star_wand_gem_5",
    "spr_gods_shield_gem_1", "spr_gods_shield_gem_2", "spr_gods_shield_gem_3",
    "spr_gods_shield_gem_4",
    "spr_divine_blessing_gem_icon", "spr_divine_shenji_gem_icon",
    "spr_divine_protect_gem_icon", "spr_divine_holy_gem_icon",
    "spr_divine_forbidden_gem_icon",
    "spr_rose_shield_gem_1", "spr_rose_shield_gem_2", "spr_rose_shield_gem_3",
    "spr_rose_shield_gem_4", "spr_rose_shield_gem_5",
    "spr_death_scythe_gem_1", "spr_death_scythe_gem_2", "spr_death_scythe_gem_3",
    "spr_death_scythe_gem_4",
    "spr_ghost_strike_gem_icon", "spr_ghost_spark_gem_icon",
    "spr_ghost_pact_gem_icon", "spr_ghost_caijue_gem_icon",
    "spr_aladdin_lamp_gem_1", "spr_aladdin_lamp_gem_2", "spr_aladdin_lamp_gem_3",
    "spr_aladdin_lamp_gem_4", "spr_aladdin_lamp_gem_5",
]


def frame_pngs(spr):
    yy = os.path.join(ROOT, "sprites", spr, spr + ".yy")
    t = open(yy, encoding="utf-8").read()
    t = re.sub(r",(\s*[}\]])", r"\1", t)
    d = json.loads(t)
    return [os.path.join(ROOT, "sprites", spr, f["name"] + ".png") for f in d["frames"]]


def main():
    if os.path.isdir(OUT):
        shutil.rmtree(OUT)
    os.makedirs(OUT)
    n = 0
    for short, (spr, frames) in SPRITES.items():
        pngs = frame_pngs(spr)
        multi = len(frames) > 1
        for fi in frames:
            src = pngs[fi]
            dst = os.path.join(OUT, "%s%s.png" % (short, ("_%d" % fi) if multi else ""))
            shutil.copyfile(src, dst)
            n += 1
    for spr in ICONS:
        pngs = frame_pngs(spr)
        dst = os.path.join(OUT, spr[4:] + ".png")
        shutil.copyfile(pngs[0], dst)
        n += 1
    print("已导出 %d 个 PNG -> %s" % (n, OUT))


if __name__ == "__main__":
    main()
