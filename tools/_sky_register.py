# -*- coding: utf-8 -*-
"""天空背景图.png -> 1109x597 关卡美术坐标的精确配准（半分辨率搜索，省内存）。"""
import gc
import os

import numpy as np
from PIL import Image

BASE = r'D:\FVM开发\game\FVM开发\res\美食大战老鼠bgm地图合集\地图素材（更新至龙渊除厄第2期）\游戏地图背景\09跨服\梦魇天空'
OUT = r'D:\gameProject\FVM-Reborn-mod\output\_tmp_sky'
os.makedirs(OUT, exist_ok=True)

st_img = Image.open(os.path.join(BASE, '天空8星.png')).convert('RGB')
st = np.asarray(st_img).astype(np.float32)
H, W, _ = st.shape

mx = st.max(2)
mn = st.min(2)
g = st[:, :, 1]
cloud = (mx > 150) & ((mx - mn) < 75) & (st[:, :, 2] > st[:, :, 0] - 15) & (st[:, :, 0] > 120)
green = (g > 120) & (g - st[:, :, 0] > 45) & (g - st[:, :, 2] > 20)
valid = ~(cloud | green)
del mx, mn, g, cloud, green
gc.collect()

# 半分辨率
st_h = np.asarray(st_img.resize((W // 2, H // 2), Image.LANCZOS)).astype(np.float32)
Hh, Wh = st_h.shape[:2]
valid_h = valid[::2, ::2][:Hh, :Wh]
ys = np.arange(0, Hh, 2)
xs = np.arange(0, Wh, 2)
SEL_Y, SEL_X = np.meshgrid(ys, xs, indexing='ij')
Wt = valid_h[SEL_Y, SEL_X].astype(np.float32)
T = st_h[SEL_Y, SEL_X]
print('search grid', T.shape, 'valid frac %.2f' % (Wt.mean()))

bg_small = Image.open(os.path.join(BASE, '天空背景图.png')).convert('RGB')
BW, BH = bg_small.size
print('bg', bg_small.size)

best = None
for s in np.arange(0.92, 1.02, 0.002):
    rw, rh = int(round(BW * s * 0.5)), int(round(BH * s * 0.5))
    r = np.asarray(bg_small.resize((rw, rh), Image.LANCZOS)).astype(np.float32) * 0.25
    for oy in range(-12, 13, 2):
        for ox in range(-12, 13, 2):
            ty = SEL_Y + oy
            tx = SEL_X + ox
            if ty.min() < 0 or tx.min() < 0 or ty.max() >= rh or tx.max() >= rw:
                continue
            d = r[ty, tx] - T
            err = float((d * d).sum(2).__mul__(Wt).sum() / max(Wt.sum(), 1))
            if best is None or err < best[0]:
                best = (err, s, ox * 2, oy * 2)
    del r
    gc.collect()
print('coarse  err=%.1f s=%.4f off=(%d,%d)' % best)

err, s0, ox0, oy0 = best
for s in np.arange(s0 - 0.004, s0 + 0.004, 0.0005):
    rw, rh = int(round(BW * s * 0.5)), int(round(BH * s * 0.5))
    r = np.asarray(bg_small.resize((rw, rh), Image.LANCZOS)).astype(np.float32) * 0.25
    for oy in range(oy0 // 2 - 3, oy0 // 2 + 4):
        for ox in range(ox0 // 2 - 3, ox0 // 2 + 4):
            ty = SEL_Y + oy
            tx = SEL_X + ox
            if ty.min() < 0 or tx.min() < 0 or ty.max() >= rh or tx.max() >= rw:
                continue
            d = r[ty, tx] - T
            e = float((d * d).sum(2).__mul__(Wt).sum() / max(Wt.sum(), 1))
            if e < err:
                err, s0, ox0, oy0 = e, s, ox * 2, oy * 2
    del r
    gc.collect()
print('fine    err=%.1f s=%.5f off=(%d,%d)' % (err, s0, ox0, oy0))

rw, rh = int(round(BW * s0)), int(round(BH * s0))
r = np.asarray(bg_small.resize((rw, rh), Image.LANCZOS)).astype(np.float32)
aligned = r[oy0:oy0 + H, ox0:ox0 + W]
print('aligned', aligned.shape)
Image.fromarray(aligned.astype(np.uint8)).save(os.path.join(OUT, 'base_registered.png'))

d = np.abs(aligned - st).max(2)
print('valid 区 |diff| 均值 %.2f 中位 %.2f 95%%分位 %.2f'
      % (d[valid].mean(), np.median(d[valid]), np.percentile(d[valid], 95)))

vis = np.zeros((H, W * 3 + 24, 3), np.uint8)
vis[:, :W] = st.astype(np.uint8)
vis[:, W + 12:W * 2 + 12] = aligned.astype(np.uint8)
vis[:, W * 2 + 24:] = np.clip(d * 4, 0, 255).astype(np.uint8)[:, :, None]
Image.fromarray(vis).save(os.path.join(OUT, 'register_check.png'))
print('已输出 base_registered.png / register_check.png')
