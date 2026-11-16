import glob, os, json, re
import numpy as np
from PIL import Image, ImageDraw

ENG = dict(ox=695.0, oy=228.0, cw=107.0, ch=116.0)
def load(p):
    s=open(p,encoding="utf-8-sig").read().replace("\x00","")
    s=re.sub(r",(\s*[}\]])",r"\1",s)
    return json.loads(s)
def frame0(spr):
    return sorted(glob.glob(os.path.join("sprites", spr, "*.png")))[0]

def render(lvpath, spr, cands, outname, tag="lava"):
    lv = load(lvpath); mp = lv["map"]
    art = Image.open(frame0(spr)).convert("RGBA")
    tiles = []
    for (x,y,sx,sy) in cands:
        canvas = Image.new("RGBA",(1920,1080),(10,10,10,255))
        big = art.resize((int(art.width*sx), int(art.height*sy)), Image.BILINEAR)
        canvas.alpha_composite(big, (int(round(x)), int(round(y))))
        d = ImageDraw.Draw(canvas, "RGBA")
        for r in range(len(mp)):
            for c in range(len(mp[r])):
                wx0 = ENG["ox"]+c*ENG["cw"]; wy0 = ENG["oy"]+r*ENG["ch"]
                has = tag in (mp[r][c].get("object") or [])
                col = (255,0,0,70) if has else (0,255,0,45)
                d.rectangle([wx0+2,wy0+2,wx0+ENG["cw"]-2,wy0+ENG["ch"]-2], fill=col)
                d.rectangle([wx0,wy0,wx0+ENG["cw"],wy0+ENG["ch"]], outline=(0,255,255,140))
        d.text((10,10), "x=%.1f y=%.1f sx=%.4f sy=%.4f"%(x,y,sx,sy), fill=(255,255,0,255))
        tiles.append(canvas.crop((600,150,1720,1060)))
    W,H = tiles[0].size
    sheet = Image.new("RGBA",(W*len(tiles), H),(0,0,0,255))
    for i,t in enumerate(tiles): sheet.alpha_composite(t,(i*W,0))
    sheet.convert("RGB").save(outname)
    print(outname, sheet.size)

render("datafiles/level_data/cross/zhuore_0.json","spr_zhuorediyu",
       [(9,42,1.786,1.798),(116.9,34.6,1.7869,1.7996)], "output/_tmp_grid/cand_zhuore.png")
