# -*- coding: utf-8 -*-
"""把四行「防爆」候选带拼成一张图，便于一次读出。"""
from PIL import Image, ImageDraw

p = r"C:/Users/18203/.workbuddy/clipboard-images/clipboard-2026-11-05T07-16-31-519Z-87f77647.png"
im = Image.open(p).convert("RGB")
W, H = im.size

cands = [195, 430, 665, 900]
parts = []
for i, y0 in enumerate(cands):
    c = im.crop((0, y0, W, min(y0 + 45, H)))
    parts.append((y0, c))

sc = 1.7
outW = int(W * sc)
outH = sum(int(c.height * sc) + 16 for _, c in parts)
canvas = Image.new("RGB", (outW, outH), (255, 255, 255))
d = ImageDraw.Draw(canvas)
y = 0
for y0, c in parts:
    d.text((2, y + 2), "y=%d" % y0, fill=(200, 0, 0))
    canvas.paste(c.resize((int(c.width * sc), int(c.height * sc))), (0, y + 14))
    y += int(c.height * sc) + 16
canvas.save(r"D:/gameProject/FVM-Reborn-mod/output/_tmp/zr_ash_rows.png")
print(canvas.size)
