# -*- coding: utf-8 -*-
"""放大单个「防爆」带，分左右两半输出，便于逐列确认。"""
from PIL import Image

p = r"C:/Users/18203/.workbuddy/clipboard-images/clipboard-2026-11-05T07-16-31-519Z-87f77647.png"
im = Image.open(p).convert("RGB")
W, H = im.size

for tag, y0 in (("row1", 195), ("row3", 665)):
    c = im.crop((0, y0, W, y0 + 40))
    half = W // 2
    for i, box in enumerate([(0, 0, half, 40), (half, 0, W, 40)]):
        part = c.crop(box)
        part = part.resize((part.width * 3, part.height * 3), Image.LANCZOS)
        out = r"D:/gameProject/FVM-Reborn-mod/output/_tmp/zr_ash_%s_%d.png" % (tag, i)
        part.save(out)
        print(out, part.size)
