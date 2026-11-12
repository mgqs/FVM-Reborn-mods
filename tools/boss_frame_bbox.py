import os, re
import numpy as np
from PIL import Image

ROOT = r"D:\gameProject\FVM-Reborn-mod"
SPR  = os.path.join(ROOT, r"sprites\spr_honglonglong_skill_3")

t = open(os.path.join(SPR, "spr_honglonglong_skill_3.yy"), encoding="utf-8", errors="ignore").read()
frames, seen = [], set()
for i in re.findall(r'"%Name":"([0-9a-f\-]{36})"', t):
    p = os.path.join(SPR, i + ".png")
    if i not in seen and os.path.exists(p):
        seen.add(i)
        frames.append(p)

XORIG, YORIG = 177, 250
print("total frames", len(frames))

for idx in list(range(11, 21)) + list(range(35, 45)):
    if idx >= len(frames):
        continue
    im = Image.open(frames[idx]).convert("RGBA")
    a = np.array(im)[:, :, 3].astype(np.int16)
    ys, xs = np.nonzero(a > 16)
    if len(xs) == 0:
        print(f"frame {idx:2d}  empty")
        continue
    cx, cy = xs.mean(), ys.mean()
    l, r, tp, bt = xs.min(), xs.max(), ys.min(), ys.max()
    boxcx, boxcy = (l + r) / 2.0, (tp + bt) / 2.0
    # world offset from boss (x,y) when image_scale = 1.8
    wcx = (boxcx - XORIG) * 1.8
    wcy = (boxcy - YORIG) * 1.8
    print(f"frame {idx:2d}  bbox x{l}-{r} y{tp}-{bt}  boxcentre ({boxcx:.1f},{boxcy:.1f})"
          f"  centroid ({cx:.1f},{cy:.1f})  world offset ({wcx:+.1f},{wcy:+.1f})")
