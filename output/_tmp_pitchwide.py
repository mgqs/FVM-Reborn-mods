import os, glob
import numpy as np
from PIL import Image

def frames(spr):
    d = os.path.join("sprites", spr)
    fs = sorted(glob.glob(os.path.join(d, "*.png")))
    return fs

def profiles(fp, band=0.6):
    im = Image.open(fp).convert("L")
    a = np.asarray(im).astype(np.float32)
    H, W = a.shape
    y0, y1 = int(H*(1-band)/2), int(H*(1+band)/2)
    x0, x1 = int(W*(1-band)/2), int(W*(1+band)/2)
    gx = np.abs(np.diff(a[y0:y1, :], axis=1)).mean(axis=0)
    gy = np.abs(np.diff(a[:, x0:x1], axis=0)).mean(axis=1)
    return gx, gy

def comb_top(prof, lo, hi, pstep=0.05, phstep=0.25, topn=6):
    n = len(prof)
    res = []
    for p in np.arange(lo, hi + 1e-9, pstep):
        best = (-1e9, 0.0)
        for ph in np.arange(0.0, p, phstep):
            idx = np.arange(ph, n - 1, p)
            if len(idx) < 5: continue
            on = np.clip(np.round(idx).astype(int), 0, n-2)
            mid = np.clip(np.round(idx + p*0.5).astype(int), 0, n-2)
            sc = float(prof[on].mean() - prof[mid].mean())
            if sc > best[0]: best = (sc, float(ph))
        res.append((best[0], float(p), best[1]))
    res.sort(reverse=True)
    # 去重：pitch 相距 < 6 只留分最高
    out = []
    for sc, p, ph in res:
        if all(abs(p - q[1]) > 6 for q in out): out.append((round(sc,2), round(p,2), round(ph,2)))
        if len(out) >= topn: break
    return out

for spr in ["spr_salad_island_land", "spr_mod_ancient_castle_0", "spr_mengyantiankong_0", "spr_zhuorediyu", "spr_shuihuozhijian_0", "spr_wuduyanjiusuo_0"]:
    fs = frames(spr)
    gx, gy = profiles(fs[0])
    print("==", spr, len(fs), "frames", Image.open(fs[0]).size)
    print("  X:", comb_top(gx, 40, 220))
    print("  Y:", comb_top(gy, 40, 220))
