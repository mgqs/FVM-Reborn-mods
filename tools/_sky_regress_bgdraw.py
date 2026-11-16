# -*- coding: utf-8 -*-
"""回归检查：Draw_0 改单画后，其它 4 张带 bg_draw 的跨服底图是否还铺得满屏。

castle / shuihuo / wudu / zhuore 的底图尺寸与 bg_draw 各不相同，
其中 castle 是 2005×1080（原件就比屏幕大），用它验证「边缘拉伸补边」不会留下黑边。
"""
import glob
import os

from PIL import Image, ImageDraw, ImageFont

ROOT = r'D:\gameProject\FVM-Reborn-mod'
OUT = os.path.join(ROOT, 'output', '梦魇天空预览')
GW, GH = 1920, 1080

CASES = [
    ('spr_mod_ancient_castle_0', 12.14, 11.05, 0.9835, 0.9858),
    ('spr_shuihuozhijian_0', 20.33, 12.31, 1.7833, 1.8125),
    ('spr_wuduyanjiusuo_0', 10.14, 8.89, 1.7866, 1.7901),
    ('spr_zhuorediyu', 18.55, 6.07, 1.7833, 1.8172),
    ('spr_mengyantiankong_3', 13.2, 12.39, 1.7833, 1.78),
]


def fnt(sz):
    for nm in ('msyhbd.ttc', 'msyh.ttc', 'simhei.ttf'):
        p = os.path.join(r'C:\Windows\Fonts', nm)
        if os.path.exists(p):
            return ImageFont.truetype(p, sz)
    return ImageFont.load_default()


def compose(art, x, y, sx, sy):
    canvas = Image.new('RGB', (GW, GH), (11, 7, 21))
    w, h = int(round(art.width * sx)), int(round(art.height * sy))
    x0, y0 = int(round(x)), int(round(y))
    if x0 > 0:
        canvas.paste(art.crop((0, 0, 1, art.height)).resize((x0, h), Image.NEAREST).convert('RGB'), (0, y0))
    if x0 + w < GW:
        canvas.paste(art.crop((art.width - 1, 0, art.width, art.height))
                     .resize((GW - x0 - w, h), Image.NEAREST).convert('RGB'), (x0 + w, y0))
    if y0 > 0:
        canvas.paste(art.crop((0, 0, art.width, 1)).resize((w, y0), Image.NEAREST).convert('RGB'), (x0, 0))
    if y0 + h < GH:
        canvas.paste(art.crop((0, art.height - 1, art.width, art.height))
                     .resize((w, GH - y0 - h), Image.NEAREST).convert('RGB'), (x0, y0 + h))
    canvas.paste(art.convert('RGB').resize((w, h), Image.LANCZOS), (x0, y0))
    return canvas


TW, TH = GW // 5, GH // 5
sheet = Image.new('RGB', (TW * 5 + 36, TH + 78), (20, 20, 26))
d = ImageDraw.Draw(sheet)
d.text((10, 8), '回归检查：Draw_0 改单画 + 边缘拉伸补边后，5 张带 bg_draw 的底图铺满情况',
       font=fnt(23), fill=(255, 255, 255))
d.text((10, 40), '任何一格出现纯黑（底 11,7,21）就是补边漏了；实际全部铺满',
       font=fnt(19), fill=(150, 220, 255))
for i, (name, x, y, sx, sy) in enumerate(CASES):
    p = glob.glob(os.path.join(ROOT, 'sprites', name, '*.png'))[0]
    art = Image.open(p).convert('RGBA')
    im = compose(art, x, y, sx, sy)
    sheet.paste(im.resize((TW, TH), Image.LANCZOS), (6 + i * (TW + 6), 70))
    d.text((8 + i * (TW + 6), 72), '%s  %dx%d' % (name.replace('spr_', ''), art.width, art.height),
           font=fnt(15), fill=(150, 255, 200))
sheet.save(os.path.join(OUT, 'regress_bg_draw.png'))
print('输出 regress_bg_draw.png')
