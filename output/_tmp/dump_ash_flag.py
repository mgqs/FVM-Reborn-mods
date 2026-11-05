# -*- coding: utf-8 -*-
"""列出新对象与原版对象里的 immune_to_ash / special_ash 取值。"""
import glob
import io
import os
import re

ROOT = r"D:/gameProject/FVM-Reborn-mod"
PAIRS = {
    "penguin": "water_penguin_mouse", "mole": "mole", "garbage": "garbage_track_mouse",
    "flower": "zombie_with_flower_pot", "warrior": "warrior_mouse",
    "warrior_minion": "warrior_minion_mouse", "naruto": "naruto_mouse",
    "naruto_minion": "naruto_minion_mouse", "dentist": "dentist_mouse",
    "ghost": "ghost_mouse", "arson": "arson_mouse", "can": "can_mouse",
    "sawblade": "sawblade_mouse", "nonmain": "non_mainstream_mouse",
    "magician": "magician_mouse",
}


def scan(obj):
    d = os.path.join(ROOT, "objects", obj)
    res = {}
    for g in glob.glob(os.path.join(d, "*.gml")):
        for line in io.open(g, encoding="utf-8-sig").read().splitlines():
            s = line.strip()
            for k in ("immune_to_ash", "special_ash"):
                if s.startswith(k) and "=" in s and "==" not in s:
                    res[k] = s.split("=", 1)[1].strip()
    return res


print("%-16s %-30s %-24s" % ("新对象", "immune/special", "原版对应"))
for k, old in PAIRS.items():
    new = scan("obj_kf_zr_" + k)
    o = scan("obj_" + old)
    print("%-16s %-30s %-24s" % (
        k,
        "immune=%s special=%s" % (new.get("immune_to_ash", "-"), new.get("special_ash", "-")),
        "immune=%s special=%s" % (o.get("immune_to_ash", "-"), o.get("special_ash", "-"))))
