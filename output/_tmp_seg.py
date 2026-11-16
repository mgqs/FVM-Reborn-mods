import os, glob, json
import numpy as np
from PIL import Image

def frame0(spr):
    return sorted(glob.glob(os.path.join("sprites", spr, "*.png")))[0]

def seg_tiles(spr, sat_max=70, v_min=55, v_max=210):
    im = Image.open(frame0(spr)).convert("RGB")
    a = np.asarray(im).astype(np.float32)
    mx = a.max(axis=2); mn = a.min(axis=2)
    sat = np.where(mx>1, (mx-mn)/np.maximum(mx,1)*255, 0)
    v = mx
    mask = (sat < sat_max) & (v > v_min) & (v < v_max)
    return mask, im.size

def proj_runs(prof, thr):
    idx = np.where(prof >= thr)[0]
    if not len(idx): return []
    g=[[idx[0]]]
    for i in idx[1:]:
        if i-g[-1][-1] <= 3: g[-1].append(i)
        else: g.append([i])
    return [(gg[0], gg[-1]) for gg in g]

for spr in ["spr_zhuorediyu","spr_shuihuozhijian_0","spr_mod_ancient_castle_0","spr_wuduyanjiusuo_0"]:
    mask, (W,H) = seg_tiles(spr)
    colfrac = mask.mean(axis=0); rowfrac = mask.mean(axis=1)
    cr = proj_runs(colfrac, colfrac.max()*0.35)
    rr = proj_runs(rowfrac, rowfrac.max()*0.35)
    print("==", spr, W, H, "tile frac %.3f"%(mask.mean()))
    print("   col spans:", [(a,b,b-a+1) for a,b in cr][:20])
    print("   row spans:", [(a,b,b-a+1) for a,b in rr][:20])
