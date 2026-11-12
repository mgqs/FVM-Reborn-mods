"""技能3（坐压）特效原点前后对比：BOSS 不动，只挪 effect 原点。

BEFORE: instance_create_depth(x, y, depth-1, ...)  scale 1.8  特效盖在 BOSS 上
NOW   : 原点 = BOSS 视觉中心 (贴图 170,170)      scale 2.1  特效在 BOSS 背后
"""
import os, re, sys
from PIL import Image, ImageDraw

sys.stdout.reconfigure(encoding="utf-8")

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


boss_img = Image.open(frame_order(BOSS_DIR)[15]).convert("RGBA")
fx_img = Image.open(frame_order(FX_DIR)[1]).convert("RGBA")

FX_ORIGIN = (139, 131)      # 特效贴图原点
BOSS_ORIGIN = (177, 250)    # BOSS 贴图原点（底部居中）
BOSS_VC = (170, 170)        # BOSS 视觉中心（落地驻留帧 15..23 alpha 加权质心均值）
CELL_X, CELL_Y = 107, 116
BOSS_SC = 1.8
FX_SC_OLD, FX_SC_NEW = 1.8, 2.1

PAD = 70
W, H = 4 * CELL_X + PAD * 2, 4 * CELL_Y + PAD * 2
COL, ROW = 2, 2


def geom(mode):
    """返回 (fx_x, fx_y, boss_x, boss_y, fx_scale) —— 世界坐标下的关键点。"""
    ox = PAD + 2 * CELL_X - COL * CELL_X
    oy = PAD + 2 * CELL_Y - ROW * CELL_Y
    ring_x, ring_y = ox + COL * CELL_X, oy + ROW * CELL_Y
    ccx = ox + COL * CELL_X + CELL_X // 2
    ccy = oy + ROW * CELL_Y + CELL_Y // 2
    boss_x, boss_y = ccx + 30, ccy + 38          # 敌人出生 = 格心 +30,+38
    vcx = boss_x + (BOSS_VC[0] - BOSS_ORIGIN[0]) * BOSS_SC
    vcy = boss_y + (BOSS_VC[1] - BOSS_ORIGIN[1]) * BOSS_SC
    if mode == "before":
        return boss_x, boss_y, boss_x, boss_y, FX_SC_OLD, ring_x, ring_y, vcx, vcy
    # now: BOSS 原位不动，特效原点 = BOSS 视觉中心
    return vcx, vcy, boss_x, boss_y, FX_SC_NEW, ring_x, ring_y, vcx, vcy


def panel(mode):
    canvas = Image.new("RGBA", (W, H), (26, 78, 84, 255))
    d = ImageDraw.Draw(canvas)
    for gx in range(PAD % CELL_X, W, CELL_X):
        d.line([(gx, 0), (gx, H)], fill=(34, 96, 102, 255))
    for gy in range(PAD % CELL_Y, H, CELL_Y):
        d.line([(0, gy), (W, gy)], fill=(34, 96, 102, 255))

    ox = PAD + 2 * CELL_X - COL * CELL_X
    oy = PAD + 2 * CELL_Y - ROW * CELL_Y

    # 4x4 判定框（rows row-2..row+1, cols col-2..col+1）
    d.rectangle([ox + (COL - 2) * CELL_X, oy + (ROW - 2) * CELL_Y,
                 ox + (COL + 2) * CELL_X, oy + (ROW + 2) * CELL_Y],
                outline=(255, 50, 50, 255), width=3)

    fx_x, fx_y, boss_x, boss_y, fsc, ring_x, ring_y, vcx, vcy = geom(mode)

    boss_layer = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    boss_canvas = boss_img.resize((int(boss_img.width * BOSS_SC), int(boss_img.height * BOSS_SC)),
                                  Image.LANCZOS)
    boss_layer.alpha_composite(boss_canvas, (int(boss_x - BOSS_ORIGIN[0] * BOSS_SC),
                                             int(boss_y - BOSS_ORIGIN[1] * BOSS_SC)))

    fx_layer = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    fx_canvas = fx_img.resize((int(fx_img.width * fsc), int(fx_img.height * fsc)), Image.LANCZOS)
    fx_layer.alpha_composite(fx_canvas, (int(fx_x - FX_ORIGIN[0] * fsc),
                                        int(fx_y - FX_ORIGIN[1] * fsc)))

    # depth + 1 = 更远 = 先画（now：特效在 BOSS 背后）；old 是 depth - 1 = 盖在 BOSS 上
    if mode == "before":
        canvas = Image.alpha_composite(canvas, boss_layer)
        canvas = Image.alpha_composite(canvas, fx_layer)
    else:
        canvas = Image.alpha_composite(canvas, fx_layer)
        canvas = Image.alpha_composite(canvas, boss_layer)

    d = ImageDraw.Draw(canvas)
    r = 2.2 * CELL_X
    d.ellipse([ring_x - r, ring_y - r, ring_x + r, ring_y + r], outline=(255, 90, 90, 200), width=2)
    d.line([(fx_x - 14, fx_y), (fx_x + 14, fx_y)], fill=(255, 255, 0, 255), width=2)
    d.line([(fx_x, fx_y - 14), (fx_x, fx_y + 14)], fill=(255, 255, 0, 255), width=2)
    return canvas


a, b = panel("before"), panel("now")
comp = Image.new("RGB", (W * 2 + 10, H + 30), (14, 14, 14))
comp.paste(a.convert("RGB"), (0, 0))
comp.paste(b.convert("RGB"), (W + 10, 0))
d = ImageDraw.Draw(comp)
d.text((8, H + 9), "BEFORE  fx origin = boss(x,y)  scale 1.8  fx over boss  ->  ring low-right of boss",
       fill=(255, 170, 170))
d.text((W + 18, H + 9), "NOW  boss(x,y) untouched, fx origin = boss visual centre  scale 2.1  fx behind boss",
       fill=(170, 255, 170))
dst = os.path.join(OUT, "fx_origin_check.png")
comp.save(dst)
print("saved", dst, comp.size)

for mode in ("before", "now"):
    fx_x, fx_y, boss_x, boss_y, fsc, ring_x, ring_y, vcx, vcy = geom(mode)
    # 特效光环半径：贴图帧1 alpha>48 的 r98 = 109.5px
    ring_r = 109.5 * fsc
    print("%-6s boss(x,y)=(%.1f,%.1f) vc=(%.1f,%.1f) fx=(%.1f,%.1f) scale=%.1f ring_r=%.1f "
          "vc->fx=(%.1f,%.1f) ring_vs_judge(top)=%.1f bottom=%.1f"
          % (mode, boss_x, boss_y, vcx, vcy, fx_x, fx_y, fsc, ring_r,
             fx_x - vcx, fx_y - vcy,
             ring_x - (ring_y - ring_r), (ring_y + ring_r) - ring_y))
