import os, re
from PIL import Image, ImageDraw

ROOT = r"D:\gameProject\FVM-Reborn-mod"
OUT = os.path.join(ROOT, "tmp")
BOSS_DIR = os.path.join(ROOT, r"sprites\spr_honglonglong_skill_3")
FX_DIR = os.path.join(ROOT, r"sprites\spr_honglonglong_skill_3_effect")


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


# 落地驻留帧 15 是 "坐压" 到位的那一帧，用它代表 BOSS 体态
boss_img = Image.open(frame_order(BOSS_DIR)[15]).convert("RGBA")
fx_img = Image.open(frame_order(FX_DIR)[1]).convert("RGBA")

FX_ORIGIN = (139, 131)      # 特效贴图原点
BOSS_ORIGIN = (177, 250)    # BOSS 贴图原点（底部居中）
BOSS_VC = (170, 170)        # BOSS 视觉中心（frames 15..23 alpha 加权质心均值）
CELL_X, CELL_Y = 107, 116
BOSS_SC = 1.8
FX_SC = 2.1

PAD = 70
W, H = 4 * CELL_X + PAD * 2, 4 * CELL_Y + PAD * 2
COL, ROW = 2, 2


def panel(mode):
    """mode: 'old' = 未吸附(原点=boss x,y, 特效盖在上面) / 'now' = 吸附到圆心 + 特效在背后"""
    canvas = Image.new("RGBA", (W, H), (26, 78, 84, 255))
    d = ImageDraw.Draw(canvas)
    for gx in range(PAD % CELL_X, W, CELL_X):
        d.line([(gx, 0), (gx, H)], fill=(34, 96, 102, 255))
    for gy in range(PAD % CELL_Y, H, CELL_Y):
        d.line([(0, gy), (W, gy)], fill=(34, 96, 102, 255))

    # world -> canvas：把网格线交点 (col*cell, row*cell) 放到画布正中
    ox = PAD + 2 * CELL_X - COL * CELL_X
    oy = PAD + 2 * CELL_Y - ROW * CELL_Y

    # 4x4 判定框
    d.rectangle([ox + (COL - 2) * CELL_X, oy + (ROW - 2) * CELL_Y,
                 ox + (COL + 2) * CELL_X, oy + (ROW + 2) * CELL_Y],
                outline=(255, 50, 50, 255), width=3)

    ring_x = ox + COL * CELL_X
    ring_y = oy + ROW * CELL_Y

    # 敌人出生点 = 格心 +30,+38
    ccx = ox + COL * CELL_X + CELL_X // 2
    ccy = oy + ROW * CELL_Y + CELL_Y // 2
    boss_x, boss_y = ccx + 30, ccy + 38

    if mode == "now":
        # Step_0.gml 15*5 分支：把 BOSS 视觉中心拽到环心
        vcx = (boss_x - BOSS_ORIGIN[0] * BOSS_SC) + BOSS_VC[0] * BOSS_SC
        vcy = (boss_y - BOSS_ORIGIN[1] * BOSS_SC) + BOSS_VC[1] * BOSS_SC
        boss_x += ring_x - vcx
        boss_y += ring_y - vcy
        fx_x, fx_y = ring_x, ring_y
    else:
        fx_x, fx_y = boss_x, boss_y

    boss_layer = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    boss_canvas = boss_img.resize((int(boss_img.width * BOSS_SC), int(boss_img.height * BOSS_SC)),
                                  Image.LANCZOS)
    boss_layer.alpha_composite(boss_canvas, (int(boss_x - BOSS_ORIGIN[0] * BOSS_SC),
                                             int(boss_y - BOSS_ORIGIN[1] * BOSS_SC)))

    fx_layer = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    fx_canvas = fx_img.resize((int(fx_img.width * FX_SC), int(fx_img.height * FX_SC)), Image.LANCZOS)
    fx_layer.alpha_composite(fx_canvas, (int(fx_x - FX_ORIGIN[0] * FX_SC),
                                         int(fx_y - FX_ORIGIN[1] * FX_SC)))

    # depth + 1 = 更远 = 先画；old 版本是 depth - 1 = 后画（盖住 BOSS）
    if mode == "now":
        canvas = Image.alpha_composite(canvas, fx_layer)
        canvas = Image.alpha_composite(canvas, boss_layer)
    else:
        canvas = Image.alpha_composite(canvas, boss_layer)
        canvas = Image.alpha_composite(canvas, fx_layer)

    d = ImageDraw.Draw(canvas)
    r = 2.2 * CELL_X
    d.ellipse([ring_x - r, ring_y - r, ring_x + r, ring_y + r], outline=(255, 90, 90, 200), width=2)
    # 环心十字，标出 BOSS 视觉中心应落的位置
    d.line([(ring_x - 14, ring_y), (ring_x + 14, ring_y)], fill=(255, 255, 0, 255), width=2)
    d.line([(ring_x, ring_y - 14), (ring_x, ring_y + 14)], fill=(255, 255, 0, 255), width=2)
    return canvas


a, b = panel("old"), panel("now")
comp = Image.new("RGB", (W * 2 + 10, H + 30), (14, 14, 14))
comp.paste(a.convert("RGB"), (0, 0))
comp.paste(b.convert("RGB"), (W + 10, 0))
d = ImageDraw.Draw(comp)
d.text((8, H + 9), "BEFORE  fx origin = boss (x,y), fx over boss  ->  boss sits high-left of ring",
       fill=(255, 170, 170))
d.text((W + 18, H + 9), "NOW  boss visual centre snapped to ring centre, fx one layer behind boss",
       fill=(170, 255, 170))
dst = os.path.join(OUT, "fx_center_check.png")
comp.save(dst)
print("saved", dst, comp.size)

# 数值断言：吸附后 BOSS 视觉中心与环心的偏差
PADn = PAD
for mode in ("old", "now"):
    ox = PADn + 2 * CELL_X - COL * CELL_X
    oy = PADn + 2 * CELL_Y - ROW * CELL_Y
    ring_x, ring_y = ox + COL * CELL_X, oy + ROW * CELL_Y
    ccx = ox + COL * CELL_X + CELL_X // 2
    ccy = oy + ROW * CELL_Y + CELL_Y // 2
    bx, by = ccx + 30, ccy + 38
    if mode == "now":
        vcx = (bx - BOSS_ORIGIN[0] * BOSS_SC) + BOSS_VC[0] * BOSS_SC
        vcy = (by - BOSS_ORIGIN[1] * BOSS_SC) + BOSS_VC[1] * BOSS_SC
        bx += ring_x - vcx
        by += ring_y - vcy
    vcx = (bx - BOSS_ORIGIN[0] * BOSS_SC) + BOSS_VC[0] * BOSS_SC
    vcy = (by - BOSS_ORIGIN[1] * BOSS_SC) + BOSS_VC[1] * BOSS_SC
    print(mode, "boss(x,y)=(%.1f,%.1f) visual_centre=(%.1f,%.1f) ring=(%d,%d) delta=(%.1f,%.1f)"
          % (bx, by, vcx, vcy, ring_x, ring_y, vcx - ring_x, vcy - ring_y))
