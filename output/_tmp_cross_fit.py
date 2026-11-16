import os, glob, json, re
import numpy as np
from PIL import Image

BASE = "datafiles/level_data/cross"

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
        canvas.paste(im, (0,0))
    return canvas, im.size, bd

def seams(gray, axis, k=0.8, md=25):
    if axis == "x":
        sig = np.abs(np.diff(gray, axis=1)).mean(axis=0)
    else:
        sig = np.abs(np.diff(gray, axis=0)).mean(axis=1)
    thr = sig.mean()+sig.std()*k
    idx = np.where(sig>=thr)[0]
    out=[]
    for i in idx:
        if not out or i-out[-1]>=md: out.append(int(i))
        elif sig[i]>sig[out[-1]]: out[-1]=int(i)
    return sig, np.array(out)

def fit(peaks, p0):
    """least squares x = a + k*p with integer k"""
    if len(peaks) < 3: return None
    a, p = peaks[0], p0
    for _ in range(8):
        k = np.round((peaks - a)/p)
        A = np.vstack([np.ones_like(k), k]).T
        sol, *_ = np.linalg.lstsq(A, peaks.astype(float), rcond=None)
        a, p = sol[0], sol[1]
    res = peaks - (a + k*p)
    return a, p, len(peaks), float(np.abs(res).max())

print("native salad reference: pitch 107/116, engine ox=695 oy=228, art row offset -31")
for name in sorted(os.listdir(BASE)):
    if not name.endswith(".json"): continue
    lv = load(os.path.join(BASE, name))
    canvas, size, bd = compose(lv)
    a = np.asarray(canvas.convert("RGB")).astype(np.float32)
    gray = a.mean(axis=2)[120:1060, 640:1700]
    sx, px = seams(gray, "x")
    sy, py = seams(gray, "y")
    fx = fit(px+640, 107.0); fy = fit(py+120, 116.0)
    def s(f):
        if not f: return "n/a"
        return f"pitch={f[1]:7.2f} first={f[0]:7.1f} n={f[2]:2d} maxres={f[3]:5.1f}"
    print(f"{name:22s} {lv['map_sprite']:26s}")
    print(f"    X {s(fx)}")
    print(f"    Y {s(fy)}")
