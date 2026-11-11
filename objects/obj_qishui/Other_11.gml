/// 弹珠汽水 开火事件：本行直线弹
var _b = instance_create_depth(x + qs_muzzle_x, y + qs_art_up, depth - 500, obj_qishui_bullet);
_b.damage         = atk;
_b.base_atk       = atk;
_b.move_speed     = 10;
_b.shape          = shape;
_b.row            = grid_row;
_b.hittable_types = get_hittable_enemy_types(target_type);
_b.bounce_times   = qs_bounce_times;
_b.chain_left     = qs_bounce_times - 1;   // 直线命中算 1 只，剩下继续弹
_b.bounce_mult    = qs_bounce_mult;
_b.bounce_cells   = qs_bounce_cells;
_b.slow_frames    = qs_slow_frames;
_b.ice_death      = qs_ice_death;

// 1/2 转贴图：Create 时 shape 还没赋（=0），只能建完再换（同雪球兔写法）
if (shape == 1)      _b.sprite_index = spr_qishui_bullet_1;
else if (shape == 2) _b.sprite_index = spr_qishui_bullet_2;

audio_play_sound(snd_shot, 0, 0);
