// obj_huojianzhu 用户事件1：发射追踪导弹
// 2026-11-08 用户口径：**导弹直接落在老鼠那一格**，靠精灵自己的「从上往下落」帧表现下落，
//   到点就炸 —— 不再从 y-520 高空慢慢飘下来（那样看着像挂在天上抽搐）。
//   二转连发 3 枚，错开 10 帧起飞。
var _best   = noone;
var _best_d = 999999;

with (obj_enemy_parent)
{
    if (hp <= 0) continue;
    if (!can_target_on(other.target_type, target_type)) continue;

    var _d = point_distance(other.x, other.y, x, y);
    if (_d < _best_d){ _best_d = _d; _best = id; }
}

if (!instance_exists(_best)) exit;

// 落点 = 目标所在格子；导弹就生成在这里（贴图第 1 帧画在画布顶部，看起来就是从天上掉下来）
var _cell = get_world_position_from_grid(_best.grid_col, _best.grid_row);

for (var _i = 0; _i < shots; _i++)
{
    var _b = instance_create_depth(_cell.x, _cell.y - 30, depth - 500, obj_huojianzhu_bullet);
    _b.damage       = atk;
    _b.target_enemy = _best;
    _b.grid_row     = _best.grid_row;
    _b.grid_col     = _best.grid_col;
    _b.stun_frames  = stun_frames;
    _b.launch_delay = _i * 10;
    _b.wave         = _i;
    _b.target_type  = "track";
    _b.hittable_types = get_hittable_enemy_types("track");

    if (shape == 1)      _b.sprite_index = spr_huojianzhu_bullet_1;
    else if (shape == 2) _b.sprite_index = spr_huojianzhu_bullet_2;
}

audio_play_sound(snd_shot, 0, 0);
