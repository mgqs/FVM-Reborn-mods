import os, re
from PIL import Image, ImageDraw

ROOT = r"D:\gameProject\FVM-Reborn-mod"
OUT  = os.path.join(ROOT, "tmp")
BOSS = os.path.join(ROOT, r"sprites\spr_honglonglong_skill_3")
FX   = os.path.join(ROOT, r"sprites\spr_honglonglong_skill_3_effect")


def frame_order(spr_dir):
    name = os.path.basename(spr_dir)
    t = open(os.path.join(spr_dir, name + ".yy"), encoding="utf-8", errors="ignore").read()
    out, seen = [], set()
    for i in re.findall(r'"%Name":"([0-9a-f\-]{36})"', t):
        p = os.path.join(spr_dir, i + ".png")
        if i not in seen and os.path.exists(p):
            seen.add(i)
            out.append(p)
    return out


boss_img = Image.open(frame_order(BOSS)[14]).convert("RGBA")
fx_img   = Image.open(frame_order(FX)[1]).convert("RGBA")

CX, CY = 139, 131
BX, BY = 177, 250
CELL_X, CELL_Y = 107, 116

PAD = 70
W, H = 4 * CELL_X + PAD * 2, 4 * CELL_Y + PAD * 2
COL, ROW = 2, 2


def draw_case(mode):
    canvas = Image.new("RGBA", (W, H), (26, 78, 84, 255))
    d = ImageDraw.Draw(canvas)
    for gx in range(PAD % CELL_X, W, CELL_X):
        d.line([(gx, 0), (gx, H)], fill=(34, 96, 102, 255))
    for gy in range(PAD % CELL_Y, H, CELL_Y):
        d.line([(0, gy), (W, gy)], fill=(34, 96, 102, 255))

    # world -> canvas: put grid line (col*cell, row*cell) at centre
    ox = PAD + 2 * CELL_X - COL * CELL_X
    oy = PAD + 2 * CELL_Y - ROW * CELL_Y

    d.rectangle([ox + (COL - 2) * CELL_X, oy + (ROW - 2) * CELL_Y,
                 ox + (COL + 2) * CELL_X, oy + (ROW + 2) * CELL_Y],
                outline=(255, 50, 50, 255), width=3)

    ccx = ox + COL * CELL_X + CELL_X // 2
    ccy = oy + ROW * CELL_Y + CELL_Y // 2
    bx, by = ccx + 30, ccy + 38

    bs = boss_img.resize((int(boss_img.width * 1.8), int(boss_img.height * 1.8)), Image.LANCZOS)
    canvas.alpha_composite(bs, (int(bx - BX * 1.8), int(by - BY * 1.8)))

    scale = 1.8 if mode == "old" else 2.1
    fx = fx_img.resize((int(fx_img.width * scale), int(fx_img.height * scale)), Image.LANCZOS)
    if mode == "old":
        ex, ey = bx, by
    else:
        ex, ey = ox + COL * CELL_X, oy + ROW * CELL_Y
    canvas.alpha_composite(fx, (int(ex - CX * scale), int(ey - CY * scale)))

    r = 2.2 * CELL_X
    d.ellipse([ex - r, ey - r, ex + r, ey + r], outline=(255, 90, 90, 210), width=2)
    d.ellipse([ex - 5, ey - 5, ex + 5, ey + 5], fill=(255, 255, 0, 255))
    return canvas


a, b = draw_case("old"), draw_case("new")
comp = Image.new("RGB", (W * 2 + 10, H + 30), (14, 14, 14))
comp.paste(a.convert("RGB"), (0, 0))
comp.paste(b.convert("RGB"), (W + 10, 0))
d = ImageDraw.Draw(comp)
d.text((8, H + 9), "BEFORE  origin = boss (x,y)  scale 1.8  -> shifted down-right, ring ~2 cells",
       fill=(255, 170, 170))
d.text((W + 18, H + 9), "AFTER  origin = 4x4 geometric centre  scale 2.1  -> ring fills judge area",
       fill=(170, 255, 170))
dst = os.path.join(OUT, "fx_before_after.png")
comp.save(dst)
print("saved", dst, comp.size)
