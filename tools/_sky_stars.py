# -*- coding: utf-8 -*-
"""梦魇天空：绿色六芒星（疑似障碍）位置检测 + 与关卡 JSON obstacle 对照。"""
import json
import os
import re

import numpy as np
from PIL import Image

BASE = r'D:\FVM开发\game\FVM开发\res\美食大战老鼠bgm地图合集\地图素材（更新至龙渊除厄第2期）\游戏地图背景\09跨服\梦魇天空'
ROOT = r'D:\gameProject\FVM-Reborn-mod'

FILES = ['天空8星.png', '天空9星、10星.png', '天空11星.png',
         '天空12星、13星.png', '天空14星.png', '天空15星.png']

# bg_draw: sx=1.7833 sy=1.78 把美术 60x65.167 映射到 107x116
# 美术列缝 384 + 60k、行缝 170 + 65.167k（cross_bg_align.py 标定）
SEAM_X, PITCH_X = 384.0, 60.0
SEAM_Y, PITCH_Y = 170.0, 65.167


def detect_green(path):
    a = np.asarray(Image.open(path).convert('RGB')).astype(np.int16)
    r, g, b = a[:, :, 0], a[:, :, 1], a[:, :, 2]
    m = (g > 150) & (g - r > 70) & (g - b > 40)
    ys, xs = np.nonzero(m)
    if len(xs) == 0:
        return []
    # 简单连通：按 x 分桶（星体大约 60px 宽）
    pts = sorted(zip(xs, ys))
    groups = []
    cur = [pts[0]]
    for p in pts[1:]:
        if p[0] - cur[-1][0] > 12:
            groups.append(cur)
            cur = [p]
        else:
            cur.append(p)
    groups.append(cur)
    # 再用 y 细分
    blobs = []
    for gset in groups:
        gset = sorted(gset, key=lambda t: t[1])
        sub = [gset[0]]
        for p in gset[1:]:
            if p[1] - sub[-1][1] > 12:
                blobs.append(sub)
                sub = [p]
            else:
                sub.append(p)
        blobs.append(sub)
    out = []
    for bl in blobs:
        if len(bl) < 600:
            continue
        bx = [p[0] for p in bl]
        by = [p[1] for p in bl]
        cx = (min(bx) + max(bx)) / 2
        cy = (min(by) + max(by)) / 2
        out.append((cx, cy, len(bl)))
    return out


def to_grid(cx, cy):
    col = (cx - SEAM_X) / PITCH_X
    row = (cy - SEAM_Y) / PITCH_Y
    return round(col, 2), round(row, 2)


print('==== 美术里的绿色星块 ====')
for f in FILES:
    p = os.path.join(BASE, f)
    blobs = detect_green(p)
    print(f, 'count=%d' % len(blobs))
    for cx, cy, n in blobs:
        c, r = to_grid(cx, cy)
        print('   px(%.0f,%.0f) grid(col=%.2f,row=%.2f) area=%d' % (cx, cy, c, r, n))

print()
print('==== 关卡 JSON obstacle 位置 ====')
for i in range(8):
    p = os.path.join(ROOT, 'datafiles', 'level_data', 'cross', 'nightmare_sky-%d.json' % i)
    t = open(p, encoding='utf-8').read().rstrip('\x00')
    j = json.loads(t)
    cells = []
    for ri, row in enumerate(j['map']):
        for ci, cell in enumerate(row):
            objs = cell.get('object') or []
            if objs:
                cells.append((ri, ci, objs))
    print('nightmare_sky-%d  map_sprite=%s  obstacle cells=%s' % (i, j['map_sprite'], cells))
