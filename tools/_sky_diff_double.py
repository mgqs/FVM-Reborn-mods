# -*- coding: utf-8 -*-
"""双画重影差分：把「旧 Draw_0 双画」与「新单画」相减，高亮出被多画一遍的区域。

用来证明「还是两层云」= 底图被 Draw_0 画了两遍（缩放 1.8090 vs 1.7833、水平错开 56px），
而不是云事件多铺了一层。
"""
import glob
import os

import numpy as np
from PIL import Image, ImageDraw, ImageFont

ROOT = r'D:\gameProject\FVM-Reborn-mod'
OUT = os.path.join(ROOT, 'output', '梦魇天空预览')
GW, GH = 1920, 1080
GX, GY, GSX, GSY = 13.2, 12.39, 1.7833, 1.78


def fnt(sz):
    for nm in ('msyhbd.ttc', 'msyh.ttc', 'simhei.ttf'):
        p = os.path.join(r'C:\Windows\Fonts', nm)
        if os.path.exists(p):
            return ImageFont.truetype(p, sz)
    return ImageFont.load_default()


def compose(art, double):
    canvas = Image.new('RGB', (GW, GH), (11, 7, 21))
    w, h = int(round(art.width * GSX)), int(round(art.height * GSY))
    x0, y0 = int(round(GX)), int(round(GY))
    if double:
        cover = max(GW / art.width, GH / art.height)
        cw, ch = int(round(art.width * cover)), int(round(art.height * cover))
        canvas.paste(art.convert('RGB').resize((cw, ch), Image.LANCZOS),
                     (int(round((GW - cw) * 0.5)), int(round((GH - ch) * 0.5))))
    else:
        canvas.paste(art.crop((0, 0, 1, art.height)).resize((x0, h), Image.NEAREST).convert('RGB'), (0, y0))
        rw = GW - (x0 + w)
        if rw > 0:
            canvas.paste(art.crop((art.width - 1, 0, art.width, art.height))
                         .resize((rw, h), Image.NEAREST).convert('RGB'), (x0 + w, y0))
        canvas.paste(art.crop((0, 0, art.width, 1)).resize((w, y0), Image.NEAREST).convert('RGB'), (x0, 0))
        bh = GH - (y0 + h)
        if bh > 0:
            canvas.paste(art.crop((0, art.height - 1, art.width, art.height))
                         .resize((w, bh), Image.NEAREST).convert('RGB'), (x0, y0 + h))
    canvas.paste(art.convert('RGB').resize((w, h), Image.LANCZOS), (x0, y0))
    return canvas


art = Image.open(glob.glob(os.path.join(ROOT, 'sprites', 'spr_mengyantiankong_3', '*.png'))[0]).convert('RGBA')
d_dbl = np.asarray(compose(art, True)).astype(np.int16)
d_sgl = np.asarray(compose(art, False)).astype(np.int16)

diff = np.abs(d_dbl - d_sgl).max(axis=2)
print('差分：mean=%.2f  >24 的像素占比 %.2f%%  >64 的占比 %.2f%%'
      % (diff.mean(), (diff > 24).mean() * 100, (diff > 64).mean() * 100))

# 热力图：黑白单画作底，差异染成红
heat = (np.stack([d_sgl.max(axis=2)] * 3, axis=2) * 0.42).astype(np.uint8)
mask = diff > 24
heat[mask] = [255, 60, 60]
heat_img = Image.fromarray(heat)

# 并排：单画 / 差分热力 / 双画
TW, TH = GW // 2, GH // 2
sheet = Image.new('RGB', (TW * 3 + 32, TH + 76), (18, 18, 24))
d = ImageDraw.Draw(sheet)
sheet.paste(compose(art, False).resize((TW, TH), Image.LANCZOS), (0, 70))
sheet.paste(heat_img.resize((TW, TH), Image.LANCZOS), (TW + 16, 70))
sheet.paste(compose(art, True).resize((TW, TH), Image.LANCZOS), (TW * 2 + 32, 70))
d.text((14, 8), '图层差分证明：红色 = 旧 Draw_0 把底图多画了一遍的区域（云、星、石柱边缘全被描了两遍）',
       font=fnt(23), fill=(255, 255, 255))
d.text((14, 40), '左＝单画（修好后）　中＝差异热力　右＝旧双画', font=fnt(22), fill=(150, 220, 255))
sheet.save(os.path.join(OUT, 'v4_double_diff.png'))
print('输出 v4_double_diff.png')
