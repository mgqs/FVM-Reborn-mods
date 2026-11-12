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

XOFF, YOFF = 177, 250
for idx in (16, 17, 18, 19, 20, 40, 41, 42, 43):
    im = Image.open(fr[idx]).convert("RGBA")
    arr = np.array(im)
    a = arr[:, :, 3].astype(np.int16)
    print(f"--- frame {idx}  size {im.size}")
    for th in (16, 64, 128, 200):
        ys, xs = np.nonzero(a > th)
        if len(xs) == 0:
            continue
        w = a[ys, xs].astype(np.float64)
        cw = (xs * w).sum() / w.sum(), (ys * w).sum() / w.sum()
        print(f"  th{th:3d}  bbox x{xs.min()}-{xs.max()} y{ys.min()}-{ys.max()}"
              f"  boxc ({(xs.min()+xs.max())/2:.1f},{(ys.min()+ys.max())/2:.1f})"
              f"  centroid ({xs.mean():.1f},{ys.mean():.1f})"
              f"  wcentroid ({cw[0]:.1f},{cw[1]:.1f})")
