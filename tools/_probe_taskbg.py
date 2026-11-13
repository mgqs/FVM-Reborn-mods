# -*- coding: utf-8 -*-
"""探测 spr_task_bg 左侧列表区的纵向范围（用于决定第 4 页签与任务行的落点）。"""
import json, glob, os
from PIL import Image

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
yy = os.path.join(ROOT, "sprites", "spr_task_bg", "spr_task_bg.yy")
txt = open(yy, encoding="utf-8").read()
frames = [m.group(1) for m in __import__("re").finditer(r'"%Name":"([0-9a-f\-]{36})"', txt)]
pngs = sorted(glob.glob(os.path.join(ROOT, "sprites", "spr_task_bg", "layers", frames[0], "*.png")))
im = Image.open(pngs[0]).convert("RGBA")
W, H = im.size
print("png", W, H)

# 场景 -> 精灵本地坐标（image_xscale=0.9, origin 804,548, 实例在 960,540）
def to_local(sx, sy):
    return (804 + (sx - 960) / 0.9, 548 + (sy - 540) / 0.9)

def to_scene(lx, ly):
    return (960 + (lx - 804) * 0.9, 540 + (ly - 548) * 0.9)

for scene_x in (300, 560, 800):
    lx = int(to_local(scene_x, 540)[0])
    print("=== scene x", scene_x, "-> local x", lx)
    prev = None
    run_start = 0
    for ly in range(0, H):
        px = im.getpixel((lx, ly))
        key = (px[0] // 12, px[1] // 12, px[2] // 12, px[3] // 24)
        if prev is None:
            prev, run_start = key, ly
        elif key != prev:
            if ly - run_start >= 8:
                y0 = to_scene(lx, run_start)[1]
                y1 = to_scene(lx, ly)[1]
                print("   ly %4d..%4d  scene_y %6.1f..%6.1f  rgba %s" % (run_start, ly - 1, y0, y1, px))
            prev, run_start = key, ly
    print("   tail ly %4d..%4d -> scene_y %6.1f..%6.1f" % (run_start, H - 1, to_scene(lx, run_start)[1], to_scene(lx, H - 1)[1]))
