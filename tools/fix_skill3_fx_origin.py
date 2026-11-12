import os, shutil, re, io, sys
sys.stdout.reconfigure(encoding="utf-8")

ROOT = r"D:\gameProject\FVM-Reborn-mod"
STEP = os.path.join(ROOT, r"objects\obj_honglonglong\Step_0.gml")
CREA = os.path.join(ROOT, r"objects\obj_honglonglong\Create_0.gml")
BK = os.path.join(ROOT, r".workbuddy\backup\skill3_fx_origin_20261112")

os.makedirs(BK, exist_ok=True)
for p in (STEP, CREA):
    dst = os.path.join(BK, os.path.basename(p) + ".bak")
    if not os.path.exists(dst):
        shutil.copy2(p, dst)

step = open(STEP, encoding="utf-8", newline="").read()
crea = open(CREA, encoding="utf-8", newline="").read()

nl = "\r\n" if "\r\n" in step else "\n"


def sub(text, old_lines, new_lines, label):
    old = nl.join(old_lines)
    new = nl.join(new_lines)
    if text.count(old) != 1:
        raise SystemExit("anchor miss: " + label + " count=" + str(text.count(old)))
    return text.replace(old, new)


# ---- 1) 14*5 分支：不再保存 4x4 几何中点，判定逻辑与注释保持原样 ----
step = sub(step, [
    "\t\t\t\t// 4x4 判定区的几何中点 = 网格线交点，15*5 播特效时要用到",
    "\t\t\t\tskill3_fx_x = global.grid_offset_x + _center_col * global.grid_cell_size_x",
    "\t\t\t\tskill3_fx_y = global.grid_offset_y + _center_row * global.grid_cell_size_y",
    "\t\t\t\t// 判定区 = 行 [_center_row-2, _center_row+1] x 列 [_center_col-2, _center_col+1]",
    "\t\t\t\t// 4 行格的上下边界是 offset+(row-2)*cell 与 offset+(row+2)*cell，",
    "\t\t\t\t// 所以几何中点 = offset + row*cell，落在网格线上而不是格心，",
    "\t\t\t\t// 也不是 BOSS 脚底的 (x, y)；特效必须画在那个中点上（见下方 15*5 分支）",
], [
    "\t\t\t\t// 判定区 = 行 [_center_row-2, _center_row+1] x 列 [_center_col-2, _center_col+1]",
], "14*5 band comment")

# ---- 2) 15*5 分支：BOSS 原地不动，只把特效原点摆到 BOSS 视觉中心 ----
old_block = [
    "\t\t\t// 15*5 = 落地那一 tick：先把 BOSS 摆到冲击波圆心，再放特效",
    "\t\t\t// 圆心 = 4x4 判定区几何中点（14*5 时已算好，存在 skill3_fx_x / skill3_fx_y）",
    "\t\t\t// BOSS 视觉中心：坐压驻留帧 15..23 的 alpha 加权质心均值 = 贴图 (169.6, 168.7)，取 (170, 170)",
    "\t\t\t// 原点 (177, 250)，image_scale 1.8 -> 视觉中心比 (x, y) 高 144px、左 13px",
    "\t\t\tvar _vcx = x + (170 - sprite_get_xoffset(sprite_index)) * image_xscale",
    "\t\t\tvar _vcy = y + (170 - sprite_get_yoffset(sprite_index)) * image_yscale",
    "\t\t\tx += skill3_fx_x - _vcx",
    "\t\t\ty += skill3_fx_y - _vcy",
]
new_block = [
    "\t\t\t// 15*5 = 落地那一 tick：BOSS 的 (x, y) 一米不动，只把特效原点摆到 BOSS 视觉中心",
    "\t\t\t// 特效贴图 278x262、origin (139,131)，光环圆心 = 贴图几何中心（实测质心偏差 <4px），",
    "\t\t\t// 所以「光环圆心落在 BOSS 视觉中心」等价于「特效画在 BOSS 视觉中心这个点上」。",
    "\t\t\t// BOSS 视觉中心：坐压驻留帧 15..23 的 alpha 加权质心均值 = 贴图 (169.6, 168.7)，取 (170, 170)；",
    "\t\t\t// 原点 (177, 250)，image_scale 1.8 -> 视觉中心比 (x, y) 高 144px、左 13px。",
    "\t\t\tvar _vcx = x + (170 - sprite_get_xoffset(sprite_index)) * image_xscale",
    "\t\t\tvar _vcy = y + (170 - sprite_get_yoffset(sprite_index)) * image_yscale",
]
step = sub(step, old_block, new_block, "15*5 visual centre")

old_call = "\t\t\tinstance_create_depth(skill3_fx_x, skill3_fx_y, depth + 1, obj_honglonglong_skill_3_effect)"
new_call = "\t\t\tinstance_create_depth(_vcx, _vcy, depth + 1, obj_honglonglong_skill_3_effect)"
if step.count(old_call) != 1:
    raise SystemExit("anchor miss: create call")
step = step.replace(old_call, new_call)

# ---- 3) Create_0.gml：删掉不再使用的 skill3_fx_x / skill3_fx_y 初始化 ----
old_cre = nl.join([
    "",
    "// 技能3：4x4 判定区几何中点（Step_0 的 14*5 里写入，15*5 里用来摆 BOSS 和特效）",
    "skill3_fx_x = x",
    "skill3_fx_y = y",
])
new_cre = ""
if crea.count(old_cre) != 1:
    raise SystemExit("anchor miss: create init block")
crea = crea.replace(old_cre, new_cre)

open(STEP, "w", encoding="utf-8", newline="").write(step)
open(CREA, "w", encoding="utf-8", newline="").write(crea)

# ---- assertions ----
step2 = open(STEP, encoding="utf-8").read()
crea2 = open(CREA, encoding="utf-8").read()
checks = {
    "boss x untouched": "x += skill3_fx_x" not in step2 and "y += skill3_fx_y" not in step2,
    "old call gone": "instance_create_depth(skill3_fx_x" not in step2,
    "new call 1": step2.count("instance_create_depth(_vcx, _vcy, depth + 1, obj_honglonglong_skill_3_effect)") == 1,
    "skill3_fx vars gone in Step": "skill3_fx_" not in step2,
    "skill3_fx vars gone in Create": "skill3_fx_" not in crea2,
    "4x4 judge intact": ("grid_row >= _center_row - 2 && grid_row <= _center_row + 1" in step2
                         and "grid_col >= _center_col - 2 && grid_col <= _center_col + 1" in step2),
    "U+FFFD step": "\ufffd" not in step2,
    "U+FFFD create": "\ufffd" not in crea2,
}
for k, v in checks.items():
    print(("OK   " if v else "FAIL ") + k)
print("step bytes/lines:", os.path.getsize(STEP), len(step2.split(nl)))
print("create bytes/lines:", os.path.getsize(CREA), len(crea2.split(nl)))
if not all(checks.values()):
    raise SystemExit(1)
