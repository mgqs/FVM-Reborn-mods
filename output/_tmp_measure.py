from PIL import Image
import os
names = ["spr_mod_ancient_castle_0","spr_mengyantiankong_0","spr_shuihuozhijian_0","spr_shuihuozhijian_1","spr_wuduyanjiusuo_0","spr_zhuorediyu"]
for n in names:
    d = os.path.join("sprites", n)
    pngs = sorted([f for f in os.listdir(d) if f.lower().endswith(".png")])
    for f in pngs[:2]:
        im = Image.open(os.path.join(d,f))
        print(n, f, im.size, im.mode)
