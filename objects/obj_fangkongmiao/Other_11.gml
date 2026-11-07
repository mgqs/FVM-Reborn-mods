// obj_fangkongmiao 用户事件1：弹出猫猫钢弹
// 目标：全场空军里最靠左（最接近洞口）的那只；同等位置取血最高的。
var _best    = noone;
var _best_x  = 99999;
var _best_hp = -1;

with (obj_enemy_parent)
{
    if (hp <= 0) continue;
    if (!can_target_on(other.target_type, target_type)) continue;

    if (x < _best_x || (x == _best_x && hp > _best_hp))
    {
        _best_x  = x;
        _best_hp = hp;
        _best    = id;
    }
}

// 出弹点：卡面上方 95px（同糖葫芦 obj_coal_starfish）。
//   原来写 y-40 会从猫头/猫身里钻出来（2026-11-08 用户口径）。
var _muzzle_y = y - 95;
var _b = instance_create_depth(x, _muzzle_y, depth - 500, obj_fangkongmiao_bullet);
_b.damage         = atk;
_b.target_enemy   = _best;
_b.move_speed     = 11;
_b.slow_frames    = slow_frames;
_b.target_type    = "air_only";
_b.hittable_types = get_hittable_enemy_types("air_only");
_b.xstart         = x;
_b.ystart         = _muzzle_y;

if (shape == 1)      _b.sprite_index = spr_fangkongmiao_bullet_1;
else if (shape == 2) _b.sprite_index = spr_fangkongmiao_bullet_2;

audio_play_sound(snd_shot, 0, 0);
