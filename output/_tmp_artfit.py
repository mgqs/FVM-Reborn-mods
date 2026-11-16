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

def comb_art(img, lo, hi, p_step=0.02, ph_step=0.25, region=None):
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
                sc = prof[on].mean() - 0.5*(prof[np.clip(on+1,0,n-2)].mean()+prof[np.clip(on-1,0,n-2)].mean())
                sc2 = prof[on].mean() - prof[mid].mean()
                sc = sc2
                if sc > b[0]: b=(sc,float(p),float(ph))
        return b
    return best(gx), best(gy)

levels = ["cross/castle-0.json","cross/nightmare_sky-0.json","cross/zhuore_0.json","cross/shuihuo_0.json","cross/shuihuo_4.json","cross/wudu_0.json"]
ENG = dict(ox=695.0, oy=228.0, cx=107.0, cy=116.0)

print("%-24s %-26s %-8s | artXpitch artXph | artYpitch artYph | mapped dx(col0) dy(row0) | driftX@c8 driftY@r6"%("level","sprite","bg"))
for lv_path in levels:
    lv = load(os.path.join("datafiles/level_data", lv_path))
    spr = lv["map_sprite"]; bd = lv.get("bg_draw")
    img = art_of(spr)
    sx = bd["sx"] if bd else 1.0; sy = bd["sy"] if bd else 1.0
    bx = bd["x"] if bd else 0; by = bd["y"] if bd else 0
    bx_res, by_res = comb_art(img, 55.0, 66.0), comb_art(img, 56.0, 70.0)
    (scx, axp, axph), (scy, ayp, ayph) = bx_res, by_res
    # mapped art cell center for col c: art cell center = axph + c*axp + axp/2? treat axph as first seam
    def art_center(ph, p, i): return ph + i*p + p*0.5
    mx0 = bx + art_center(axph, axp, 0)*sx
    my0 = by + art_center(ayph, ayp, 0)*sy
    e0x = ENG["ox"] + ENG["cx"]*0.5
    e0y = ENG["oy"] + ENG["cy"]*0.5
    mp_x = axp*sx; mp_y = ayp*sy
    drift_x = (mx0 - e0x) + 8*(mp_x - ENG["cx"])
    drift_y = (my0 - e0y) + 6*(mp_y - ENG["cy"])
    print("%-24s %-26s %-8s | %6.2f %6.2f | %6.2f %6.2f | %+8.1f %+8.1f | %+7.1f %+7.1f"%(lv_path, spr, bd is not None and "yes" or "no", axp, axph, ayp, ayph, mx0-e0x, my0-e0y, drift_x, drift_y))
