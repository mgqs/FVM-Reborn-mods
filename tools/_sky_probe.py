# -*- coding: utf-8 -*-
"""梦魇天空素材关系探测：天空背景图.png 与 天空N星.png 的缩放/偏移关系。"""
import os
import numpy as np
from PIL import Image

BASE = r'D:\FVM开发\game\FVM开发\res\美食大战老鼠bgm地图合集\地图素材（更新至龙渊除厄第2期）\游戏地图背景\09跨服\梦魇天空'
OUT = r'D:\gameProject\FVM-Reborn-mod\output\_tmp_sky'


def load_gray(name):
    return np.asarray(Image.open(os.path.join(BASE, name)).convert('L')).astype(np.float32)


def grad(a):
    gy, gx = np.gradient(a)
    return np.hypot(gx, gy)


def phase_corr(A, B):
    FA = np.fft.rfft2(A - A.mean())
    FB = np.fft.rfft2(B - B.mean())
    R = FA * np.conj(FB)
    R /= (np.abs(R) + 1e-8)
    c = np.fft.irfft2(R, s=A.shape)
    dy, dx = np.unravel_index(np.argmax(c), c.shape)
    if dy > A.shape[0] // 2:
        dy -= A.shape[0]
    if dx > A.shape[1] // 2:
        dx -= A.shape[1]
    return dy, dx, float(c.max())


base = load_gray('天空背景图.png')
star = load_gray('天空8星.png')
print('base', base.shape, 'star', star.shape)

best = None
for s in np.arange(0.90, 1.08, 0.005):
    w = int(round(base.shape[1] * s))
    h = int(round(base.shape[0] * s))
    r = np.asarray(Image.fromarray(base).resize((w, h), Image.LANCZOS)).astype(np.float32)
    H, W = star.shape
    canvas = np.zeros((H, W), np.float32)
    ox = (w - W) // 2
    oy = (h - H) // 2
    sx0, sy0 = max(0, ox), max(0, oy)
    canvas[max(0, -oy):max(0, -oy) + min(H, h), max(0, -ox):max(0, -ox) + min(W, w)] = \
        r[max(0, oy):max(0, oy) + min(H, h), max(0, ox):max(0, ox) + min(W, w)]
    dy, dx, peak = phase_corr(grad(canvas), grad(star))
    if best is None or peak > best[0]:
        best = (peak, s, dx, dy, ox, oy)
print('best scale/offset:', best)

# 直接用缩放后的图与 star 求一次相位，输出叠加目检图
peak, s, dx, dy, ox, oy = best
w = int(round(base.shape[1] * s))
h = int(round(base.shape[0] * s))
r = np.asarray(Image.fromarray(base).resize((w, h), Image.LANCZOS)).astype(np.float32)
H, W = star.shape
canvas = np.zeros((H, W), np.float32)
canvas[max(0, -oy):max(0, -oy) + min(H, h), max(0, -ox):max(0, -ox) + min(W, w)] = \
    r[max(0, oy):max(0, oy) + min(H, h), max(0, ox):max(0, ox) + min(W, w)]
shifted = np.roll(canvas, (dy, dx), axis=(0, 1))
img = np.zeros((H, W, 3), np.uint8)
img[:, :, 0] = np.clip(shifted, 0, 255)
img[:, :, 1] = np.clip(star, 0, 255)
Image.fromarray(img).save(os.path.join(OUT, 'overlay_bg_vs_8star.png'))
print('overlay saved')
