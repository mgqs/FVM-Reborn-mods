/// 雪球兔 弹体 Create（从上方砸下的追踪雪球）
event_inherited();

damage     = 0;
base_atk   = 0;
move_speed = 14;
row        = 0;
shape      = 0;

target_type    = "track";
damage_type    = "normal";
hittable_types = get_hittable_enemy_types(target_type);

target_id    = noone;
hitted_enemy = noone;
has_hit      = false;
hit_tick     = 0;

tx = x;
ty = y;
start_y = y;
start_x = x;
fall_delay = 0;
fall_t     = 0;
fall_speed_y = 0;

splash_ratio = 0;
splash_cells = 1;

image_speed  = 0;
image_index  = 0;
image_angle  = 0;

// 三形态共用同一张冰球（_1/_2 与本体前 10 帧逐像素相同，2026-11-13 已删）
sprite_index = spr_snowrabbit_bullet;

image_xscale = 1;
image_yscale = 1;
