import numpy as np, glob, os
from PIL import Image

def prof(path, crop=None):
    im = Image.open(path).convert("RGB")
    if crop: im = im.crop(crop)
    a = np.asarray(im).astype(np.float32)
    g = a.mean(axis=2)
    gx = np.abs(np.diff(g, axis=1)).mean(axis=0)
    gy = np.abs(np.diff(g, axis=0)).mean(axis=1)
    return gx, gy, a.shape

def comb(profile, p_lo, p_hi, p_step=0.02, ph_step=0.5, tol=1):
    """vectorized: score = mean(profile at lattice) - mean(profile at midpoints)"""
    n = len(profile)
    best = (-1e9, None, None)
    ps = np.arange(p_lo, p_hi + 1e-9, p_step)
    for p in ps:
        for ph in np.arange(0.0, p, ph_step):
            idx = np.arange(ph, n-1, p)
            if len(idx) < 6: continue
            on = np.clip(np.round(idx).astype(int), 0, n-2)
            mid = np.clip(np.round(idx + p*0.5).astype(int), 0, n-2)
            sc = profile[on].mean() - profile[mid].mean()
            if sc > best[0]: best = (sc, float(p), float(ph))
    return best

# validate on native salad board (2005x1080) - crop inner board area
p = sorted(glob.glob("sprites/spr_salad_island_land/*.png"))[0]
gx, gy, shape = prof(p, crop=(700, 150, 1660, 1010))
bx = comb(gx, 100, 125, 0.05, 1.0)
by = comb(gy, 108, 125, 0.05, 1.0)
print("SALAD native  X pitch=%.2f phase_local=%.1f abs=%.1f score=%.2f" % (bx[1], bx[2], bx[2]+700, bx[0]))
print("SALAD native  Y pitch=%.2f phase_local=%.1f abs=%.1f score=%.2f" % (by[1], by[2], by[2]+150, by[0]))
