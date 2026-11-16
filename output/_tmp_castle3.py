import glob
import numpy as np
from PIL import Image

fp = sorted(glob.glob("sprites/spr_mod_ancient_castle_0/*.png"))[0]
a = np.asarray(Image.open(fp).convert("RGB")).astype(np.float32)
H,W,_ = a.shape
mx=a.max(axis=2); mn=a.min(axis=2)
sat=np.where(mx>1,(mx-mn)/np.maximum(mx,1)*255,0)
slate = ((sat<45)&(mx>85)&(mx<185)).astype(np.float32)
# 限制在棋盘区
sub = slate[290:910, 790:1600]
print("frac", round(float(sub.mean()),3), "sub", sub.shape)
# 边缘绝对值梯度
gx = np.abs(np.diff(sub, axis=1)).mean(axis=0)
gy = np.abs(np.diff(sub, axis=0)).mean(axis=1)
def ac(p):
    s=p-p.mean(); n=len(s)
    F=np.fft.rfft(s,2*n); r=np.fft.irfft(F*np.conj(F))[:n]; return r/(r[0]+1e-9)
acx, acy = ac(gx), ac(gy)
def toppeaks(v, lo=60, hi=140):
    out=[(float(v[i]), i) for i in range(lo, min(hi,len(v)-2)) if v[i]>v[i-1] and v[i]>=v[i+1]]
    out.sort(reverse=True)
    return [(round(s,2), p) for s,p in out[:5]]
print("X pitch candidates:", toppeaks(acx))
print("Y pitch candidates:", toppeaks(acy))
# 直接找缝：梯度极大（石板有暗缝）
def peaks(v, k=2.0, md=15):
    thr=v.mean()+v.std()*k
    idx=np.where(v>=thr)[0]; out=[]
    for i in idx:
        if not out or i-out[-1]>=md: out.append(int(i))
        elif v[i]>v[out[-1]]: out[-1]=int(i)
    return out
px = peaks(gx); py = peaks(gy)
print("X grad peaks(+790):", [p+790 for p in px], "diff", np.diff(px).tolist())
print("Y grad peaks(+290):", [p+290 for p in py], "diff", np.diff(py).tolist())
