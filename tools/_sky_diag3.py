# -*- coding: utf-8 -*-
"""校验：原美术的天空像素是否与 天空背景图 对齐后的像素一致（决定能否无缝贴云）。"""
import glob
import os

import numpy as np
from PIL import Image

BASE = r'D:\FVM开发\game\FVM开发\res\美食大战老鼠bgm地图合集\地图素材（更新至龙渊除厄第2期）\游戏地图背景\09跨服\梦魇天空'
ROOT = r'D:\gameProject\FVM-Reborn-mod'

S, OX, OY = 0.9640, 15, 1
ART_W, ART_H = 1109, 597
GX, GY, GSX, GSY = 13.2, 12.39, 1.7833, 1.78
GRID_X, GRID_Y, CELL_W, CELL_H = 695, 228, 107, 116

bg = Image.open(os.path.join(BASE, '天空背景图.png')).convert('RGB')
BASE_ART = bg.resize((int(round(bg.width * S)), int(round(bg.height * S))), Image.LANCZOS) \
             .crop((OX, OY, OX + ART_W, OY + ART_H))
b = np.asarray(BASE_ART).astype(np.int16)


def cell_box(row, col, pad=0):
    """格子边界 -> 美术像素框。"""
    x0 = (GRID_X + col * CELL_W - GX) / GSX - pad
    x1 = (GRID_X + (col + 1) * CELL_W - GX) / GSX + pad
    y0 = (GRID_Y + row * CELL_H - GY) / GSY - pad
    y1 = (GRID_Y + (row + 1) * CELL_H - GY) / GSY + pad
    return int(round(x0)), int(round(y0)), int(round(x1)), int(round(y1))


print('格子美术像素宽高：%.1f x %.1f' % (CELL_W / GSX, CELL_H / GSY))
print('cell(0,0) box =', cell_box(0, 0))
print()

for n in (0, 3, 7):
    p = glob.glob(os.path.join(ROOT, 'sprites', 'spr_mengyantiankong_%d' % n, '*.png'))[0]
    a = np.asarray(Image.open(p).convert('RGB')).astype(np.int16)
    d = np.abs(a - b).max(2)
    print('spr_%d  全图差异 均值%.1f  >30占%.1f%%' % (n, d.mean(), (d > 30).mean() * 100))
    for row in range(7):
        line = []
        for col in range(9):
            x0, y0, x1, y1 = cell_box(row, col)
            sub = d[y0:y1, x0:x1]
            line.append('%4.1f' % (100.0 * (sub > 30).mean()))
        print('   row%d 差异%%(>30) 每列: %s' % (row, ' '.join(line)))
    print()
