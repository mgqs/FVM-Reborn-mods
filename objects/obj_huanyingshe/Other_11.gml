// obj_huanyingshe 用户事件1：投掷蛇蛋（固定发数 · 有敌行各 1 发 · 多余的按「最前」补）
// 2026-11-08 口径（用户）：
//   · 发数固定 3 / 6，与「有敌人的行数」无关
//   · **有老鼠的行至少 1 发**（每路先各铺 1 发）
//   · **没老鼠的行不会有蛋落在上面**：那一路的蛋改打「最前」的那一路（多出来的空路依次往后轮）
//   · 多出来的子弹（二转 6 - 5 = 1）同样按「最前」补 —— 谁的老鼠推得最靠前，就先补谁
// 「最前」= 该路最左那只的 grid_col 最小（最靠洞口）；同列按「本行优先」的道序
// 子弹：参数化抛物线飞向目标（落点每帧跟着目标更新），命中 bbox / 到点即爆，溅射中心用目标的 grid_row/col。
var _lanes  = [];   // 本行 ± row_span 的所有合法行（按「本行优先」：0 / -1 / +1 / -2 / +2）
var _lane_t = [];   // 每路最左那只（没有 = noone）
var _lane_c = [];   // 每路最左那只的列号（999999 = 该路没敌人）
var _offs   = [0, -1, 1, -2, 2];

for (var _o = 0; _o < array_length(_offs); _o++)
{
    var _off = _offs[_o];
    if (abs(_off) > row_span) continue;

    var _lane = grid_row + _off;
    if (_lane < 0 || _lane >= global.grid_rows) continue;

    var _best   = noone;
    var _best_c = 999999;
    with (obj_enemy_parent)
    {
        if (hp <= 0) continue;
        if (grid_row != _lane) continue;
        if (grid_col < other.grid_col) continue;
        if (grid_col > global.grid_cols + 1) continue;
        if (!can_target_on(other.target_type, target_type)) continue;

        if (grid_col < _best_c)
        {
            _best_c = grid_col;
            _best   = id;
        }
    }

    array_push(_lanes,  _lane);
    array_push(_lane_t, _best);
    array_push(_lane_c, instance_exists(_best) ? _best_c : 999999);
}

var _ln = array_length(_lanes);
if (_ln <= 0) exit;

// ── 有敌人的路，按「最前」排序：grid_col 越小（推得越靠前）排越前，同列按本行优先的道序 ──
var _ord  = [];
var _pos2 = 0;
for (var _i1 = 0; _i1 < _ln; _i1++)
{
    if (_lane_c[_i1] >= 999999) continue;          // 这一路没老鼠 → 不进候选

    _pos2 = array_length(_ord);
    for (var _i2 = 0; _i2 < array_length(_ord); _i2++)
    {
        if (_lane_c[_i1] < _lane_c[_ord[_i2]])
        {
            _pos2 = _i2;
            break;
        }
    }
    array_insert(_ord, _pos2, _i1);
}
if (array_length(_ord) <= 0) exit;                 // 整条带子里一个目标都没有（正常已被 Step 的有敌判定挡掉）

// ── 发数分配：每路先各 1 发；余量按「最前」轮流补有敌的路 ──
var _pick = array_create(egg_count, -1);
var _m    = min(egg_count, _ln);
for (var _a = 0; _a < _m; _a++) _pick[_a] = _a;

var _rest = egg_count - _m;
for (var _r = 0; _r < _rest; _r++)
{
    _pick[_m + _r] = _ord[_r mod array_length(_ord)];
}

// ── 逐发出弹 ──
var _orphan = 0;    // 空路的蛋：第一发去最前那路，第二发去次前那路……
for (var _n = 0; _n < egg_count; _n++)
{
    var _li  = _pick[_n];
    if (_li < 0) _li = _n mod _ln;

    var _tgt = _lane_t[_li];
    if (!instance_exists(_tgt))
    {
        // 这一路没老鼠：蛋不取消，改打「最前」的有敌路（空路多于一发时依次往后轮）
        _tgt = _lane_t[_ord[_orphan mod array_length(_ord)]];
        _orphan++;
    }
    if (!instance_exists(_tgt)) continue;

    // 起点 = 卡面上方（每发往后错开 8px，避免同一路的 2 发完全重叠、连成一串飞出）
    var _sx = x - _n * 8;
    var _sy = y - 120;
    // 落点 = 目标身上（之后每帧跟着目标更新）
    var _lx = _tgt.x;
    var _ly = _tgt.y - 45;

    var _b = instance_create_depth(_sx, _sy, depth - 500, obj_huanyingshe_bullet);
    _b.start_x     = _sx;
    _b.start_y     = _sy;
    _b.land_x      = _lx;
    _b.land_y      = _ly;
    _b.arc_h       = 140;                                            // 弧顶再往上抬多少 px
    _b.land_frame  = clamp(26 + abs(_lx - _sx) / 55, 26, 50) + _n * 2; // 飞行帧数（距离越远越久；逐发错开 2 帧）
    _b.target_id   = _tgt;
    _b.grid_target_row = _tgt.grid_row;
    _b.grid_target_col = _tgt.grid_col;
    _b.damage       = atk;
    _b.splash_ratio = splash_ratio;
    _b.damage_type  = "throw";
    _b.target_type  = "throw";
    _b.hittable_types = get_hittable_enemy_types("throw");

    if (shape == 1)      _b.sprite_index = spr_huanyingshe_bullet_1;
    else if (shape == 2) _b.sprite_index = spr_huanyingshe_bullet_2;
}

audio_play_sound(snd_throw, 0, 0);
