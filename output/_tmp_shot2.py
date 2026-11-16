from PIL import Image
p = r"D:\DSH\home\attachments\v1\objects\04\0487bdbddd653aae59337ed98e3a3ec3d40db55b9c85d522f3642a848933ccd3"
im = Image.open(p).convert("RGB")
w,h = im.size
# quadrant crops, upscale 4x
for i,(x0,y0,x1,y1) in enumerate([(0,0,w//2,h//2),(w//2,0,w,h//2),(0,h//2,w//2,h),(w//2,h//2,w,h)]):
    c = im.crop((x0,y0,x1,y1))
    c = c.resize((c.width*4, c.height*4), Image.LANCZOS)
    c.save(f"output/_tmp_grid/shot_q{i}.png")
    print(i, c.size)
