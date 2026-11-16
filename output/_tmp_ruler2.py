import glob, os
from PIL import Image, ImageDraw
fp = sorted(glob.glob("sprites/spr_mod_ancient_castle_0/*.png"))[0]
im = Image.open(fp).convert("RGB")
d = ImageDraw.Draw(im)
for x in range(0, im.width, 100):
    d.line([(x,0),(x,im.height)], fill=(0,255,0), width=1)
    d.text((x+2,2), str(x), fill=(255,255,0))
for y in range(0, im.height, 100):
    d.line([(0,y),(im.width,y)], fill=(255,0,255), width=1)
    d.text((2,y+2), str(y), fill=(255,255,0))
im.save("output/_tmp_grid/ruler_castle.png")
print(im.size)
