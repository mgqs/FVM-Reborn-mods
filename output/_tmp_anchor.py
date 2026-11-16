import glob, os, json, re
import numpy as np
from PIL import Image

ENG = dict(ox=695.0, oy=228.0, cw=107.0, ch=116.0)
FIT = json.load(open("output/_tmp_grid/fit2.json"))
def load(p):
    s=open(p,encoding="utf-8-sig").read().replace("\x00","")
    s=re.sub(r",(\s*[}\]])",r"\1",s)
    return json.loads(s)
def frame0(spr):
    return sorted(glob.glob(os.path.join("sprites", spr, "*.png")))[0]

def masks(a):
    r,g,b = a[:,:,0],a[:,:,1],a[:,:,2]
    orange = ((r>120)&(r-g>45)&(r-b>45)).astype(np.float32)
    mx=a.max(axis=2); mn=a.min(axis=2)
    sat=np.where(mx>1,(mx-mn)/np.maximum(mx,1)*255,0)
    grey = ((sat<70)&(mx>80)&(mx<215)).astype(np.float32)
    blue = ((b>r+10)&(b>50)).astype(np.float32)
    return orange, grey, blue

def cellsample(mask, px, py, phx, phy, i0, j0, frac=0.55):
    out=np.zeros((7,9), np.float32)
    for r in range(7):
        for c in range(9):
            cx = phx + (i0+c+0.5)*px
            cy = phy + (j0+r+0.5)*py
            hx = px*frac*0.5; hy = py*frac*0.5
            x0=int(round(cx-hx)); x1=int(round(cx+hx)); y0=int(round(cy-hy)); y1=int(round(cy+hy))
            H,W = mask.shape
            if x0<0 or y0<0 or x1>=W or y1>=H: return None
            out[r,c]=mask[y0:y1+1, x0:x1+1].mean()
    return out

def search(name, lvfile, spr, kind):
    f = FIT[name]
    a = np.asarray(Image.open(frame0(spr)).convert("RGB")).astype(np.float32)
    orange, grey, blue = masks(a)
    mp = load("datafiles/level_data/cross/"+lvfile)["map"]
    lmask = np.array([["lava" in (c.get("object") or []) for c in row] for row in mp], dtype=bool)
    best=None
    for i0 in range(0, 8):
        for j0 in range(0, 6):
            o = cellsample(orange, f["px"], f["py"], f["phx"], f["phy"], i0, j0)
            if o is None: continue
            pred = o > 0.5
            acc = float((pred == lmask).mean())
            gap = float(o[lmask].mean() - o[~lmask].mean())
            if best is None or (acc, gap) > best[0:2]:
                best = (acc, gap, i0, j0, o)
    acc, gap, i0, j0, o = best
    sx = ENG["cw"]/f["px"]; sy = ENG["ch"]/f["py"]
    x = ENG["ox"] - (f["phx"]+i0*f["px"])*sx
    y = ENG["oy"] - (f["phy"]+j0*f["py"])*sy
    print("== %-8s %-22s acc=%.3f gap=%+.2f i0=%d j0=%d -> {x:%.1f, y:%.1f, sx:%.4f, sy:%.4f}"%(name, spr, acc, gap, i0, j0, x, y, sx, sy))
    print("   map :", "".join("L" if v else "." for v in lmask.flatten()))
    print("   art :", "".join("L" if v>0.5 else "." for v in (o>0.5).flatten()))
    print("   ofr :", "".join("%d"%min(9,int(v*10)) for v in o.flatten()))
    return dict(x=round(float(x),2), y=round(float(y),2), sx=round(float(sx),4), sy=round(float(sy),4), acc=acc, i0=i0, j0=j0)

out={}
out["zhuore"] = search("zhuore","zhuore_0.json","spr_zhuorediyu","lava")
out["shuihuo0"] = search("shuihuo0","shuihuo_0.json","spr_shuihuozhijian_0","lava")
out["shuihuo1"] = search("shuihuo1","shuihuo_4.json","spr_shuihuozhijian_1","lava")
json.dump(out, open("output/_tmp_grid/anchored.json","w"), indent=1)
