import os, glob, json
import numpy as np
from PIL import Image

def frame0(spr):
    fs = sorted(glob.glob(os.path.join("sprites", spr, "*.png")))
    return fs[0] if fs else None

def longest_run(mask):
    # mask: 1D bool
    best=0; cur=0; s=-1; bs=-1
    for i,v in enumerate(mask):
        if v:
            if cur==0: s=i
            cur+=1
            if cur>best: best=cur; bs=s
        else: cur=0
    return best, bs

def lines_run(spr, gthr=9.0, minfrac=0.55):
    fp = frame0(spr)
    a = np.asarray(Image.open(fp).convert("L")).astype(np.float32)
    H,W = a.shape
    m = np.abs(np.diff(a, axis=1)) > gthr   # H x W-1
    cols=[]
    for x in range(m.shape[1]):
        r,_ = longest_run(m[:, x])
        cols.append(r)
    cols=np.array(cols)/H
    m2 = np.abs(np.diff(a, axis=0)) > gthr
    rows=[]
    for y in range(m2.shape[0]):
        r,_ = longest_run(m2[y, :])
        rows.append(r)
    rows=np.array(rows)/W
    def group(v, frac):
        idx=np.where(v>=frac)[0]
        if not len(idx): return []
        g=[[idx[0]]]
        for i in idx[1:]:
            if i-g[-1][-1]<=2: g[-1].append(i)
            else: g.append([i])
        return [(float(np.mean(gg)), float(v[[int(round(np.mean(gg)))]][0] if False else max(v[i] for i in gg))) for gg in g]
    return group(cols, minfrac), group(rows, minfrac), (W,H)

def best_prog(cands, lo=52, hi=72, minn=7):
    # cands: list of (pos, strength)
    pos = np.array([c[0] for c in cands])
    if len(pos) < minn: return None
    best=None
    for i in range(len(pos)):
        for j in range(i+1, len(pos)):
            d = pos[j]-pos[i]
            for k in range(1, 12):
                p = d/k
                if p < lo or p > hi: continue
                ph = pos[i] - p*np.floor(pos[i]/p)
                # 计分：落在栅格 ±1.5 内的强线数
                res = np.abs((pos - ph + p*0.5) % p - p*0.5)
                inl = res <= 1.5
                n = inl.sum()
                if n < minn: continue
                # 线性回归精修
                idx = np.round((pos[inl]-ph)/p)
                A = np.vstack([np.ones(inl.sum()), idx]).T
                sol,*_ = np.linalg.lstsq(A, pos[inl], rcond=None)
                a0, p0 = float(sol[0]), float(sol[1])
                if p0 < lo or p0 > hi: continue
                sc = n
                if best is None or sc > best[0]:
                    best = (sc, a0, p0, float(np.abs(pos[inl]-(a0+idx*p0)).max()))
    return best

out={}
for spr in ["spr_salad_island_land","spr_wuduyanjiusuo_0","spr_zhuorediyu","spr_shuihuozhijian_0","spr_shuihuozhijian_1","spr_mengyantiankong_0","spr_mod_ancient_castle_0"]:
    cx_, cy_, (W,H) = lines_run(spr)
    print("==", spr, W,H)
    print("   cols:", [(round(p,1), round(s,2)) for p,s in cx_])
    print("   rows:", [(round(p,1), round(s,2)) for p,s in cy_])
    bx = best_prog(cx_, 100 if "salad" in spr or "castle" in spr else 52, 130 if "salad" in spr or "castle" in spr else 72)
    by = best_prog(cy_, 100 if "salad" in spr or "castle" in spr else 52, 130 if "salad" in spr or "castle" in spr else 72)
    print("   Xprog:", bx and (bx[0], round(bx[1],2), round(bx[2],3), round(bx[3],2)))
    print("   Yprog:", by and (by[0], round(by[1],2), round(by[2],3), round(by[3],2)))
    out[spr]=dict(cols=[(float(p),float(s)) for p,s in cx_], rows=[(float(p),float(s)) for p,s in cy_],
                  Xprog=bx and [bx[0],float(bx[1]),float(bx[2]),float(bx[3])], Yprog=by and [by[0],float(by[1]),float(by[2]),float(by[3])])
json.dump(out, open("output/_tmp_grid/runlines.json","w"), indent=1)
