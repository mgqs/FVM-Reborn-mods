import numpy as np
from PIL import Image
p=r"D:\DSH\home\attachments\v1\objects\04\0487bdbddd653aae59337ed98e3a3ec3d40db55b9c85d522f3642a848933ccd3"
a=np.asarray(Image.open(p).convert("RGB")).astype(np.float32)
H,W,_=a.shape
r,g,b=a[:,:,0],a[:,:,1],a[:,:,2]
mx=a.max(axis=2); mn=a.min(axis=2)
sat=np.where(mx>1,(mx-mn)/np.maximum(mx,1)*255,0)
# 紫灰石板：b>r, 亮度中等
tile=((b>r+8)&(b>g+8)&(mx>70)&(mx<190)&(sat<110))
print("tile frac", round(float(tile.mean()),3))
colf=tile.mean(axis=0); rowf=tile.mean(axis=1)
def spans(v, thr):
    idx=np.where(v>thr)[0]
    if not len(idx): return []
    gs=[[idx[0]]]
    for i in idx[1:]:
        if i-gs[-1][-1]<=3: gs[-1].append(i)
        else: gs.append([i])
    return [(int(g[0]),int(g[-1])) for g in gs]
print("col spans", spans(colf, colf.max()*0.35))
print("row spans", spans(rowf, rowf.max()*0.35))
# 每个 span 的中线（格中心候选）
cs=[ (s[0]+s[1])/2 for s in spans(colf, colf.max()*0.35)]
rs=[ (s[0]+s[1])/2 for s in spans(rowf, rowf.max()*0.35)]
print("col centers", [round(c,1) for c in cs], "diff", np.round(np.diff(cs),1).tolist())
print("row centers", [round(c,1) for c in rs], "diff", np.round(np.diff(rs),1).tolist())
