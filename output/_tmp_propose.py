import os, glob, json
import numpy as np
from PIL import Image

def frame0(spr):
    fs = sorted(glob.glob(os.path.join("sprites", spr, "*.png")))
    return fs[0]

def profs(fp, cx=(0.22,0.78), cy=(0.22,0.78), band=(0.45,0.55)):
    a = np.asarray(Image.open(fp).convert("L")).astype(np.float32)
    H,W = a.shape
    y0,y1 = int(H*cy[0]), int(H*cy[1])
    x0,x1 = int(W*cx[0]), int(W*cx[1])
    # 用竖条带的中段算 X 梯度，避免边框装饰
    bx0,bx1 = int(W*cx[0]), int(W*cx[1])
    gx = np.abs(np.diff(a[y0:y1, :], axis=1)).mean(axis=0)
    gy = np.abs(np.diff(a[:, bx0:bx1], axis=0)).mean(axis=1)
    return gx, gy, (W,H)

def acf_pitch(prof, lo, hi):
    s = prof - prof.mean()
    n = len(s)
    F = np.fft.rfft(s, 2*n)
    ac = np.fft.irfft(F*np.conj(F))[:n]
    ac /= (ac[0]+1e-9)
    best=(-1,0)
    idx = np.arange(int(lo), int(hi)+1)
    for i in idx:
        if ac[i]>ac[i-1] and ac[i]>=ac[i+1] and ac[i]>best[0]: best=(float(ac[i]), float(i))
    return best

def comb(prof, p0, span=1.2, pstep=0.05, phstep=0.25):
    n=len(prof); best=(-1e9,p0,0.0)
    for p in np.arange(p0-span, p0+span+1e-9, pstep):
        for ph in np.arange(0.0, p, phstep):
            idx=np.arange(ph, n-1, p)
            if len(idx)<6: continue
            on=np.clip(np.round(idx).astype(int),0,n-2)
            mid=np.clip(np.round(idx+p*0.5).astype(int),0,n-2)
            sc=float(prof[on].mean()-prof[mid].mean())
            if sc>best[0]: best=(sc,float(p),float(ph))
    return best

ENG = dict(ox=695.0, oy=228.0, cx=107.0, cy=116.0)
cur = {  # 当前 JSON 里的 bg_draw（castle 无）
 "spr_mengyantiankong": (2,10,1.777,1.884),
 "spr_shuihuozhijian_0": (17,43,1.775,1.805),
 "spr_shuihuozhijian_1": (21,44,1.7765,1.811),
 "spr_wuduyanjiusuo": (2,36,1.8,1.8),
 "spr_zhuorediyu": (9,42,1.786,1.798),
 "spr_mod_ancient_castle": (0,0,1.0,1.0),
}
fams = ["spr_mengyantiankong_0","spr_shuihuozhijian_0","spr_shuihuozhijian_1","spr_wuduyanjiusuo_0","spr_zhuorediyu","spr_mod_ancient_castle_0"]
out={}
for spr in fams:
    fp = frame0(spr)
    gx, gy, (W,H) = profs(fp)
    ax_score, ax_guess = acf_pitch(gx, 45, 240)
    ay_score, ay_guess = acf_pitch(gy, 45, 240)
    sx_score, px, phx = comb(gx, ax_guess, span=2.0)
    sy_score, py, phy = comb(gy, ay_guess, span=2.0)
    fam = spr.rsplit("_",1)[0] if not spr.endswith("zhuorediyu") else spr
    bd = cur.get(fam, (0,0,1,1))
    sx_new = ENG["cx"]/px; sy_new = ENG["cy"]/py
    # k 选择：使新 x 最接近原 x
    best=None
    for k in range(-3, 40):
        ax_ = 695.0 - (phx + k*px)*sx_new
        if best is None or abs(ax_-bd[0]) < abs(best[0]-bd[0]): best=(ax_,k)
    x_new, kx = best
    best=None
    for k in range(-3, 40):
        ay_ = 228.0 - (phy + k*py)*sy_new
        if best is None or abs(ay_-bd[1]) < abs(best[1]-bd[1]): best=(ay_,k)
    y_new, ky = best
    out[spr] = dict(art=(W,H), px=px, py=py, phx=phx, phy=phy, sx=round(sx_new,4), sy=round(sy_new,4),
                    x=round(x_new,2), y=round(y_new,2), k=(kx,ky), cur=bd,
                    score=(round(sx_score,2), round(sy_score,2)))
    print("%-26s art=%dx%d  p=(%6.2f,%6.2f) ph=(%6.2f,%6.2f)  -> sx=%.3f sy=%.3f x=%.1f y=%.1f   cur=%s" % (spr, W,H, px,py,phx,phy,sx_new,sy_new,x_new,y_new,bd))
json.dump(out, open("output/_tmp_grid/proposal.json","w",encoding="utf-8"), ensure_ascii=False, indent=1)
