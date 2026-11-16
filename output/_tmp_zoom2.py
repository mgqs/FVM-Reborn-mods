from PIL import Image
import sys
def zoom(src, box, scale, dst):
    im = Image.open(src)
    c = im.crop(box)
    c = c.resize((int(c.width*scale), int(c.height*scale)), Image.LANCZOS)
    c.save(dst); print(dst, c.size)
zoom("output/_tmp_grid/align_zhuore.png", (680,220,1320,700), 2.0, "output/_tmp_grid/zz_zhuore.png")
zoom("output/_tmp_grid/align_shuihuo_a.png", (680,220,1320,700), 2.0, "output/_tmp_grid/zz_shuihuo_a.png")
zoom("output/_tmp_grid/align_wudu.png", (680,220,1320,700), 2.0, "output/_tmp_grid/zz_wudu.png")
