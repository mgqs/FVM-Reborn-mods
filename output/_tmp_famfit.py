import os, glob, json
import numpy as np
from PIL import Image

def fam_frames(fam):
    d = os.path.join("sprites", fam)
    return sorted(glob.glob(os.path.join(d, "*.png")))

def avg_profiles(files, ywin=(0.2,0.8), xwin=(0.2,0.8)):
    gxs=[]; gys=[]
    for fp in files:
        a = np.asarray(Image.open(fp).convert("L")).astype(np.float32)
        H,W = a.shape
        gxs.append(np.abs(np.diff(a[int(H*ywin[0]):int(H*ywin[1]), :], axis=1)).mean(axis=0))
        gys.append(np.abs(np.diff(a[:, int(W*xwin[0]):int(W*xwin[1])], axis=0)).mean(axis=1))
    n = min(len(p) for p in gxs)
    return np.mean([p[:n-1] for p in gxs], axis=0), np.mean([p[:n-1] for p in gys], axis=0), (W,H)

def comb_fit(prof, lo, hi, pstep=0.02, phstep=0.05, minc=6):
    n = len(prof); best=(-9e9, None, None)
    x = np.arange(1, n-1)
    for p in np.arange(lo, hi+1e-9, pstep):
        for ph in np.arange(0.0, p, phstep):
            idx = np.arange(ph, n-1, p)
            if len(idx) < minc: continue
            on = np.clip(np.round(idx).astype(int), 0, n-2)
            mid = np.clip(np.round(idx + p*0.5).astype(int), 0, n-2)
            sc = float(prof[on].mean() - prof[mid].mean())
            if sc > best[0]: best = (sc, float(p), float(ph))
    return best

fams = ["spr_mengyantiankong","spr_zhuorediyu","spr_shuihuozhijian_0","spr_shuihuozhijian_1","spr_wuduyanjiusuo","spr_mod_ancient_castle","spr_salad_island_land"]
res={}
for fam in fams:
    files = fam_frames(fam)[:8]
    gx, gy, (W,H) = avg_profiles(files)
    bx = comb_fit(gx, 50, 72); by = comb_fit(gy, 50, 78)
    res[fam]=dict(n=len(files), W=W, H=H, px=round(bx[1],2), phx=round(bx[2],2), scx=round(bx[0],2),
                  py=round(by[1],2), phy=round(by[2],2), scy=round(by[0],2))
    print("%-24s frames=%d art=%dx%d  X p=%.2f ph=%.2f sc=%.2f | Y p=%.2f ph=%.2f sc=%.2f"%(
        fam, len(files), W,H, bx[1], bx[2], bx[0], by[1], by[2], by[0]))
json.dump(res, open("output/_tmp_grid/famfit.json","w"), indent=1, ensure_ascii=False, default=float)
