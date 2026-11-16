import os, glob, json
from PIL import Image
import numpy as np

CROSS = "datafiles/level_data/cross"

def load_bg(level_json):
    s = open(level_json, encoding="utf-8").read()
    spr = json.loads(s)["map_sprite"]
    bd = json.loads(s).get("bg_draw")
    png = sorted(glob.glob(os.path.join("sprites", spr, "*.png")))[0]
    return spr, bd, Image.open(png).convert("RGBA")

def to_screen(im, bd):
    W,H = 1920,1080
    canvas = Image.new("RGBA",(W,H),(0,0,0,0))
    if bd is None:
        canvas.paste(im,(0,0))
    else:
        sw = int(round(im.width*bd["sx"])); sh = int(round(im.height*bd["sy"]))
        im2 = im.resize((sw,sh), Image.LANCZOS)
        canvas.paste(im2,(int(round(bd["x"])),int(round(bd["y"]))), im2)
    return canvas

def lattice_score(profile, p, phase, n_expect):
    """mean of profile at lattice positions phase + k*p"""
    n = len(profile)
    vals=[]
    k=0
    while True:
        idx = phase + k*p
        if idx > n-2: break
        i0=int(round(idx))
        vals.append(max(profile[max(0,i0-2):i0+3].max(),0))
        k+=1
    if len(vals) < 4: return -1, len(vals)
    return float(np.mean(vals)), len(vals)

def best_lattice(profile, pmin, pmax, pstep=0.05):
    best=(-1e9,None,None)
    p=pmin
    while p<=pmax+1e-9:
        ph=0.0
        while ph<p:
            sc,n = lattice_score(profile,p,ph,0)
            if sc>best[0]: best=(sc,p,ph)
            ph+=0.25
        p+=pstep
    return best

def profiles(canvas):
    a=np.asarray(canvas.convert("RGB")).astype(np.float32)
    alpha=np.asarray(canvas.split()[-1]).astype(np.float32)
    g=a.mean(axis=2)
    gx=np.abs(np.diff(g,axis=1)).mean(axis=0)
    gy=np.abs(np.diff(g,axis=0)).mean(axis=1)
    axm=np.abs(np.diff(alpha,axis=1)).mean(axis=0)
    aym=np.abs(np.diff(alpha,axis=0)).mean(axis=1)
    return gx+axm, gy+aym

levels = ["cross/wudu_0.json","cross/zhuore_0.json","cross/shuihuo_0.json","cross/shuihuo_4.json","cross/nightmare_sky-0.json","cross/castle-0.json"]
for lv in levels:
    path=os.path.join("datafiles/level_data",lv)
    spr,bd,im = load_bg(path)
    canvas = to_screen(im,bd)
    gx,gy = profiles(canvas)
    bx = best_lattice(gx, 104, 110)
    by = best_lattice(gy, 113, 119)
    print(f"{lv:26s} {spr}")
    print(f"   screen X lattice: pitch={bx[1]:.2f} phase={bx[2]:.2f} score={bx[0]:.2f}  (engine 107.0 / 695.0)")
    print(f"   screen Y lattice: pitch={by[1]:.2f} phase={by[2]:.2f} score={by[0]:.2f}  (engine 116.0 / 228.0)")
