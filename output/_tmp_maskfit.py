import os, glob, json, re
import numpy as np
from PIL import Image

ENG = dict(ox=695.0, oy=228.0, cw=107.0, ch=116.0)

def load(p):
    s = open(p, encoding="utf-8-sig").read().replace("\x00","")
    s = re.sub(r",(\s*[}\]])", r"\1", s)
    return json.loads(s)

def frame0(spr):
    return sorted(glob.glob(os.path.join("sprites", spr, "*.png")))[0]

def stonemask(im, sat_max=72, vmin=50, vmax=215):
    a = np.asarray(im.convert("RGB")).astype(np.float32)
    mx = a.max(axis=2); mn = a.min(axis=2)
    sat = np.where(mx>1,(mx-mn)/np.maximum(mx,1)*255.0,0.0)
    return ((sat<sat_max)&(mx>vmin)&(mx<vmax)).astype(np.float32), mx

def cell_score(mask, mapc, sx, sy, x0, y0, inner=0.30):
    tot=0.0; n=0; bad=0
    for r in range(len(mapc)):
        for c in range(len(mapc[r])):
            lava = "lava" in (mapc[r][c].get("object") or [])
            wx0 = ENG["ox"]+c*ENG["cw"]; wy0 = ENG["oy"]+r*ENG["ch"]
            l = wx0+ENG["cw"]*inner; rgt = wx0+ENG["cw"]*(1-inner)
            t = wy0+ENG["ch"]*inner; b = wy0+ENG["ch"]*(1-inner)
            ax0=(l-x0)/sx; ax1=(rgt-x0)/sx; ay0=(t-y0)/sy; ay1=(b-y0)/sy
            if ax0<0 or ay0<0 or ax1>mask.shape[1]-1 or ay1>mask.shape[0]-1:
                bad+=1; continue
            v = mask[int(ay0):int(ay1)+1, int(ax0):int(ax1)+1].mean()
            tot += (v if not lava else 1.0-v)*(-1 if lava else 1)*-1*-1
            n+=1
    return (tot/n if n and not bad else -9.0), bad

def cell_score2(mask, mapc, sx, sy, x0, y0, inner=0.32):
    stone=[]; lava=[]
    for r in range(len(mapc)):
        for c in range(len(mapc[r])):
            is_lava = "lava" in (mapc[r][c].get("object") or [])
            wx0 = ENG["ox"]+c*ENG["cw"]; wy0 = ENG["oy"]+r*ENG["ch"]
            ax0=(wx0+ENG["cw"]*inner-x0)/sx; ax1=(wx0+ENG["cw"]*(1-inner)-x0)/sx
            ay0=(wy0+ENG["ch"]*inner-y0)/sy; ay1=(wy0+ENG["ch"]*(1-inner)-y0)/sy
            if ax0<0 or ay0<0 or ax1>mask.shape[1]-1 or ay1>mask.shape[0]-1: return -9.0
            v = float(mask[int(ay0):int(ay1)+1, int(ax0):int(ax1)+1].mean())
            (lava if is_lava else stone).append(v)
    if not stone or not lava: return -9.0
    return float(np.mean(stone) - np.mean(lava))

def fit(lv_path, spr, cur):
    lv = load(lv_path); mapc = lv["map"]
    mask,_ = stonemask(Image.open(frame0(spr)))
    H,W = mask.shape
    sx,sy,x,y = cur
    best = cell_score2(mask,mapc,sx,sy,x,y)
    for ss,os_ in [(0.02,4.0),(0.005,1.0),(0.002,0.25)]:
        for _ in range(2):
            for c in np.arange(sx-ss, sx+ss+1e-9, ss):
                v=cell_score2(mask,mapc,float(c),sy,x,y)
                if v>best: best,sx=v,float(c)
            for c in np.arange(sy-ss, sy+ss+1e-9, ss):
                v=cell_score2(mask,mapc,sx,float(c),x,y)
                if v>best: best,sy=v,float(c)
            for c in np.arange(x-14*os_, x+14*os_+1e-9, os_):
                v=cell_score2(mask,mapc,sx,sy,float(c),y)
                if v>best: best,x=v,float(c)
            for c in np.arange(y-14*os_, y+14*os_+1e-9, os_):
                v=cell_score2(mask,mapc,sx,sy,x,float(c))
                if v>best: best,y=v,float(c)
    return best, sx, sy, x, y

jobs = [
 ("zhuore",  ["cross/zhuore_%d.json"%i for i in range(8)],   ["spr_zhuorediyu"]*8, (9,42,1.786,1.798)),
 ("wudu",    ["cross/wudu_%d.json"%i for i in range(8)],     ["spr_wuduyanjiusuo_%d"%i for i in range(8)], (2,36,1.8,1.8)),
 ("sky",     ["cross/nightmare_sky-%d.json"%i for i in range(8)], ["spr_mengyantiankong_%d"%i for i in range(8)], (2,10,1.777,1.884)),
 ("shuihuoA",["cross/shuihuo_%d.json"%i for i in range(4)],  ["spr_shuihuozhijian_0"]*4, (17,43,1.775,1.805)),
 ("shuihuoB",["cross/shuihuo_%d.json"%i for i in range(4,8)],["spr_shuihuozhijian_1"]*4, (21,44,1.7765,1.811)),
]
res={}
for name, paths, sprs, cur in jobs:
    acc=[]
    for lp, sp in zip(paths, sprs):
        sc,sx,sy,x,y = fit(os.path.join("datafiles/level_data", lp), sp, cur)
        acc.append((sc,sx,sy,x,y))
        print("  %-28s %-24s sc=%.3f -> x=%.1f y=%.1f sx=%.4f sy=%.4f"%(os.path.basename(lp), sp, sc, x,y,sx,sy))
    arr=np.array([a[1:] for a in acc])
    med = np.median(arr, axis=0)
    res[name]=dict(x=round(float(med[0]),2), y=round(float(med[1]),2), sx=round(float(med[2]),4), sy=round(float(med[3]),4), cur=list(cur))
    print("== %-9s median {x:%.1f y:%.1f sx:%.4f sy:%.4f}  cur=%s"%(name, med[0],med[1],med[2],med[3],cur))
json.dump(res, open("output/_tmp_grid/maskfit.json","w"), indent=1)
