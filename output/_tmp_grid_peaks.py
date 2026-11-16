import os, glob
from PIL import Image
import numpy as np

def first_frame(name):
    return sorted(glob.glob(os.path.join("sprites", name, "*.png")))[0]

def edge_profiles(path):
    a = np.asarray(Image.open(path).convert("RGB")).astype(np.float32)
    g = a.mean(axis=2)
    gx = np.abs(np.diff(g, axis=1)).mean(axis=0)
    gy = np.abs(np.diff(g, axis=0)).mean(axis=1)
    return g.shape, gx, gy

def peaks(sig, min_frac=0.45, min_dist=25):
    thr = sig.mean() + sig.std()*1.0
    idx = np.where(sig > max(thr, sig.max()*min_frac))[0]
    out=[]
    for i in idx:
        if not out or i-out[-1] >= min_dist:
            out.append(int(i))
        else:
            if sig[i] > sig[out[-1]]:
                out[-1]=int(i)
    return out

for name in ["spr_wuduyanjiusuo_0","spr_zhuorediyu","spr_shuihuozhijian_0","spr_mengyantiankong_0","spr_mod_ancient_castle_0"]:
    p = first_frame(name)
    shape, gx, gy = edge_profiles(p)
    px = peaks(gx); py = peaks(gy)
    print(name, shape[1], "x", shape[0])
    print("  X peaks:", px)
    print("  X diff :", np.diff(px).tolist())
    print("  Y peaks:", py)
    print("  Y diff :", np.diff(py).tolist())
