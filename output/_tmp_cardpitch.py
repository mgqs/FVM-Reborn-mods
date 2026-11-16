import numpy as np
from PIL import Image
im = Image.open(r"D:\DSH\home\attachments\v1\objects\04\0487bdbddd653aae59337ed98e3a3ec3d40db55b9c85d522f3642a848933ccd3").convert("RGB")
a = np.asarray(im).astype(np.float32)
print("size", im.size)
# card block region: left ~ x 0..200, y 0..375
sub = a[:, 0:210].mean(axis=2)
def ac(sig):
    s = sig - sig.mean()
    r = np.correlate(s, s, "full")[len(s)-1:]
    return r/(r[0]+1e-9)
colprof = sub.mean(axis=1)  # per row
rowprof = sub.mean(axis=0)  # per col
acy = ac(colprof); acx = ac(rowprof)
def peaks(sig, lo, hi, md=8):
    out=[]
    for p in range(lo, min(hi, len(sig)-2)):
        if sig[p] > sig[p-1] and sig[p] >= sig[p+1] and sig[p] > 0.15:
            if not out or p-out[-1] >= md: out.append(p)
            elif sig[p] > sig[out[-1]]: out[-1]=p
    return [(p, round(float(sig[p]),3)) for p in out]
print("vertical card pitch candidates:", peaks(acy, 20, 200))
print("horizontal card pitch candidates:", peaks(acx, 20, 200))
