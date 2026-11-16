import numpy as np, glob
from PIL import Image

def seams(path, region=None, k=0.9, md=25):
    im = Image.open(path).convert("RGB")
    x0,y0 = (region[0], region[1]) if region else (0,0)
    if region: im = im.crop(region)
    a = np.asarray(im).astype(np.float32).mean(axis=2)
    gx = np.abs(np.diff(a, axis=1)).mean(axis=0)
    gy = np.abs(np.diff(a, axis=0)).mean(axis=1)
    def pk(sig):
        thr = sig.mean()+sig.std()*k
        idx = np.where(sig>=thr)[0]; out=[]
        for i in idx:
            if not out or i-out[-1]>=md: out.append(int(i))
            elif sig[i]>sig[out[-1]]: out[-1]=int(i)
        return np.array(out, dtype=float)
    return pk(gx)+x0+1, pk(gy)+y0+1

def lsq(peaks, p0, tol=0.35):
    if len(peaks) < 4: return None
    a, p = peaks[0], p0
    for _ in range(10):
        k = np.round((peaks-a)/p)
        keep = np.abs(peaks-(a+k*p)) < tol*p
        if keep.sum() < 4: break
        A = np.vstack([np.ones(keep.sum()), k[keep]]).T
        sol,*_ = np.linalg.lstsq(A, peaks[keep], rcond=None)
        a, p = sol[0], sol[1]
    res = peaks[keep]-(a+k[keep]*p)
    return a, p, int(keep.sum()), float(np.abs(res).max())

p = sorted(glob.glob("sprites/spr_salad_island_land/*.png"))[0]
px, py = seams(p, (650,120,1680,1040))
print("native X peaks", px.tolist())
print("native Y peaks", py.tolist())
print("X fit", lsq(px, 107.0))
print("Y fit", lsq(py, 116.0))
