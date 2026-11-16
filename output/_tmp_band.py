import glob, os
import numpy as np
from PIL import Image

def f0(spr): return sorted(glob.glob(os.path.join("sprites", spr, "*.png")))[0]

def band_seams(spr, axis, a0, a1, b0, b1, thr_k=1.0, md=8):
    a = np.asarray(Image.open(f0(spr)).convert("L")).astype(np.float32)
    if axis=="x":
        sub = a[b0:b1, a0:a1]
        prof = np.abs(np.diff(sub, axis=1)).mean(axis=0)
    else:
        sub = a[a0:a1, b0:b1]
        prof = np.abs(np.diff(sub, axis=0)).mean(axis=1)
    thr = prof.mean()+prof.std()*thr_k
    idx=np.where(prof>=thr)[0]; out=[]
    for i in idx:
        if not out or i-out[-1]>=md: out.append(int(i))
        elif prof[i]>prof[out[-1]]: out[-1]=int(i)
    pos = [p+(a0 if axis=="x" else a0) for p in out]
    return pos, np.round(np.diff(out),1).tolist() if len(out)>1 else []

# wudu: 純地板帶（y 300..420, x 300..1100）
print("wudu X seams:", band_seams("spr_wuduyanjiusuo_0","x",300,1100,300,420))
print("wudu Y seams:", band_seams("spr_wuduyanjiusuo_0","y",120,560,400,900))
print("sky  X seams:", band_seams("spr_mengyantiankong_0","x",320,1000,180,420))
print("sky  Y seams:", band_seams("spr_mengyantiankong_0","y",120,570,380,950))
print("castle X seams:", band_seams("spr_mod_ancient_castle_0","x",800,1600,340,860))
print("castle Y seams:", band_seams("spr_mod_ancient_castle_0","y",300,900,850,1500))
print("salad X seams:", band_seams("spr_salad_island_land","x",650,1700,200,1000))
print("salad Y seams:", band_seams("spr_salad_island_land","y",150,1050,700,1600))
