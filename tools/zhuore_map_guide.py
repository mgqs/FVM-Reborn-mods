# -*- coding: utf-8 -*-
"""生成灼热地域地图对照图：底图 + 网格坐标 + 可放置/空洞标记

输出 output/zhuore_map_guide.png，写 map 时对着看即可。
"""
import os
import sys

from PIL import Image, ImageDraw, ImageFont

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import zhuore_build as B
import zhuore_levels_build as L

ROOT = L.ROOT
BG = L.BG_DRAW
OX, OY, CW, CH = 695, 228, 107, 116


def font(size):
    for p in ("C:/Windows/Fonts/arialbd.ttf", "C:/Windows/Fonts/arial.ttf"):
        if os.path.isfile(p):
            return ImageFont.truetype(p, size)
    return ImageFont.load_default()


def main():
    im = B.frame_image(L.MAP_SPRITE, 0).convert("RGB")
    big = im.resize((int(im.width * BG["sx"]), int(im.height * BG["sy"])), Image.LANCZOS)
    canvas = Image.new("RGB", (1920, 1080), (0, 0, 0))
    canvas.paste(big, (BG["x"], BG["y"]))
    d = ImageDraw.Draw(canvas, "RGBA")

    f_cell = font(26)
    f_small = font(17)
    for r in range(7):
        for c in range(9):
            x, y = OX + CW * c, OY + CH * r
            ok = L.MAP_LAYOUT[r][c] == "#"
            if ok:
                d.rectangle([x, y, x + CW, y + CH], outline=(80, 220, 255, 210), width=2)
                d.ellipse([x + 6, y + 6, x + 34, y + 34], fill=(20, 60, 90, 200))
                d.text((x + 12, y + 10), str(c), font=f_small, fill=(255, 235, 140))
                d.text((x + 12, y + 28), str(r), font=f_small, fill=(255, 235, 140))
            else:
                d.rectangle([x, y, x + CW, y + CH], outline=(255, 90, 90, 150), width=2)
                d.line([x + 20, y + 20, x + CW - 20, y + CH - 20], fill=(255, 90, 90, 170), width=3)
                d.line([x + CW - 20, y + 20, x + 20, y + CH - 20], fill=(255, 90, 90, 170), width=3)

    d.rectangle([0, 0, 1920, 44], fill=(0, 0, 0, 170))
    d.text((16, 8), "zhuore map  |  blue = normal (placement ok)   red X = water (lava pit)   "
                    "label = col / row", font=f_small, fill=(230, 230, 230))

    out = os.path.join(ROOT, "output", "zhuore_map_guide.png")
    canvas.save(out)
    print("写出", out, canvas.size)
    print("可放置格 %d / 63" % sum(row.count("#") for row in L.MAP_LAYOUT))


if __name__ == "__main__":
    main()
