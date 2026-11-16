import os, glob, json, re
import numpy as np
from PIL import Image

def load(path):
    s = open(path, encoding="utf-8-sig").read().replace("\x00","")
    s = re.sub(r",(\s*[}\]])", r"\1", s)
    return json.loads(s)

def art_of(spr):
    png = sorted(glob.glob(os.path.join("sprites", spr, "*.png")))[0]
    return Image.open(png).convert("RGB")

def comb(img, lo, hi, p_step=0.05, ph_step=0.25, region=None):
    im = img.crop(region) if region else img
    a = np.asarray(im).astype(np.float32).mean(axis=2)
    gx = np.abs(np.diff(a, axis=1)).mean(axis=0)
    gy = np.abs(np.diff(a, axis=0)).mean(axis=1)
    def best(prof):
        n=len(prof); b=(-1e9,None,None)
        for p in np.arange(lo, hi+1e-9, p_step):
            for ph in np.arange(0.0, p, ph_step):
                idx = np.arange(ph, n-1, p)
                if len(idx) < 6: continue
                on = np.clip(np.round(idx).astype(int),0,n-2)
                mid = np.clip(np.round(idx+p*0.5).astype(int),0,n-2)
                sc = prof[on].mean() - prof[mid].mean()
                if sc > b[0]: b=(sc,float(p),float(ph))
        return b
    return best(gx), best(gy)

levels = ["cross/castle-0.json","cross/nightmare_sky-0.json","cross/zhuore_0.json","cross/shuihuo_0.json","cross/shuihuo_4.json","cross/wudu_0.json"]
ENG = dict(ox=695.0, oy=228.0, cx=107.0, cy=116.0)
print("%-24s %-26s | artPitch(x,y) | mapped0 dx,dy | mapped pitch | drift@c8 | drift@r6"%("level","sprite"))
for lv_path in levels:
    lv = load(os.path.join("datafiles/level_data", lv_path))
    spr = lv["map_sprite"]; bd = lv.get("bg_draw") or {"x":0,"y":0,"sx":1.0,"sy":1.0}
    img = art_of(spr)
    (scx, axp, axph), (scy, ayp, ayph) = comb(img, 52.0, 70.0)
    sx, sy, bx, by = bd["sx"], bd["sy"], bd["x"], bd["y"]
    c0x = bx + (axph + axp*0.5)*sx
    c0y = by + (ayph + ayp*0.5)*sy
    dx = c0x - (ENG["ox"] + ENG["cx"]*0.5)
    dy = c0y - (ENG["oy"] + ENG["cy"]*0.5)
    mpx, mpy = axp*sx, ayp*sy
    print("%-24s %-26s | %6.2f,%6.2f | %+7.1f,%+7.1f | %6.2f,%6.2f | %+7.1f | %+7.1f"%(
        lv_path, spr, axp, ayp, dx, dy, mpx, mpy, dx+8*(mpx-ENG["cx"]), dy+6*(mpy-ENG["cy"])))
