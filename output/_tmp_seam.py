import os, glob, json
import numpy as np
from PIL import Image

ENG_X, ENG_Y, CCW, CRH = 695.0, 228.0, 107.0, 116.0
BW, BH = CCW*9, CRH*7

def frame0(spr):
    return sorted(glob.glob(os.path.join("sprites", spr, "*.png")))[0]

def profs(a, ywin=(0.25,0.75), xwin=(0.25,0.75)):
    H,W = a.shape
    gx = np.abs(np.diff(a[int(H*ywin[0]):int(H*ywin[1]), :], axis=1)).mean(axis=0)
    gy = np.abs(np.diff(a[:, int(W*xwin[0]):int(W*xwin[1])], axis=0)).mean(axis=1)
    return gx, gy

def seam_scan(g, p_range, tol=2.5, min_run=6):
    n = len(g)
    best = None
    for p in np.arange(p_range[0], p_range[1]+1e-9, 0.02):
        kmax = int(n/p)
        if kmax < min_run: continue
        for ph in np.arange(0.0, p, 0.5):
            pos = ph + np.arange(0, kmax)*p
            pos = pos[(pos > 1) & (pos < n-2)]
            if len(pos) < min_run: continue
            found = []; offs = []
            for q in pos:
                lo, hi = int(max(1,q-tol)), int(min(n-2,q+tol))
                if hi <= lo: continue
                seg = g[lo:hi+1]
                j = int(np.argmax(seg))
                if seg[j] > 0:  # any local peak
                    found.append(lo+j); offs.append(lo+j-q)
            if len(found) < min_run: continue
            offs = np.array(offs)
            # 取连续段最多的
            sc = len(found) - 0.5*np.abs(offs).std()
            if best is None or sc > best[0]:
                best = (sc, float(p), float(ph), np.array(found, dtype=float), float(np.abs(offs).mean()))
    return best

def board_from_seams(found, p):
    f = found
    # 只留间距≈p 的连续段
    keep=[f[0]]
    for q in f[1:]:
        if abs((q-keep[-1]) - p) < p*0.12: keep.append(q)
        else:
            if len(keep) >= 7: break
            keep=[q]
    keep=np.array(keep)
    if len(keep) < 7: return None
    n = len(keep)-1
    pitch = (keep[-1]-keep[0])/n
    return keep[0], keep[-1], n, pitch

CUR = {
 "spr_mengyantiankong_0": (2,10,1.777,1.884),
 "spr_mod_ancient_castle_0": (0,0,1.0,1.0),
 "spr_zhuorediyu": (9,42,1.786,1.798),
 "spr_shuihuozhijian_0": (17,43,1.775,1.805),
 "spr_shuihuozhijian_1": (21,44,1.7765,1.811),
 "spr_wuduyanjiusuo_0": (2,36,1.8,1.8),
}
out={}
for spr,(cx,cy,csx,csy) in CUR.items():
    a = np.asarray(Image.open(frame0(spr)).convert("L")).astype(np.float32)
    H,W = a.shape
    gx, gy = profs(a)
    bx = seam_scan(gx, (50,70)); by = seam_scan(gy, (55,75))
    Sx = board_from_seams(bx[3], bx[1]); Sy = board_from_seams(by[3], by[1])
    print("==", spr, "art", W, H)
    print("   X seam p=%.2f run=%d  bbox=%s"%(bx[1], len(bx[3]), Sx))
    print("   Y seam p=%.2f run=%d  bbox=%s"%(by[1], len(by[3]), Sy))
    if Sx and Sy:
        sx = BW/ (Sx[0] and (Sx[1]-Sx[0]) or 1) * (9/ Sx[2]) if False else BW/((Sx[1]-Sx[0])*9/Sx[2])
        sy = BH/((Sy[1]-Sy[0])*7/Sy[2])
        x = ENG_X - Sx[0]*sx
        y = ENG_Y - Sy[0]*sy
        out[spr]=dict(x=round(float(x),2), y=round(float(y),2), sx=round(float(sx),4), sy=round(float(sy),4),
                      cells_x=Sx[2], cells_y=Sy[2], cur=[cx,cy,csx,csy])
        print("   -> {x:%.1f, y:%.1f, sx:%.4f, sy:%.4f}  (cells %d x %d) cur=%s  dpx=%+.0f dpy=%+.0f"%(
            x,y,sx,sy,Sx[2],Sy[2],(cx,cy,csx,csy), x-cx, y-cy))
json.dump(out, open("output/_tmp_grid/seamfit.json","w"), indent=1, ensure_ascii=False)
