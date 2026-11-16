from PIL import Image
p=r"D:\DSH\home\attachments\v1\objects\04\0487bdbddd653aae59337ed98e3a3ec3d40db55b9c85d522f3642a848933ccd3"
im=Image.open(p).convert("RGB")
W,H=im.size
print(W,H)
# 4 quadrant crops at 4x
for i,(box,name) in enumerate([
  ((0,0,223,188),"q_tl"),((223,0,446,188),"q_tr"),
  ((0,188,223,375),"q_bl"),((223,188,446,375),"q_br")]):
    c=im.crop(box); c=c.resize((c.width*4,c.height*4), Image.LANCZOS)
    c.save(f"output/_tmp_grid/z4_{name}.png"); print(name, c.size)
im.resize((W*3,H*3), Image.LANCZOS).save("output/_tmp_grid/z3_full.png")
