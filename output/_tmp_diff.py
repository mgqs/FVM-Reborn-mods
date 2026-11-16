import glob, os, json
import numpy as np
from PIL import Image

def frame0(spr):
    return sorted(glob.glob(os.path.join("sprites", spr, "*.png")))[0]

def diff_pitch(a, axis, lo, hi, margin=0.12):
    H,W = a.shape
    if axis=="x":
        y0,y1 = int(H*margin), int(H*(1-margin))
        sub = a[y0:y1, :]
        best=[]
        for d in range(int(lo), int(hi)+1):
            A = sub[:, :-d]; B = sub[:, d:]
            if A.shape[1] < 50: break
            best.append((d, float(np.abs(A-B).mean())))
    else:
        x0,x1 = int(W*margin), int(W*(1-margin))
        sub = a[:, x0:x1]
        best=[]
        for d in range(int(lo), int(hi)+1):
            A = sub[:-d, :]; B = sub[d:, :]
            if A.shape[0] < 50: break
            best.append((d, float(np.abs(A-B).mean())))
    arr = np.array(best)
    mins = [(int(d), round(float(v),2)) for i,(d,v) in enumerate(best)
            if 0<i<len(best)-1 and v<=best[i-1][1] and v<=best[i+1][1]]
    mins.sort(key=lambda t:t[1])
    return mins[:6]

JOBS = [("zhuore","spr_zhuorediyu",(45,75),(45,75)),
        ("shuihuo0","spr_shuihuozhijian_0",(45,75),(45,75)),
        ("shuihuo1","spr_shuihuozhijian_1",(45,75),(45,75)),
        ("sky","spr_mengyantiankong_0",(45,75),(45,75)),
        ("wudu","spr_wuduyanjiusuo_0",(45,75),(45,75)),
        ("castle","spr_mod_ancient_castle_0",(95,130),(95,130)),
        ("salad","spr_salad_island_land",(95,130),(95,130))]
for key, spr, xr, yr in JOBS:
    a = np.asarray(Image.open(frame0(spr)).convert("L")).astype(np.float32)
    print("%-9s %-26s X:"%(key,spr), diff_pitch(a,"x",*xr))
    print("%-9s %-26s Y:"%("", ""), diff_pitch(a,"y",*yr))
