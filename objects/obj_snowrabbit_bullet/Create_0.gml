/// 雪球兔 弹体 Create（从上方砸下的追踪雪球）
event_inherited();

damage     = 0;
base_atk   = 0;
move_speed = 14;
row        = 0;
shape      = 0;

// 直击走 with(目标实例)、不判类型；这里只给二转 3*3 溅射筛用（can_target_on）。
// 卡片层是 all，溅射必须同口径 —— 留 track 会让地鼠 / 幽灵 / 非主流吃不到溅射。
target_type    = "all";
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
