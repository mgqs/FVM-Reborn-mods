import glob, os, json
import numpy as np
from PIL import Image

def frame0(spr):
    return sorted(glob.glob(os.path.join("sprites", spr, "*.png")))[0]

def sqfit(prof, lo, hi):
    # 方波：prof 近似 alternation，周期 2p，找最优 p 与 phase
    n=len(prof); t=np.arange(n)
    p_ = prof - prof.mean()
    best=None
    for p in np.arange(lo, hi+1e-9, 0.05):
        w = 2*np.pi/(2*p)
        a = np.abs(np.dot(p_, np.cos(w*t)))**2 + np.abs(np.dot(p_, np.sin(w*t)))**2
        if best is None or a>best[0]:
            best=(a, float(p))
    p = best[1]
    w = 2*np.pi/(2*p)
    c = np.dot(p_, np.cos(w*t)); s = np.dot(p_, np.sin(w*t))
    ph = (np.arctan2(s, c)/w) % (2*p)
    # phase 定义：cos 峰（亮块中心）在 ph + k*2p
    return best[0]/n, p, ph

def report(spr, xa, xb, ya, yb):
    a = np.asarray(Image.open(frame0(spr)).convert("L")).astype(np.float32)
    H,W = a.shape
    xa,xb = int(W*xa), int(W*xb); ya,yb = int(H*ya), int(H*yb)
    sub = a[ya:yb, xa:xb]
    py = sub.mean(axis=1); px = sub.mean(axis=0)
    ry = sqfit(py, 20, 100); rx = sqfit(px, 20, 100)
    print("%-26s region x[%d:%d] y[%d:%d]  X: p=%.2f ph=%.2f (cell=%.2f)  Y: p=%.2f ph=%.2f (cell=%.2f)"%(
        spr, xa,xb,ya,yb, rx[1], rx[2], rx[1], ry[1], ry[2], ry[1]))
    return dict(px=rx[1], phx=rx[2], py=ry[1], phy=ry[2], W=W, H=H, region=[xa,xb,ya,yb])

cfg = {
 "spr_wuduyanjiusuo_0": (0.62, 0.85, 0.18, 0.85),
 "spr_zhuorediyu":      (0.30, 0.55, 0.30, 0.85),
 "spr_shuihuozhijian_0":(0.32, 0.50, 0.30, 0.85),
 "spr_shuihuozhijian_1":(0.32, 0.50, 0.30, 0.85),
 "spr_mengyantiankong_0":(0.30, 0.55, 0.30, 0.85),
 "spr_mod_ancient_castle_0":(0.45, 0.75, 0.25, 0.85),
 "spr_salad_island_land":(0.40, 0.70, 0.30, 0.85),
}
out={}
for spr,(xa,xb,ya,yb) in cfg.items():
    out[spr]=report(spr, xa,xb,ya,yb)
json.dump(out, open("output/_tmp_grid/sqfit.json","w"), indent=1, ensure_ascii=False, default=float)
