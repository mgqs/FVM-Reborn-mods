# -*- coding: utf-8 -*-
"""运行时模拟：底图（纯天空 + col0-1 云/障碍）+ 唯一一层从 col9 飘入的云。

用来直观确认「只剩一层可移动云」时战场的观感：col2-8 初始是干净天空，
云排从右侧进入后逐列左移（obj_cloud Step 每帧 x -= 0.25）。
"""
import glob
import os

from PIL import Image, ImageDraw, ImageFont

ROOT = r'D:\gameProject\FVM-Reborn-mod'
OUT = os.path.join(ROOT, 'output', '梦魇天空预览')
BUILD = os.path.join(OUT, 'build')

GX, GY, GSX, GSY = 13.2, 12.39, 1.7833, 1.78
GRID_X, GRID_Y, CELL_W, CELL_H = 695, 228, 107, 116
GW, GH = 1920, 1080


def fnt(size):
    for nm in ('msyhbd.ttc', 'msyh.ttc', 'simhei.ttf'):
        p = os.path.join(r'C:\Windows\Fonts', nm)
        if os.path.exists(p):
            return ImageFont.truetype(p, size)
    return ImageFont.load_default()


def to_screen(art_rgba):
    im = art_rgba.convert('RGB').resize(
        (int(round(art_rgba.width * GSX)), int(round(art_rgba.height * GSY))), Image.LANCZOS)
    c = Image.new('RGB', (GW, GH), (8, 6, 16))
    c.paste(im, (int(round(GX)), int(round(GY))))
    return c


CLOUD_GAME_W = int(round(83 * 1.8))
CLOUD_GAME_H = int(round(70 * 1.8))
_cloud = Image.open(sorted(glob.glob(os.path.join(ROOT, 'sprites', 'spr_cloud_night', '*.png')))[0]).convert('RGBA')
CLOUD_GAME = _cloud.resize((CLOUD_GAME_W, CLOUD_GAME_H), Image.LANCZOS)

BASE = Image.open(os.path.join(BUILD, 'spr_mengyantiankong_0.png')).convert('RGBA')

stages = [
    ('战斗开始（col 2-8 无云，只剩天空）', None),
    ('云排第一次飘入 col 9', 9),
    ('云飘到 col 7-8（第一层继续左移）', 7),
    ('云飘到 col 5-6', 5),
    ('云飘到 col 3-4，后续云排持续跟进', 3),
]

imgs = []
for title, col in stages:
    canvas = to_screen(BASE).convert('RGBA')
    if col is not None:
        for c in (col, col + 1, col + 2):
            if c > 9:
                continue
            for row in range(7):
                cx = GRID_X + c * CELL_W + CELL_W / 2
                cy = GRID_Y + row * CELL_H + CELL_H / 2 - 10
                canvas.alpha_composite(CLOUD_GAME, (int(round(cx - CLOUD_GAME.width / 2)),
                                                    int(round(cy - CLOUD_GAME.height / 2))))
    canvas = canvas.convert('RGB')
    d = ImageDraw.Draw(canvas)
    d.rectangle([0, 0, GW, 40], fill=(0, 0, 0, 175))
    d.text((16, 5), title, font=fnt(26), fill=(255, 255, 255))
    imgs.append(canvas)

TW, TH = GW // 2, GH // 2
sheet = Image.new('RGB', (TW * 2 + 16, TH * 2 + 70), (22, 22, 28))
for i, im in enumerate(imgs[:4]):
    sheet.paste(im.resize((TW, TH), Image.LANCZOS), ((i % 2) * (TW + 16), 60 + (i // 2) * TH))
d = ImageDraw.Draw(sheet)
d.text((14, 6), '运行时模拟：底图纯天空 + col0-1 云/障碍，引擎只有一层云从右侧飘入（obj_cloud 每帧 x -= 0.25）',
       font=fnt(24), fill=(160, 255, 190))
d.text((14, 34), '四格依次为：开战空场 → 云排进入 col9 → 左移到 col7-8 → 继续到 col5-6，只有这一层在动',
       font=fnt(18), fill=(200, 200, 200))
sheet.save(os.path.join(OUT, 'runtime_single_layer.png'))
print('runtime_single_layer.png 已输出')
