# -*- coding: utf-8 -*-
"""诊断：1) 对齐后的纯背景在 col0-1 长什么样；2) 原美术里的绿色六芒星到底在哪、多大。"""
import os

import numpy as np
from PIL import Image

BASE = r'D:\FVM开发\game\FVM开发\res\美食大战老鼠bgm地图合集\地图素材（更新至龙渊除厄第2期）\游戏地图背景\09跨服\梦魇天空'
ROOT = r'D:\gameProject\FVM-Reborn-mod'
OUT = os.path.join(ROOT, 'output', '梦魇天空预览', 'diag')
os.makedirs(OUT, exist_ok=True)

S, OX, OY = 0.9640, 15, 1
ART_W, ART_H = 1109, 597
GX, GY, GSX, GSY = 13.2, 12.39, 1.7833, 1.78
GRID_X, GRID_Y, CELL_W, CELL_H = 695, 228, 107, 116

bg = Image.open(os.path.join(BASE, '天空背景图.png')).convert('RGB')
rw, rh = int(round(bg.width * S)), int(round(bg.height * S))
BASE_ART = bg.resize((rw, rh), Image.LANCZOS).crop((OX, OY, OX + ART_W, OY + ART_H))
BASE_ART.save(os.path.join(OUT, 'base_art.png'))

# col0-1 在美术坐标里落在哪
print('col0 左缘 art_x =', (GRID_X - GX) / GSX)
print('col2 左缘 art_x =', (GRID_X + 2 * CELL_W - GX) / GSX)
print('grid 顶  art_y =', (GRID_Y - GY) / GSY)
print('grid 底  art_y =', (GRID_Y + 7 * CELL_H - GY) / GSY)

# 原美术 vs 纯背景 的差异掩码（col0-1 范围）
art = Image.open(os.path.join(BASE, '天空8星.png')).convert('RGB')
a = np.asarray(art).astype(np.int16)
b = np.asarray(BASE_ART).astype(np.int16)
diff = np.abs(a - b).max(2)
m = (diff > 40).astype(np.uint8) * 255
Image.fromarray(m).save(os.path.join(OUT, 'diff_mask.png'))
print('差异像素占比 %.2f%%' % ((diff > 40).mean() * 100))

# 绿色掩码：找所有绿块 bbox
r, g, bl = a[:, :, 0], a[:, :, 1], a[:, :, 2]
green = (g > 130) & (g - r > 55) & (g - bl > 35)
print('绿色像素数', int(green.sum()))

H, W = green.shape
seen = np.zeros_like(green, bool)
blobs = []
ys, xs = np.nonzero(green)
for y0, x0 in zip(ys.tolist(), xs.tolist()):
    if seen[y0, x0]:
        continue
    stack = [(y0, x0)]
    seen[y0, x0] = True
    pts = []
    while stack:
        y, x = stack.pop()
        pts.append((y, x))
        for dy in (-1, 0, 1):
            for dx in (-1, 0, 1):
                ny, nx = y + dy, x + dx
                if 0 <= ny < H and 0 <= nx < W and green[ny, nx] and not seen[ny, nx]:
                    seen[ny, nx] = True
                    stack.append((ny, nx))
    if len(pts) < 300:
        continue
    py = [p[0] for p in pts]
    px = [p[1] for p in pts]
    blobs.append((min(px), min(py), max(px) + 1, max(py) + 1, len(pts)))

blobs.sort(key=lambda t: -t[4])
print('绿块 %d 个（面积>=300）' % len(blobs))
for i, (x0, y0, x1, y1, area) in enumerate(blobs[:12]):
    w, h = x1 - x0, y1 - y0
    print('  #%d bbox=(%d,%d,%d,%d) %dx%d area=%d  aspect=%.2f'
          % (i, x0, y0, x1, y1, w, h, area, w / max(1, h)))
    art.crop((x0, y0, x1, y1)).save(os.path.join(OUT, 'blob_%d.png' % i))

# 单元格中心 -> 美术坐标，标注每个障碍格附近最大绿块
print()
for row in range(7):
    for col in range(2):
        cx = (GRID_X + col * CELL_W + CELL_W / 2 - GX) / GSX
        cy = (GRID_Y + row * CELL_H + CELL_H / 2 - GY) / GSY
        near = None
        for (x0, y0, x1, y1, area) in blobs:
            if x0 - 12 <= cx <= x1 + 12 and y0 - 12 <= cy <= y1 + 12:
                if near is None or area > near[4]:
                    near = (x0, y0, x1, y1, area)
        print('  cell(r%d,c%d) art_center=(%.0f,%.0f) -> %s' % (row, col, cx, cy, near))
print()
print('输出：', OUT)
