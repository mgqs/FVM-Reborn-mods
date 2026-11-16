import os, glob, json
import numpy as np
from PIL import Image

FAMS = {
 "sky":  ["spr_mengyantiankong_%d"%i for i in range(8)],
 "zhuore": ["spr_zhuorediyu"],
 "shuihuo0": ["spr_shuihuozhijian_0"],
 "shuihuo1": ["spr_shuihuozhijian_1"],
 "wudu": ["spr_wuduyanjiusuo_%d"%i for i in range(8)],
 "castle": ["spr_mod_ancient_castle_%d"%i for i in range(8)],
 "salad": ["spr_salad_island_land"],
}

def firstframe(spr):
    fs = sorted(glob.glob(os.path.join("sprites", spr, "*.png")))
    return fs[0] if fs else None

def profs(fp, ywin=(0.20,0.80), xwin=(0.22,0.78)):
    a = np.asarray(Image.open(fp).convert("L")).astype(np.float32)
    H,W = a.shape
    gx = np.abs(np.diff(a[int(H*ywin[0]):int(H*ywin[1]), :], axis=1)).mean(axis=0)
    gy = np.abs(np.diff(a[:, int(W*xwin[0]):int(W*xwin[1])], axis=0)).mean(axis=1)
    return gx, gy, (W,H)

def comb_fit(prof, lo, hi, pstep=0.02, phstep=0.1, minc=5):
    n=len(prof); best=(-9e9, None, None)
    for p in np.arange(lo, hi+1e-9, pstep):
        for ph in np.arange(0.0, p, phstep):
            idx = np.arange(ph, n-1, p)
            if len(idx) < minc: continue
            on = np.clip(np.round(idx).astype(int), 0, n-2)
            mid = np.clip(np.round(idx + p*0.5).astype(int), 0, n-2)
            sc = float(prof[on].mean() - prof[mid].mean())
            if sc > best[0]: best = (sc, float(p), float(ph))
    return best

res={}
for key, sprs in FAMS.items():
    files = [firstframe(s) for s in sprs]
    files = [f for f in files if f]
    if not files:
        print("!! no png", key); continue
    GX=[]; GY=[]; wh=None
    for fp in files:
        gx, gy, wh = profs(fp)
        GX.append(gx); GY.append(gy)
    n = min(min(len(v) for v in GX), min(len(v) for v in GY))
    gx = np.mean([v[:n] for v in GX], axis=0)
    gy = np.mean([v[:n] for v in GY], axis=0)
    bx = comb_fit(gx, 45, 75); by = comb_fit(gy, 45, 80)
    res[key]=dict(n=len(files), W=wh[0], H=wh[1], px=float(round(bx[1],3)), phx=float(round(bx[2],2)),
                  py=float(round(by[1],3)), phy=float(round(by[2],2)), scx=float(round(bx[0],2)), scy=float(round(by[0],2)))
    print("%-9s n=%d art=%dx%d | X p=%6.2f ph=%6.2f sc=%5.2f | Y p=%6.2f ph=%6.2f sc=%5.2f"%(
        key, len(files), wh[0], wh[1], bx[1], bx[2], bx[0], by[1], by[2], by[0]))
json.dump(res, open("output/_tmp_grid/famfit.json","w"), indent=1, ensure_ascii=False)
