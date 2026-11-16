# -*- coding: utf-8 -*-
""" identificar 工程 8 张梦魇天空 sprite 对应哪张源素材，并量化改动量。"""
import glob
import hashlib
import os

import numpy as np
from PIL import Image

BASE = r'D:\FVM开发\game\FVM开发\res\美食大战老鼠bgm地图合集\地图素材（更新至龙渊除厄第2期）\游戏地图背景\09跨服\梦魇天空'
ROOT = r'D:\gameProject\FVM-Reborn-mod'

srcs = {}
for p in sorted(glob.glob(os.path.join(BASE, '*.png'))):
    srcs[os.path.basename(p)] = np.asarray(Image.open(p).convert('RGB')).astype(np.int16)

for i in range(8):
    p = glob.glob(os.path.join(ROOT, 'sprites', 'spr_mengyantiankong_%d' % i, '*.png'))[0]
    im = Image.open(p).convert('RGB')
    a = np.asarray(im).astype(np.int16)
    line = 'spr_%d %s' % (i, im.size)
    for name, b in srcs.items():
        if b.shape != a.shape:
            line += ' | %s size-diff' % name
            continue
        d = np.abs(a - b).mean()
        # 差异像素比例
        diffmask = (np.abs(a - b).max(2) > 12)
        line += ' | %s meanDiff=%.2f diffPx=%.1f%%' % (name, d, 100.0 * diffmask.mean())
    print(line)
