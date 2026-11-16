# -*- coding: utf-8 -*-
"""把 天空背景图.png 对齐到关卡美术坐标（1109x597），并与 天空8星.png 求差，
用于确认「底图 + 云 + 障碍星」能否完整还原原美术。"""
import os

import numpy as np
from PIL import Image

BASE = r'D:\FVM开发\game\FVM开发\res\美食大战老鼠bgm地图合集\地图素材（更新至龙渊除厄第2期）\游戏地图背景\09跨服\梦魇天空'
OUT = r'D:\gameProject\FVM-Reborn-mod\output\_tmp_sky'
os.makedirs(OUT, exist_ok=True)

S = 0.9640      # bg_orig 缩到 1125x598 时与 star 同尺度
OX, OY = 15, 1  # star(x,y) = bg_resized(x+OX, y+OY)

bg = Image.open(os.path.join(BASE, '天空背景图.png')).convert('RGB')
st = Image.open(os.path.join(BASE, '天空8星.png')).convert('RGB')

# bg_resized = bg 缩到 (1167*S, 620*S)
rw, rh = int(round(bg.width * S)), int(round(bg.height * S))
bgr = bg.resize((rw, rh), Image.LANCZOS)
base = bgr.crop((OX, OY, OX + st.width, OY + st.height))
base.save(os.path.join(OUT, 'base_aligned.png'))
print('base aligned', base.size, ' bg resized', (rw, rh))

b = np.asarray(base).astype(np.int16)
s = np.asarray(st).astype(np.int16)
d = np.abs(b - s).max(2)
print('diff>12 像素占比 %.2f%%' % (100.0 * (d > 12).mean()))
print('diff>40 像素占比 %.2f%%' % (100.0 * (d > 40).mean()))

# 差异可视化：原美术 / 对齐底图 / 差异热区
vis = np.zeros((st.height, st.width * 3 + 20, 3), np.uint8)
vis[:, :st.width] = np.asarray(st)
vis[:, st.width + 10:st.width * 2 + 10] = np.asarray(base)
heat = np.clip(d * 3, 0, 255).astype(np.uint8)
vis[:, st.width * 2 + 20:] = np.stack([heat] * 3, axis=2)
Image.fromarray(vis).resize((vis.shape[1] // 2, vis.shape[0] // 2)).save(
    os.path.join(OUT, 'diff_star_base.png'))

# 云与星掩码 -> 转游戏坐标，确认云朵格位
r, g, bb = s[:, :, 0], s[:, :, 1], s[:, :, 2]
mx = s.max(2)
mn = s.min(2)
cloud = (d > 25) & ((mx - mn) < 60) & (mx > 170)
green = (d > 25) & (g > 150) & (g - r > 60) & (g - bb > 30)
print('cloud px', cloud.sum(), 'green px', green.sum())

# 游戏坐标换算
def a2g_x(x):
    return 13.2 + x * 1.7833


def a2g_y(y):
    return 12.39 + y * 1.78


def cell_of(x, y):
    return ((a2g_x(x) - 695) / 107.0, (a2g_y(y) - 228) / 116.0)


for name, mask in (('green', green),):
    ys, xs = np.nonzero(mask)
    if len(xs) == 0:
        continue
    # 简易分团
    order = np.argsort(xs)
    pts = list(zip(xs[order], ys[order]))
    groups, cur = [], [pts[0]]
    for p in pts[1:]:
        if p[0] - cur[-1][0] > 15:
            groups.append(cur)
            cur = [p]
        else:
            cur.append(p)
    groups.append(cur)
    blobs = []
    for gp in groups:
        gp = sorted(gp, key=lambda t: t[1])
        sub = [gp[0]]
        for p in gp[1:]:
            if p[1] - sub[-1][1] > 15:
                blobs.append(sub)
                sub = [p]
            else:
                sub.append(p)
        blobs.append(sub)
    print('== %s blobs ==' % name)
    for bl in blobs:
        if len(bl) < 400:
            continue
        bx = [p[0] for p in bl]
        by = [p[1] for p in bl]
        cx, cy = (min(bx) + max(bx)) / 2.0, (min(by) + max(by)) / 2.0
        c, rw_ = cell_of(cx, cy)
        print('  art(%.0f,%.0f) size %dx%d  -> grid(col=%.2f,row=%.2f) area=%d'
              % (cx, cy, max(bx) - min(bx), max(by) - min(by), c, rw_, len(bl)))
