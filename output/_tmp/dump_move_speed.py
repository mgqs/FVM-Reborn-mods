# -*- coding: utf-8 -*-
"""列出 15 个新对象里所有 move_speed 赋值，并对照表格速度（×0.03）。"""
import glob
import io
import os
import re

ROOT = r"D:/gameProject/FVM-Reborn-mod"

# 表格速度（第一个数字）+ 表格防爆
TABLE = {
    "penguin": ("20", True),
    "mole": ("30", True),
    "garbage": ("17.14", True),
    "flower": ("12", True),
    "warrior": ("40", True),
    "warrior_minion": ("8.57", True),
    "naruto": ("40", True),
    "naruto_minion": ("8.57", True),
    "dentist": ("30", True),
    "ghost": ("20", True),
    "arson": ("20", True),
    "can": ("10", True),
    "sawblade": ("30", True),
    "nonmain": ("10", True),
    "magician": ("20", True),
}

for key in TABLE:
    d = os.path.join(ROOT, "objects", "obj_kf_zr_" + key)
    hits = []
    for g in sorted(glob.glob(os.path.join(d, "*.gml"))):
        for ln, line in enumerate(io.open(g, encoding="utf-8-sig").read().splitlines(), 1):
            if "move_speed" in line and "=" in line and "current_move_speed" not in line:
                hits.append("%s:%d %s" % (os.path.basename(g), ln, line.strip()))
    reg_speed, _ = TABLE[key]
    print("== %-14s 表格 %-6s → %.4f" % (key, reg_speed, float(reg_speed) * 0.03))
    for h in hits:
        print("     ", h)
    if not hits:
        print("      <无 move_speed 赋值>")
