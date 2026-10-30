// obj_eightcake（8周年蛋糕）开火事件（event_user(1)）
// 往本行最前面那只老鼠身上投一件：普通蛋糕子弹 / 蜡烛子弹（每第 3n 次）；
// 二转时每第 10n 次再额外补一颗可乐炸弹（与蜡烛子弹相互独立）。
eightcake_shot_count++;

var _is_burn = (eightcake_shot_count mod 3 == 0);
var _is_bomb = (shape >= 2 && eightcake_shot_count mod 10 == 0);

// 出膛口 = 勺子末端（精灵原点在盘子中心、卡片按 1.8 倍画：
//   勺尖在精灵坐标 (42,60)，相对原点 (100,115) 是 (-58,-55) → 1.8 倍后 ≈ (-104,-99)）
var _muzzle_x = x - 104;
var _muzzle_y = y - 99;

var _tgt = eightcake_target;
var _has_tgt = (_tgt != noone && instance_exists(_tgt) && _tgt.hp > 0);

// 没有目标时的兜底落点：前方 8 格的格子中心
var _target_col = eightcake_target_col;
if (_target_col < 0 || _target_col >= global.grid_cols)
    _target_col = min(grid_col + eightcake_throw_dist, global.grid_cols - 1);
var _cell = get_world_position_from_grid(_target_col, grid_row);

if (_is_burn)
{
    // ===== 蜡烛：砸到老鼠身上，火在**本行格子**上烧 =====
    //   老鼠跑到地图外（第 9 格右边）也照样砸它 —— 不按格子截断
    var _bx = _has_tgt ? _tgt.x : _cell.x;
    var _bcol = _has_tgt ? _tgt.grid_col : _target_col;
    // 火的位置：本行格子的**视觉中线**。地图贴图画出来的格子缝比逻辑网格高 36px
    //   （同 bbq 的 _art_up），只按 grid 中线摆会整体偏低、看着烧到下一行
    var _by = get_world_position_from_grid(_bcol, grid_row).y - 36;
    var _bd = point_distance(_muzzle_x, _muzzle_y, _bx, _by);

    var _b = instance_create_depth(_muzzle_x, _muzzle_y, depth - 500, obj_eightcake_burn_bullet);
    // 蜡烛贴图按形态换：本体 32 帧（飞行 0~13 / 落地 14 / 火 15~30）
    //   一转、二转是 36 帧（飞行 0~16 / 17 空 / 落地 18 / 火 19~34）—— 帧段要跟着换，不然飞着就闪出火
    if (shape >= 2)
    {
        _b.sprite_index = spr_eightcake_burn_bullet_2;
        _b.fly_end = 16; _b.burn_start = 19;
    }
    else if (shape == 1)
    {
        _b.sprite_index = spr_eightcake_burn_bullet_1;
        _b.fly_end = 16; _b.burn_start = 19;
    }
    _b.damage = round(atk * eightcake_burn_ratio);
    _b.raw_atk = atk;
    _b.row = grid_row;
    _b.col = _bcol;
    _b.sx = _muzzle_x;
    _b.sy = _muzzle_y;
    _b.tx = _bx;
    _b.ty = _by;
    _b.T   = clamp(round(_bd / 20), 20, 46);          // 距离越远飞得越久
    _b.arc = clamp(_bd * 0.42, 80, 300);             // 拱高随距离走
}
else
{
    // ===== 普通蛋糕块：砸最前面那只的**身体中心**（不是脚底，否则看着像掉在脚上 / 前一格）=====
    var _bx2 = _has_tgt ? _tgt.x : _cell.x;
    var _by2 = _has_tgt ? (_tgt.y - 50) : _cell.y;
    var _bcol2 = _has_tgt ? _tgt.grid_col : _target_col;
    var _bd2 = point_distance(_muzzle_x, _muzzle_y, _bx2, _by2);

    var _b2 = instance_create_depth(_muzzle_x, _muzzle_y, depth - 500, obj_eightcake_bullet);
    // 蛋糕块贴图按形态换（三张都是 18 帧：0~16 飞行、17 空帧）
    if (shape >= 2) _b2.sprite_index = spr_eightcake_bullet_2;
    else if (shape == 1) _b2.sprite_index = spr_eightcake_bullet_1;
    _b2.damage = atk;
    _b2.row = grid_row;
    _b2.col = _bcol2;
    _b2.sx = _muzzle_x;
    _b2.sy = _muzzle_y;
    _b2.tx = _bx2;
    _b2.ty = _by2;
    _b2.T   = clamp(round(_bd2 / 20), 20, 46);
    _b2.arc = clamp(_bd2 * 0.42, 80, 300);
}

if (_is_bomb)
{
    // 可乐炸弹仍按格子落（3×3 爆炸需要格子）
    var _b3 = instance_create_depth(_muzzle_x + 18, _muzzle_y - 4, depth - 500, obj_eightcake_bomb);
    _b3.damage = eightcake_bomb_damage;
    _b3.row = grid_row;
    _b3.col = _target_col;
    _b3.sx = _muzzle_x + 18;
    _b3.sy = _muzzle_y - 4;
    _b3.tx = _cell.x;
    _b3.ty = _cell.y + global.grid_cell_size_y / 2 - 14;
}

audio_play_sound(snd_shot, 0, 0);
