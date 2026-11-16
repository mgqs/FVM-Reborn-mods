# -*- coding: utf-8 -*-
"""天空背景图.png -> 关卡美术（1109x597）配准。

底图只比关卡美术大约 1.4%，所以用 FFT 归一化互相关（NCC）在多个缩放候选上
一次性求出全部偏移，再全分辨率复算 MSE 精选。
模板取左侧石柱带（x 0..360，两图都无云、无绿星），避免云层干扰。
"""
import gc
import os

import numpy as np
from PIL import Image

BASE = r'D:\FVM开发\game\FVM开发\res\美食大战老鼠bgm地图合集\地图素材（更新至龙渊除厄第2期）\游戏地图背景\09跨服\梦魇天空'
OUT = r'D:\gameProject\FVM-Reborn-mod\output\_tmp_sky'
os.makedirs(OUT, exist_ok=True)

st_img = Image.open(os.path.join(BASE, '天空8星.png')).convert('RGB')
bg_img = Image.open(os.path.join(BASE, '天空背景图.png')).convert('RGB')
SW, SH = st_img.size
BW, BH = bg_img.size
print('star', st_img.size, 'bg', bg_img.size)

STRIP_W = 360
strip = np.asarray(st_img.crop((0, 0, STRIP_W, SH)).convert('L')).astype(np.float64)


def box_sums(A, th, tw):
    """返回每个 (oy,ox) 位置 th×tw 窗口的和，形状 (H-th+1, W-tw+1)。"""
    S = np.zeros((A.shape[0] + 1, A.shape[1] + 1))
    S[1:, 1:] = A.cumsum(0).cumsum(1)
    return S[th:, tw:] - S[:-th, tw:] - S[th:, :-tw] + S[:-th, :-tw]


def ncc_surface(I, T):
    """I 大图、T 模板（均灰度 float64）。返回 (ncc, oxs, oys)。"""
    th, tw = T.shape
    H, W = I.shape
    if H < th or W < tw:
        return None
    Tm = T - T.mean()
    Tn = np.sqrt((Tm * Tm).sum())
    pad = np.zeros((H, W))
    pad[:th, :tw] = Tm[::-1, ::-1]        # 相关 = 卷积（核翻转）
    F = np.fft.rfft2(I, s=(H, W)) * np.fft.rfft2(pad, s=(H, W))
    corr = np.fft.irfft2(F, s=(H, W))
    corr = corr[th - 1:, tw - 1:]          # 有效区 (H-th+1, W-tw+1)

    sI = box_sums(I, th, tw)
    sI2 = box_sums(I * I, th, tw)
    n = th * tw
    varI = sI2 - sI * sI / n
    varI = np.maximum(varI, 1e-6)
    ncc = (corr - sI * T.sum() / n) / (np.sqrt(varI) * Tn + 1e-9)
    return ncc


results = []
for s in np.arange(0.930, 1.020, 0.002):
    rw, rh = int(round(BW * s)), int(round(BH * s))
    if rh < SH or rw < STRIP_W:
        continue
    I = np.asarray(bg_img.resize((rw, rh), Image.LANCZOS).convert('L')).astype(np.float64)
    surf = ncc_surface(I, strip)
    if surf is None:
        del I
        gc.collect()
        continue
    oy, ox = np.unravel_index(np.argmax(surf), surf.shape)
    results.append((float(surf[oy, ox]), float(s), int(ox), int(oy)))
    del I, surf
    gc.collect()

results.sort(reverse=True)
print('top 8 (ncc, scale, ox, oy):')
for r in results[:8]:
    print('   %.4f  s=%.3f  off=(%d,%d)' % r)

# 全分辨率复算 MSE 精选前 8 名 ±2 偏移
best = None
for ncc, s, cx, cy in results[:8]:
    rw, rh = int(round(BW * s)), int(round(BH * s))
    I = np.asarray(bg_img.resize((rw, rh), Image.LANCZOS)).astype(np.float32)
    T = np.asarray(st_img.crop((0, 0, STRIP_W, SH))).astype(np.float32)
    for oy in range(max(0, cy - 2), min(rh - SH, cy + 2) + 1):
        for ox in range(max(0, cx - 2), min(rw - STRIP_W, cx + 2) + 1):
            d = I[oy:oy + SH, ox:ox + STRIP_W] - T
            err = float((d * d).mean())
            if best is None or err < best[0]:
                best = (err, s, ox, oy, ncc)
    del I, T
    gc.collect()

err, s_best, ox_best, oy_best, ncc_best = best
print()
print('BEST strip-MSE=%.2f  scale=%.4f  offset=(%d,%d)  (ncc=%.4f)'
      % (err, s_best, ox_best, oy_best, ncc_best))
print('=> 底图缩放到 %dx%d 后，从 (%d,%d) 采样 = 关卡美术坐标'
      % (round(BW * s_best), round(BH * s_best), ox_best, oy_best))

rw, rh = int(round(BW * s_best)), int(round(BH * s_best))
I = np.asarray(bg_img.resize((rw, rh), Image.LANCZOS)).astype(np.float32)
aligned = I[oy_best:oy_best + SH, ox_best:ox_best + SW]
if aligned.shape[:2] != (SH, SW):
    pad = np.zeros((SH, SW, 3), np.float32)
    pad[:aligned.shape[0], :aligned.shape[1]] = aligned
    aligned = pad
Image.fromarray(aligned.astype(np.uint8)).save(os.path.join(OUT, 'base_registered.png'))

d = np.abs(aligned - np.asarray(st_img).astype(np.float32)).max(2)
print('全图 |diff| 中位 %.2f  90%%分位 %.2f' % (np.median(d), np.percentile(d, 90)))
