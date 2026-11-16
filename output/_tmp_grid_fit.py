import os, glob
from PIL import Image
import numpy as np

def first_frame(name):
    pngs = sorted(glob.glob(os.path.join("sprites", name, "*.png")))
    return pngs[0]

def edge_profiles(path):
    im = Image.open(path).convert("RGB")
    a = np.asarray(im).astype(np.float32)
    g = a.mean(axis=2)
    gx = np.abs(np.diff(g, axis=1)).mean(axis=0)  # per-column vertical-edge strength
    gy = np.abs(np.diff(g, axis=0)).mean(axis=1)  # per-row horizontal-edge strength
    return g.shape, gx, gy

def fit(sig, pmin, pmax):
    sig = sig.astype(np.float64)
    n = len(sig)
    best = (-1, None, None)
    for p10 in range(int(pmin*10), int(pmax*10)+1):
        p = p10/10.0
        # phase search in 0.5 px steps
        for ph10 in range(0, int(p*10), 5):
            ph = ph10/10.0
            k = 0
            s = 0.0
            cnt = 0
            while True:
                idx = ph + k*p
                if idx >= n-1: break
                i0 = int(round(idx))
                s += max(sig[max(0,i0-1)], sig[i0], sig[min(n-1,i0+1)])
                cnt += 1
                k += 1
            if cnt >= 6:
                score = s/cnt
                if score > best[0]:
                    best = (score, p, ph)
    return best

for name in ["spr_wuduyanjiusuo_0","spr_zhuorediyu","spr_shuihuozhijian_0","spr_shuihuozhijian_1","spr_mengyantiankong_0","spr_mod_ancient_castle_0"]:
    p = first_frame(name)
    shape, gx, gy = edge_profiles(p)
    sx_score, px, phx = fit(gx, 50, 70)
    sy_score, py, phy = fit(gy, 55, 75)
    print(f"{name:26s} {shape[1]}x{shape[0]}  pitchX={px} phaseX={phx} score={sx_score:.2f} | pitchY={py} phaseY={phy} score={sy_score:.2f}")
