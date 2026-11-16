import glob, os, json, re
import numpy as np
from PIL import Image

ENG = dict(ox=695.0, oy=228.0, cw=107.0, ch=116.0)
def load(p):
    s=open(p,encoding="utf-8-sig").read().replace("\x00","")
    s=re.sub(r",(\s*[}\]])",r"\1",s)
    return json.loads(s)
def frame0(spr):
    return sorted(glob.glob(os.path.join("sprites", spr, "*.png")))[0]

def lavamask(im):
    a=np.asarray(im.convert("RGB")).astype(np.float32)
    r,g,b=a[:,:,0],a[:,:,1],a[:,:,2]
    return ((r>110)&(r>g+45)&(g>b-20)).astype(np.float32), a

def ascii_score(mask, mp, sx, sy, x, y, inner=0.34):
    H,W = mask.shape
    lava_f=[]; stone_f=[]
    for r in range(len(mp)):
        row=""
        for c in range(len(mp[r])):
            wx0=ENG["ox"]+c*ENG["cw"]; wy0=ENG["oy"]+r*ENG["ch"]
            ax0=(wx0+ENG["cw"]*inner-x)/sx; ax1=(wx0+ENG["cw"]*(1-inner)-x)/sx
            ay0=(wy0+ENG["ch"]*inner-y)/sy; ay1=(wy0+ENG["ch"]*(1-inner)-y)/sy
            if ax0<0 or ay0<0 or ax1>W-1 or ay1>H-1:
                return -9.0, None
            f=float(mask[int(ay0):int(ay1)+1, int(ax0):int(ax1)+1].mean())
            isl = "lava" in (mp[r][c].get("object") or [])
            (lava_f if isl else stone_f).append(f)
            row += ("L" if isl else ".") + ("%d"%min(9,int(f*10+0.5)))
        if r==0 and False: pass
    if not lava_f or not stone_f: return -9.0, None
    return float(np.mean(lava_f)-np.mean(stone_f)), (np.array(lava_f), np.array(stone_f))

def descend(mask, mp, start):
    sx,sy,x,y = start
    best,_ = ascii_score(mask,mp,sx,sy,x,y)
    for ss,os_ in [(0.02,6.0),(0.004,1.0),(0.001,0.25)]:
        for _ in range(2):
            for c in np.arange(sx-ss*2, sx+ss*2+1e-9, ss):
                v,_=ascii_score(mask,mp,float(c),sy,x,y)
                if v>best: best,sx=v,float(c)
            for c in np.arange(sy-ss*2, sy+ss*2+1e-9, ss):
                v,_=ascii_score(mask,mp,sx,float(c),x,y)
                if v>best: best,sy=v,float(c)
            for c in np.arange(x-10*os_, x+10*os_+1e-9, os_):
                v,_=ascii_score(mask,mp,sx,sy,float(c),y)
                if v>best: best,x=v,float(c)
            for c in np.arange(y-10*os_, y+10*os_+1e-9, os_):
                v,_=ascii_score(mask,mp,sx,sy,x,float(c))
                if v>best: best,y=v,float(c)
    return best,sx,sy,x,y

for name, spr, lv, cur in [("zhuore","spr_zhuorediyu","cross/zhuore_0.json",(9,42,1.786,1.798)),
                           ("shuihuo0","spr_shuihuozhijian_0","cross/shuihuo_0.json",(17,43,1.775,1.805))]:
    mask,_ = lavamask(Image.open(frame0(spr)))
    mp = load("datafiles/level_data/"+lv)["map"]
    sc0,_ = ascii_score(mask,mp,*cur)
    s,sx,sy,x,y = descend(mask,mp,cur)
    print("== %s cur sc=%.3f  fitted sc=%.3f -> x=%.1f y=%.1f sx=%.4f sy=%.4f"%(name,sc0,s,x,y,sx,sy))
    sc,(lf,sf) = ascii_score(mask,mp,sx,sy,x,y)
    print("   lavaFrac", np.round(lf,2).tolist())
    print("   stoneFrac", np.round(sf,2).tolist())
