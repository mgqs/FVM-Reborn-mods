# -*- coding: utf-8 -*-
"""把「再来十次」按钮重排成「再来五十次」。

按行扫描不透明区，用同行底色覆盖文字，再重绘 —— 胶囊圆角不会被破坏。
输出：assets/btn_again50.png
"""
import os
import sys

from PIL import Image, ImageDraw, ImageFont

HERE = os.path.dirname(os.path.abspath(__file__))
SRC = r"C:/Users/18203/Desktop/转转/images/238.png"
FONT = r"C:/Windows/Fonts/msyhbd.ttc"


def erase(im):
    w, h = im.size
    px = im.load()
    for y in range(h):
        xs = [x for x in range(w) if px[x, y][3] > 200]
        if not xs:
            continue
        x0, x1 = xs[0], xs[-1]
        if x1 - x0 < 16:
            continue
        c = px[x0 + 2, y]
        for x in range(x0 + 3, x1 - 2):
            px[x, y] = c
    return im


def draw(im, text, size=19):
    w, h = im.size
    d = ImageDraw.Draw(im)
    f = ImageFont.truetype(FONT, size)
    tw = d.textlength(text, font=f)
    x = (w - tw) / 2
    cy = h / 2
    d.text((x, cy), text, font=f, fill=(255, 255, 255), anchor="lm",
           stroke_width=4, stroke_fill=(214, 84, 20))
    d.text((x, cy - 1), text, font=f, fill=(255, 250, 228), anchor="lm")
    return im


def main():
    im = Image.open(SRC).convert("RGBA")
    im = erase(im)
    im = draw(im, "再来五十次")
    out = os.path.join(HERE, "assets", "btn_again50.png")
    im.save(out)
    print("生成 %s %s" % (out, im.size))
    return 0


if __name__ == "__main__":
    sys.exit(main())
