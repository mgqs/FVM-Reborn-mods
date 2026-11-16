# -*- coding: utf-8 -*-
"""生成「神器 / 宝石进化页」槽位标签精灵 spr_gear_evo_label（4 帧，同一画布）。

用户 2026-11-16 提供的原版美术（QQ 下载目录下的 138/160/162/164.png）：
    138.png  33×15  「武器」
    160.png  26×27  「进化」「凭证」两行
    162.png  26×13  「神器」
    164.png  25×12  「宝石」
四张尺寸不同，GMSprite 帧要对齐到同一画布才好用一个原点居中画，
所以先补透明边到 34×28（四张最大尺寸 × 取整）再交给 make_multi_frame_sprite.build()。

帧序（GML 里按这个下标取）：
    0 = 武器   1 = 进化凭证   2 = 神器   3 = 宝石

用法：python tools/make_gear_evo_label_sprite.py
"""
import os
import sys

from PIL import Image

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
sys.path.insert(0, os.path.join(ROOT, 'tools'))
from make_multi_frame_sprite import build  # noqa: E402

SRC_DIR = r'D:\ruanjian\QQ\QQ下载'
SRCS = ['138', '160', '162', '164']          # 帧序 = 下面 GML 里的下标
CANVAS_W, CANVAS_H = 34, 28                  # 四张里最大是 33×27
TMP = os.path.join(ROOT, 'output', '_tmp')

NAME = 'spr_gear_evo_label'


def pad_all():
    os.makedirs(TMP, exist_ok=True)
    out = []
    for i, n in enumerate(SRCS):
        p = os.path.join(SRC_DIR, n + '.png')
        im = Image.open(p).convert('RGBA')
        assert im.width <= CANVAS_W and im.height <= CANVAS_H, (n, im.size)
        canvas = Image.new('RGBA', (CANVAS_W, CANVAS_H), (0, 0, 0, 0))
        canvas.alpha_composite(im, ((CANVAS_W - im.width) // 2, (CANVAS_H - im.height) // 2))
        dst = os.path.join(TMP, 'gear_label_%d.png' % i)
        canvas.save(dst)
        print('补边:', n, im.size, '->', dst)
        out.append(dst)
    return out


if __name__ == '__main__':
    pngs = pad_all()
    build(NAME, pngs, CANVAS_W, CANVAS_H, CANVAS_W // 2, CANVAS_H // 2, 'UI', pdir='mod/Craft')
    print('完成：%s（4 帧：0=武器 1=进化凭证 2=神器 3=宝石）' % NAME)
