# -*- coding: utf-8 -*-
"""生成任务看板「一键领取」按钮精灵 spr_task_claim_all_btn（3 帧 156x44）。

帧序：0 常态 / 1 按下悬停 / 2 禁用（无待领任务）。
底板不带文字 —— 「一键领取（N）」由对象 Draw 事件用 font_yuan 画，
这样待领条数变化、以后改文案都不用重生成精灵。

幂等：sprite 目录由 make_multi_frame_sprite.build 整体重建。
运行：python tools/make_task_claim_all_btn.py
"""
import os
import sys

from PIL import Image, ImageDraw

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
sys.path.insert(0, os.path.join(ROOT, 'tools'))
from make_multi_frame_sprite import build

W, H, R = 144, 48, 12
SS = 4          # 超采样倍数，缩回后圆角才平滑

# name, 上方色, 下方色, 描边色, 顶部高光透明度, 整体透明度
FRAMES = [
    ('normal',   (0xa9, 0xb6, 0xc4), (0x7c, 0x8b, 0x9a), (0x3d, 0x4a, 0x58), 70, 255),
    ('hover',    (0xc9, 0xd8, 0xe6), (0x94, 0xa5, 0xb6), (0x2f, 0x3b, 0x47), 95, 255),
    ('disabled', (0x6d, 0x7a, 0x87), (0x56, 0x62, 0x70), (0x33, 0x3d, 0x47), 40, 225),
]


def make_frame(top, bot, border, hi_a, alpha):
    w, h, r = W * SS, H * SS, R * SS
    mask = Image.new('L', (w, h), 0)
    ImageDraw.Draw(mask).rounded_rectangle([0, 0, w - 1, h - 1], radius=r, fill=255)

    grad = Image.new('RGBA', (w, h))
    gd = ImageDraw.Draw(grad)
    for y in range(h):
        t = y / float(h - 1)
        c = tuple(int(top[i] + (bot[i] - top[i]) * t) for i in range(3))
        gd.line([(0, y), (w, y)], fill=c + (255,))
    grad.putalpha(mask)

    hl_mask = Image.new('L', (w, h), 0)
    ImageDraw.Draw(hl_mask).rounded_rectangle(
        [3 * SS, 3 * SS, w - 1 - 3 * SS, int(h * 0.42)], radius=max(1, r - 2 * SS), fill=hi_a)
    hl = Image.new('RGBA', (w, h), (255, 255, 255, 0))
    hl.putalpha(hl_mask)

    bd = Image.new('RGBA', (w, h), (0, 0, 0, 0))
    ImageDraw.Draw(bd).rounded_rectangle([0, 0, w - 1, h - 1], radius=r,
                                         outline=border + (255,), width=3 * SS)

    im = Image.alpha_composite(grad, hl)
    im = Image.alpha_composite(im, bd)
    im = im.resize((W, H), Image.LANCZOS)
    if alpha < 255:
        im.putalpha(im.getchannel('A').point(lambda v: v * alpha // 255))
    return im


def main():
    out = os.path.join(ROOT, 'output', '_tmp', 'task_claim_all')
    os.makedirs(out, exist_ok=True)
    pngs = []
    for i, (name, top, bot, border, hi_a, alpha) in enumerate(FRAMES):
        p = os.path.join(out, '%d_%s.png' % (i, name))
        make_frame(top, bot, border, hi_a, alpha).save(p)
        pngs.append(p)
        print('帧已生成:', p)
    build('spr_task_claim_all_btn', pngs, W, H, W // 2, H // 2, 'UI')


if __name__ == '__main__':
    main()
