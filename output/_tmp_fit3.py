import glob, os, json
import numpy as np
from PIL import Image

def frame0(spr):
    fs = sorted(glob.glob(os.path.join("sprites", spr, "*.png")))
    return fs[0] if fs else None

def prof(spr, axis, ywin=(0.15,0.85), xwin=(0.15,0.85)):
    fp = frame0(spr)
    a = np.asarray(Image.open(fp).convert("L")).astype(np.float32)
    H,W = a.shape
    if axis=="x":
        p = np.abs(np.diff(a[int(H*ywin[0]):int(H*ywin[1]), :], axis=1)).mean(axis=0)
    else:
        p = np.abs(np.diff(a[:, int(W*xwin[0]):int(W*xwin[1])], axis=0)).mean(axis=1)
    m = p.mean(); s = p.std()+1e-6
    return (p-m)/s

def hist_fit(p, lo=40.0, hi=80.0, step=0.02, binw=0.2):
    n = len(p); idx = np.arange(1, n-1, dtype=np.float64)
    best = None
    for pitch in np.arange(lo, hi+1e-9, step):
        r = idx % pitch
        nb = int(round(pitch/binw))
        h = np.bincount((r/binw).astype(int), weights=p[1:n-1], minlength=nb)
        c = np.bincount((r/binw).astype(int), minlength=nb)
        h = h/np.maximum(c,1)
        mid = (np.arange(nb)*binw + pitch*0.5) % pitch
        hm = h[((mid/binw).astype(int)) % nb]
        d = h - hm
        j = int(np.argmax(d))
        if best is None or d[j] > best[0]:
            best = (float(d[j]), float(pitch), float(j*binw))
    return best

def refine(p, pitch, ph):
    n=len(p); idx=np.arange(1,n-1,dtype=np.float64)
    best=(-9e9,pitch,ph)
    for pp in np.arange(pitch-0.3, pitch+0.3+1e-9, 0.01):
        for q in np.arange(ph-0.4, ph+0.4+1e-9, 0.05):
            r = (idx - q) % pp
            on = r < pp*0.25
            off = (r > pp*0.35) & (r < pp*0.65)
            if on.sum()<5 or off.sum()<5: continue
            sc = float(p[1:n-1][on].mean() - p[1:n-1][off].mean())
            if sc>best[0]: best=(sc,float(pp),float(q%pp))
    return best

FAMS = [("zhuore","spr_zhuorediyu"),("zhuore","spr_zhuorediyu"),
        ("shuihuo0","spr_shuihuozhijian_0"),("shuihuo1","spr_shuihuozhijian_1"),
        ("sky","spr_mengyantiankong_0"),("wudu","spr_wuduyanjiusuo_0"),
        ("castle","spr_mod_ancient_castle_0"),("salad","spr_salad_island_land")]
seen=set(); out={}
for key, spr in FAMS:
    if key in seen: continue
    seen.add(key)
    px = prof(spr,"x"); py = prof(spr,"y")
    hx = hist_fit(px); hy = hist_fit(py)
    rx = refine(px, hx[1], hx[2]); ry = refine(py, hy[1], hy[2])
    out[key] = dict(spr=spr, sx_art=rx[1], sx_ph=rx[2], sx_sc=rx[0], sy_art=ry[1], sy_ph=ry[2], sy_sc=ry[0])
    print("%-9s %-24s  X p=%.2f ph=%.2f (%.2f)   Y p=%.2f ph=%.2f (%.2f)"%(
        key, spr, rx[1], rx[2], rx[0], ry[1], ry[2], ry[0]))
json.dump(out, open("output/_tmp_grid/fit2.json","w"), indent=1)
