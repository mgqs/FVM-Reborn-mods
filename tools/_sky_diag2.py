# -*- coding: utf-8 -*-
"""定位原版美术里的绿色六芒星障碍 + 取 spr_cloud_night 做云瓦片基准。"""
import glob
import os

import numpy as np
from PIL import Image

BASE = r'D:\FVM开发\game\FVM开发\res\美食大战老鼠bgm地图合集\地图素材（更新至龙渊除厄第2期）\游戏地图背景\09跨服\梦魇天空'
ROOT = r'D:\gameProject\FVM-Reborn-mod'
OUT = os.path.join(ROOT, 'output', '梦魇天空预览', 'diag')
os.makedirs(OUT, exist_ok=True)

GX, GY, GSX, GSY = 13.2, 12.39, 1.7833, 1.78
GRID_X, GRID_Y, CELL_W, CELL_H = 695, 228, 107, 116


def cell_art(row, col):
    return ((GRID_X + col * CELL_W + CELL_W / 2 - GX) / GSX,
            (GRID_Y + row * CELL_H + CELL_H / 2 - GY) / GSY)


def blobs_of(mask, min_area=200):
    H, W = mask.shape
    seen = np.zeros_like(mask, bool)
    out = []
    ys, xs = np.nonzero(mask)
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
                    if 0 <= ny < H and 0 <= nx < W and mask[ny, nx] and not seen[ny, nx]:
                        seen[ny, nx] = True
                        stack.append((ny, nx))
        if len(pts) < min_area:
            continue
        py = [p[0] for p in pts]
        px = [p[1] for p in pts]
        out.append((min(px), min(py), max(px) + 1, max(py) + 1, len(pts)))
    return out


COL0_X = (GRID_X - GX) / GSX        # 382.32
COL2_X = (GRID_X + 2 * CELL_W - GX) / GSX  # 502.33
ROW0_Y = (GRID_Y - GY) / GSY        # 121.13
ROW7_Y = (GRID_Y + 7 * CELL_H - GY) / GSY  # 577.31
print('格子区在美术坐标里：x %.1f ~ %.1f, y %.1f ~ %.1f' % (COL0_X, COL2_X + 6 * 0 + 420, ROW0_Y, ROW7_Y))
print('col0 格心 art_x=%.0f  col1=%.0f' % (cell_art(0, 0)[0], cell_art(0, 1)[0]))
print()

for n in range(8):
    p = glob.glob(os.path.join(ROOT, 'sprites', 'spr_mengyantiankong_%d' % n, '*.png'))[0]
    a = np.asarray(Image.open(p).convert('RGB')).astype(np.int16)
    r, g, b = a[:, :, 0], a[:, :, 1], a[:, :, 2]
    green = (g > 140) & (g - r > 60) & (g - b > 40)
    bs = [bb for bb in blobs_of(green, 300) if bb[0] >= 360]
    print('spr_%d 绿块(格区左侧外)%d 个：' % (n, len(bs)))
    for x0, y0, x1, y1, area in sorted(bs, key=lambda t: (t[1], t[0])):
        # 反解到格
        gcol = (GX + x0 * GSX - GRID_X) / CELL_W
        grow = (GY + y0 * GSY - GRID_Y) / CELL_H
        print('   bbox=(%d,%d,%d,%d) %dx%d area=%d -> 约 col%.2f row%.2f'
              % (x0, y0, x1, y1, x1 - x0, y1 - y0, area, gcol, grow))
    if bs:
        x0, y0, x1, y1, _ = max(bs, key=lambda t: t[4])
        Image.open(p).convert('RGB').crop((x0, y0, x1, y1)).save(
            os.path.join(OUT, 'star_spr%d.png' % n))

# 云素材
cp = sorted(glob.glob(os.path.join(ROOT, 'sprites', 'spr_cloud_night', '*.png')))
print()
print('spr_cloud_night 帧：', [os.path.basename(x) for x in cp])
im = Image.open(cp[0]).convert('RGBA')
print('单帧尺寸', im.size)
im.save(os.path.join(OUT, 'cloud_frame0.png'))
scaled = im.resize((int(round(im.width * 1.8 / GSX)), int(round(im.height * 1.8 / GSY))), Image.LANCZOS)
scaled.save(os.path.join(OUT, 'cloud_scaled_to_art.png'))
print('换算到美术坐标后尺寸', scaled.size)
print('格宽 107/%.4f = %.1f 美术像素' % (GSX, CELL_W / GSX))
print('格高 116/%.4f = %.1f 美术像素' % (GSY, CELL_H / GSY))
