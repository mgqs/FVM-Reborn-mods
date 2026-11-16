# -*- coding: utf-8 -*-
"""天空背景图.png（无云纯背景）与 天空8星.png（带云/星）的精确几何关系。

策略：只用两图都「无云无星」的结构区（左侧石柱带 x<370，顶部/底部）
做 scale + offset 的联合搜索，避免云层干扰。
"""
import os

import numpy as np
from PIL import Image

BASE = r'D:\FVM开发\game\FVM开发\res\美食大战老鼠bgm地图合集\地图素材（更新至龙渊除厄第2期）\游戏地图背景\09跨服\梦魇天空'


def rgb(name):
    return np.asarray(Image.open(os.path.join(BASE, name)).convert('RGB')).astype(np.float32)


bg = rgb('天空背景图.png')
st = rgb('天空8星.png')
print('bg', bg.shape, 'star', st.shape)

# 结构区：左侧石柱带（两图都无云）
ROI = (slice(0, 597), slice(0, 360))
print('ROI star mean', st[ROI].mean(), 'bg mean', bg[ROI].mean())

best = None
for s in np.arange(0.90, 1.12, 0.002):
    w = int(round(bg.shape[1] * s))
    h = int(round(bg.shape[0] * s))
    r = np.asarray(Image.fromarray(bg.astype(np.uint8)).resize((w, h), Image.LANCZOS)).astype(np.float32)
    H, W, _ = st.shape
    if h < H or w < W:
        # 需要 bg 缩放后至少覆盖 star
        pass
    # 在 [-40,40] 内搜偏移，比较 ROI 区
    for oy in range(-40, 41, 2):
        for ox in range(-40, 41, 2):
            # star(x,y) 对应缩放后 bg 的 (x+ox, y+oy)
            ys = np.arange(0, H, 4)
            xs = np.arange(0, 360, 4)
            Y, X = np.meshgrid(ys, xs, indexing='ij')
            ty = Y + oy
            tx = X + ox
            if ty.min() < 0 or tx.min() < 0 or ty.max() >= h or tx.max() >= w:
                continue
            diff = r[ty, tx] - st[Y, X]
            err = float((diff * diff).mean())
            if best is None or err < best[0]:
                best = (err, s, ox, oy, w, h)
print('coarse best err=%.2f scale=%.3f offset=(%d,%d) resized=%dx%d' % best)

err, s, ox, oy, w, h = best
for s2 in np.arange(s - 0.004, s + 0.004, 0.0005):
    w2 = int(round(bg.shape[1] * s2))
    h2 = int(round(bg.shape[0] * s2))
    r = np.asarray(Image.fromarray(bg.astype(np.uint8)).resize((w2, h2), Image.LANCZOS)).astype(np.float32)
    for oy2 in range(oy - 3, oy + 4):
        for ox2 in range(ox - 3, ox + 4):
            ys = np.arange(0, 597, 2)
            xs = np.arange(0, 360, 2)
            Y, X = np.meshgrid(ys, xs, indexing='ij')
            ty = Y + oy2
            tx = X + ox2
            if ty.min() < 0 or tx.min() < 0 or ty.max() >= h2 or tx.max() >= w2:
                continue
            diff = r[ty, tx] - st[Y, X]
            e = float((diff * diff).mean())
            if e < err:
                err, s, ox, oy, w, h = (e, s2, ox2, oy2, w2, h2)
print('fine best err=%.2f scale=%.4f offset=(%d,%d) resized=%dx%d' % (err, s, ox, oy, w, h))
print()
print('结论：把 天空背景图.png 缩放到 (%.4f) 后，(star 坐标 + offset) 采样 = bg 像素' % s)
print('  即 star_w=%d 时 bg 覆盖宽度 %d，只多出 %d px' % (w, 0, 0))
print('  bg 缩放到 1109 宽需要的系数 = %.6f' % (1109.0 / 1167.0))
