# -*- coding: utf-8 -*-
"""炎帝终转（shape3）+ 石榴爆爆冰 的精灵批生成。

素材来源：C:\\Users\\18203\\Desktop\\皮特\\炎帝终转+石榴
口径（沿用工程既有精灵）：
  · 地块精灵 —— 原点取「alpha 包围盒底边中心」（同 spr_rabbit_lantern / spr_shennong_god）
  · 朝右子弹 —— 原点贴包围盒右侧、垂直居中（同 spr_shennong_god_bullet）
  · 竖向坠落子弹（石榴籽）—— 原点取包围盒顶端中心
  · 特效 —— 原点取底边中心（同 spr_mouse_ash_death / spr_mouse_frozen）
"""
import os
import re
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from make_multi_frame_sprite import build  # noqa: E402

SRC_ROOT = r"C:\Users\18203\Desktop\皮特\炎帝终转+石榴"

# (源目录, 精灵名, 纹理组, 原点模式)
JOBS = [
    ("spr-yandi-god/3shape", "spr_shennong_god_3", "cards", "foot"),
    ("spr-yandi-god/3bullet", "spr_shennong_god_bullet_3", "bullet", "right_center"),
    ("spr-shiliu/0shape", "spr_shiliu_0", "cards", "foot"),
    ("spr-shiliu/1shape", "spr_shiliu_1", "cards", "foot"),
    ("spr-shiliu/2shape", "spr_shiliu_2", "cards", "foot"),
    ("spr-shiliu/0bullet", "spr_shiliu_bullet_0", "bullet", "top_center"),
    ("spr-shiliu/1bullet", "spr_shiliu_bullet_1", "bullet", "top_center"),
    ("spr-shiliu/2bulet", "spr_shiliu_bullet_2", "bullet", "top_center"),
    ("spr-shiliu/effect-mousedeath", "spr_shiliu_ash_effect", "effects", "foot"),
    ("spr-shiliu/effect-mousefreeze", "spr_shiliu_freeze_effect", "effects", "foot"),
]


def frame_paths(d):
    names = [f for f in os.listdir(d) if f.lower().endswith(".png")]
    names.sort(key=lambda x: int(os.path.splitext(x)[0]))
    return [os.path.join(d, f) for f in names]


def union_bbox(paths, w, h):
    from PIL import Image
    import numpy as np
    minx, miny, maxx, maxy = w, h, 0, 0
    for p in paths:
        a = np.array(Image.open(p).convert("RGBA"))[:, :, 3]
        ys, xs = np.nonzero(a > 8)
        if len(xs) == 0:
            continue
        minx = min(minx, int(xs.min()))
        maxx = max(maxx, int(xs.max()))
        miny = min(miny, int(ys.min()))
        maxy = max(maxy, int(ys.max()))
    return minx, miny, maxx, maxy


def origin_for(mode, w, h, bb):
    from PIL import Image
    minx, miny, maxx, maxy = bb
    if mode == "foot":
        return int(round((minx + maxx) / 2.0)), maxy
    if mode == "right_center":
        return max(0, maxx - 4), int(round((miny + maxy) / 2.0))
    if mode == "top_center":
        return int(round((minx + maxx) / 2.0)), miny
    raise ValueError(mode)


def main():
    from PIL import Image
    only = sys.argv[1:] if len(sys.argv) > 1 else None
    for rel, name, tg, mode in JOBS:
        if only and name not in only:
            continue
        d = os.path.join(SRC_ROOT, rel.replace("/", os.sep))
        paths = frame_paths(d)
        w, h = Image.open(paths[0]).size
        bb = union_bbox(paths, w, h)
        ox, oy = origin_for(mode, w, h, bb)
        build(name, paths, w, h, ox, oy, tg)
        print("    %dx%d  origin(%d,%d)  bbox=%s  frames=%d" % (w, h, ox, oy, bb, len(paths)))


if __name__ == "__main__":
    main()
