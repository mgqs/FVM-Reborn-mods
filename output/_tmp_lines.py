import os, glob, json
import numpy as np
from PIL import Image

def frame0(spr):
    return sorted(glob.glob(os.path.join("sprites", spr, "*.png")))[0]

def lines(spr, thr=6.0, minfrac=0.35):
    a = np.asarray(Image.open(frame0(spr)).convert("RGB")).astype(np.float32).mean(axis=2)
    H,W = a.shape
    gx = np.abs(np.diff(a, axis=1))   # H x (W-1)
    gy = np.abs(np.diff(a, axis=0))   # (H-1) x W
    # 一条真实格线：该列上大量行的梯度都超过阈值
    cx = (gx > thr).sum(axis=0)/H
    cy = (gy > thr).sum(axis=1)/W
    def cluster(v, frac):
        idx = np.where(v > frac)[0]
        if not len(idx): return []
        groups=[[idx[0]]]
        for i in idx[1:]:
            if i-groups[-1][-1] <= 2: groups[-1].append(i)
            else: groups.append([i])
        return [float(np.mean(g)) for g in groups if len(g)>=1]
    return cluster(cx, minfrac), cluster(cy, minfrac), (W,H)

for spr in ["spr_wuduyanjiusuo_0","spr_zhuorediyu","spr_shuihuozhijian_0","spr_shuihuozhijian_1","spr_mengyantiankong_0","spr_mod_ancient_castle_0","spr_salad_island_land"]:
    vx, vy, (W,H) = lines(spr)
    print("==", spr, W, H)
    print("   Vx:", [round(v,1) for v in vx])
    print("   dVx:", [round(float(b-a),1) for a,b in zip(vx, vx[1:])])
    print("   Hy:", [round(v,1) for v in vy])
    print("   dHy:", [round(float(b-a),1) for a,b in zip(vy, vy[1:])])
