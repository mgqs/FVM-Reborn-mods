from PIL import Image
import glob, os
for n in ["spr_wuduyanjiusuo_0","spr_zhuorediyu","spr_shuihuozhijian_0","spr_mengyantiankong_0"]:
    p = sorted(glob.glob(os.path.join("sprites", n, "*.png")))[0]
    im = Image.open(p).convert("RGB")
    out = os.path.join("output/_tmp_grid", n + "_view.png")
    im.save(out)
    print(out, im.size)
