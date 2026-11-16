# -*- coding: utf-8 -*-
"""复现 obj_battle/Draw_0.gml 的双次绘制，验证「两层云」的真正来源。

Draw_0.gml 在 bg_draw 存在时会画两遍同一张底图：
  ① 兜底：cover 比例（max(1920/w, 1080/h)）居中铺满 → 缩放 1.8090，位置 (-43, 0)
  ② 精确：bg_draw（sx=1.7833, sy=1.78）→ 位置 (13, 12)
两者缩放差 1.4%、水平错位约 56 px —— 底图里的云与障碍会被画两次。
"""
import glob
import os

from PIL import Image, ImageDraw, ImageFont

ROOT = r'D:\gameProject\FVM-Reborn-mod'
OUT = os.path.join(ROOT, 'output', '梦魇天空预览')
GW, GH = 1920, 1080
GX, GY, GSX, GSY = 13.2, 12.39, 1.7833, 1.78
GRID_X, GRID_Y, CELL_W, CELL_H = 695, 228, 107, 116


def fnt(sz):
    for nm in ('msyhbd.ttc', 'msyh.ttc', 'simhei.ttf'):
        p = os.path.join(r'C:\Windows\Fonts', nm)
        if os.path.exists(p):
            return ImageFont.truetype(p, sz)
    return ImageFont.load_default()


def render(art, double):
    """double=True 复现现状（兜底+精确），False 只画精确那份。"""
    canvas = Image.new('RGB', (GW, GH), (11, 7, 21))
    if double:
        cover = max(GW / art.width, GH / art.height)
        w, h = int(round(art.width * cover)), int(round(art.height * cover))
        base = art.convert('RGB').resize((w, h), Image.LANCZOS)
        canvas.paste(base, (int(round((GW - w) * 0.5)), int(round((GH - h) * 0.5))))
    w2, h2 = int(round(art.width * GSX)), int(round(art.height * GSY))
    exact = art.convert('RGB').resize((w2, h2), Image.LANCZOS)
    canvas.paste(exact, (int(round(GX)), int(round(GY))))
    return canvas


def grid(img):
    out = img.copy()
    d = ImageDraw.Draw(out, 'RGBA')
    for c in range(10):
        x = GRID_X + c * CELL_W
        d.line([(x, GRID_Y), (x, GRID_Y + 7 * CELL_H)], fill=(0, 255, 255, 55), width=1)
    for r in range(8):
        y = GRID_Y + r * CELL_H
        d.line([(GRID_X, y), (GRID_X + 9 * CELL_W, y)], fill=(0, 255, 255, 55), width=1)
    d.rectangle([GRID_X, GRID_Y, GRID_X + 2 * CELL_W, GRID_Y + 7 * CELL_H],
                outline=(255, 210, 0, 235), width=3)
    return out


art = Image.open(glob.glob(os.path.join(ROOT, 'sprites', 'spr_mengyantiankong_3', '*.png'))[0])

a = grid(render(art, True))
b = grid(render(art, False))
a.save(os.path.join(OUT, 'diag_double_draw.png'))
b.save(os.path.join(OUT, 'diag_single_draw.png'))

TW, TH = GW // 2, GH // 2
sheet = Image.new('RGB', (TW * 2 + 16, TH + 76), (22, 22, 28))
sheet.paste(a.resize((TW, TH), Image.LANCZOS), (0, 70))
sheet.paste(b.resize((TW, TH), Image.LANCZOS), (TW + 16, 70))
d = ImageDraw.Draw(sheet)
d.text((14, 8), '左＝现状 Draw_0 双画（兜底 cover 1.8090 @(-43,0) + 精确 1.7833 @(13,12)）→ 云与障碍各出现两次',
       font=fnt(23), fill=(255, 170, 120))
d.text((14, 36), '右＝只画精确那一份 → 单层。这就是「还是两层云」的真正原因（与 events 无关）',
       font=fnt(23), fill=(140, 255, 170))
sheet.save(os.path.join(OUT, 'diag_double_vs_single.png'))

print('cover 缩放 %.4f  精确缩放 %.4f  比例差 %.2f%%'
      % (max(GW / art.width, GH / art.height), GSX,
         (max(GW / art.width, GH / art.height) / GSX - 1) * 100))
print('水平错位 %.1f px' % (GX - (GW - art.width * max(GW / art.width, GH / art.height)) / 2))
print('输出 diag_double_vs_single.png')
