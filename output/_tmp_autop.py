import numpy as np, glob, os
from PIL import Image

def autopitch(sig, lo, hi):
    s = sig - sig.mean()
    ac = np.correlate(s, s, mode="full")[len(s)-1:]
    ac = ac/ (ac[0]+1e-9)
    best=None
    for p in np.arange(lo, hi, 0.05):
        i = int(np.floor(p)); f = p-i
        v = ac[i]*(1-f) + ac[i+1]*f
        if best is None or v > best[1]: best=(p,v)
    return best

def phase_of(sig, pitch, tol_frac=0.5, coarse=25):
    """best phase with strong narrow peaks; returns (score, phase)"""
    n = len(sig)
    best = (-1e9, 0.0)
    ph = 0.0
    while ph < pitch:
        idx = np.arange(ph, n-1, pitch)
        on = np.clip(np.round(idx).astype(int), 0, n-2)
        mid = np.clip(np.round(idx+pitch*0.5).astype(int), 0, n-2)
        sc = sig[on].mean() - sig[mid].mean()
        if sc > best[0]: best = (sc, ph)
        ph += 0.25
    return best

def measure(path, region, plo, phi, label):
    im = Image.open(path).convert("RGB")
    x0,y0,x1,y1 = region
    a = np.asarray(im.crop(region)).astype(np.float32)
    g = a.mean(axis=2)
    gx = np.abs(np.diff(g, axis=1)).mean(axis=0)
    gy = np.abs(np.diff(g, axis=0)).mean(axis=1)
    px, pxv = autopitch(gx, plo[0], phi[0])
    py, pyv = autopitch(gy, plo[1], phi[1])
    sx, phx = phase_of(gx, px)
    sy, phy = phase_of(gy, py)
    # absolute in image coords: profile index i corresponds to boundary between col i and i+1 -> boundary x = i+1
    ax = x0 + phx + 1.0
    ay = y0 + phy + 1.0
    print(f"{label:30s} pitch=({px:6.2f},{py:6.2f}) ac=({pxv:.2f},{pyv:.2f}) first_seam=({ax:7.2f},{ay:7.2f}) score=({sx:.2f},{sy:.2f})")
    return (px,py,ax,ay)

# calibration on native (1:1) map
p = sorted(glob.glob("sprites/spr_salad_island_land/*.png"))[0]
measure(p, (650,120,1680,1040), (100,108), (114,124), "NATIVE salad_island (1:1)")
