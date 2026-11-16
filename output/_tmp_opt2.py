import os, glob, json
import numpy as np
from PIL import Image

BX0, BY0, BC, BR = 695.0, 228.0, 107.0, 116.0
BW, BH = int(BC*9), int(BR*7)
BX1, BY1 = BX0+BW, BY0+BH

def frame0(spr):
    return sorted(glob.glob(os.path.join("sprites", spr, "*.png")))[0]

def board_score(art, W, H, sx, sy, x, y):
    x0=(BX0-x)/sx; x1=(BX1-x)/sx; y0=(BY0-y)/sy; y1=(BY1-y)/sy
    if x0 < 0 or y0 < 0 or x1 > W-1 or y1 > H-1: return -9.0
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
    return comb(gx, BC, 9) + comb(gy, BR, 7)

def optim(art, W, H, sx0, sy0, x0, y0):
    sx, sy, x, y = sx0, sy0, x0, y0
    best = board_score(art, W, H, sx, sy, x, y)
    for ss, both, os_ in [(0.03, 40, 4.0), (0.008, 12, 1.0), (0.002, 3, 0.25)]:
        for _ in range(2):
            for cand in np.arange(sx-ss*2, sx+ss*2+1e-9, ss):
                v = board_score(art, W, H, float(cand), sy, x, y)
                if v > best: best, sx = v, float(cand)
            for cand in np.arange(sy-ss*2, sy+ss*2+1e-9, ss):
                v = board_score(art, W, H, sx, float(cand), x, y)
                if v > best: best, sy = v, float(cand)
            for cand in np.arange(x-both*os_, x+both*os_+1e-9, os_):
                v = board_score(art, W, H, sx, sy, float(cand), y)
                if v > best: best, x = v, float(cand)
            for cand in np.arange(y-both*os_, y+both*os_+1e-9, os_):
                v = board_score(art, W, H, sx, sy, x, float(cand))
                if v > best: best, y = v, float(cand)
    return best, sx, sy, x, y

CUR = {
 "spr_mengyantiankong_0": (2,10,1.777,1.884),
 "spr_mod_ancient_castle_0": (0,0,1.0,1.0),
 "spr_zhuorediyu": (9,42,1.786,1.798),
 "spr_shuihuozhijian_0": (17,43,1.775,1.805),
 "spr_shuihuozhijian_1": (21,44,1.7765,1.811),
 "spr_wuduyanjiusuo_0": (2,36,1.8,1.8),
}
out={}
for spr,(cx,cy,csx,csy) in CUR.items():
    im = Image.open(frame0(spr)).convert("L"); W,H = im.size
    best,sx,sy,x,y = optim(im, W, H, csx, csy, cx, cy)
    out[spr]=dict(x=round(x,2),y=round(y,2),sx=round(sx,4),sy=round(sy,4),score=round(best,3),cur=[cx,cy,csx,csy])
    print("%-26s score %6.2f -> {x:%.1f, y:%.1f, sx:%.4f, sy:%.4f}  cur=%s  dpx=%.1f dpy=%.1f"%(
        spr,best,x,y,sx,sy,(cx,cy,csx,csy), (x-cx), (y-cy)))
json.dump(out, open("output/_tmp_grid/fit_local.json","w"), indent=1)
