# -*- coding: utf-8 -*-
"""把「200点券 / 1440点券」按钮底图改成「20000金币 / 100000金币」。

做法：擦掉原文字（用同行的垂直渐变底色横向填充，保留紫边框），
再用系统中黑体重新排「数字 + 金币」两段文字（描边色取自原字描边）。

只在预览里用；正式版应让美术出「金币」文案的按钮图。
输出：assets/price_20000.png、assets/price_100000.png
"""
import os
import sys

from PIL import Image, ImageDraw, ImageFont

HERE = os.path.dirname(os.path.abspath(__file__))
SRC = r"C:/Users/18203/Desktop/转转/images"
FONT = r"C:/Windows/Fonts/msyhbd.ttc"

# 源图 → 目标文件 / 数字文案 / 描边色 / 数字字号
JOBS = [
    ("346.png", "price_20000.png", "20000", (196, 78, 20), 27),
    ("354.png", "price_100000.png", "100000", (168, 40, 96), 25),
    ("358.png", "price_1000000.png", "1000000", (150, 30, 84), 22),
]


def erase_text(im):
    """用每行 x=32 处的底色覆盖中部文字区，保留左右紫边框。"""
    w, h = im.size
    px = im.load()
    x0, x1 = 34, w - 34
    for y in range(h):
        c = px[32, y]
        for x in range(x0, x1):
            px[x, y] = c
    return im


def draw_label(im, digits, stroke_rgb, num_size=27):
    w, h = im.size
    d = ImageDraw.Draw(im)
    unit_size = max(13, num_size - 10)
    try:
        f_num = ImageFont.truetype(FONT, num_size)
        f_unit = ImageFont.truetype(FONT, unit_size)
    except OSError:
        print("字体缺失，退回默认字体")
        f_num = f_unit = ImageFont.load_default()

    wn = d.textlength(digits, font=f_num)
    wu = d.textlength("金币", font=f_unit)
    gap = 1
    total = wn + gap + wu
    x = (w - total) / 2
    cy = h / 2

    # 数字：粗描边 + 白到浅黄渐变（用两遍实色近似）
    d.text((x, cy), digits, font=f_num, fill=(255, 255, 255), anchor="lm",
           stroke_width=4, stroke_fill=stroke_rgb)
    d.text((x, cy - 1), digits, font=f_num, fill=(255, 252, 232), anchor="lm")
    # 金币：小一号，底部对齐
    d.text((x + wn + gap, cy + 3), "金币", font=f_unit, fill=(255, 255, 255), anchor="lm",
           stroke_width=3, stroke_fill=stroke_rgb)
    d.text((x + wn + gap, cy + 2), "金币", font=f_unit, fill=(255, 252, 232), anchor="lm")
    return im


def main():
    out = os.path.join(HERE, "assets")
    os.makedirs(out, exist_ok=True)
    for src, dst, digits, stroke, nsize in JOBS:
        sp = os.path.join(SRC, src)
        if not os.path.exists(sp):
            print("缺源图: %s" % sp)
            return 1
        im = Image.open(sp).convert("RGBA")
        im = erase_text(im)
        im = draw_label(im, digits, stroke, nsize)
        im.save(os.path.join(out, dst))
        print("生成 %s  (%s)" % (dst, im.size))
    return 0


if __name__ == "__main__":
    sys.exit(main())
