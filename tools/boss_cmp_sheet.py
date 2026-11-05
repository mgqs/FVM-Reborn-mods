# -*- coding: utf-8 -*-
"""把「原版精灵」与「新建精灵」逐帧并排拼图，用于核验动作节奏与分段是否错位。

    python tools/boss_cmp_sheet.py <key> <spr_key> [每行帧数]
例：
    python tools/boss_cmp_sheet.py jack fire_mouse
    python tools/boss_cmp_sheet.py mary move
"""
import os
import sys

from PIL import Image, ImageDraw

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(HERE)
sys.path.insert(0, HERE)
import zhuore_boss_build as B        # noqa: E402
import zhuore_boss_spec as S         # noqa: E402

ROW_H = 90          # 每个帧格的高度（等比缩放）
PAD = 4


def _grid(images, cols, tag, color):
    """把一串帧排成矩阵，返回 (canvas, 每格坐标)。"""
    cells = []
    for im in images:
        s = ROW_H / float(im.height) if im.height else 1.0
        cells.append(im.resize((max(1, int(im.width * s)), ROW_H), Image.LANCZOS))
    cw = max(c.width for c in cells) + PAD
    rows = (len(cells) + cols - 1) // cols
    w, h = cw * cols, (ROW_H + 16) * rows + 16
    cv = Image.new("RGBA", (w, h), (24, 24, 24, 255))
    d = ImageDraw.Draw(cv)
    d.text((2, 2), tag, fill=color)
    for i, c in enumerate(cells):
        r, k = divmod(i, cols)
        x = k * cw + (cw - c.width) // 2
        y = 16 + r * (ROW_H + 16)
        cv.paste(c, (x, y), c)
        d.text((k * cw + 1, y - 10), str(i), fill=(240, 210, 100))
    return cv


def main(key, spr_key, cols=13):
    boss = [m for m in S.MICE if m["key"] == key][0]
    item = [s for s in boss["sprites"] if s[0] == spr_key][0]
    new_name = B.sprite_name(boss["key"], spr_key)
    old_name = item[1]
    nm = B.sprite_meta(new_name)
    om = B.sprite_meta(old_name)

    news = [Image.open(os.path.join(B.SPR_DIR, new_name, f)).convert("RGBA")
            for f in nm["frames"]]
    olds = [Image.open(os.path.join(B.SPR_DIR, old_name, f)).convert("RGBA")
            for f in om["frames"]]

    top = _grid(olds, cols, "OLD %s (%d)" % (old_name, len(olds)), (150, 200, 255))
    bot = _grid(news, cols, "NEW %s (%d)" % (new_name, len(news)), (150, 225, 150))
    w = max(top.width, bot.width)
    out = Image.new("RGBA", (w, top.height + bot.height + 8), (24, 24, 24, 255))
    out.paste(top, (0, 0))
    out.paste(bot, (0, top.height + 8))
    os.makedirs(os.path.join(ROOT, "output/_tmp"), exist_ok=True)
    p = os.path.join(ROOT, "output/_tmp/cmp_%s_%s.png" % (key, spr_key))
    out.save(p)
    print(p, out.size)


if __name__ == "__main__":
    main(sys.argv[1], sys.argv[2],
         int(sys.argv[3]) if len(sys.argv) > 3 else 13)
