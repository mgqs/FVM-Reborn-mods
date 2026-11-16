import glob, os, json
import numpy as np
from PIL import Image
from collections import deque

def frame0(spr):
    return sorted(glob.glob(os.path.join("sprites", spr, "*.png")))[0]

def label(mask, minarea=900, maxwh=160):
    H,W = mask.shape
    lab = np.zeros((H,W), np.int16)
    out=[]; cur=0
    ys,xs = np.nonzero(mask)
    for y,x in zip(ys,xs):
        if lab[y,x]: continue
        cur+=1; q=deque([(y,x)]); lab[y,x]=cur
        pix=[]
        while q:
            cy,cx=q.popleft(); pix.append((cy,cx))
            for dy,dx in ((1,0),(-1,0),(0,1),(0,-1)):
                ny,nx=cy+dy,cx+dx
                if 0<=ny<H and 0<=nx<W and mask[ny,nx] and not lab[ny,nx]:
                    lab[ny,nx]=cur; q.append((ny,nx))
        if len(pix)<minarea: continue
        a=np.array(pix)
        w=a[:,1].max()-a[:,1].min()+1; h=a[:,0].max()-a[:,0].min()+1
        if w>maxwh or h>maxwh: continue
        # 孔洞度（bbox 填充率）
        fill = len(pix)/(w*h)
        out.append((float(a[:,1].mean()), float(a[:,0].mean()), int(w), int(h), round(float(fill),2), len(pix)))
    return out

def maskset(a, kind):
    mx=a.max(axis=2); mn=a.min(axis=2)
    r,g,b=a[:,:,0],a[:,:,1],a[:,:,2]
    if kind=="blue": return (b>r+12)&(b>55)&(mx<235)
    if kind=="stone":
        sat=np.where(mx>1,(mx-mn)/np.maximum(mx,1)*255,0)
        return (sat<80)&(mx>55)&(mx<220)
    if kind=="bright":
        sat=np.where(mx>1,(mx-mn)/np.maximum(mx,1)*255,0)
        return (sat<60)&(mx>70)&(mx<200)
    raise SystemExit

def fit1d(vals, lo, hi, tol=2.2, step=0.05):
    vals=np.array(sorted(vals)); best=None
    for p in np.arange(lo,hi+1e-9,step):
        for ph in np.arange(0.0,p,0.5):
            d=np.abs((vals-ph+p*0.5)%p-p*0.5)
            inl=d<=tol
            n=int(inl.sum())
            if n<4: continue
            idx=np.round((vals[inl]-ph)/p)
            A=np.vstack([np.ones(n),idx]).T
            sol,*_=np.linalg.lstsq(A,vals[inl],rcond=None)
            a0,p0=float(sol[0]),float(sol[1])
            if not (lo-1 <= p0 <= hi+1): continue
            rmse=float(np.abs(vals[inl]-(a0+idx*p0)).mean())
            sc=n-rmse
            if best is None or sc>best[0]: best=(sc,a0,p0,n,rmse,idx.min(),idx.max())
    return best

JOBS = {
 "zhuore":   ("spr_zhuorediyu","stone",(1114,600)),
 "wudu":     ("spr_wuduyanjiusuo_0","bright",(1108,597)),
 "shuihuo0": ("spr_shuihuozhijian_0","blue",(1108,597)),
 "shuihuo1": ("spr_shuihuozhijian_1","blue",(1108,597)),
 "sky":      ("spr_mengyantiankong_0","bright",(1109,597)),
 "castle":   ("spr_mod_ancient_castle_0","bright",(2005,1080)),
 "salad":    ("spr_salad_island_land","bright",(2005,1080)),
}
OUT={}
for k,(spr,kind,size) in JOBS.items():
    a=np.asarray(Image.open(frame0(spr)).convert("RGB")).astype(np.float32)
    comps=label(maskset(a,kind))
    print("==",k,spr,"comps",len(comps))
    if not comps: continue
    xs=[c[0] for c in comps]; ys=[c[1] for c in comps]
    fx=fit1d(xs, 45,140); fy=fit1d(ys, 45,140)
    print("   X fit:", fx and (fx[3], round(fx[1],2), round(fx[2],3), round(fx[4],2), fx[5], fx[6]))
    print("   Y fit:", fy and (fy[3], round(fy[1],2), round(fy[2],3), round(fy[4],2), fy[5], fy[6]))
    OUT[k]=dict(spr=spr, kind=kind, size=size, n=len(comps),
        X=fx and dict(a0=fx[1], p=fx[2], n=fx[3], rmse=fx[4], kmin=int(fx[5]), kmax=int(fx[6])),
        Y=fy and dict(a0=fy[1], p=fy[2], n=fy[3], rmse=fy[4], kmin=int(fy[5]), kmax=int(fy[6])))
json.dump(OUT, open("output/_tmp_grid/platefit.json","w"), indent=1)
