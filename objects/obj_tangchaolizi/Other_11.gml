// obj_tangchaolizi（糖炒栗子）开火事件（event_user(1)）
// 甩一颗栗子，抛物线砸向**目标所在格子**（带提前量，可到第 10 列地图外）；飞行中撞到老鼠会当场炸在它所在格
//   （同生煎锅）；落地后由 obj_tangchaolizi_bullet_effect 按格子结算灼烧（0 转十字 5 格 / 1·2 转 3×3）。
// 出弹守卫：只有 Step 的脱手帧（tc_firing = true）才能生成子弹。
// 令牌消费掉就失效（这里只清 tc_firing，**不动 tc_fired** —— 那是负责「本轮只投一颗」的锁存位）
if (!tc_firing) exit;
tc_firing = false;

var _tgt = tc_target;
var _has_tgt = (_tgt != noone && instance_exists(_tgt) && _tgt.hp > 0);

// 落点格：列 = 目标那一列（**不夹地图列**，老鼠排到多外面就丢多外面）；行恒 = 本行（同生煎锅）
var _col = _has_tgt ? tc_tcol : min(grid_col + range, global.grid_cols);
var _row = grid_row;

// 出膛口 = 锅口：精灵原点在锅底中心，锅口中心约在精灵坐标 (+1, -42)，
//   卡片按 1.8 倍画 → 世界坐标约 (+4, -74)
var _sx = x + 4;
var _sy = y - 74;

// 提前量（照生煎锅）：老鼠朝左推进，飞行这 T 帧它会走过 move_speed × T 像素。
//   不提前的话火焰永远落在「开火那一刻」的格，落地时老鼠已经往左走了 → 看着总慢半拍。
//   落点是整格，所以按格 round：不足半格不提前，半格以上提前 1 格。
if (_has_tgt && variable_instance_exists(_tgt, "move_speed") && _tgt.move_speed > 0)
{
    var _t0 = clamp(round(30 + ((get_world_position_from_grid(_col, _row).x - _sx) / 1000) * 45), 30, 75);
    _col = max(0, _col - round(_tgt.move_speed * _t0 / global.grid_cell_size_x));
}

// 落点 = 格子中心（get_world_position_from_grid 返回的就是中心）。
// 🔴 纵向再按「地图贴图格线」上抬 36（同 bbq 的 _art_up）：贴图画出来的格线比逻辑网格高 36px，
//    不抬的话火焰整体看着压在下一行。要微调只改这一个数，判定（row/col）不受影响。
var _cell = get_world_position_from_grid(_col, _row);
var _art_up = 36;
var _ty_vis = _cell.y - _art_up;
var _dist = point_distance(_sx, _sy, _cell.x, _ty_vis);

var _b = instance_create_depth(_sx, _sy, depth - 500, obj_tangchaolizi_bullet);
if (shape >= 2)      _b.sprite_index = spr_tangchaolizi_bullet_2;
else if (shape == 1) _b.sprite_index = spr_tangchaolizi_bullet_1;
else                 _b.sprite_index = spr_tangchaolizi_bullet;

_b.shape  = shape;
_b.damage = atk;
_b.damage_corner = atk_base0;   // 二转时四角格用 0 转 atk（十字格才吃二转加成）
_b.row    = _row;
_b.col    = _col;
_b.sx = _sx;
_b.sy = _sy;
_b.tx = _cell.x;
_b.ty = _ty_vis;      // 视觉落点 = 贴图格线（比逻辑格心高 36），火焰和栗子都落在这
// 飞行时间：生煎锅口径 clamp(30 + dx/1000*45, 30, 75) 帧（比原来的 20~46 慢一截）
_b.T   = clamp(round(30 + ((_cell.x - _sx) / 1000) * 45), 30, 75);
// 拱高：固定 120（生煎锅/融合栗子的实际顶点都在这附近，不再随距离拉到 300 那么夸张）
_b.arc = 120;

audio_play_sound(snd_throw, 0, 0);
