# -*- coding: utf-8 -*-
"""读取原版 / 梦魇天空条目的 speed、ash_proof，用于反推表格速度口径。"""
import io
import os
import re

ROOT = r"D:/gameProject/FVM-Reborn-mod"
t = io.open(os.path.join(ROOT, "scripts/enemy_init/enemy_init.gml"), encoding="utf-8-sig").read()

want = [
    "kuafu_rambo", "kuafu_pirate", "kuafu_bat", "kuafu_wrestler", "kuafu_panda",
    "kuafu_armour", "kuafu_soar", "kuafu_jet", "kuafu_hopper", "kuafu_gift",
    "kuafu_flute", "kuafu_barrier", "kuafu_glider", "kuafu_cucumber",
    "kuafu_football_fan", "kuafu_iron_pan", "kuafu_skateboard", "kuafu_landlady",
    "kuafu_waste_flying", "kuafu_airbrone", "kuafu_paratrooper",
    "water_penguin_mouse", "mole", "garbage_track_mouse", "zombie_with_flower_pot",
    "warrior_mouse", "naruto_mouse", "dentist_mouse", "ghost_mouse",
    "arson_mouse", "can_mouse", "sawblade_mouse", "non_mainstream_mouse",
    "magician_mouse",
]

FIELD = r'"?%s"?\s*:\s*([^,}\n]+)'


def field(body, name):
    m = re.search(FIELD % name, body)
    return m.group(1).strip() if m else "-"


for w in want:
    m = re.search(r'register_enemy\("%s",\s*\{(.*?)\}\)' % re.escape(w), t, re.S)
    if not m:
        print("%-26s <未注册>" % w)
        continue
    b = m.group(1)
    print("%-26s speed=%-8s ash=%-6s hp=%-7s feature=%s"
          % (w, field(b, "speed"), field(b, "ash_proof"), field(b, "hp"), field(b, "feature")))
