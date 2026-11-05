# -*- coding: utf-8 -*-
"""按规格把每只 BOSS 的每个精灵「每段的首帧」拼成矩阵图，用于肉眼确认分段。

    python tools/boss_seg_sheet.py <key>
"""
import os
import sys

from PIL import Image, ImageDraw

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(HERE)
sys.path.insert(0, HERE)
import zhuore_boss_build as B        # noqa: E402
import zhuore_boss_spec as S         # noqa: E402


def sheet(boss, out, sc=0.32):
    rows = []
    for item in boss["sprites"]:
        name = B.sprite_name(boss["key"], item[0])
        segs = item[3]
        starts, cur = [], 0
        for seg in segs:
            starts.append(cur)
            cur += seg[1]
        ims = []
        for idx in starts:
            im = B.frame_image(name, idx)
            ims.append((idx, im.resize((max(1, int(im.width * sc)),
                                        max(1, int(im.height * sc))))))
        rows.append((item[0], ims))

    cw = max(max(im.width for _, im in ims) for _, ims in rows)
    ch = max(max(im.height for _, im in ims) for _, ims in rows)
    cols = max(len(ims) for _, ims in rows)
    label_w = 150
    c = Image.new("RGBA", (label_w + cw * cols, (ch + 14) * len(rows)), (22, 22, 22, 255))
    d = ImageDraw.Draw(c)
    for r, (label, ims) in enumerate(rows):
        y = r * (ch + 14) + 12
        d.text((2, y + ch // 2 - 4), label, fill=(150, 225, 150))
        for k, (idx, im) in enumerate(ims):
            x = label_w + k * cw + (cw - im.width) // 2
            c.paste(im, (x, y), im)
            d.text((label_w + k * cw + 1, y - 10), str(idx), fill=(240, 210, 100))
    c.save(out)
    print(out, c.size)


if __name__ == "__main__":
    key = sys.argv[1]
    boss = [m for m in S.MICE if m["key"] == key][0]
    os.makedirs("output/_tmp", exist_ok=True)
    sheet(boss, "output/_tmp/seg_%s.png" % key)
