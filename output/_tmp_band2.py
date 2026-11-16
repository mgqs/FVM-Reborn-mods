import glob, os
import numpy as np
from PIL import Image
def f0(spr): return sorted(glob.glob(os.path.join("sprites", spr, "*.png")))[0]
def seams(spr, axis, a0, a1, b0, b1, k=0.8, md=9):
    a = np.asarray(Image.open(f0(spr)).convert("L")).astype(np.float32)
    if axis=="x":
        prof = np.abs(np.diff(a[b0:b1, a0:a1], axis=1)).mean(axis=0)
    else:
        prof = np.abs(np.diff(a[a0:a1, b0:b1], axis=0)).mean(axis=1)
    thr = prof.mean()+prof.std()*k
    idx=np.where(prof>=thr)[0]; out=[]
    for i in idx:
        if not out or i-out[-1]>=md: out.append(int(i))
        elif prof[i]>prof[out[-1]]: out[-1]=int(i)
    return [p+a0 for p in out], np.round(np.diff(out),1).tolist() if len(out)>1 else []
print("zhuore X:", seams("spr_zhuorediyu","x",350,980,150,520))
print("zhuore Y:", seams("spr_zhuorediyu","y",90,570,380,960))
print("shuihuo0 X:", seams("spr_shuihuozhijian_0","x",330,960,150,520))
print("shuihuo0 Y:", seams("spr_shuihuozhijian_0","y",90,570,380,960))
print("shuihuo1 X:", seams("spr_shuihuozhijian_1","x",330,960,150,520))
print("shuihuo1 Y:", seams("spr_shuihuozhijian_1","y",90,570,380,960))
