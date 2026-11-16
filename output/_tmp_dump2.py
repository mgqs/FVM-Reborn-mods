from PIL import Image
import glob, os
for n in ["spr_shuihuozhijian_1","spr_mengyantiankong_0","spr_mod_ancient_castle_0","spr_wuduyanjiusuo_1"]:
    fs = sorted(glob.glob(os.path.join("sprites", n, "*.png")))
    print(n, len(fs))
    im = Image.open(fs[0]).convert("RGB")
    out = os.path.join("output/_tmp_grid", n + "_view.png")
    im.save(out)
    print(out, im.size)
