from PIL import Image
p = r"D:\DSH\home\attachments\v1\objects\04\0487bdbddd653aae59337ed98e3a3ec3d40db55b9c85d522f3642a848933ccd3"
im = Image.open(p)
print(im.size, im.mode, im.format)
im2 = im.convert("RGB")
im2.resize((im.width*3, im.height*3), Image.NEAREST).save("output/_tmp_grid/shot_x3.png")
print("saved")
