# -*- coding: utf-8 -*-
"""给有真实冷却的宝石对象接上 hex_b3_gem_cd_mult()"""
import io, os, re

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
TARGETS = [
    "obj_bomb_gem", "obj_cateye_gem", "obj_divine_blessing_gem",
    "obj_flamerecover_gem", "obj_freeze_gem", "obj_holy_gem",
    "obj_laser_gem", "obj_starlight_gem",
]
MARK = "hex_b3_gem_cd_mult()"

for o in TARGETS:
    p = os.path.join(ROOT, "objects", o, "Create_0.gml")
    src = io.open(p, "r", encoding="utf-8", newline="").read()
    if MARK in src:
        print("skip (已接线):", o); continue
    lines = src.split("\n")
    out, done = [], False
    for ln in lines:
        out.append(ln)
        # 只认「cooldown = <非 0 表达式>」这一行，且尚未被处理
        m = re.match(r"^(\s*)cooldown\s*=\s*(.+?)\s*;?\s*$", ln)
        if not done and m and m.group(2).strip() != "0":
            indent = m.group(1)
            out.append(indent + "// 海克斯二期：宝石三件套（技能冷却倍率，非海克斯下恒 1.0）")
            out.append(indent + "cooldown = cooldown * " + MARK)
            done = True
    if not done:
        print("[X] 未找到 cooldown 赋值:", o); continue
    io.open(p, "w", encoding="utf-8", newline="").write("\n".join(out))
    print("ok:", o)
