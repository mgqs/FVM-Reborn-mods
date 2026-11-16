import os, glob, json
import numpy as np
from PIL import Image

BX0, BY0, BC, BR = 695.0, 228.0, 107.0, 116.0
BW, BH = int(BC*9), int(BR*7)   # 963 x 812
BX1, BY1 = BX0+BW, BY0+BH

def frame0(spr):
    return sorted(glob.glob(os.path.join("sprites", spr, "*.png")))[0]

def board_score(art, W, H, sx, sy, x, y, ret=False):
    x0=(BX0-x)/sx; x1=(BX1-x)/sx; y0=(BY0-y)/sy; y1=(BY1-y)/sy
    if x0 < 0 or y0 < 0 or x1 > W-1 or y1 > H-1: return (-9 if not ret else (-9,None,None))
    crop = art.crop((x0,y0,x1,y1)).resize((BW,BH), Image.BILINEAR)
    a = np.asarray(crop, dtype=np.float32)
    gx = np.abs(np.diff(a, axis=1)).mean(axis=0)
    gy = np.abs(np.diff(a, axis=0)).mean(axis=1)
    def comb(g, pitch, n):
        seam=[]; mid=[]
        for i in range(1,n):
            c = pitch*i - 1
            seam.append(g[max(0,int(c)-2):int(c)+3].max())
            m = c + pitch*0.5
            mid.append(g[max(0,int(m)-2):int(m)+3].max())
        seam=np.array(seam); mid=np.array(mid)
        return (seam.mean()-mid.mean())/(g.mean()+1e-3)
    sc = comb(gx, BC, 9) + comb(gy, BR, 7)
    if ret: return (sc, gx, gy)
    return sc

def search(art, W, H, sx0, sy0, x0, y0, srange, xr=140):
    sx, sy, x, y = sx0, sy0, x0, y0
    best = board_score(art, W, H, sx, sy, x, y)
    for it, (ss, xs) in enumerate([(0.02, 4.0), (0.005, 1.0), (0.002, 0.25)]):
        # scale sweep
        for cand in np.arange(sx-srange, sx+srange+1e-9, ss):
            v = board_score(art, W, H, float(cand), sy, x, y)
            if v > best: best, sx = v, float(cand)
        for cand in np.arange(sy-srange, sy+srange+1e-9, ss):
            v = board_score(art, W, H, sx, float(cand), x, y)
            if v > best: best, sy = v, float(cand)
        # offset sweep
        for cand in np.arange(x-xr*xs if it==0 else x-6*xs, x + (xr*xs if it==0 else 6*xs)+1e-9, xs):
            v = board_score(art, W, H, sx, sy, float(cand), y)
            if v > best: best, x = v, float(cand)
        for cand in np.arange(y-xr*xs if it==0 else y-6*xs, y + (xr*xs if it==0 else 6*xs)+1e-9, xs):
            v = board_score(art, W, H, sx, sy, x, float(cand))
            if v > best: best, y = v, float(cand)
        srange = 0.006 if it==1 else srange
    return best, sx, sy, x, y

cur = {
 "spr_mengyantiankong": (2,10,1.777,1.884),
 "spr_shuihuozhijian_0": (17,43,1.775,1.805),
 "spr_shuihuozhijian_1": (21,44,1.7765,1.811),
 "spr_wuduyanjiusuo": (2,36,1.8,1.8),
 "spr_zhuorediyu": (9,42,1.786,1.798),
 "spr_mod_ancient_castle": (0,0,1.0,1.0),
}
fams = ["spr_mengyantiankong_0","spr_zhuorediyu","spr_shuihuozhijian_0","spr_shuihuozhijian_1","spr_wuduyanjiusuo_0","spr_mod_ancient_castle_0"]
res={}
for spr in fams:
    fp = frame0(spr)
    im = Image.open(fp).convert("L")
    W,H = im.size
    fam = spr if spr=="spr_zhuorediyu" else spr.rsplit("_",1)[0]
    cx, cy, csx, csy = cur[fam]
    best, sx, sy, x, y = search(im, W, H, csx, csy, cx, cy, 0.06 if spr!="spr_mod_ancient_castle_0" else 0.06)
    res[spr]=dict(x=round(x,2),y=round(y,2),sx=round(sx,4),sy=round(sy,4),score=round(best,3),cur=[cx,cy,csx,csy],size=[W,H])
    print("%-26s best=%.3f  new {x:%.1f, y:%.1f, sx:%.4f, sy:%.4f}  cur=%s"%(spr,best,x,y,sx,sy,cur[fam]))
json.dump(res, open("output/_tmp_grid/fit_local.json","w"), indent=1)
