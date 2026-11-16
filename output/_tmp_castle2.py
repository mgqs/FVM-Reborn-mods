import glob, os
import numpy as np
from PIL import Image

fp = sorted(glob.glob("sprites/spr_mod_ancient_castle_0/*.png"))[0]
a = np.asarray(Image.open(fp).convert("RGB")).astype(np.float32)
H,W,_ = a.shape
# 棋盘石板区：灰紫色、亮度中等
r,g,b = a[:,:,0],a[:,:,1],a[:,:,2]
mx=a.max(axis=2); mn=a.min(axis=2)
sat=np.where(mx>1,(mx-mn)/np.maximum(mx,1)*255,0)
slate = (sat<40)&(mx>95)&(mx<175)
sub = slate[280:920, 760:1650]
print("frac", sub.mean().round(3))
cols = sub.mean(axis=0); rows = sub.mean(axis=1)
def spans(v, thr):
    idx=np.where(v>thr)[0]
    if not len(idx): return []
    gs=[[idx[0]]]
    for i in idx[1:]:
        if i-gs[-1][-1]<=4: gs[-1].append(i)
        else: gs.append([i])
    return [(g[0]+ (760 if v is cols else 280), g[-1]+(760 if v is cols else 280)) for g in gs]
print("col spans", spans(cols, cols.max()*0.5))
print("row spans", spans(rows, rows.max()*0.5))
# 逐列/行强度剖面找格缝
gx = cols
peaks=[]
for i in range(2,len(gx)-2):
    if gx[i]<gx[i-2] and gx[i]<=gx[i+2] and gx[i] < gx.mean()*0.75:
        if not peaks or i-peaks[-1]>8: peaks.append(i+760)
print("col gaps", peaks, "diffs", np.diff(peaks).tolist() if len(peaks)>1 else None)
gy = rows
peaks2=[]
for i in range(2,len(gy)-2):
    if gy[i]<gy[i-2] and gy[i]<=gy[i+2] and gy[i] < gy.mean()*0.75:
        if not peaks2 or i-peaks2[-1]>8: peaks2.append(i+280)
print("row gaps", peaks2, "diffs", np.diff(peaks2).tolist() if len(peaks2)>1 else None)
