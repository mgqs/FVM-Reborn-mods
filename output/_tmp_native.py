import os, glob, json, re
from PIL import Image, ImageDraw

def load(path):
    s = open(path, encoding="utf-8-sig").read().replace("\x00","")
    s = re.sub(r",(\s*[}\]])", r"\1", s)
    return json.loads(s)

def compose(lv, W=1920, H=1080):
    spr = lv["map_sprite"]
    png = sorted(glob.glob(os.path.join("sprites", spr, "*.png")))[0]
    im = Image.open(png).convert("RGBA")
    bd = lv.get("bg_draw")
    canvas = Image.new("RGBA", (W,H), (0,0,0,255))
    if bd:
        w = max(1,int(round(im.width*bd["sx"]))); h = max(1,int(round(im.height*bd["sy"])))
        im2 = im.resize((w,h), Image.LANCZOS)
        canvas.paste(im2, (int(round(bd["x"])), int(round(bd["y"]))), im2)
    else:
        canvas.paste(im, (0,0))
    return canvas, im.size

# native map calibration: find a tower level with a painted tile grid
cands = sorted(glob.glob("datafiles/level_data/tower/*.json"))[:8] + sorted(glob.glob("datafiles/level_data/volcanic/*.json"))[:4]
for p in cands[:6]:
    lv = load(p)
    c, size = compose(lv)
    print(os.path.basename(p), lv["map_sprite"], size, "bg_draw" in lv)
