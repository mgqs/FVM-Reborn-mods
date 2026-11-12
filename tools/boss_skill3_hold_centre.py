import os, re
import numpy as np
from PIL import Image

SPR = r"D:\gameProject\FVM-Reborn-mod\sprites\spr_honglonglong_skill_3"
t = open(os.path.join(SPR, "spr_honglonglong_skill_3.yy"), encoding="utf-8", errors="ignore").read()
fr, seen = [], set()
for i in re.findall(r'"%Name":"([0-9a-f\-]{36})"', t):
    p = os.path.join(SPR, i + ".png")
    if i not in seen and os.path.exists(p):
        seen.add(i)
        fr.append(p)

# SKILL3 播的是 image_index = floor(timer/5) mod 24，落地 tick 是 15*5 -> frame 15
# 之后到 24*5-1 之间播 frame 15..23
tot = np.zeros(2)
n = 0
for idx in range(15, 24):
    a = np.array(Image.open(fr[idx]).convert("RGBA"))[:, :, 3].astype(np.int16)
    ys, xs = np.nonzero(a > 16)
    w = a[ys, xs].astype(np.float64)
    c = np.array([(xs * w).sum() / w.sum(), (ys * w).sum() / w.sum()])
    tot += c
    n += 1
    print(f"frame {idx:2d}  wcentroid ({c[0]:.2f}, {c[1]:.2f})  px {len(xs)}")
print(f"mean over frames 15..23 = ({tot[0]/n:.2f}, {tot[1]/n:.2f})")
print(f"origin used by sprite = (177, 250)  -> world offset per 1.8 scale:")
print(f"  x {(tot[0]/n - 177)*1.8:+.1f}   y {(tot[1]/n - 250)*1.8:+.1f}")
