import os, re, shutil, sys

ROOT = r"D:\gameProject\FVM-Reborn-mod"
BK   = os.path.join(ROOT, r".workbuddy\backup\skill3_fx_center_20261112")
os.makedirs(BK, exist_ok=True)

STEP = os.path.join(ROOT, r"objects\obj_honglonglong\Step_0.gml")
CRE  = os.path.join(ROOT, r"objects\obj_honglonglong\Create_0.gml")

for p in (STEP, CRE):
    shutil.copy2(p, os.path.join(BK, os.path.basename(p) + ".bak"))

# ---------- 1) Step_0.gml : 14*5 存下 4x4 判定区几何中点 ----------
raw = open(STEP, "rb").read()
assert b"\r\n" in raw
t = raw.decode("utf-8")
lines = t.split("\r\n")

anchor = "\t\t\t\tvar _center_col = _model_grid.col"
idx = [i for i, l in enumerate(lines) if l == anchor]
if len(idx) != 1:
    raise SystemExit("anchor _center_col hit %d" % len(idx))
i = idx[0]
store = [
    "\t\t\t\t// 4x4 判定区的几何中点 = 网格线交点，15*5 播特效时要用到",
    "\t\t\t\tskill3_fx_x = global.grid_offset_x + _center_col * global.grid_cell_size_x",
    "\t\t\t\tskill3_fx_y = global.grid_offset_y + _center_row * global.grid_cell_size_y",
]
lines[i + 1:i + 1] = store

# ---------- 2) Step_0.gml : 15*5 把 BOSS 摆到冲击波圆心 ----------
start = [k for k, l in enumerate(lines) if re.match(r"^\t\tif timer == 15 \* 5\{$", l)]
if len(start) != 1:
    raise SystemExit("anchor 15*5 hit %d" % len(start))
s = start[0]
for k in range(s + 1, s + 5):
    if not lines[k].lstrip().startswith("//"):
        raise SystemExit("expected comment at line %d, got %r" % (k + 1, lines[k][:40]))
code = lines[s + 5:s + 9]
if not code[0].strip().startswith("var _fx_grid"):
    raise SystemExit("expected code at %d, got %r" % (s + 6, code[0][:50]))

new_block = [
    "\t\t\t// 15*5 = 落地那一 tick：先把 BOSS 摆到冲击波圆心，再放特效",
    "\t\t\t// 圆心 = 4x4 判定区几何中点（14*5 时已算好，存在 skill3_fx_x / skill3_fx_y）",
    "\t\t\t// BOSS 视觉中心：坐压落地帧的 alpha 质心在贴图 (170, 175)，原点 (177, 250)",
    "\t\t\tvar _vcx = x + (170 - sprite_get_xoffset(sprite_index)) * image_xscale",
    "\t\t\tvar _vcy = y + (175 - sprite_get_yoffset(sprite_index)) * image_yscale",
    "\t\t\tx += skill3_fx_x - _vcx",
    "\t\t\ty += skill3_fx_y - _vcy",
    "\t\t\tinstance_create_depth(skill3_fx_x, skill3_fx_y, depth - 1, obj_honglonglong_skill_3_effect)",
]
lines[s + 1:s + 9] = new_block

open(STEP, "wb").write("\r\n".join(lines).encode("utf-8"))

# ---------- 3) Create_0.gml : 初始化两个坐标 ----------
c = open(CRE, "rb").read().decode("utf-8")
assert c.count("y_move_speed = 0") == 1
c = c.replace("y_move_speed = 0",
              "y_move_speed = 0\r\n\r\n"
              "// 技能3：4x4 判定区几何中点（Step_0 的 14*5 里写入，15*5 里用来摆 BOSS 和特效）\r\n"
              "skill3_fx_x = x\r\n"
              "skill3_fx_y = y")
open(CRE, "wb").write(c.encode("utf-8"))

# ---------- 4) 断言 ----------
t2 = open(STEP, encoding="utf-8").read()
c2 = open(CRE, encoding="utf-8").read()
print("Step lines      :", t2.count("\n") + 1)
print("store band ctr  :", t2.count("skill3_fx_x = global.grid_offset_x + _center_col"))
print("snap boss       :", t2.count("x += skill3_fx_x - _vcx"))
print("old fx_grid gone:", "var _fx_grid" not in t2)
print("effect at ctr   :", t2.count("instance_create_depth(skill3_fx_x, skill3_fx_y"))
print("4x4 judge intact:", t2.count("grid_row >= _center_row - 2 && grid_row <= _center_row + 1") == 1)
print("Create init     :", c2.count("skill3_fx_x = x") == 1, c2.count("skill3_fx_y = y") == 1)
print("U+FFFD          :", t2.count("\ufffd") + c2.count("\ufffd"))
