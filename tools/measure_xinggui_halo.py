# -*- coding: utf-8 -*-
r"""
量「星轨神」四角括号光环的**视觉框**尺寸（2026-11-13）

为什么需要这个脚本
------------------
`spr_xinggui_god_effect*` 是四角括号框（中间空），画布里除了括号本体，四角还各挂了一颗
星芒/光晕。所以 `bbox` 比玩家眼里的「框」大一圈，而且**形态越高撑得越多**：

    shape0  bbox 311x327  / 括号 271x287   （多 15%）
    shape1  bbox 325x334  / 括号 272x282   （多 19%）
    shape2  bbox 392x370  / 括号 276x311   （多 42%）

`obj_xinggui_god/Create_0` 如果按 bbox 缩放，就会「形态越高、框越小」（用户实测 4.2 / 5.0 / 5.2 格）。

取法
----
把常亮帧（`xg_hold_frame = 10`）摊成 alpha 掩码，统计每一行 / 每一列的不透明像素数，
**最多的一行 / 一列就是四角括号的臂所在位置**，臂的跨度即视觉框：

    vis_x0, vis_x1 = 像素数最多的那一列的…（左右两条竖臂）
    vis_y0, vis_y1 = 像素数最多的那一行的…（上下两条横臂）

用法
----
    python tools/measure_xinggui_halo.py
把输出填回 `objects/obj_xinggui_god/Create_0.gml` 的 `_vis_w / _vis_h` 表。
"""
import glob
import io
import json
import os
import re

import numpy as np
from PIL import Image

PROJ = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
HOLD = 10          # obj_xinggui_god/Create_0 里 xg_hold_frame 的值
ALPHA = 8


def frames(spr):
    yy = io.open(os.path.join(PROJ, 'sprites', spr, spr + '.yy'), encoding='utf-8').read()
    d = json.loads(re.sub(r',(\s*[}\]])', r'\1', yy))
    return [glob.glob(os.path.join(PROJ, 'sprites', spr, 'layers', f['name'], '*.png'))[0]
            for f in d['frames']]


def arm_spans(mask):
    """返回 (左右竖臂的 x 区间, 上下横臂的 y 区间)"""
    H, W = mask.shape
    col = mask.sum(axis=0)          # 每列像素数：竖臂所在列远大于其它列
    row = mask.sum(axis=1)          # 每行像素数：横臂所在行远大于其它行

    col_thr = col.max() * 0.75
    row_thr = row.max() * 0.75
    xs = np.where(col >= col_thr)[0]
    ys = np.where(row >= row_thr)[0]
    return (int(xs.min()), int(xs.max())), (int(ys.min()), int(ys.max()))


def main():
    print('%-26s %-6s %-18s %-18s %s' % ('sprite', 'hold', 'bbox', '括号视觉框', '按 bbox 的放大率'))
    for spr in ['spr_xinggui_god_effect', 'spr_xinggui_god_effect_1',
                'spr_xinggui_god_effect_2', 'spr_xinggui_god_effect_3']:
        fs = frames(spr)
        im = Image.open(fs[HOLD]).convert('RGBA')
        mask = np.asarray(im).astype(int)[:, :, 3] > ALPHA
        ys, xs = np.where(mask)
        bx = (int(xs.min()), int(ys.min()), int(xs.max()), int(ys.max()))
        (vx0, vx1), (vy0, vy1) = arm_spans(mask)
        bw, bh = bx[2] - bx[0] + 1, bx[3] - bx[1] + 1
        vw, vh = vx1 - vx0 + 1, vy1 - vy0 + 1
        print('%-26s %-6d %-18s %-18s %.0f%% / %.0f%%' % (
            spr, HOLD,
            '%dx%d' % (bw, bh),
            '%dx%d  (x%d..%d y%d..%d)' % (vw, vh, vx0, vx1, vy0, vy1),
            (bw / vw - 1) * 100, (bh / vh - 1) * 100))
        # 视觉框中心 vs 画布中心（Origin 在画布中心，差得多就要补偿位置）
        cx, cy = (vx0 + vx1) / 2, (vy0 + vy1) / 2
        ox, oy = im.width / 2, im.height / 2
        if abs(cx - ox) > 3 or abs(cy - oy) > 3:
            print('    ⚠ 视觉框中心 (%.1f,%.1f) 与画布中心 (%.1f,%.1f) 偏差较大' % (cx, cy, ox, oy))


if __name__ == '__main__':
    main()
