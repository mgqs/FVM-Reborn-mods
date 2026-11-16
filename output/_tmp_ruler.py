import glob, os
from PIL import Image, ImageDraw
for spr in ["spr_shuihuozhijian_0","spr_wuduyanjiusuo_0","spr_zhuorediyu","spr_mengyantiankong_0"]:
    fp = sorted(glob.glob(os.path.join("sprites", spr, "*.png")))[0]
    im = Image.open(fp).convert("RGB")
    im = im.resize((im.width*2, im.height*2), Image.NEAREST)
    d = ImageDraw.Draw(im)
    for x in range(0, im.width, 100):
        d.line([(x,0),(x,im.height)], fill=(0,255,0,120), width=1)
        d.text((x+2,2), str(x//2), fill=(255,255,0))
    for y in range(0, im.height, 100):
        d.line([(0,y),(im.width,y)], fill=(255,0,255,120), width=1)
        d.text((2,y+2), str(y//2), fill=(255,255,0))
    im.save(f"output/_tmp_grid/ruler_{spr}.png")
    print(spr, im.size)
