# -*- coding: utf-8 -*-
"""把 SWF 导出帧按指定帧号拼成一张图，用于目视核对分段。
用法: python tools/_swf_sheet.py <dir> <1-based帧号逗号表> [列数] [最大边长]
"""
import os
import sys
from PIL import Image

d = sys.argv[1]
picks = [int(x) for x in sys.argv[2].split(",")]
cols = int(sys.argv[3]) if len(sys.argv) > 3 else len(picks)
maxside = float(sys.argv[4]) if len(sys.argv) > 4 else 300.0

ims = []
for p in picks:
    fp = os.path.join(d, "%d.png" % p)
    im = Image.open(fp).convert("RGBA")
    ims.append((p, im))

w, h = ims[0][1].size
scale = min(1.0, maxside / max(w, h))
tw, th = int(w * scale), int(h * scale)
rows = (len(ims) + cols - 1) // cols
canvas = Image.new("RGB", (tw * cols, th * rows), (235, 235, 235))
for i, (p, im) in enumerate(ims):
    bg = Image.new("RGBA", im.size, (235, 235, 235, 255))
    bg.alpha_composite(im)
    canvas.paste(bg.convert("RGB").resize((tw, th)), ((i % cols) * tw, (i // cols) * th))
out = os.path.join("output", "_tmp", "swfsheet_%s.png" % os.path.basename(d.rstrip("\\/"))[:28].replace(" ", "_"))
canvas.save(out)
print(out, "帧:", picks)
