import numpy as np
from PIL import Image
p = r"D:\DSH\home\attachments\v1\objects\04\0487bdbddd653aae59337ed98e3a3ec3d40db55b9c85d522f3642a848933ccd3"
im = Image.open(p).convert("RGB")
a = np.asarray(im).astype(np.float32)
H,W,_ = a.shape
mx = a.max(axis=2); mn = a.min(axis=2)
sat = mx-mn
# bright saturated = card halos / cards
mask = (mx>140)&(sat>60)
print("mask frac", mask.mean().round(3))
colprof = mask.sum(axis=0); rowprof = mask.sum(axis=1)
def peaks(prof, minv, md=10):
    out=[]
    for i in range(2, len(prof)-2):
        if prof[i]>=prof[i-2:i+3].max() and prof[i]>minv:
            if not out or i-out[-1]>=md: out.append(i)
            elif prof[i]>prof[out[-1]]: out[-1]=i
    return out
px = peaks(colprof, colprof.mean()*1.2)
py = peaks(rowprof, rowprof.mean()*1.2)
print("card col peaks", px, "diffs", np.diff(px).tolist())
print("card row peaks", py, "diffs", np.diff(py).tolist())
# background tile seams: purple/dark tiles -> use gradient on low-saturation region
low = (sat<70)&(mx<170)&(mx>40)
print("low-sat frac", low.mean().round(3))
sub = np.where(low, a.mean(axis=2), np.nan)
# column-wise gradient inside x 100..400
reg = a[:, 240:446].mean(axis=2)
gx = np.abs(np.diff(reg, axis=1)).mean(axis=0)
print("right-region top X gradients:", [(i+240, round(float(v),1)) for i,v in enumerate(gx) if v>gx.mean()+gx.std()][:40])
