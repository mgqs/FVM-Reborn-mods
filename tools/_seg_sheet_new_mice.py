# -*- coding: utf-8 -*-
"""把新小怪精灵的每一段首帧拼成矩阵图，人工核对分段是否正确。"""
import os
import re
import json
import sys
from PIL import Image

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
sys.path.insert(0, os.path.join(ROOT, "tools"))
import cross_new_mice_spec as S

OUT = os.path.join(ROOT, "output", "_tmp")


def frames_of(name):
    s = open(os.path.join(ROOT, "sprites", name, name + ".yy"), encoding="utf-8").read()
    d = json.loads(re.sub(r",(\s*[}\]])", r"\1", s))
    return [f["%Name"] + ".png" for f in d["frames"]], d["width"], d["height"]


def sprite_name(case, suffix):
    if suffix in ("main", "water"):
        return "spr_" + case["prefix"] + case["key"]
    return "spr_%s%s_%s" % (case["prefix"], case["key"], suffix)


for case in S.CASES:
    for suffix, _old, total, segs, _ref in case["sprites"]:
        name = sprite_name(case, suffix)
        files, w, h = frames_of(name)
        # 每段取首帧 + 末帧
        picks, labels = [], []
        idx = 0
        for label, _st, _en, n in segs:
            picks.append(idx)
            labels.append("%s[%d]" % (label, idx))
            picks.append(min(idx + n - 1, total - 1))
            labels.append("")
            idx += n
        scale = min(1.0, 220.0 / max(w, h))
        tw, th = int(w * scale), int(h * scale)
        cols = len(picks)
        canvas = Image.new("RGB", (tw * cols, th), (240, 240, 240))
        for i, fi in enumerate(picks):
            im = Image.open(os.path.join(ROOT, "sprites", name, files[fi])).convert("RGBA")
            bg = Image.new("RGBA", im.size, (240, 240, 240, 255))
            bg.alpha_composite(im)
            canvas.paste(bg.convert("RGB").resize((tw, th)), (i * tw, 0))
        p = os.path.join(OUT, "seg_%s.png" % name)
        canvas.save(p)
        print("%-34s %s" % (name, " | ".join(l for l in labels if l)))
        print("    -> %s" % p)
