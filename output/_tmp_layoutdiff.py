import glob, os, json, re
import numpy as np
from PIL import Image

def load(p):
    s=open(p,encoding="utf-8-sig").read().replace("\x00","")
    s=re.sub(r",(\s*[}\]])",r"\1",s)
    return json.loads(s)
def frame0(spr):
    return sorted(glob.glob(os.path.join("sprites", spr, "*.png")))[0]

def cellmap(lv):
    return [[tuple(c.get("object") or []) for c in row] for row in lv["map"]]

for fam, pat in [("zhuore","zhuore_%d.json"),("shuihuo","shuihuo_%d.json"),("castle","castle-%d.json"),("sky","nightmare_sky-%d.json"),("wudu","wudu_%d.json")]:
    maps=[]
    for i in range(8):
        lv = load("datafiles/level_data/cross/"+pat%i)
        maps.append(cellmap(lv))
    same = all(m==maps[0] for m in maps)
    print("%-8s all-same-layout=%s"%(fam, same))
    if not same:
        for i in range(1,8):
            diff = [(r,c) for r in range(7) for c in range(9) if maps[i][r][c]!=maps[0][r][c]]
            print("   level%d diff cells:"%i, diff)
