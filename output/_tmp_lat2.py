import os, glob, json
import numpy as np
from PIL import Image

CROSS = "datafiles/level_data/cross"
ENGINE = dict(ox=695.0, oy=228.0, cx=107.0, cy=116.0, cols=9, rows=7)

def read_level(path):
    s = open(path, encoding="utf-8").read()
    # tolerate trailing NUL / trailing commas
    s = s.replace("\x00","")
    return json.loads(s) if False else None

def load(path):
    s = open(path, encoding="utf-8-sig").read().replace("\x00","")
    import re
    s2 = re.sub(r",(\s*[}\]])", r"\1", s)
    return json.loads(s2)

def compose(level, W=1920, H=1080):
    spr = level["map_sprite"]
    png = sorted(glob.glob(os.path.join("sprites", spr, "*.png")))[0]
    im = Image.open(png).convert("RGBA")
    bd = level.get("bg_draw")
    canvas = Image.new("RGBA", (W,H), (0,0,0,255))
    if bd:
        w = max(1,int(round(im.width*bd["sx"]))); h = max(1,int(round(im.height*bd["sy"])))
        im2 = im.resize((w,h), Image.LANCZOS)
        canvas.paste(im2, (int(round(bd["x"])), int(round(bd["y"]))), im2)
    else:
        canvas.paste(im, (0,0), im)
    return spr, bd, canvas

def edge_profiles(img, x0, x1, y0, y1):
    a = np.asarray(img.crop((x0,y0,x1,y1)).convert("RGB")).astype(np.float32)
    g = a.mean(axis=2)
    gx = np.abs(np.diff(g, axis=1)).mean(axis=0)
    gy = np.abs(np.diff(g, axis=0)).mean(axis=1)
    return gx, gy

def peaks(sig, k=1.2, min_dist=20):
    thr = sig.mean() + sig.std()*k
    idx = np.where(sig >= thr)[0]
    out=[]
    for i in idx:
        if not out or i-out[-1] >= min_dist:
            out.append(int(i))
        elif sig[i] > sig[out[-1]]:
            out[-1]=int(i)
    return out

def subpix(sig, i):
    if i<=0 or i>=len(sig)-1: return float(i)
    a,b,c = sig[i-1], sig[i], sig[i+1]
    d = a-2*b+c
    if abs(d) < 1e-9: return float(i)
    return i + 0.5*(a-c)/d

def fit_lattice(plist, p0):
    """assign integer indices, least-squares fit x = phase + k*pitch"""
    if len(plist) < 4: return None
    ph = plist[0]
    for _ in range(6):
        k = np.array([round((x-ph)/p0) for x in plist], dtype=float)
        A = np.vstack([np.ones_like(k), k]).T
        sol, *_ = np.linalg.lstsq(A, np.array(plist), rcond=None)
        ph, p0 = sol[0], sol[1]
    resid = np.array(plist) - (ph + k*p0)
    return ph, p0, len(plist), float(np.abs(resid).max())

for name in sorted(os.listdir(CROSS)):
    if not name.endswith(".json"): continue
    path = os.path.join(CROSS, name)
    lv = load(path)
    spr, bd, canvas = compose(lv)
    # measure inside engine play area, widened by half a cell
    gx, gy = edge_profiles(canvas, 640, 1740, 180, 1060)
    px = peaks(gx); py = peaks(gy)
    fx = fit_lattice(px, ENGINE["cx"])
    fy = fit_lattice(py, ENGINE["cy"])
    def fmt(f, base):
        if not f: return "n/a"
        ph,p,n,mx = f
        # first line index 0 = engine first boundary -> offset
        return f"pitch={p:7.2f} phase={ph+640:8.2f} n={n:2d} maxres={mx:5.2f} vsEng={p-base:+6.2f}"
    print(f"{name:22s} {spr:28s} bd={'yes' if bd else 'no '}")
    print(f"   X {fmt(fx, ENGINE['cx'])}")
    print(f"   Y {fmt(fy, ENGINE['cy'])}")
