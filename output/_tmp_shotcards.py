import numpy as np
from PIL import Image
p=r"D:\DSH\home\attachments\v1\objects\04\0487bdbddd653aae59337ed98e3a3ec3d40db55b9c85d522f3642a848933ccd3"
im=Image.open(p).convert("RGB"); a=np.asarray(im).astype(np.float32)
H,W,_=a.shape
r,g,b=a[:,:,0],a[:,:,1],a[:,:,2]
# 卡片：亮黄/白边（高亮度、低蓝）
card=((r>200)&(g>150)&(b<170))
print("card px frac", card.mean().round(3))
# 找卡片中心：连通域
from collections import deque
mask=card
lab=np.zeros((H,W),np.int16); comps=[]; cur=0
ys,xs=np.nonzero(mask)
for y,x in zip(ys,xs):
    if lab[y,x]: continue
    cur+=1; q=deque([(y,x)]); lab[y,x]=cur; pix=[]
    while q:
        cy,cx=q.popleft(); pix.append((cy,cx))
        for dy,dx in ((1,0),(-1,0),(0,1),(0,-1)):
            ny,nx=cy+dy,cx+dx
            if 0<=ny<H and 0<=nx<W and mask[ny,nx] and not lab[ny,nx]:
                lab[ny,nx]=cur; q.append((ny,nx))
    if len(pix)>150:
        arr=np.array(pix)
        comps.append((float(arr[:,1].mean()), float(arr[:,0].mean()), len(pix),
                      int(arr[:,1].min()), int(arr[:,1].max()), int(arr[:,0].min()), int(arr[:,0].max())))
comps.sort(key=lambda t:(t[1],t[0]))
print("n comps", len(comps))
for c in comps[:40]:
    print("   cx=%.1f cy=%.1f area=%d x[%d..%d] y[%d..%d]"%c)
