import os
from PIL import Image, ImageDraw
names = ["castle-0","nightmare_sky-0","zhuore_0","shuihuo_0","wudu_0","salad_native"]
files = {
 "castle-0":"output/_tmp_grid/ov_castle-0.png",
 "nightmare_sky-0":"output/_tmp_grid/ov_nightmare_sky-0.png",
 "zhuore_0":"output/_tmp_grid/ov_zhuore_0.png",
 "shuihuo_0":"output/_tmp_grid/ov_shuihuo_0.png",
 "wudu_0":"output/_tmp_grid/ov_wudu_0.png",
}
files["salad_native"] = None
box = (660, 200, 1320, 530)  # 660x330
W,H = box[2]-box[0], box[3]-box[1]
sheet = Image.new("RGB",(W*2, H*3),(0,0,0))
d = ImageDraw.Draw(sheet)
for i,n in enumerate(names):
    if files.get(n):
        im = Image.open(files[n]).convert("RGB").crop(box)
    else:
        im = Image.open(sorted(os.listdir("sprites/spr_salad_island_land") and [os.path.join("sprites/spr_salad_island_land",f) for f in os.listdir("sprites/spr_salad_island_land") if f.endswith(".png")])[0]).convert("RGB").crop(box)
    x = (i%2)*W; y=(i//2)*H
    sheet.paste(im,(x,y))
    d.rectangle([x,y,x+120,y+14], fill=(0,0,0))
    d.text((x+2,y+1), n, fill=(255,255,255))
sheet.save("output/_tmp_grid/sheet_board.png")
print(sheet.size)
