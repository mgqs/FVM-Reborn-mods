# -*- coding: utf-8 -*-
"""扫描新章节小怪素材：帧尺寸、空帧、与原版精灵尺寸/帧数对比。"""
import os
from PIL import Image

ROOT = r"C:\Users\18203\Desktop\跨服"
CASE = [
    ("水火之间/小怪/精灵/划艇僵尸鼠", 56, "spr_rowboat_mouse", 42),
    ("水火之间/小怪/精灵/龙舟僵尸鼠", 56, "spr_dragon_boat_mouse", 42),
    ("水火之间/小怪/精灵/旗舰僵尸鼠", 56, "spr_flagship_mouse", 42),
    ("水火之间/小怪/精灵/拳皇潜艇僵尸鼠", 94, "spr_kof_submarine_mouse_land", 36),
    ("巫毒研究所/小怪/精灵/垃圾车僵尸鼠", 30, "spr_garbage_track_mouse", 32),
]

for rel, expect, old_spr, old_frames in CASE:
    d = os.path.join(ROOT, rel.replace("/", os.sep))
    files = sorted([f for f in os.listdir(d) if f.lower().endswith(".png")],
                   key=lambda f: int(os.path.splitext(f)[0]))
    empty = []
    sizes = {}
    for f in files:
        im = Image.open(os.path.join(d, f)).convert("RGBA")
        sizes[im.size] = sizes.get(im.size, 0) + 1
        if im.split()[3].getbbox() is None:
            empty.append(f)
    print("%-16s 帧数=%-3d(期望 %d) 尺寸=%s 空帧=%s" % (rel.split("/")[2], len(files), expect,
                                                dict(list(sizes.items())[:4]), empty or "无"))
    print("                 原版 %s %d 帧" % (old_spr, old_frames))
