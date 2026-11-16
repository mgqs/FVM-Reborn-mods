# -*- coding: utf-8 -*-
"""变异绿巨人技能1：修复前 vs 修复后 帧对照图。

数据源：
  修复前 = output/_tmp/bak_hulk_s1/<精灵>/（重建前备份）
  修复后 = sprites/<精灵>/（当前）
"""
import json
import os
import re

from PIL import Image, ImageDraw, ImageFont

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
BAK = os.path.join(ROOT, "output", "_tmp", "bak_hulk_s1")
OUT = os.path.join(ROOT, "output", "kf_wd_hulk_skill1_fix.png")

W, LABEL_W, PAD = 1680, 392, 16
CHUNK = 13          # 每行最多几张缩略图
TH = 72             # 缩略图高度
BG = (247, 249, 252)
INK = (28, 32, 44)
MUT = (108, 116, 132)
OK = (18, 118, 60)
BAD = (192, 88, 24)
SEP = (216, 221, 231)


def load_yy(p):
    s = open(p, encoding="utf-8-sig").read()
    s = re.sub(r",(\s*[}\]])", r"\1", s)
    return json.loads(s)


def frames_of(sprite, base):
    d = os.path.join(base, sprite)
    y = load_yy(os.path.join(d, sprite + ".yy"))
    return [os.path.join(d, f["name"] + ".png") for f in y["frames"]]


def font(sz, bold=False):
    for name in (("msyhbd.ttc" if bold else "msyh.ttc"), "simhei.ttf"):
        for root in (r"C:\Windows\Fonts", "/usr/share/fonts"):
            p = os.path.join(root, name)
            if os.path.exists(p):
                try:
                    return ImageFont.truetype(p, sz)
                except OSError:
                    pass
    return ImageFont.load_default()


def wrap(text, font_obj, max_w, draw):
    lines = []
    for seg in text.split("\n"):
        cur = ""
        for ch in seg:
            if draw.textlength(cur + ch, font=font_obj) > max_w:
                lines.append(cur)
                cur = ch
            else:
                cur += ch
        lines.append(cur)
    return lines


ROWS = [
    ("修复前", "spr_kf_wd_hulk_skill_1", BAK,
     "14 帧，取自跳跃段 #114 #128 …\n对齐代价 1.19（应为 0.00）", BAD),
    ("修复后", "spr_kf_wd_hulk_skill_1", os.path.join(ROOT, "sprites"),
     "8 帧 = 滚球 4 + 受伤滚球 4\nSWF #106~#109 / #316~#319", OK),
    ("修复前", "spr_kf_wd_hulk_skill_1_ready", BAK,
     "16 帧拼凑，对齐代价 6.06", BAD),
    ("修复后", "spr_kf_wd_hulk_skill_1_ready", os.path.join(ROOT, "sprites"),
     "22 帧 = 变滚球 11 + 受伤变滚球 11\nSWF #95~#105 / #305~#315", OK),
]


def main():
    rows = []
    avail = W - LABEL_W - PAD * 2 - 8
    per_row = min(CHUNK, 13)
    tw, th, step = 0, TH, 0
    for tag, spr, base, note, color in ROWS:
        paths = frames_of(spr, base)
        im = Image.open(paths[0])
        scale = TH / im.height
        tw, th = int(im.width * scale), TH
        step = tw + 6
        if step * per_row > avail:
            step = avail / per_row
            tw = int(step - 6)
            th = int(tw / im.width * im.height)
        nlines = (len(paths) + per_row - 1) // per_row
        rows.append((tag, spr, note, color, paths, tw, th, step, nlines))

    head_h = 96
    total = head_h + sum(r[6] * r[8] + 56 for r in rows) + PAD * 2
    canvas = Image.new("RGB", (W, total), BG)
    d = ImageDraw.Draw(canvas)
    f_note = font(13)

    d.text((PAD + 4, 20), "变异绿巨人 · 技能1（滚动）修复对照", font=font(30, True), fill=INK)
    d.text((PAD + 4, 60),
           "SWF 源：变异绿巨人.swf → DefineSprite_190（480 帧 / 532×454），分段依据 FrameLabel",
           font=font(15), fill=MUT)

    y = head_h
    for tag, spr, note, color, paths, tw, th, step, nlines in rows:
        block_h = th * nlines + 24
        d.line([(PAD, y), (W - PAD, y)], fill=SEP)
        d.text((PAD + 4, y + 8), tag, font=font(19, True), fill=color)
        d.text((PAD + 4, y + 34), spr.replace("spr_kf_wd_hulk_", ""), font=font(15), fill=INK)
        yy = y + 56
        for ln in wrap(note, f_note, LABEL_W - 24, d):
            d.text((PAD + 4, yy), ln, font=f_note, fill=MUT)
            yy += 19

        for i, p in enumerate(paths):
            im = Image.open(p).convert("RGBA")
            bg = Image.new("RGBA", im.size, (238, 242, 248, 255))
            bg.alpha_composite(im)
            col, row = i % per_row, i // per_row
            x = LABEL_W + col * step
            canvas.paste(bg.convert("RGB").resize((tw, th), Image.LANCZOS),
                         (int(x), y + 4 + row * th))
            d.text((int(x) + 2, y + row * th + th - 12), str(i), font=font(10), fill=(150, 156, 170))
        y += block_h + 32

    canvas.save(OUT)
    print("->", OUT, canvas.size)


if __name__ == "__main__":
    main()
