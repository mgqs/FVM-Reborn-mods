from PIL import Image
p = r"D:\DSH\home\attachments\v1\objects\04\0487bdbddd653aae59337ed98e3a3ec3d40db55b9c85d522f3642a848933ccd3"
im = Image.open(p).convert("RGB")
# left half zoom 6x to examine plant vs tile seams
c = im.crop((0,0,230,375)).resize((230*6, 375*6), Image.LANCZOS)
c.save("output/_tmp_grid/shot_left6.png")
c2 = im.crop((215,0,446,375)).resize(((446-215)*6, 375*6), Image.LANCZOS)
c2.save("output/_tmp_grid/shot_right6.png")
print(c.size, c2.size)
