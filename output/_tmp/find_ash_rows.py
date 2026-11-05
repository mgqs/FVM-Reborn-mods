# -*- coding: utf-8 -*-
"""定位截图中绿色对勾所在的行，用于裁切「防爆」行。"""
from PIL import Image
import numpy as np

p = r"C:/Users/18203/.workbuddy/clipboard-images/clipboard-2026-11-05T07-16-31-519Z-87f77647.png"
im = Image.open(p).convert("RGB")
a = np.asarray(im).astype(int)
r, g, b = a[..., 0], a[..., 1], a[..., 2]

# 深绿对勾
green = (g > 70) & (g < 150) & (r < 110) & (b < 110) & (g - r > 25) & (g - b > 25)
cnt = green.sum(axis=1)
rows = [(y, int(c)) for y, c in enumerate(cnt) if c > 8]
print("高度", a.shape[0], "宽", a.shape[1])
# 合并连续行
groups = []
for y, c in rows:
    if groups and y - groups[-1][1] <= 3:
        groups[-1][1] = y
        groups[-1][2] = max(groups[-1][2], c)
    else:
        groups.append([y, y, c])
for g0 in groups:
    print("行带 y=%d..%d 峰值 %d 中点 %d" % (g0[0], g0[1], g0[2], (g0[0] + g0[1]) // 2))
