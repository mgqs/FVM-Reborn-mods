// obj_fashishe_bullet（法师蛇 · 蛇形穿透弹）Create 事件
// 弹道：沿本行向右匀速，y 上做正弦摆动；全程穿透（同一只老鼠只吃一次）。
// 过火 / 反弹：与 bbq 子弹同一套（火盆 / 融盆 / 火神 / 金牛 / 能量喵 + 布丁 / 水神）。
event_inherited();

can_dandantu_store = true;

sprite_index = spr_fashishe_bullet;
image_speed  = 0;
image_index  = 0;
image_angle  = 0;
image_alpha  = 1;
image_blend  = c_white;
image_xscale = 1.5;
image_yscale = 1.5;

damage    = 0;
move_speed = 6.5;
move_dir   = 1;          // 1 = 向右；被布丁 / 水神反弹后 -1

row    = 0;
base_y = y;              // 正弦摆动的中心线
phase  = 0;              // 两发之间错开半周期
wave_amp   = 15;
wave_speed = 0.13;

end_x      = 2200;
end_x_left = -200;
bounced    = false;
fading     = false;   // 出图后播「飞行到极限」的消散帧（第 5 帧起）
fade_t     = 0;

damage_type = "normal";     // 平射（2026-11-08 口径）
target_type = "normal";

// 过火字段（Collision_obj_* 与 ronghehuopen_pass_fire 都按这几个判定）
kind        = "fire";
burnt       = 0;
can_burn    = true;
brazier_list = ds_list_create();

hitted = ds_list_create();
hittable_types = get_hittable_enemy_types(target_type);
max_life = 400;
life = 0;
