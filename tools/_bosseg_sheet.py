# -*- coding: utf-8 -*-
"""新 BOSS 精灵分段目检：每个精灵取「正常半边首末帧 + 受伤半边首末帧」拼图。"""
import os
import re
import json
import sys

from PIL import Image

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
sys.path.insert(0, os.path.join(ROOT, "tools"))
import cross_new_boss_spec as S

OUT = os.path.join(ROOT, "output", "_tmp")


def frames_of(name):
    s = open(os.path.join(ROOT, "sprites", name, name + ".yy"), encoding="utf-8").read()
    d = json.loads(re.sub(r",(\s*[}\]])", r"\1", s))
    return [f["%Name"] + ".png" for f in d["frames"]], d["width"], d["height"]


for boss in S.BOSSES:
    rows = []
    for sfx, old_spr, total, segs in boss["sprites"]:
        name = "spr_%s%s_%s" % (boss["prefix"], boss["key"], sfx)
        files, w, h = frames_of(name)
        if sfx == "appear":
            halves = [(0, 79), (80, 159)]
        else:
            half = total // 2
            halves = [(0, half - 1), (half, total - 1)]
        picks, labels = [], []
        for a, b in halves:
            picks += [a, b]
            labels += ["%s[%d]" % (sfx, a), ""]
        scale = min(1.0, 150.0 / max(w, h))
        tw, th = int(w * scale), int(h * scale)
        canvas = Image.new("RGB", (tw * len(picks), th), (240, 240, 240))
        for i, fi in enumerate(picks):
            im = Image.open(os.path.join(ROOT, "sprites", name, files[fi])).convert("RGBA")
            bg = Image.new("RGBA", im.size, (240, 240, 240, 255))
            bg.alpha_composite(im)
            canvas.paste(bg.convert("RGB").resize((tw, th)), (i * tw, 0))
        p = os.path.join(OUT, "bosseg_%s.png" % name)
        canvas.save(p)
        print(name, "->", p)
