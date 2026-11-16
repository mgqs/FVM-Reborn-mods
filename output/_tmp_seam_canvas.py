import numpy as np
from PIL import Image
def seams_img(im, axis, a0,a1,b0,b1, k=0.8, md=9):
    a=np.asarray(im.convert("L")).astype(np.float32)
    if axis=="x": prof=np.abs(np.diff(a[b0:b1,a0:a1],axis=1)).mean(axis=0)
    else: prof=np.abs(np.diff(a[a0:a1,b0:b1],axis=0)).mean(axis=1)
    thr=prof.mean()+prof.std()*k
    idx=np.where(prof>=thr)[0]; out=[]
    for i in idx:
        if not out or i-out[-1]>=md: out.append(int(i))
        elif prof[i]>prof[out[-1]]: out[-1]=int(i)
    return [p+a0 for p in out], np.round(np.diff(out),1).tolist() if len(out)>1 else []
for name in ["align_zhuore","align_shuihuo_a","align_shuihuo_b","align_wudu","align_nightmare_sky","align_castle","align_old_zhuore"]:
    try: im=Image.open("output/_tmp_grid/%s.png"%name)
    except Exception as e: print(name,"MISSING"); continue
    xs=seams_img(im,"x",700,1660,240,1000)
    ys=seams_img(im,"y",240,1000,700,1660)
    print(name)
    print("   X", xs)
    print("   Y", ys)
