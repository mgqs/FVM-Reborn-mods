import numpy as np, glob
from PIL import Image
p = sorted(glob.glob("sprites/spr_salad_island_land/*.png"))[0]
a = np.asarray(Image.open(p).convert("RGB")).astype(np.float32)
g = a.mean(axis=2)
# checkerboard region roughly x 650..1650, y 120..1000
sub = g[120:1010, 640:1660]
gx = np.abs(np.diff(sub, axis=1)).mean(axis=0)
gy = np.abs(np.diff(sub, axis=0)).mean(axis=1)
def peaks(sig, k=0.8, md=40):
    thr = sig.mean()+sig.std()*k
    idx=np.where(sig>=thr)[0]; out=[]
    for i in idx:
        if not out or i-out[-1]>=md: out.append(int(i))
        elif sig[i]>sig[out[-1]]: out[-1]=int(i)
    return out
px = peaks(gx); py = peaks(gy)
print("X peaks (abs):", [p+640 for p in px])
print("X diffs:", np.diff([p+640 for p in px]).tolist())
print("Y peaks (abs):", [p+120 for p in py])
print("Y diffs:", np.diff([p+120 for p in py]).tolist())
