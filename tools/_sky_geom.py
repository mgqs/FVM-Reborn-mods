# -*- coding: utf-8 -*-
"""确认 天空背景图.png 与 天空N星.png 是否同尺度裁剪关系（NCC 匹配无云的石柱区）。"""
import os
import numpy as np
from PIL import Image

BASE = r'D:\FVM开发\game\FVM开发\res\美食大战老鼠bgm地图合集\地图素材（更新至龙渊除厄第2期）\游戏地图背景\09跨服\梦魇天空'


def arr(name):
    return np.asarray(Image.open(os.path.join(BASE, name)).convert('RGB')).astype(np.float32)


bg = arr('天空背景图.png')
st = arr('天空8星.png')
print('bg', bg.shape, 'star', st.shape)


def ncc_best(big, tpl):
    """暴力 NCC，tpl 在 big 内滑窗（1:1 尺度）。"""
    th, tw, _ = tpl.shape
    t = tpl - tpl.mean()
    tn = np.sqrt((t * t).sum())
    best = (-2, 0, 0)
    H, W, _ = big.shape
    for oy in range(0, H - th + 1):
        for ox in range(0, W - tw + 1):
            w = big[oy:oy + th, ox:ox + tw]
            v = w - w.mean()
            vn = np.sqrt((v * v).sum())
            if vn < 1e-6:
                continue
            s = float((t * v).sum() / (tn * vn))
            if s > best[0]:
                best = (s, ox, oy)
    return best


# 取 8 星图左侧石柱区的一块（无云、无绿星）：x 40..240, y 240..440
tpl = st[240:440, 40:240]
print('tpl from star @ (40,240) size', tpl.shape)
score, ox, oy = ncc_best(bg, tpl)
print('match in bg: score=%.4f  offset=(%d,%d)  => star_origin_in_bg=(%d,%d)' % (score, ox, oy, ox - 40, oy - 240))

# 取右侧石柱区：x 950..1080, y 380..560
tpl2 = st[380:560, 950:1080]
score2, ox2, oy2 = ncc_best(bg, tpl2)
print('match2: score=%.4f  star_origin_in_bg=(%d,%d)' % (score2, ox2 - 950, oy2 - 380))

# 取顶部区域：x 600..800, y 5..90
tpl3 = st[5:90, 600:800]
score3, ox3, oy3 = ncc_best(bg, tpl3)
print('match3: score=%.4f  star_origin_in_bg=(%d,%d)' % (score3, ox3 - 600, oy3 - 5))
