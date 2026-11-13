/// 弹珠汽水 开火事件：本行直线弹
var _b = instance_create_depth(x + qs_muzzle_x, y + qs_art_up, depth - 500, obj_qishui_bullet);
// 2026-11-13 用户口径：**直射弹 = 攻击表 2 倍伤害**，弹射弹 = 攻击表原值（不是反过来）
_b.damage         = atk * qs_direct_mult;
_b.base_atk       = atk;
_b.move_speed     = 10;
_b.shape          = shape;
_b.row            = grid_row;
_b.hittable_types = get_hittable_enemy_types(target_type);
_b.bounce_times   = qs_bounce_times;
_b.chain_left     = qs_bounce_times;       // 直射 + 弹射 3 次 = 最多打 4 只
_b.bounce_mult    = qs_bounce_mult;
_b.bounce_cells   = qs_bounce_cells;
_b.slow_frames    = qs_slow_frames;
_b.ice_death      = qs_ice_death;

// 2026-11-13：直射段所有形态都用普通弹体（Create 里已设好），这里不再按 shape 换 _2；
//   spr_qishui_bullet_2 只给「弹射段」用，切换在 obj_qishui_bullet/Destroy_0 里做

audio_play_sound(snd_shot, 0, 0);
