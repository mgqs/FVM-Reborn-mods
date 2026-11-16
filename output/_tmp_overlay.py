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

LEVELS = ["cross/wudu_0.json","cross/zhuore_0.json","cross/shuihuo_0.json","cross/shuihuo_4.json","cross/nightmare_sky-0.json","cross/castle-0.json"]
for lv_path in LEVELS:
    lv = load(os.path.join("datafiles/level_data", lv_path))
    c = compose(lv).convert("RGB")
    d = ImageDraw.Draw(c)
    ox, oy, cx, cy = 695, 228, 107, 116
    for k in range(11):
        x = ox + k*cx
        d.line([(x,0),(x,1080)], fill=(0,255,0), width=2)
    for k in range(9):
        y = oy + k*cy
        d.line([(0,y),(1920,y)], fill=(0,255,0), width=2)
    d.rectangle([ox,oy,ox+9*cx,oy+7*cy], outline=(255,0,0), width=3)
    out = "output/_tmp_grid/ov_" + os.path.basename(lv_path).replace(".json","") + ".png"
    c.save(out)
    print(out)
