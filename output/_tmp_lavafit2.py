import glob, os, json, re
import numpy as np
from PIL import Image

ENG = dict(ox=695.0, oy=228.0, cw=107.0, ch=116.0)
COLS, ROWS = 9, 7

def load(p):
    s=open(p,encoding="utf-8-sig").read().replace("\x00","")
    s=re.sub(r",(\s*[}\]])",r"\1",s)
    return json.loads(s)
def frame0(spr):
    return sorted(glob.glob(os.path.join("sprites", spr, "*.png")))[0]

def stone_mask(a):
    mx=a.max(axis=2); mn=a.min(axis=2)
    sat=np.where(mx>1,(mx-mn)/np.maximum(mx,1)*255,0)
    return ((sat<90)&(mx>70)&(mx<215)).astype(np.float32)

def lava_mask(a):
    r,g,b=a[:,:,0],a[:,:,1],a[:,:,2]
    return ((r>120)&(r>g+40)&(g<150)).astype(np.float32)

def cell_fracs(mask, sx, sy, x, y, inner=0.36):
    H,W = mask.shape
    out=np.zeros((ROWS,COLS), np.float32); ok=True
    for r in range(ROWS):
        for c in range(COLS):
            wx0=ENG["ox"]+c*ENG["cw"]; wy0=ENG["oy"]+r*ENG["ch"]
            ax0=(wx0+ENG["cw"]*inner-x)/sx; ax1=(wx0+ENG["cw"]*(1-inner)-x)/sx
            ay0=(wy0+ENG["ch"]*inner-y)/sy; ay1=(wy0+ENG["ch"]*(1-inner)-y)/sy
            if ax0<0 or ay0<0 or ax1>W-1 or ay1>H-1: return None
            out[r,c]=mask[int(ay0):int(ay1)+1, int(ax0):int(ax1)+1].mean()
    return out

def objective(mask, lmask, sx, sy, x, y):
    f = cell_fracs(mask, sx, sy, x, y)
    if f is None: return -9.0
    a = f[~lmask].mean() - f[lmask].mean()   # 非lava格应更"石头"
    return float(a)

def descend(mask, lmask, x, y, sx, sy):
    best = objective(mask, lmask, sx, sy, x, y)
    rounds = [(0.03, 8.0), (0.008, 2.0), (0.002, 0.5)]
    for ss, os_ in rounds:
        for _ in range(3):
            for c in np.arange(sx-ss, sx+ss+1e-9, ss/2):
                v=objective(mask, lmask, float(c), sy, x, y)
                if v>best: best,sx=v,float(c)
            for c in np.arange(sy-ss, sy+ss+1e-9, ss/2):
                v=objective(mask, lmask, sx, float(c), x, y)
                if v>best: best,sy=v,float(c)
            for c in np.arange(x-12*os_, x+12*os_+1e-9, os_):
                v=objective(mask, lmask, sx, sy, float(c), y)
                if v>best: best,x=v,float(c)
            for c in np.arange(y-12*os_, y+12*os_+1e-9, os_):
                v=objective(mask, lmask, sx, sy, x, float(c))
                if v>best: best,y=v,float(c)
    return best, x, y, sx, sy

jobs=[("zhuore","zhuore_0.json","spr_zhuorediyu","stone",(9.0,42.0,1.786,1.798)),
      ("shuihuo0","shuihuo_0.json","spr_shuihuozhijian_0","lava",(17.0,43.0,1.775,1.805))]
for name, lvname, spr, mkind, cur in jobs:
    a = np.asarray(Image.open(frame0(spr)).convert("RGB")).astype(np.float32)
    mask = stone_mask(a) if mkind=="stone" else lava_mask(a)
    mp = load("datafiles/level_data/cross/"+lvname)["map"]
    lmask = np.array([["lava" in (c.get("object") or []) for c in row] for row in mp], dtype=bool)
    print("==", name, "lava cells", int(lmask.sum()), "/", lmask.size)
    print("   cur obj=%.3f"%objective(mask, lmask, cur[2], cur[3], cur[0], cur[1]))
    best,x,y,sx,sy = descend(mask, lmask, *cur)
    print("   fit obj=%.3f -> x=%.2f y=%.2f sx=%.4f sy=%.4f"%(best,x,y,sx,sy))
