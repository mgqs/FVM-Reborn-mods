# -*- coding: utf-8 -*-
"""生成变异战神血条小图标 spr_infected_zhanshen_icon（48x40，原点居中）。

血条 obj_boss_hpbar/Draw_0 里 icon_height = sprite_height * 1.8，
图标精灵必须和同类一样是 48x40（见 spr_mario_mouse_icon / spr_arno_icon …）。
直接把 282x238 的 idle 帧登记成 icon 会把血条撑到屏幕外。

用法：python tools/make_inf_zhanshen_icon.py
"""
import os
import sys

from PIL import Image, ImageFilter

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
sys.path.insert(0, os.path.join(ROOT, "tools"))
from inf_zhanshen_repair import SPRITES, sprite_meta  # noqa: E402
from make_multi_frame_sprite import build  # noqa: E402

ICON = "spr_infected_zhanshen_icon"
SRC_SPRITE = "spr_infected_zhanshen_idle"
W, H = 48, 40

src_name = SRC_SPRITE
_, _, _, frames = sprite_meta(src_name)
src = Image.open(os.path.join(SPRITES, src_name, frames[0] + ".png")).convert("RGBA")
box = src.getbbox()
art = src.crop(box)

pad_x, pad_y = 2, 2
scale = min((W - pad_x * 2) / art.width, (H - pad_y * 2) / art.height)
size = (max(1, round(art.width * scale)), max(1, round(art.height * scale)))
art = art.resize(size, Image.LANCZOS)
art = art.filter(ImageFilter.UnsharpMask(radius=1.0, percent=140, threshold=0))

canvas = Image.new("RGBA", (W, H), (0, 0, 0, 0))
canvas.alpha_composite(art, ((W - size[0]) // 2, H - pad_y - size[1]))

out_dir = os.path.join(ROOT, "output", "_tmp", "icon_src")
os.makedirs(out_dir, exist_ok=True)
png = os.path.join(out_dir, "1.png")
canvas.save(png)
print("图标源图:", png, "内容框", box, "缩放后", size)

build(ICON, [png], W, H, W // 2, H // 2, "enemy_delicious")
print("完成:", ICON)
