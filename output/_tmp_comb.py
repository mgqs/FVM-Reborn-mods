import os, glob, json, re
import numpy as np
from PIL import Image

BASE = "datafiles/level_data"
ENG = dict(ox=695.0, oy=228.0, cx=107.0, cy=116.0, cols=9, rows=7)

def load(path):
    s = open(path, encoding="utf-8-sig").read().replace("\x00","")
    s = re.sub(r",(\s*[}\]])", r"\1", s)
    return json.loads(s)

def compose(lv, W=1920, H=1080):
    spr = lv["map_sprite"]
    png = sorted(glob.glob(os.path.join("sprites", spr, "*.png")))[0]
    im = Image.open(png).convert("RGBA")
    bd = lv.get("bg_draw")
    canvas = Image.new("RGBA", (W,H), (0,0,0,255))
    if bd:
        w = max(1,int(round(im.width*bd["sx"]))); h = max(1,int(round(im.height*bd["sy"])))
        im2 = im.resize((w,h), Image.LANCZOS)
        canvas.paste(im2, (int(round(bd["x"])), int(round(bd["y"]))), im2)
    else:
        canvas.paste(im, (0,0), im)
    return canvas

def seam_profiles(canvas, x0=700, x1=1685, y0=232, y1=1035):
    a = np.asarray(canvas.crop((x0,y0,x1,y1)).convert("RGB")).astype(np.float32)
    g = a.mean(axis=2)
    # vertical seams -> column profile; horizontal seams -> row profile
    gx = np.abs(np.diff(g, axis=1)).mean(axis=0)
    gy = np.abs(np.diff(g, axis=0)).mean(axis=1)
    return gx, gy, x0, y0

def comb_score(prof, pitch, phase, span):
    n = len(prof)
    on = []; off = []
    k = 0
    while True:
        p = phase + k*pitch
        if p >= n-1: break
        i = int(round(p))
        lo, hi = max(0,i-1), min(n, i+2)
        on.append(prof[lo:hi].max())
        m = int(round(p + pitch*0.5))
        if m < n-1:
            off.append(prof[max(0,m-1):min(n,m+2)].max())
        k += 1
    if len(on) < 5 or not off: return -1e9
    return float(np.mean(on) - np.mean(off))

def best_comb(prof, p_lo, p_hi):
    best = (-1e9, None, None)
    p = p_lo
    while p <= p_hi:
        ph = 0.0
        while ph < p:
            sc = comb_score(prof, p, ph, len(prof))
            if sc > best[0]: best = (sc, p, ph)
            ph += 1.0
        p += 0.05
    return best

def report(path, label):
    lv = load(path)
    c = compose(lv)
    gx, gy, ox, oy = seam_profiles(c)
    sx, px, phx = best_comb(gx, 100.0, 114.0)
    sy, py, phy = best_comb(gy, 108.0, 124.0)
    # convert to absolute screen coords, align nearest to engine grid
    absx = ox + phx; absy = oy + phy
    # residual: nearest engine boundary distance for the comb line closest to engine line 0
    def resid(absphase, pitch, origin):
        k = round((origin - absphase)/pitch)
        return absphase + k*pitch - origin
    rx = resid(absx, px, ENG["ox"]) if px else float('nan')
    ry = resid(absy, py, ENG["oy"]) if py else float('nan')
    return dict(label=label, spr=lv["map_sprite"], bd=lv.get("bg_draw"),
                px=px, py=py, scorex=sx, scorey=sy, rx=rx, ry=ry)

rows = []
for sub in ["cross"]:
    for name in sorted(os.listdir(os.path.join(BASE, sub))):
        if name.endswith(".json"):
            rows.append(report(os.path.join(BASE, sub, name), sub+"/"+name))
for r in rows:
    print(f"{r['label']:24s} {r['spr']:28s} pitchX={r['px']:7.2f} dx={r['rx']:+6.2f}  pitchY={r['py']:7.2f} dy={r['ry']:+6.2f}  scoreX={r['scorex']:.1f} scoreY={r['scorey']:.1f}")
