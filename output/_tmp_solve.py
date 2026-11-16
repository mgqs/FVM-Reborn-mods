import glob, os, json
import numpy as np
from PIL import Image, ImageDraw

ENG = dict(ox=695.0, oy=228.0, cw=107.0, ch=116.0)
FIT = json.load(open("output/_tmp_grid/fit2.json"))
CUR = {
 "zhuore": (9,42,1.786,1.798),
 "shuihuo0": (17,43,1.775,1.805),
 "shuihuo1": (21,44,1.7765,1.811),
 "sky": (2,10,1.777,1.884),
 "wudu": (2,36,1.8,1.8),
 "castle": (0,0,1.0,1.0),
}
def frame0(spr):
    return sorted(glob.glob(os.path.join("sprites", spr, "*.png")))[0]

def solve(key):
    f = FIT[key]; cur = CUR[key]
    p, ph = f["px"], f["phx"]
    sx = ENG["cw"]/p
    # 选 k 使 x 最接近当前
    best=None
    for k in range(-2, 60):
        s = ph + k*p
        x = ENG["ox"] - s*sx
        if best is None or abs(x-cur[0]) < abs(best[0]-cur[0]): best=(x,k,s)
    x, kx, sxs = best
    p2, ph2 = f["py"], f["phy"]
    sy = ENG["ch"]/p2
    best=None
    for k in range(-2, 60):
        s = ph2 + k*p2
        y = ENG["oy"] - s*sy
        if best is None or abs(y-cur[1]) < abs(best[1]-cur[1]): best=(y,k,s)
    y, ky, sys = best
    return dict(x=round(float(x),2), y=round(float(y),2), sx=round(float(sx),4), sy=round(float(sy),4), k=(kx,ky))

res = {k: solve(k) for k in FIT}
json.dump(res, open("output/_tmp_grid/solved.json","w"), indent=1)
for k,v in res.items(): print("%-9s -> {x:%.1f, y:%.1f, sx:%.4f, sy:%.4f}  cur=%s"%(k,v["x"],v["y"],v["sx"],v["sy"],CUR[k]))
