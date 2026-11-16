# -*- coding: utf-8 -*-
"""自检：巫毒底图网格区域是否还残留铁笼（白色金属框 / 深黑网面）。

判据只针对「网格区域」：底图四周的书本、南瓜、铁门等装饰本来就有灰白色，
不能算残留。铁笼的金属框亮度很高（min>150 且低饱和），网面接近纯黑。

用法: python tools/wudu_erase_selfcheck.py
"""
import os, re
from PIL import Image

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
OX, OY, CW, CH, COLS, ROWS = 695, 228, 107, 116, 9, 7
BX, BY, SX, SY = 2, 36, 1.8, 1.8


def sprite_png(i):
    d = os.path.join(ROOT, "sprites", "spr_wuduyanjiusuo_%d" % i)
    txt = open(os.path.join(d, "spr_wuduyanjiusuo_%d.yy" % i), encoding="utf-8").read()
    frame = re.search(r'"\$GMSpriteFrame":"v1","%Name":"([0-9a-f\-]+)"', txt).group(1)
    return os.path.join(d, frame + ".png")


def main():
    gx0 = int((OX - BX) / SX); gx1 = int((OX + CW * COLS - BX) / SX)
    gy0 = int((OY - BY) / SY); gy1 = int((OY + CH * ROWS - BY) / SY)
    bad = 0
    for i in range(8):
        im = Image.open(sprite_png(i)).convert("RGB")
        px = im.load()
        W, H = im.size
        metal = mesh = 0
        for y in range(max(0, gy0), min(H, gy1)):
            for x in range(max(0, gx0), min(W, gx1)):
                r, g, b = px[x, y]
                if min(r, g, b) > 150 and max(r, g, b) - min(r, g, b) < 40:
                    metal += 1
                elif r < 60 and g < 60 and b < 60:
                    mesh += 1
        ok = metal < 200 and mesh < 200
        bad += 0 if ok else 1
        print("wudu_%d  网格内 金属 %4d px / 黑网 %4d px  %s"
              % (i, metal, mesh, "OK" if ok else "!! 疑似残留"))
    print("全部通过" if bad == 0 else "%d 张需要复查" % bad)


if __name__ == "__main__":
    main()
