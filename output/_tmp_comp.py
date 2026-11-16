import glob, os, json, re, collections
import numpy as np
from PIL import Image

def load(p):
    s=open(p,encoding="utf-8-sig").read().replace("\x00","")
    s=re.sub(r",(\s*[}\]])",r"\1",s)
    return json.loads(s)

def label(mask):
    H,W = mask.shape
    lab = np.zeros((H,W), dtype=np.int32)
    cur = 0
    comps = []
    from collections import deque
    for y in range(H):
        for x in range(W):
            if mask[y,x] and lab[y,x]==0:
                cur += 1
                q = deque([(y,x)]); lab[y,x]=cur
                pix=[]
                while q:
                    cy,cx = q.popleft(); pix.append((cy,cx))
                    for dy,dx in ((1,0),(-1,0),(0,1),(0,-1)):
                        ny,nx = cy+dy, cx+dx
                        if 0<=ny<H and 0<=nx<W and mask[ny,nx] and lab[ny,nx]==0:
                            lab[ny,nx]=cur; q.append((ny,nx))
                comps.append(pix)
    return comps

def plates(spr, mode):
    fp = sorted(glob.glob(os.path.join("sprites", spr, "*.png")))[0]
    a = np.asarray(Image.open(fp).convert("RGB")).astype(np.float32)
    r,g,b = a[:,:,0],a[:,:,1],a[:,:,2]
    mx = a.max(axis=2); mn = a.min(axis=2)
    if mode=="blue":
        m = (b > r+15) & (b > 60)
    else:
        sat = np.where(mx>1,(mx-mn)/np.maximum(mx,1)*255,0)
        m = (sat<75) & (mx>60) & (mx<215)
    comps = label(m)
    res=[]
    for pix in comps:
        if len(pix) < 1200: continue
        ys = np.array([p[0] for p in pix]); xs = np.array([p[1] for p in pix])
        w = xs.max()-xs.min()+1; h = ys.max()-ys.min()+1
        if w>140 or h>140: continue
        res.append((float(xs.mean()), float(ys.mean()), int(len(pix)), int(w), int(h)))
    return sorted(res, key=lambda t:(t[1],t[0])), Image.open(fp).size

for spr, mode in [("spr_shuihuozhijian_0","blue"),("spr_zhuorediyu","stone")]:
    cents, size = plates(spr, mode)
    print("==", spr, mode, size, "n=", len(cents))
    for c in cents: print("   %.1f %.1f area=%d wh=%dx%d"%c)
