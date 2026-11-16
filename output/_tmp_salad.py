from PIL import Image
import numpy as np, glob, os
p = sorted(glob.glob("sprites/spr_salad_island_land/*.png"))[0]
im = Image.open(p).convert("RGB")
print(p, im.size)
im.resize((im.width//2, im.height//2), Image.LANCZOS).save("output/_tmp_grid/salad_view.png")
