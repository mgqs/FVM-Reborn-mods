# [已废弃] 本脚本只扫「站立首帧」，对帧间位移大的敌人判定框严重偏小。
# 现由 tools/gen_enemy_body_frames.ps1 取代（逐帧扫描 + keyframes 顺序）。
# 保留仅作历史参考，不要再用它覆盖 enemy_body.gml。

# -*- coding: utf-8 -*-
"""
gen_enemy_body.py —— 生成 scripts/enemy_body/enemy_body.gml（敌人固定判定框表）

一条命令跑完：扫敌人 sprite → 算站立首帧实心边界 → 过滤特效 → 写 GML。

用法（项目根目录）：
  & "C:\\Users\\18203\\.dsh\\dsh-runtimes\\dsh-plugin-desktop-primary-runtime\\dependencies\\python\\python.exe" tools\\gen_enemy_body.py

注意：会整段重写 enemy_body.gml 的 #macro 与函数体，数据段不要手改。
"""
import io, os, re, json
from PIL import Image

root = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

def read(p):
    return io.open(p, encoding="utf-8-sig", errors="replace").read()

# ── 1. 收集敌人 sprite 名 ────────────────────────────────────────────
regspr = set()
for f in ("scripts/enemy_init/enemy_init.gml", "scripts/boss_init/boss_init.gml"):
    t = read(os.path.join(root, f))
    for m in re.finditer(r'"spr"\s*:\s*(spr_[A-Za-z0-9_]+)', t):
        regspr.add(m.group(1))

obj_parents = {}
od = os.path.join(root, "objects")
for name in os.listdir(od):
    yy = os.path.join(od, name, name + ".yy")
    if not os.path.isfile(yy):
        continue
    t = read(yy)
    m = re.search(r'"parentObjectId"\s*:\s*\{\s*"name"\s*:\s*"([^"]+)"', t)
    obj_parents[name] = m.group(1) if m else None

def is_enemy(o, d=0):
    if d > 12: return False
    p = obj_parents.get(o)
    if p is None: return False
    if p == "obj_enemy_parent": return True
    return is_enemy(p, d + 1)

spr_from_obj = set()
for o in [x for x in obj_parents if is_enemy(x)]:
    d = os.path.join(od, o)
    for ev in os.listdir(d):
        if not ev.endswith(".gml"):
            continue
        t = read(os.path.join(d, ev))
        for m in re.finditer(r'\b(?:sprite_index|idle_spr|move_spr|attack_spr|death_spr|appear_spr|spr)\s*=\s*(spr_[A-Za-z0-9_]+)', t):
            spr_from_obj.add(m.group(1))

allspr = sorted(regspr | spr_from_obj)
print("注册表 spr:", len(regspr), " 对象引用 spr:", len(spr_from_obj), " 合计:", len(allspr))

# ── 2. 扫首帧实心边界 ────────────────────────────────────────────────
raw, bad = {}, []
for s in allspr:
    yy = os.path.join(root, "sprites", s, s + ".yy")
    if not os.path.isfile(yy):
        bad.append(s); continue
    t = read(yy)
    mw = re.search(r'"width":\s*(\d+)', t)
    mh = re.search(r'"height":\s*(\d+)', t)
    mox = re.search(r'"xorigin":\s*(-?\d+)', t)
    moy = re.search(r'"yorigin":\s*(-?\d+)', t)
    mf = re.search(r'"frames"\s*:\s*\[\s*\{.*?"name"\s*:\s*"([^"]+)"', t, re.S)
    if not (mw and mh and mox and moy and mf):
        bad.append(s); continue
    W, H = int(mw.group(1)), int(mh.group(1))
    ox, oy = int(mox.group(1)), int(moy.group(1))
    if W < 24 or H < 24:
        continue
    png = os.path.join(root, "sprites", s, mf.group(1) + ".png")
    if not os.path.isfile(png):
        bad.append(s); continue
    try:
        im = Image.open(png).convert("RGBA")
    except Exception:
        bad.append(s); continue
    bb = im.split()[3].getbbox()
    if bb is None:
        continue
    l, tp, r, b = bb
    raw[s] = {"l": l - ox, "r": r - 1 - ox, "t": tp - oy, "b": b - 1 - oy, "w": r - l, "h": b - tp}
print("扫出:", len(raw), " 跳过:", len(bad))

# ── 3. 过滤（注册表里的永不剔） ──────────────────────────────────────
SKIP = ("appear", "disappear", "effect", "skill", "laser", "lightning",
        "_fx", "shadow", "warning", "target", "aim")
kept = {}
for k, v in raw.items():
    ln = k.lower()
    if k not in regspr and any(w in ln for w in SKIP):
        continue
    if v["w"] < 24 or v["h"] < 24:
        continue
    if abs(v["l"]) > 300 or abs(v["r"]) > 300:
        continue
    kept[k] = v
print("进表:", len(kept), " 注册表覆盖:", len(regspr & set(kept)), "/", len(regspr))
miss = sorted(regspr - set(kept))
if miss:
    print("警告：注册表未覆盖 ->", miss)

json.dump(kept, open(os.path.join(root, "tools/_enemy_body_raw.json"), "w", encoding="utf-8"),
          ensure_ascii=False, indent=0)

# ── 4. 写 GML ────────────────────────────────────────────────────────
rows = [(k, kept[k]["l"], kept[k]["r"], kept[k]["t"], kept[k]["b"]) for k in sorted(kept)]

head = '''/// enemy_body —— 敌人固定判定框表（碰撞精度 B 方案）
/// 生成器：tools/gen_enemy_body.py（重跑即可刷新，勿手改数据段）
///
/// 设计：每个敌人离线扫「站立首帧」的实心像素范围，存成相对实例原点的
/// 固定偏移 { l, r, t, b }。运行时按实例 image_xscale 换算世界坐标，
/// 不再使用实例 bbox —— collisionKind=4 的精灵会随动作突变
/// （巨人鼠挥爪帧左缘从 -57 拉到 -104，凭空多出 47px），导致命中时机忽早忽晚。
///
/// 退回方式：把 ENEMY_BODY_ENABLED 改成 false，全部判定恢复引擎 bbox，
/// 无需改任何调用点。

#macro ENEMY_BODY_ENABLED true

/// @func enemy_body_ensure()
/// @desc 惰性构建 sprite 索引 -> 判定框 的 ds_map，只建一次
function enemy_body_ensure() {
	static _busy = false;
	if (_busy) return;
	if (variable_global_exists("enemy_body_tbl")) return;
	_busy = true;

	var _t = ds_map_create();
	var _rows = [
'''

body = "\n".join('\t\t["%s", %d, %d, %d, %d],' % r for r in rows)

tail = '''	];

	var _n = array_length(_rows);
	for (var _i = 0; _i < _n; _i++) {
		var _r = _rows[_i];
		var _spr = asset_get_index(_r[0]);
		if (_spr < 0) continue;
		_t[? _spr] = { l: _r[1], r: _r[2], t: _r[3], b: _r[4] };
	}

	global.enemy_body_tbl = _t;
	_busy = false;
}

/// @func enemy_body_is_enemy(_e)
/// @desc 实例是否属于 obj_enemy_parent 家族（结果缓存到实例上，只算一次）
function enemy_body_is_enemy(_e) {
	if (is_undefined(_e) || _e == noone) return false;
	// 对象索引（obj_xxx）能骗过 instance_exists，读实例变量会崩，先挡掉
	if (object_exists(_e)) return false;
	if (!instance_exists(_e)) return false;
	if (!variable_instance_exists(_e, "_eb_is_enemy")) {
		var _oi = _e.object_index;
		_e._eb_is_enemy = (_oi == obj_enemy_parent) || object_is_ancestor(_oi, obj_enemy_parent);
	}
	return _e._eb_is_enemy;
}

/// @func enemy_body_get(_e)
/// @desc 返回 { l, r, t, b }（相对原点的固定像素偏移）；不适用返回 undefined
function enemy_body_get(_e) {
	if (!ENEMY_BODY_ENABLED) return undefined;
	if (object_exists(_e)) return undefined;
	if (!enemy_body_is_enemy(_e)) return undefined;
	enemy_body_ensure();
	var _spr = _e.sprite_index;
	if (_spr < 0) return undefined;
	if (!ds_map_exists(global.enemy_body_tbl, _spr)) return undefined;
	return global.enemy_body_tbl[? _spr];
}

/// @func enemy_body_has(_e)
/// @desc 该实例是否有固定判定框数据
function enemy_body_has(_e) {
	return !is_undefined(enemy_body_get(_e));
}

/// @func enemy_body_left(_e)
/// @desc 身体左缘的世界坐标；无数据时退回实例 bbox_left
function enemy_body_left(_e) {
	var _b = enemy_body_get(_e);
	if (is_undefined(_b)) return _e.bbox_left;
	var _sx = _e.image_xscale;
	if (_sx < 0) return _e.x + _b.r * _sx;
	return _e.x + _b.l * _sx;
}

/// @func enemy_body_right(_e)
/// @desc 身体右缘的世界坐标；无数据时退回实例 bbox_right
function enemy_body_right(_e) {
	var _b = enemy_body_get(_e);
	if (is_undefined(_b)) return _e.bbox_right;
	var _sx = _e.image_xscale;
	if (_sx < 0) return _e.x + _b.l * _sx;
	return _e.x + _b.r * _sx;
}

/// @func enemy_body_top(_e)
function enemy_body_top(_e) {
	var _b = enemy_body_get(_e);
	if (is_undefined(_b)) return _e.bbox_top;
	return _e.y + _b.t * abs(_e.image_yscale);
}

/// @func enemy_body_bottom(_e)
function enemy_body_bottom(_e) {
	var _b = enemy_body_get(_e);
	if (is_undefined(_b)) return _e.bbox_bottom;
	return _e.y + _b.b * abs(_e.image_yscale);
}

/// @func enemy_body_rect(_e)
/// @desc 一次性取四点，避免上面四个函数各查一次表
function enemy_body_rect(_e) {
	var _b = enemy_body_get(_e);
	if (is_undefined(_b)) {
		return { l: _e.bbox_left, r: _e.bbox_right, t: _e.bbox_top, b: _e.bbox_bottom };
	}
	var _sx = abs(_e.image_xscale);
	var _sy = abs(_e.image_yscale);
	var _neg = (_e.image_xscale < 0);
	return {
		l: _e.x + (_neg ? _b.r : _b.l) * _sx,
		r: _e.x + (_neg ? _b.l : _b.r) * _sx,
		t: _e.y + _b.t * _sy,
		b: _e.y + _b.b * _sy
	};
}

/// @func enemy_in_blast(_e, _bx, _by, _r)
/// @desc 爆炸判定：爆炸点到敌人身体矩形的最近距离 <= _r（贴视觉，只放宽不收紧）
function enemy_in_blast(_e, _bx, _by, _r) {
	if (!instance_exists(_e)) return false;
	var _rc = enemy_body_rect(_e);
	var _dx = 0;
	if (_bx < _rc.l) _dx = _rc.l - _bx;
	else if (_bx > _rc.r) _dx = _bx - _rc.r;
	var _dy = 0;
	if (_by < _rc.t) _dy = _rc.t - _by;
	else if (_by > _rc.b) _dy = _by - _rc.b;
	return (_dx * _dx + _dy * _dy) <= (_r * _r);
}

/// @func enemy_in_card_range(_cx, _cy, _e, _range_px)
/// @desc 卡片索敌辅助：卡片中心到敌人身体矩形的最近距离 <= _range_px
///       给需要像素级射程的卡用；老卡继续用整格判定不受影响
function enemy_in_card_range(_cx, _cy, _e, _range_px) {
	if (!instance_exists(_e)) return false;
	var _rc = enemy_body_rect(_e);
	var _dx = 0;
	if (_cx < _rc.l) _dx = _rc.l - _cx;
	else if (_cx > _rc.r) _dx = _cx - _rc.r;
	var _dy = 0;
	if (_cy < _rc.t) _dy = _rc.t - _cy;
	else if (_cy > _rc.b) _dy = _cy - _rc.b;
	return (_dx * _dx + _dy * _dy) <= (_range_px * _range_px);
}
'''

out = head + body + "\n" + tail
p = os.path.join(root, "scripts", "enemy_body", "enemy_body.gml")
io.open(p, "w", encoding="utf-8", newline="\n").write(out)
print("写入", p, os.path.getsize(p), "B")
