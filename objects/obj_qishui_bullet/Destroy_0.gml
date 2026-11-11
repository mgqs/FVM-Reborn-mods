/// 弹珠汽水 弹体 Destroy：命中后向周围最近的另外目标弹射
/// 首颗弹射子弹伤害 = 直线弹 × 弹射倍率，之后的弹射保持该伤害
if (chain_left <= 0) exit;
if (!has_hit) exit;

// 目标可能已经被 2 转碎冰销毁了 → 用命中瞬间存下来的坐标 / 格子，不再依赖实例还在
var _from = hitted_enemy;
var _fx   = hit_x;
var _fy   = hit_y;
var _fcol = hit_col;
var _frow = hit_row;

// ── 在 bounce_cells 格半径内找最近的其他目标 ──
var _best     = noone;
var _best_dis = 999999;

with (obj_enemy_parent){
    if (hp <= 0) exit;
    if (instance_exists(_from) && id == _from) exit;   // 刚打过的那只（还活着才排除）
    if (target_type == "obstacle") exit;
    if (abs(grid_col - _fcol) > other.bounce_cells) exit;
    if (abs(grid_row - _frow) > other.bounce_cells) exit;
    if (!can_target_on(other.target_type, target_type)) exit;

    var _dis = point_distance(_fx, _fy, x, y);
    if (_dis < _best_dis){
        _best_dis = _dis;
        _best = id;
    }
}

if (_best == noone) exit;

// ── 生成弹射子弹：从**本颗弹现在的位置**起飞，飞向最近那只 ──
//   原来直接出生在目标身上、move_x/move_y = 0，看起来是瞬移
var _sx = x;
var _sy = y;

var _nb = instance_create_depth(_sx, _sy, depth, obj_qishui_bullet);
_nb.is_bounce     = true;
_nb.bounce_target = _best;
_nb.skip_enemy    = _from;
_nb.bounce_life   = 0;
_nb.move_x        = 0;
_nb.move_y        = 0;
_nb.damage        = damage * bounce_mult;
_nb.base_atk      = base_atk;
_nb.move_speed    = move_speed;
_nb.shape         = shape;
_nb.row           = _best.grid_row;
_nb.target_type   = target_type;
_nb.damage_type   = damage_type;
_nb.hittable_types = hittable_types;
_nb.bounce_times  = bounce_times;
_nb.chain_left    = chain_left - 1;
_nb.bounce_mult   = bounce_mult;
_nb.bounce_cells  = bounce_cells;
_nb.slow_frames   = slow_frames;
_nb.ice_death     = ice_death;
_nb.hit_tick      = 0;

if (shape == 1)      _nb.sprite_index = spr_qishui_bullet_1;
else if (shape == 2) _nb.sprite_index = spr_qishui_bullet_2;
else                 _nb.sprite_index = spr_qishui_bullet;
