# -*- coding: utf-8 -*-
"""落地后自检：从磁盘上的真实精灵重新合成 1920×1080 预览，并与备份旧图对比。"""
import glob
import os

import numpy as np
from PIL import Image, ImageDraw, ImageFont

ROOT = r'D:\gameProject\FVM-Reborn-mod'
OUT = os.path.join(ROOT, 'output', '梦魇天空预览')
BACKUP = os.path.join(OUT, 'backup')

GX, GY, GSX, GSY = 13.2, 12.39, 1.7833, 1.78
GRID_X, GRID_Y, CELL_W, CELL_H = 695, 228, 107, 116
GW, GH = 1920, 1080
NAMES = ['天空静夜', '天空蒙雾', '天空薄雾', '天空迷雾',
         '天空浓雾', '天空重雾', '天空夜雾', '天空终雾']


def fnt(sz):
    for nm in ('msyhbd.ttc', 'msyh.ttc', 'simhei.ttf'):
        p = os.path.join(r'C:\Windows\Fonts', nm)
        if os.path.exists(p):
            return ImageFont.truetype(p, sz)
    return ImageFont.load_default()


def to_screen(art):
    im = art.convert('RGB').resize((int(round(art.width * GSX)), int(round(art.height * GSY))),
                                   Image.LANCZOS)
    c = Image.new('RGB', (GW, GH), (8, 6, 16))
    c.paste(im, (int(round(GX)), int(round(GY))))
    return c


def grid(img):
    out = img.copy()
    d = ImageDraw.Draw(out, 'RGBA')
    for c in range(10):
        x = GRID_X + c * CELL_W
        d.line([(x, GRID_Y), (x, GRID_Y + 7 * CELL_H)], fill=(0, 255, 255, 60), width=1)
    for r in range(8):
        y = GRID_Y + r * CELL_H
        d.line([(GRID_X, y), (GRID_X + 9 * CELL_W, y)], fill=(0, 255, 255, 60), width=1)
    d.rectangle([GRID_X, GRID_Y, GRID_X + 2 * CELL_W, GRID_Y + 7 * CELL_H],
                outline=(255, 210, 0, 235), width=3)
    return out


# 自检：两份 PNG 必须一致、尺寸 1109×597
ok = True
for n in range(8):
    top = glob.glob(os.path.join(ROOT, 'sprites', 'spr_mengyantiankong_%d' % n, '*.png'))[0]
    lay = glob.glob(os.path.join(ROOT, 'sprites', 'spr_mengyantiankong_%d' % n,
                                 'layers', '*', '*.png'))[0]
    a = np.asarray(Image.open(top).convert('RGB')).astype(np.int16)
    b = np.asarray(Image.open(lay).convert('RGB')).astype(np.int16)
    same = (a == b).all()
    size_ok = Image.open(top).size == (1109, 597)
    print('spr_%d  顶层+layer一致=%s  尺寸1109x597=%s' % (n, same, size_ok))
    ok = ok and same and size_ok

    old_p = os.path.join(BACKUP, 'spr_mengyantiankong_%d' % n,
                         os.path.basename(os.path.dirname(
                             os.path.join(BACKUP, 'spr_mengyantiankong_%d' % n, 'x.png'))) )
for n in range(8):
    cur_p = glob.glob(os.path.join(ROOT, 'sprites', 'spr_mengyantiankong_%d' % n, '*.png'))[0]
    old_cands = glob.glob(os.path.join(BACKUP, 'spr_mengyantiankong_%d' % n, '*.png'))
    old_p = old_cands[0]
    a = np.asarray(Image.open(old_p).convert('RGB')).astype(np.int16)
    b = np.asarray(Image.open(cur_p).convert('RGB')).astype(np.int16)
    d = np.abs(a - b).max(2)
    print('spr_%d  旧图->新图 差异>30 占 %.2f%%  均值 %.1f' % (n, (d > 30).mean() * 100, d.mean()))

# 出终版预览
for n in (0, 3, 7):
    art = Image.open(glob.glob(os.path.join(ROOT, 'sprites', 'spr_mengyantiankong_%d' % n, '*.png'))[0])
    s = grid(to_screen(art))
    d = ImageDraw.Draw(s)
    d.rectangle([0, 0, GW, 42], fill=(0, 0, 0, 175))
    d.text((16, 6), '落地后 · 关卡 %d %s ｜ 底图=纯天空 ｜ col0-1 云+障碍 ｜ col2-8 只由飘入云覆盖'
           % (n, NAMES[n]), font=fnt(26), fill=(255, 255, 255))
    s.save(os.path.join(OUT, 'applied_%d.png' % n))

print('\nALL_OK' if ok else '\n存在不一致')
