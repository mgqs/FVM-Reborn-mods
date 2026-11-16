import glob, os, json
import numpy as np
from PIL import Image

def frame0(spr):
    return sorted(glob.glob(os.path.join("sprites", spr, "*.png")))[0]

def prof(spr, axis, ywin=(0.15,0.85), xwin=(0.15,0.85)):
    a = np.asarray(Image.open(frame0(spr)).convert("L")).astype(np.float32)
    H,W = a.shape
    if axis=="x":
        p = np.abs(np.diff(a[int(H*ywin[0]):int(H*ywin[1]), :], axis=1)).mean(axis=0)
    else:
        p = np.abs(np.diff(a[:, int(W*xwin[0]):int(W*xwin[1])], axis=0)).mean(axis=1)
    return p.astype(np.float64)

def periodogram(p, lo, hi, step=0.01):
    n = len(p); x = np.arange(n, dtype=np.float64)
    w = p - p.mean()
    w = np.maximum(w, 0)
    tot = w.sum()+1e-12
    best=None
    for pitch in np.arange(lo, hi+1e-9, step):
        z = np.sum(w*np.exp(-2j*np.pi*x/pitch))/tot
        m = abs(z)
        if best is None or m > best[0]:
            ph = (-np.angle(z)/(2*np.pi)*pitch) % pitch
            best = (float(m), float(pitch), float(ph))
    return best

def polish(p, pitch, ph, plo, phi):
    n=len(p); x=np.arange(n,dtype=np.float64)
    w=np.maximum(p-p.mean(),0)
    best=(-9e9,pitch,ph)
    for pp in np.arange(max(plo,pitch-0.6), min(phi,pitch+0.6)+1e-9, 0.01):
        for q in np.arange(ph-0.6, ph+0.6+1e-9, 0.05):
            r = (x - q) % pp
            on = r < pp*0.30
            sc = float((w[on].sum()/(on.sum()+1e-9)) / (w.sum()/(n+1e-9)))
            if sc>best[0]: best=(sc,float(pp),float(q%pp))
    return best

JOBS = [("zhuore","spr_zhuorediyu",(45,75),(45,75)),
        ("shuihuo0","spr_shuihuozhijian_0",(45,75),(45,75)),
        ("shuihuo1","spr_shuihuozhijian_1",(45,75),(45,75)),
        ("sky","spr_mengyantiankong_0",(45,75),(45,75)),
        ("wudu","spr_wuduyanjiusuo_0",(45,75),(45,75)),
        ("castle","spr_mod_ancient_castle_0",(90,130),(90,130)),
        ("salad","spr_salad_island_land",(90,130),(90,130))]
out={}
for key, spr, xr, yr in JOBS:
    px = prof(spr,"x"); py = prof(spr,"y")
    hx = periodogram(px, *xr); hy = periodogram(py, *yr)
    rx = polish(px, hx[1], hx[2], *xr); ry = polish(py, hy[1], hy[2], *yr)
    out[key]=dict(spr=spr, px=rx[1], phx=rx[2], scx=rx[0], py=ry[1], phy=ry[2], scy=ry[0])
    print("%-9s %-24s X p=%6.2f ph=%6.2f (%.2f)  Y p=%6.2f ph=%6.2f (%.2f)"%(key,spr,rx[1],rx[2],rx[0],ry[1],ry[2],ry[0]))
json.dump(out, open("output/_tmp_grid/fit2.json","w"), indent=1)
