# -*- coding: utf-8 -*-
"""按 GML 里新写的坐标，把「神器进化」页在真实素材上静态合成一张，
用来在进游戏前核对：三个竖排按钮 / 两槽 / 箭头-结果-按钮 / 右侧列表 / 底部凭证架是否对齐。
只读 preview 导出的 assets，不改任何工程文件。"""
import os
from PIL import Image, ImageDraw, ImageFont

A = r"D:/gameProject/FVM-Reborn-mod/output/craft_evolution_preview/assets"
W, H = 1920, 1080
CX, CY = 960, 540
BG_S = 0.9
BG_L, BG_T = CX - 1844 * BG_S / 2, CY - 1166 * BG_S / 2


def sp(name):
    p = os.path.join(A, name)
    return Image.open(p).convert("RGBA") if os.path.exists(p) else None


def paste(canvas, im, cx, cy, w, h=None):
    if im is None:
        return
    if h is None:
        h = int(im.height * w / im.width)
    im2 = im.resize((max(1, int(w)), max(1, int(h))), Image.LANCZOS)
    canvas.alpha_composite(im2, (int(cx - im2.width / 2), int(cy - im2.height / 2)))


canvas = Image.new("RGBA", (W, H), (10, 20, 34, 255))
for n in ("bg_base.png", "bg_left.png", "bg_right.png", "bg_bar.png"):
    im = sp(n)
    if im:
        im2 = im.resize((int(im.width * BG_S), int(im.height * BG_S)), Image.LANCZOS)
        canvas.alpha_composite(im2, (int(BG_L), int(BG_T)))

font = ImageFont.truetype("C:/Windows/Fonts/msyhbd.ttc", 24)
font_s = ImageFont.truetype("C:/Windows/Fonts/msyhbd.ttc", 12)
d = ImageDraw.Draw(canvas)

# ── 三个竖排按钮：x-660，y-80 / +80 / +240，82.8x151.2 ──
labels = [("金卡", "进化"), ("神器", "进化"), ("宝石", "进化")]
for i, (l1, l2) in enumerate(labels):
    cx = CX - 660
    cy = [CY - 80, CY + 80, CY + 240][i]
    plate = sp("btnsel_1.png" if i == 1 else "btnsel_0.png")
    paste(canvas, plate, cx, cy, 82.8, 151.2)
    col = (106, 63, 24) if i == 1 else (253, 243, 221)
    for row, txt in enumerate((l1, l2)):
        for col_i, ch in enumerate(txt):
            px = cx + (col_i - 0.5) * 16.5 * 1.8
            py = cy + (row - 0.5) * 21 * 1.8 - 6
            d.text((px, py), ch, font=font, fill=col, anchor="mm", stroke_width=2,
                   stroke_fill=(255, 243, 221) if i == 1 else (74, 42, 18))

# ── 两个槽 + 箭头 + 结果 + 按钮 ──
paste(canvas, sp("slot_card.png"), CX - 455, CY - 40, 104.4, 122.4)
paste(canvas, sp("poseidon_dart_gun_icon.png"), CX - 455, CY - 40, 78)
paste(canvas, sp("slot_prop.png"), CX - 155, CY - 40 + 9, 104, 104)
cb = sp("credit_bg.png")
paste(canvas, cb, CX - 155, CY - 40, 84)
paste(canvas, sp("zeus_bolt_icon.png"), CX - 155, CY - 40, 84 * 0.62)
paste(canvas, sp("arrow.png"), CX - 305, CY + 34, 34 * 1.8)
paste(canvas, sp("slot_result.png"), CX - 305, CY + 118, 104.4, 122.4)
paste(canvas, sp("zeus_bolt_icon.png"), CX - 305, CY + 118, 78)
paste(canvas, sp("btn_0.png"), CX - 305, CY + 216, 145.8, 75.6)

# ── 右侧列表：x+196 / y-321，7 列 84x96 ──
weapons = ["poseidon_dart_gun", "zeus_bolt", "gods_shield", "master_shield",
           "death_scythe", "hades_scythe", "aladdin_lamp"]
for i, wid in enumerate(weapons):
    gx = CX + 196 + (i % 7) * 84
    gy = CY - 321 + (i // 7) * 96
    paste(canvas, sp(wid + "_icon.png"), gx, gy - 4, 62)
    d.text((gx, gy + 30), "", font=font_s, anchor="mm")

# ── 底部凭证架：x-797 / y+409，10 格 91.4 宽 87 高 ──
BX, BY, BW, BH = CX - 797, CY + 411, 914, 83
pitch = BW / 10
cellw = pitch - 3
for i in range(10):
    x1 = BX + i * pitch
    d.rounded_rectangle([x1, BY, x1 + cellw, BY + BH], radius=int(4 * 1.8),
                        fill=(9, 58, 102), outline=(0, 26, 52), width=3)
credits = ["zeus_bolt", "star_wand", "master_shield", "rose_shield", "hades_scythe",
           "aladdin_lamp", "zeus_bolt", "star_wand", "master_shield", "rose_shield"]
for i, cid in enumerate(credits):
    ccx = BX + i * pitch + cellw * 0.5
    ccy = BY + BH * 0.47
    paste(canvas, cb, ccx, ccy, cellw * 0.74)
    paste(canvas, sp(cid + "_icon.png"), ccx, ccy, cellw * 0.74 * 0.62)
    d.text((ccx + cellw * 0.5 - 6, BY + BH - 6), "1" if i < 6 else "0",
           font=font_s, fill=(255, 255, 255), anchor="rd", stroke_width=2, stroke_fill=(0, 0, 0))

canvas.convert("RGB").save(r"D:/gameProject/FVM-Reborn-mod/output/_mock_gear.png")
print("ok")
