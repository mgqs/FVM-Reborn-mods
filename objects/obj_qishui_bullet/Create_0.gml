/// 弹珠汽水 弹体 Create（直线弹：命中后弹射到周围最近的另外目标）
event_inherited();

damage     = 0;
base_atk   = 0;
move_speed = 10;
row        = 0;
shape      = 0;

target_type    = "normal";
damage_type    = "normal";
hittable_types = ["normal", "obstacle", "invisible"];

hit_tick     = 0;
hitted_enemy = noone;
has_hit      = false;

// 命中瞬间的坐标 / 格子：2 转碎冰会把目标当场销毁，Destroy 里就读不到它的 x/grid_* 了
hit_x   = 0;
hit_y   = 0;
hit_col = 0;
hit_row = 0;

// 弹射态（由 Destroy 里创建的子弹置 true，走 move_x/move_y 直线插值）
is_bounce     = false;
move_x        = 0;
move_y        = 0;
bounce_target = noone;    // 这一段弹射要飞向谁
skip_enemy    = noone;    // 刚打过的那只，别再补一刀
bounce_life   = 0;        // 弹射段寿命（防止目标没了之后一直挂着）

bounce_times = 3;    // 总计能打几只（含直线命中那一下）
chain_left   = 0;    // 这颗子弹命中后还能再弹几次
bounce_mult  = 2;
bounce_cells = 1;
slow_frames  = 0;
ice_death    = false;

if (shape == 1)      sprite_index = spr_qishui_bullet_1;
else if (shape == 2) sprite_index = spr_qishui_bullet_2;
else                 sprite_index = spr_qishui_bullet;

image_speed  = 1;
image_xscale = 1.4;
image_yscale = 1.4;
