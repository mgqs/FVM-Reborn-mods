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
    return canvas

# crop zoom: play area columns 0..1 and rows 0..2 with engine lattice, 3x zoom
for lv_path in ["cross/shuihuo_0.json","cross/zhuore_0.json","cross/wudu_0.json"]:
    lv = load(os.path.join("datafiles/level_data", lv_path))
    c = compose(lv).convert("RGB")
    box = (660, 180, 1180, 660)
    crop = c.crop(box)
    z = crop.resize((crop.width*3, crop.height*3), Image.LANCZOS)
    d = ImageDraw.Draw(z)
    ox, oy = 695, 228
    for k in range(0, 12):
        x = (ox + k*107 - box[0])*3
        d.line([(x,0),(x,z.height)], fill=(0,255,0), width=2)
        d.text((x+4, 4), f"c{k}", fill=(0,255,0))
    for k in range(0, 9):
        y = (oy + k*116 - box[1])*3
        d.line([(0,y),(z.width,y)], fill=(255,0,255), width=2)
        d.text((4, y+2), f"r{k}", fill=(255,0,255))
    out = "output/_tmp_grid/zoom_" + os.path.basename(lv_path).replace(".json","") + ".png"
    z.save(out)
    print(out, z.size)
