import os, glob, json
import numpy as np
from PIL import Image

def frame0(spr):
    return sorted(glob.glob(os.path.join("sprites", spr, "*.png")))[0]

def profs(fp, yband=(0.18,0.82), xband=(0.18,0.82)):
    a = np.asarray(Image.open(fp).convert("L")).astype(np.float32)
    H,W = a.shape
    gx = np.abs(np.diff(a[int(H*yband[0]):int(H*yband[1]), :], axis=1)).mean(axis=0)
    gy = np.abs(np.diff(a[:, int(W*xband[0]):int(W*xband[1])], axis=0)).mean(axis=1)
    def zn(p):
        m = np.median(p); s = np.median(np.abs(p-m))*1.4826 + 1e-6
        return (p-m)/s
    return zn(gx), zn(gy), (W,H)

def comb_hist(prof, lo=40.0, hi=140.0, pstep=0.02, binw=0.25):
    n = len(prof); best=(-1e9, None, None)
    idx = np.arange(1, n-1)
    for p in np.arange(lo, hi+1e-9, pstep):
        r = idx - np.floor(idx/p)*p
        nb = int(np.ceil(p/binw))
        h, _ = np.histogram(r, bins=nb, range=(0, p), weights=prof[idx])
        c, _ = np.histogram(r, bins=nb, range=(0, p))
        h = h/np.maximum(c,1)
        mid = (np.arange(nb)*binw + p*0.5) % p
        hm = h[(mid/binw).astype(int) % nb]
        sc = h - hm
        j = int(np.argmax(sc))
        if sc[j] > best[0]:
            best = (float(sc[j]), float(p), float(j*binw))
    return best

def refine(prof, p, ph, pspan=0.6, phspan=0.6):
    n=len(prof); best=(-1e9,p,ph)
    for pp in np.arange(p-pspan, p+pspan+1e-9, 0.02):
        for q in np.arange(ph-phspan, ph+phspan+1e-9, 0.1):
            qs = np.arange(q, n-1, pp)
            if len(qs) < 5: continue
            on = np.clip(np.round(qs).astype(int),0,n-2)
            mid = np.clip(np.round(qs+pp*0.5).astype(int),0,n-2)
            sc = float(prof[on].mean()-prof[mid].mean())
            if sc>best[0]: best=(sc,float(pp),float(q%pp))
    return best

fams = ["spr_salad_island_land","spr_mod_ancient_castle_0","spr_mengyantiankong_0","spr_zhuorediyu","spr_shuihuozhijian_0","spr_shuihuozhijian_1","spr_wuduyanjiusuo_0"]
res={}
for spr in fams:
    fp = frame0(spr)
    gx, gy, (W,H) = profs(fp)
    rx = comb_hist(gx); ry = comb_hist(gy)
    bx = refine(gx, rx[1], rx[2]); by = refine(gy, ry[1], ry[2])
    res[spr]=dict(W=W,H=H,px=bx[1],phx=bx[2],scx=bx[0],py=by[1],phy=by[2],scy=by[0])
    print("%-26s %dx%d  X p=%.2f ph=%.2f sc=%.2f | Y p=%.2f ph=%.2f sc=%.2f"%(spr,W,H,bx[1],bx[2],bx[0],by[1],by[2],by[0]))
json.dump(res, open("output/_tmp_grid/lattice.json","w"), indent=1)
