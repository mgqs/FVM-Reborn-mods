import os, re
from PIL import Image

d = r"sprites\spr_honglonglong_skill_3_effect"
t = open(os.path.join(d, "spr_honglonglong_skill_3_effect.yy"), encoding="utf-8", errors="ignore").read()
ids = []
for i in re.findall(r'"%Name":"([0-9a-f\-]{36})"', t):
    if i not in ids and os.path.exists(os.path.join(d, i + ".png")):
        ids.append(i)

print("frames:", len(ids))
visible = []
for i, g in enumerate(ids):
    a = Image.open(os.path.join(d, g + ".png")).convert("RGBA").getextrema()[3]
    if a[1] > 0:
        visible.append(i)
    print("  %2d %s alpha_extrema=%s" % (i, g[:8], a))
print("visible frame indices:", visible, "-> last visible =", visible[-1])
