# -*- coding: utf-8 -*-
"""v3 底图合成：底层=天空背景图（配准 1109×597），col0-1 逐格贴 spr_cloud_night 云 + 绿星障碍。"""
import glob
import os

import numpy as np
from PIL import Image, ImageDraw, ImageFont

BASE = r'D:\FVM开发\game\FVM开发\res\美食大战老鼠bgm地图合集\地图素材（更新至龙渊除厄第2期）\游戏地图背景\09跨服\梦魇天空'
ROOT = r'D:\gameProject\FVM-Reborn-mod'
OUT = os.path.join(ROOT, 'output', '梦魇天空预览')
BUILD = os.path.join(OUT, 'build')
os.makedirs(BUILD, exist_ok=True)

S, OX, OY = 0.9640, 15, 1
ART_W, ART_H = 1109, 597
GX, GY, GSX, GSY = 13.2, 12.39, 1.7833, 1.78
GRID_X, GRID_Y, CELL_W, CELL_H = 695, 228, 107, 116
GW, GH = 1920, 1080

CELL_ART_W = CELL_W / GSX   # 60.0
CELL_ART_H = CELL_H / GSY   # 65.2

NAMES = ['天空静夜', '天空蒙雾', '天空薄雾', '天空迷雾',
         '天空浓雾', '天空重雾', '天空夜雾', '天空终雾']
OBSTACLES = {
    0: [], 1: [(2, 0), (4, 0)], 2: [(2, 0), (4, 0)],
    3: [(1, 0), (3, 0), (5, 0)], 4: [(1, 0), (3, 1), (5, 0)],
    5: [(1, 0), (3, 1), (5, 0)], 6: [(1, 1), (3, 1), (5, 1)],
    7: [(1, 0), (2, 1), (3, 0), (4, 1), (5, 0)],
}


def cell_center_art(row, col):
    return ((GRID_X + col * CELL_W + CELL_W / 2 - GX) / GSX,
            (GRID_Y + row * CELL_H + CELL_H / 2 - GY) / GSY)


def fnt(size):
    for nm in ('msyhbd.ttc', 'msyh.ttc', 'simhei.ttf'):
        p = os.path.join(r'C:\Windows\Fonts', nm)
        if os.path.exists(p):
            return ImageFont.truetype(p, size)
    return ImageFont.load_default()


# ---------- 底层 ----------
_bg = Image.open(os.path.join(BASE, '天空背景图.png')).convert('RGB')
BASE_ART = _bg.resize((int(round(_bg.width * S)), int(round(_bg.height * S))), Image.LANCZOS) \
              .crop((OX, OY, OX + ART_W, OY + ART_H)).convert('RGBA')

# ---------- 云瓦片：spr_cloud_night 两帧，按引擎 1.8 倍缩放口径 ----------
# 引擎里 obj_cloud 的 image_xscale/yscale = 1.8，83×70 → 149×126 游戏像素；
# 换成美术像素 = 149/GSX × 126/GSY ≈ 84×71，即 1.4 格宽，能自然叠成连续云墙。
_cloud_frames = sorted(glob.glob(os.path.join(ROOT, 'sprites', 'spr_cloud_night', '*.png')))
CLOUDS = []
for _p in _cloud_frames:
    _im = Image.open(_p).convert('RGBA')
    _cw = int(round(_im.width * 1.8 / GSX))
    _ch = int(round(_im.height * 1.8 / GSY))
    CLOUDS.append(_im.resize((_cw, _ch), Image.LANCZOS))
CLOUDS[0].save(os.path.join(OUT, 'tile_cloud.png'))
print('云瓦片 %s ×%d 帧（引擎 1.8 倍口径），格 %.1fx%.1f 美术像素'
      % (CLOUDS[0].size, len(CLOUDS), CELL_ART_W, CELL_ART_H))

# ---------- 障碍：从 spr_1 抠一颗带内圈的绿星（含透明底）----------
_s1 = Image.open(glob.glob(os.path.join(ROOT, 'sprites', 'spr_mengyantiankong_1', '*.png'))[0]).convert('RGB')
BOX = (388, 216, 462, 302)          # 六芒星 + 内圈，留 4px 边
star = _s1.crop(BOX)
a = np.asarray(star).astype(np.int16)
r, g, b = a[:, :, 0], a[:, :, 1], a[:, :, 2]
keep = (g > 100) & (g - r > 30) & (g - b > 15)
alpha = Image.fromarray((keep.astype(np.uint8) * 255)).filter(ImageFilter.GaussianBlur(0.8)) if False else \
        Image.fromarray(keep.astype(np.uint8) * 255)
star = star.convert('RGBA')
star.putalpha(alpha)
STAR = star.crop(star.getbbox())
STAR.save(os.path.join(OUT, 'tile_star.png'))
print('障碍图案 %s' % (STAR.size,))


def build(n):
    art = BASE_ART.copy()
    # 先铺云：col0-1 共 14 格，逐格一朵，两帧交替（对应引擎 image_index = cloud_count mod 2）
    for col in range(2):
        for row in range(7):
            cx, cy = cell_center_art(row, col)
            tile = CLOUDS[(row + col) % 2]
            art.alpha_composite(tile, (int(round(cx - tile.width / 2)),
                                       int(round(cy - tile.height / 2))))
    # 再贴障碍
    for row, col in OBSTACLES[n]:
        cx, cy = cell_center_art(row, col)
        art.alpha_composite(STAR, (int(round(cx - STAR.width / 2)),
                                   int(round(cy - STAR.height / 2))))
    return art


def to_screen(art):
    im = art.convert('RGB').resize((int(round(art.width * GSX)), int(round(art.height * GSY))), Image.LANCZOS)
    canvas = Image.new('RGB', (GW, GH), (8, 6, 16))
    canvas.paste(im, (int(round(GX)), int(round(GY))))
    return canvas


def overlay(img, note):
    out = img.copy()
    d = ImageDraw.Draw(out, 'RGBA')
    for c in range(10):
        x = GRID_X + c * CELL_W
        d.line([(x, GRID_Y), (x, GRID_Y + 7 * CELL_H)], fill=(0, 255, 255, 65), width=1)
    for rr in range(8):
        y = GRID_Y + rr * CELL_H
        d.line([(GRID_X, y), (GRID_X + 9 * CELL_W, y)], fill=(0, 255, 255, 65), width=1)
    d.rectangle([GRID_X, GRID_Y, GRID_X + 2 * CELL_W, GRID_Y + 7 * CELL_H],
                outline=(255, 210, 0, 235), width=3)
    d.rectangle([0, 0, GW, 44], fill=(0, 0, 0, 175))
    d.text((16, 6), note, font=fnt(27), fill=(255, 255, 255, 255))
    return out


for n in range(8):
    art = build(n)
    art.convert('RGB').save(os.path.join(BUILD, 'spr_mengyantiankong_%d.png' % n))
    s = to_screen(art)
    s = overlay(s, '关卡 %d %s ｜ 底层=天空背景图 ｜ col0-1 云+障碍 %s ｜ col2-8 空'
                % (n, NAMES[n], OBSTACLES[n] if OBSTACLES[n] else '（仅云）'))
    s.save(os.path.join(OUT, 'target_%d.png' % n))
    print('关卡 %d -> spr_mengyantiankong_%d.png' % (n, n))

# 对比
cur = Image.open(glob.glob(os.path.join(ROOT, 'sprites', 'spr_mengyantiankong_0', '*.png'))[0]).convert('RGB')
cur_s = to_screen(cur.convert('RGBA'))
new_s = overlay(to_screen(build(0)), '新的 spr_mengyantiankong_0')
pair = Image.new('RGB', (GW, GH // 2 + 60), (22, 22, 28))
pair.paste(cur_s.resize((GW // 2, GH // 2), Image.LANCZOS), (0, 60))
pair.paste(new_s.resize((GW // 2, GH // 2), Image.LANCZOS), (GW // 2, 60))
d = ImageDraw.Draw(pair)
d.text((14, 8), '现状 spr_0：底图自带满屏云 + 引擎铺 col2-8 云 + 每5秒从右侧飘入 = 两层可移动云',
       font=fnt(25), fill=(255, 170, 120))
d.text((GW // 2 + 14, 8), '目标：纯天空底图 + 仅 col0-1 云与障碍 → 只剩一层移动云',
       font=fnt(25), fill=(140, 255, 170))
pair.save(os.path.join(OUT, 'compare.png'))
print('\n成品：', BUILD)
