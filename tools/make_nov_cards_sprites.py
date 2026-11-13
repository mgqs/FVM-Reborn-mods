# -*- coding: utf-8 -*-
"""11 月第二批新卡（元素蛇 / 星轨神 / 银河马）精灵批生成。

素材：C:\\Users\\18203\\Desktop\\皮特\\11月份做卡11.12
口径（沿用工程既有精灵）：
  · 地块精灵 —— 原点取「alpha 包围盒底边中心」（同 spr_fushengcha / spr_haiyang_god）
  · 朝右子弹 —— 原点贴包围盒右侧、垂直居中（同 spr_shennong_god_bullet）
  · 坠落陨石 —— 原点取「最后一个非空帧包围盒中心」= 砸中目标那一格
  · 特效 / 范围框 —— 原点取画布中心
  · 元素蛇 0shape/1shape/2shape 各 84 帧 = 4 段 × 21 帧（黄 / 紫 / 蓝 / 红），按段切精灵
"""
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from make_multi_frame_sprite import build  # noqa: E402

SRC_ROOT = r"C:\Users\18203\Desktop\皮特\11月份做卡11.12"

COLORS = ["", "_p", "_b", "_r"]          # 黄 / 紫 / 蓝 / 红
COLOR_DIRS = ["yellow", "purple", "blue", "red"]
SEG = 21                                  # 元素蛇每段帧数
SEGS = [(1, 21), (22, 42), (43, 63), (64, 84)]

JOBS = []

# ── 元素蛇：3 形态 × 4 色 ─────────────────────────────
for _si, _sdir in enumerate(["0shape", "1shape", "2shape"]):
    _shp = "" if _si == 0 else "_%d" % _si
    for _ci, _csuf in enumerate(COLORS):
        _a, _b = SEGS[_ci]
        JOBS.append(("spr-yuansushe/" + _sdir, "spr_yuansushe%s%s" % (_shp, _csuf),
                     "cards", "foot", (_a, _b)))
    for _ci, _csuf in enumerate(COLORS):
        JOBS.append(("spr-yuansushe/%s%sbullet" % (_si, COLOR_DIRS[_ci]),
                     "spr_yuansushe%s_bullet%s" % (_shp, _csuf), "bullet", "right_center", None))

# ── 元素蛇：状态特效 ──────────────────────────────────
JOBS += [
    ("spr-yuansushe/effect-critical-hit", "spr_yuansushe_fx_crit", "effects", "foot", None),
    ("spr-yuansushe/effect-dizzy", "spr_yuansushe_fx_dizzy", "effects", "center", None),
    ("spr-yuansushe/effect-froze", "spr_yuansushe_fx_froze", "effects", "center", None),
    ("spr-yuansushe/effect-poison", "spr_yuansushe_fx_poison", "effects", "center", None),
    ("spr-yuansushe/effect-slowdown", "spr_yuansushe_fx_slow", "effects", "center", None),
]

# ── 星轨神：4 形态 + 范围框 ───────────────────────────
JOBS += [
    ("spr-xinggui-god/0shape", "spr_xinggui_god", "cards", "foot", None),
    ("spr-xinggui-god/1shape", "spr_xinggui_god_1", "cards", "foot", None),
    ("spr-xinggui-god/2shape", "spr_xinggui_god_2", "cards", "foot", None),
    ("spr-xinggui-god/3shape", "spr_xinggui_god_3", "cards", "foot", None),
    ("spr-xinggui-god/0effect", "spr_xinggui_god_effect", "effects", "center", None),
    ("spr-xinggui-god/1effect", "spr_xinggui_god_effect_1", "effects", "center", None),
    ("spr-xinggui-god/2effect", "spr_xinggui_god_effect_2", "effects", "center", None),
    ("spr-xinggui-god/3effect-less-than4", "spr_xinggui_god_effect_3", "effects", "center", None),
    ("spr-xinggui-god/3effect-least-4", "spr_xinggui_god_effect_3_full", "effects", "center", None),
]

# ── 银河马：3 形态 + 陨石 ─────────────────────────────
JOBS += [
    ("spr-galaxyhorse/0shape", "spr_galaxy_horse", "cards", "foot", None),
    ("spr-galaxyhorse/1shape", "spr_galaxy_horse_1", "cards", "foot", None),
    ("spr-galaxyhorse/2shape", "spr_galaxy_horse_2", "cards", "foot", None),
    ("spr-galaxyhorse/0bullet", "spr_galaxy_horse_bullet", "bullet", "impact", None),
    ("spr-galaxyhorse/1bullet", "spr_galaxy_horse_bullet_1", "bullet", "impact", None),
    ("spr-galaxyhorse/2bullet", "spr_galaxy_horse_bullet_2", "bullet", "impact", None),
]


def frame_paths(d):
    names = [f for f in os.listdir(d) if f.lower().endswith(".png")]
    names.sort(key=lambda x: int(os.path.splitext(x)[0]))
    return [os.path.join(d, f) for f in names]


def alpha_array(p):
    from PIL import Image
    import numpy as np
    return np.array(Image.open(p).convert("RGBA"))[:, :, 3]


def union_bbox(paths, w, h):
    minx, miny, maxx, maxy = w, h, 0, 0
    for p in paths:
        a = alpha_array(p)
        ys, xs = (a > 8).nonzero()
        if len(xs) == 0:
            continue
        minx = min(minx, int(xs.min()))
        maxx = max(maxx, int(xs.max()))
        miny = min(miny, int(ys.min()))
        maxy = max(maxy, int(ys.max()))
    return minx, miny, maxx, maxy


def origin_for(mode, w, h, bb, paths):
    minx, miny, maxx, maxy = bb
    if mode == "foot":
        return int(round((minx + maxx) / 2.0)), maxy
    if mode == "right_center":
        return max(0, maxx - 4), int(round((miny + maxy) / 2.0))
    if mode == "center":
        return w // 2, h // 2
    if mode == "impact":
        # 最后一个非空帧的包围盒中心 = 落地炸点
        for p in reversed(paths):
            a = alpha_array(p)
            ys, xs = (a > 8).nonzero()
            if len(xs):
                return int(round((xs.min() + xs.max()) / 2.0)), int(round((ys.min() + ys.max()) / 2.0))
        return w // 2, h // 2
    raise ValueError(mode)


def last_nonempty_count(paths):
    n = len(paths)
    while n > 1:
        a = alpha_array(paths[n - 1])
        if (a > 8).any():
            break
        n -= 1
    return n


def main():
    from PIL import Image
    only = sys.argv[1:] if len(sys.argv) > 1 else None
    for rel, name, tg, mode, rng in JOBS:
        if only and name not in only:
            continue
        d = os.path.join(SRC_ROOT, rel.replace("/", os.sep))
        paths = frame_paths(d)
        if rng:
            paths = paths[rng[0] - 1:rng[1]]
        else:
            # 陨石末尾有几帧全空，按最后一个非空帧截断
            if mode == "impact":
                paths = paths[:last_nonempty_count(paths)]
        w, h = Image.open(paths[0]).size
        bb = union_bbox(paths, w, h)
        ox, oy = origin_for(mode, w, h, bb, paths)
        build(name, paths, w, h, ox, oy, tg)
        print("    %dx%d  origin(%d,%d)  bbox=%s  frames=%d" % (w, h, ox, oy, bb, len(paths)))


if __name__ == "__main__":
    main()
