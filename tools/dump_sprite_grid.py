# -*- coding: utf-8 -*-
"""导出精灵全帧网格图，便于肉眼比对分段。"""
import sys
import os

sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "tools"))
import zhuore_build as B            # noqa: E402
from PIL import Image, ImageDraw    # noqa: E402


def grid(sprite, out, cols=14, sc=0.35, marks=(), total=None):
    m = B.sprite_meta(sprite)
    n = total or len(m["frames"])
    ims = []
    for i in range(n):
        im = B.frame_image(sprite, i)
        ims.append((i, im.resize((max(1, int(im.width * sc)),
                                 max(1, int(im.height * sc))))))
    cw = max(im.width for _, im in ims)
    ch = max(im.height for _, im in ims)
    rows = (n + cols - 1) // cols
    c = Image.new("RGBA", (cw * cols, (ch + 13) * rows), (24, 24, 24, 255))
    d = ImageDraw.Draw(c)
    for k, (i, im) in enumerate(ims):
        x = (k % cols) * cw
        y = (k // cols) * (ch + 13) + 12
        c.paste(im, (x, y), im)
        d.text((x + 1, y - 11), str(i), fill=(130, 230, 130))
        if i in marks:
            d.line([(x, 0), (x, c.height)], fill=(230, 200, 60))
    c.save(out)
    print(out, c.size, n, "帧")


if __name__ == "__main__":
    args = sys.argv[1:]
    if not args:
        print("用法: python dump_sprite_grid.py <精灵名> [输出路径] [列数] [缩放]")
        sys.exit(0)
    sprite = args[0]
    out = args[1] if len(args) > 1 else "output/_tmp/%s.png" % sprite
    cols = int(args[2]) if len(args) > 2 else 14
    sc = float(args[3]) if len(args) > 3 else 0.35
    os.makedirs(os.path.dirname(out) or ".", exist_ok=True)
    grid(sprite, out, cols, sc)
