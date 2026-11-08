// obj_huanyingshe_bullet（追踪蛇蛋）Create
// 2026-11-08 重写：参数化抛物线（起点 → 落点插值 + 正弦弧），落点每帧跟着目标更新，
//   命中 bbox / 到点即爆 → 爆点格子 = 目标的 grid_row/col（**不反推**），3×3 溅射。
// 素材 10 帧：0~4 蛋飞行、5~8 碎片、9 空白。
event_inherited();

can_dandantu_store = false;

sprite_index = spr_huanyingshe_bullet;
image_speed  = 0;
image_index  = 0;
image_angle  = 0;
image_alpha  = 1;
image_blend  = c_white;
image_xscale = 1.5;
image_yscale = 1.5;

damage       = 0;
splash_ratio = 0.3;

// 抛物线：起点 → 落点，p = life / land_frame，弧高 arc_h
start_x     = x;
start_y     = y;
land_x      = x;
land_y      = y;
land_frame  = 30;
arc_h       = 140;
life        = 0;
max_life    = 120;    // 兜底（正常 land_frame 就炸了）

// 追踪目标与爆点格子（溅射中心一律用它，别再按落点 world→grid 反算）
target_id       = noone;
grid_target_row = 0;
grid_target_col = 0;

// 命中碎片段（素材第 6~9 帧 = 索引 5~8）
exploding = false;
explode_t = 0;
hit_first = 5;
hit_last  = 8;
hit_tick  = 0;

damage_type = "throw";     // 投掷类伤害（同铛铛虎 / 糖球投手 / 煮蛋器）：无视护罩直扣本体
target_type = "throw";
hittable_types = get_hittable_enemy_types("throw");
