import sys; sys.path.insert(0,'tools')
import zhuore_build as B, zhuore_spec as S
from PIL import Image
import numpy as np

def norm(im, n=64):
    im = im.convert('RGBA')
    bb = im.split()[3].getbbox()
    if bb: im = im.crop(bb)
    return np.asarray(im.resize((n, n), Image.LANCZOS), dtype=np.float32)

rows = []
for m in S.MICE:
    for suffix, old, total, segs in m["sprites"]:
        new = B.sprite_name(m["key"], suffix)
        ds = []
        for i in range(total):
            a = norm(B.frame_image(new, i)); b = norm(B.frame_image(old, i))
            ds.append(float(np.abs(a - b).mean()))
        ds = np.array(ds)
        rows.append((m["key"], suffix, ds.mean(), ds.max(), int(ds.argmax())))

rows.sort(key=lambda r: -r[3])
print("%-14s %-8s  %6s %6s %5s" % ("鼠", "精灵", "均差", "最大差", "帧"))
for r in rows:
    print("%-14s %-8s  %6.2f %6.2f %5d" % (r[0], r[1], r[2], r[3], r[4]))
