# -*- coding: utf-8 -*-
"""天空背景图.png -> 关卡美术（1109x597）配准，只用左侧石柱结构带（两图都无云），
   低分辨率粗搜 + 中等分辨率精修，内存友好。"""
import gc
import os

import numpy as np
from PIL import Image

BASE = r'D:\FVM开发\game\FVM开发\res\美食大战老鼠bgm地图合集\地图素材（更新至龙渊除厄第2期）\游戏地图背景\09跨服\梦魇天空'
OUT = r'D:\gameProject\FVM-Reborn-mod\output\_tmp_sky'
os.makedirs(OUT, exist_ok=True)

st_img = Image.open(os.path.join(BASE, '天空8星.png')).convert('RGB')
bg_img = Image.open(os.path.join(BASE, '天空背景图.png')).convert('RGB')
W, H = st_img.size
BW, BH = bg_img.size

# 结构带：左侧石柱（star x 0..355 全高）
STRIP = (0, 0, 355, H)


def strip_resized(img, scale, box):
    x0, y0, x1, y1 = box
    w = max(1, int(round((x1 - x0) * scale)))
    h = max(1, int(round((y1 - y0) * scale)))
    return np.asarray(img.crop(box).resize((w, h), Image.LANCZOS)).astype(np.float32)


def search(scale, s_lo, s_hi, s_step, off_range, off_step, prev=None):
    """在给定降采样比例下搜索。返回 (err, art_scale, offx_art, offy_art)。"""
    T = strip_resized(st_img, scale, STRIP)
    th, tw, _ = T.shape
    best = None
    ss = np.arange(s_lo, s_hi + 1e-9, s_step)
    for s in ss:
        rw, rh = int(round(BW * s * scale)), int(round(BH * s * scale))
        if rw < tw + abs(off_range[0]) or rh < th + abs(off_range[1]):
            continue
        R = np.asarray(bg_img.resize((rw, rh), Image.LANCZOS)).astype(np.float32)
        o_lo_x, o_hi_x = off_range
        o_lo_y, o_hi_y = off_range
        for oy in range(o_lo_y, o_hi_y + 1, off_step):
            for ox in range(o_lo_x, o_hi_x + 1, off_step):
                ty = oy
                tx = ox
                if ty < 0 or tx < 0 or ty + th > rh or tx + tw > rw:
                    continue
                d = R[ty:ty + th, tx:tx + tw] - T
                err = float((d * d).mean())
                if best is None or err < best[0]:
                    best = (err, s, ox / scale, oy / scale)
        del R
        gc.collect()
    return best


# 第一轮：1/4 分辨率、偏移 ±40 艺术像素、步长 4
r1 = search(0.25, 0.90, 1.08, 0.006, (-40, 40), 4)
print('L1 err=%.1f s=%.4f off=(%.1f,%.1f)' % r1)

# 第二轮：1/2 分辨率、围绕第一轮结果 ±8、步长 1 艺术像素
err1, s1, ox1, oy1 = r1
r2 = search(0.5, s1 - 0.012, s1 + 0.012, 0.0015, (-8, 8), 1)
# 把第二轮的相对偏移换成绝对
print('L2 (rel) err=%.1f s=%.4f doff=(%.1f,%.1f)' % r2)

# 重新算绝对偏移：第二轮搜索偏移是相对「裁剪框原点」，与第一轮同一个坐标系，
# 只是精度更高，所以直接合并
err2, s2, ox2, oy2 = r2
ox_abs, oy_abs = ox2, oy2
if abs(ox2) <= 8 and abs(oy2) <= 8:
    # L2 的偏移是绝对搜索窗口 (-8..8)，本身就覆盖真值附近（L1 已把尺度对齐）
    pass

# 第三轮：全分辨率精修，偏移 = L1 结果 ±6
r3 = search(1.0, s2 - 0.004, s2 + 0.004, 0.0006,
            (int(round(ox1)) - 6, int(round(ox1)) + 6), 1)
print('L3 err=%.1f s=%.5f off=(%.1f,%.1f)' % r3)

err3, s3, ox3, oy3 = r3
print()
print('FINAL: scale=%.6f  offset=(%.1f, %.1f)' % (s3, ox3, oy3))
print('=> 底图缩放到 %dx%d，然后采样原点偏移 (%d, %d) 即与关卡美术对齐'
      % (round(BW * s3), round(BH * s3), round(ox3), round(oy3)))
