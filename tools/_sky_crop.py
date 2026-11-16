# -*- coding: utf-8 -*-
"""裁切查看 天空背景图.png 与 天空8星.png 的关键区域。"""
import os

from PIL import Image

BASE = r'D:\FVM开发\game\FVM开发\res\美食大战老鼠bgm地图合集\地图素材（更新至龙渊除厄第2期）\游戏地图背景\09跨服\梦魇天空'
OUT = r'D:\gameProject\FVM-Reborn-mod\output\_tmp_sky'
os.makedirs(OUT, exist_ok=True)

bg = Image.open(os.path.join(BASE, '天空背景图.png')).convert('RGB')
st = Image.open(os.path.join(BASE, '天空8星.png')).convert('RGB')

# 左侧两列 game x 695..909 -> art: game = 13.2 + art*1.7833
def g2a_x(gx, sx=1.7833, ox=13.2):
    return (gx - ox) / sx


def g2a_y(gy, sy=1.78, oy=12.39):
    return (gy - oy) / sy


print('col0 left  art x = %.1f' % g2a_x(695))
print('col2 left  art x = %.1f' % g2a_x(909))
print('row0 top   art y = %.1f' % g2a_y(228))
print('row7 bot   art y = %.1f' % g2a_y(228 + 7 * 116))

# bg 与 star 的对应：star = bg 缩放 0.964 后偏移 (15,1) 采样
# 即 bg(x,y) ≈ star(x/0.964 + ...) —— 直接用 star 坐标系裁切两图对照
box_star = (330, 60, 700, 600)
st.crop(box_star).save(os.path.join(OUT, 'crop_star_left.png'))
print('crop_star_left', st.crop(box_star).size)

# bg 同区域：star 坐标 (x,y) -> bg 坐标 ((x+15)/0.964, (y+1)/0.964)
f = 1 / 0.964
box_bg = tuple(int(v * f) for v in (box_star[0] + 15, box_star[1] + 1, box_star[2] + 15, box_star[3] + 1))
bg.crop(box_bg).save(os.path.join(OUT, 'crop_bg_left.png'))
print('crop_bg_left', bg.crop(box_bg).size)
