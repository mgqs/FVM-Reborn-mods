import glob, os, json, re
import numpy as np
from PIL import Image

def frame0(spr):
    return sorted(glob.glob(os.path.join("sprites", spr, "*.png")))[0]

def autocorr_pitch(a, axis, lo, hi, ywin=(0.10,0.90), xwin=(0.10,0.90), topk=4):
    H,W = a.shape
    if axis=="x":
        p = np.abs(np.diff(a[int(H*ywin[0]):int(H*ywin[1]), :], axis=1)).mean(axis=0)
    else:
        p = np.abs(np.diff(a[:, int(W*xwin[0]):int(W*xwin[1])], axis=0)).mean(axis=1)
    s = p - p.mean(); n=len(s)
    F = np.fft.rfft(s, 2*n)
    ac = np.fft.irfft(F*np.conj(F))[:n]
    ac /= (ac[0]+1e-9)
    cands=[]
    for i in range(int(lo)+1, min(int(hi), n-2)):
        if ac[i]>ac[i-1] and ac[i]>=ac[i+1]:
            cands.append((float(ac[i]), float(i)))
    cands.sort(reverse=True)
    out=[]
    for sc, pp in cands:
        if all(abs(pp-q[1])>3 for q in out): out.append((sc,pp))
        if len(out)>=topk: break
    return out

def phase_sq(a, axis, pitch, lo_frac=0.0, hi_frac=1.0, ywin=(0.10,0.90), xwin=(0.10,0.90)):
    H,W = a.shape
    if axis=="x":
        p = np.abs(np.diff(a[int(H*ywin[0]):int(H*ywin[1]), :], axis=1)).mean(axis=0)
    else:
        p = np.abs(np.diff(a[:, int(W*xwin[0]):int(W*xwin[1])], axis=0)).mean(axis=1)
    m = p.mean(); s=p.std()+1e-9
    z=(p-m)/s
    n=len(z); x=np.arange(n, dtype=np.float64)
    best=(-9e9, 0.0)
    for q in np.arange(0.0, pitch, 0.05):
        r = (x-q) % pitch
        on = r < pitch*0.30
        off = (r > pitch*0.35) & (r < pitch*0.65)
        if on.sum()<4 or off.sum()<4: continue
        sc = float(z[on].mean()-z[off].mean())
        if sc>best[0]: best=(sc, float(q))
    return best[1], best[0]

for spr in ["spr_wuduyanjiusuo_0","spr_mengyantiankong_0","spr_mod_ancient_castle_0","spr_salad_island_land"]:
    a = np.asarray(Image.open(frame0(spr)).convert("L")).astype(np.float32)
    print("==", spr, Image.open(frame0(spr)).size)
    print("   X ac:", [(round(s,2), round(p,1)) for s,p in autocorr_pitch(a,"x",45,135)])
    print("   Y ac:", [(round(s,2), round(p,1)) for s,p in autocorr_pitch(a,"y",45,135)])
