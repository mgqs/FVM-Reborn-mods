import os, glob, json
from PIL import Image
import numpy as np

def first_frame(dirname):
    pngs = sorted(glob.glob(os.path.join("sprites", dirname, "*.png")))
    return pngs[0] if pngs else None

def profiles(path):
    im = Image.open(path).convert("RGB")
    a = np.asarray(im).astype(np.float32)
    g = a.mean(axis=2)
    gx = np.abs(np.diff(g, axis=1)).mean(axis=0)   # length W-1
    gy = np.abs(np.diff(g, axis=0)).mean(axis=1)   # length H-1
    return g.shape, gx, gy

def dominant_pitch(sig, lo=30, hi=140):
    s = sig - sig.mean()
    ac = np.correlate(s, s, mode='full')[len(s)-1:]
    ac /= (ac[0] + 1e-9)
    lo = max(lo, 4)
    hi = min(hi, len(ac)-2)
    best = None
    for p in range(lo, hi):
        if ac[p] > ac[p-1] and ac[p] >= ac[p+1]:
            if best is None or ac[p] > ac[best]:
                best = p
    return best, (ac[best] if best else None)

for name in ["spr_wuduyanjiusuo_0","spr_zhuorediyu","spr_shuihuozhijian_0","spr_shuihuozhijian_1","spr_mengyantiankong_0","spr_mod_ancient_castle_0"]:
    p = first_frame(name)
    shape, gx, gy = profiles(p)
    px, ax = dominant_pitch(gx)
    py, ay = dominant_pitch(gy)
    print(f"{name:26s} size={shape[1]}x{shape[0]} pitchX={px}({ax:.2f}) pitchY={py}({ay:.2f})")
