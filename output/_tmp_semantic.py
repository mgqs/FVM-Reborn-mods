import json,re
import numpy as np
from PIL import Image

def load(p):
    s=open(p,encoding="utf-8-sig").read().replace("\x00","")
    return json.loads(re.sub(r",(\s*[}\]])",r"\1",s))

OX,OY,CW,CH=695,228,107,116

def cells(im, pad=0.30):
    a=np.asarray(im.convert("RGB")).astype(np.float32)
    out=[]
    for r in range(7):
        row=[]
        for c in range(9):
            x0=int(OX+c*CW+CW*pad); x1=int(OX+(c+1)*CW-CW*pad)
            y0=int(OY+r*CH+CH*pad); y1=int(OY+(r+1)*CH-CH*pad)
            # 用整格但去掉边缘也不行，格子相对美术有 -29 偏移；这里按美术格心取样
            yy0=y0-29; yy1=y1-29
            patch=a[max(0,yy0):yy1, x0:x1]
            row.append(patch.reshape(-1,3).mean(axis=0))
        out.append(row)
    return np.array(out)

def report(name, jsonp, imgp):
    d=load(jsonp)
    im=Image.open(imgp)
    m=cells(im)
    R,G,B=m[...,0],m[...,1],m[...,2]
    lava = R>150
    stone = (R>90)&(R<175)&(abs(R-G)<40)&(B>70)
    # 岩浆格：橙红高 R、低 B
    is_lava_map=np.array([[("lava" in (c.get("object") or [])) for c in row] for row in d["map"]])
    hit=0; tot=0
    for r in range(7):
        for c in range(9):
            want = is_lava_map[r][c]
            got = lava[r][c] and not stone[r][c]
            hit += (want==got); tot+=1
    print("%-18s lava-vs-art acc = %.3f  (lava map %d)" % (name, hit/tot, is_lava_map.sum()))
    # 打印 7x9 对比
    for r in range(7):
        print("   map", "".join("#" if is_lava_map[r][c] else "." for c in range(9)),
              " art", "".join("#" if (lava[r][c] and not stone[r][c]) else "." for c in range(9)))

report("zhuore_0", "datafiles/level_data/cross/zhuore_0.json", "output/_tmp_grid/align_zhuore.png")
report("shuihuo_0", "datafiles/level_data/cross/shuihuo_0.json", "output/_tmp_grid/align_shuihuo_a.png")
report("shuihuo_4", "datafiles/level_data/cross/shuihuo_4.json", "output/_tmp_grid/align_shuihuo_b.png")
