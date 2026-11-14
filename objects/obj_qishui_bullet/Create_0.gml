/// 弹珠汽水 弹体 Create（直线弹：命中后弹射到周围最近的另外目标）
event_inherited();

damage     = 0;
base_atk   = 0;
move_speed = 10;
row        = 0;
shape      = 0;

target_type    = "normal";
damage_type    = "normal";
// 2026-11-13：按**正常直射口径**取表 = `get_hittable_enemy_types("normal")` → 普通 + 障碍。
//   · 障碍（含夸父飞猪这种临时障碍）挡在弹道上时，和打到老鼠一样结算、一样触发弹射；
//   · 不打幽灵（原来手写多写了 invisible，属于配错的溢出）。
hittable_types = get_hittable_enemy_types(target_type);

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

// 弹射段抛物线（2026-11-13：像色拉那样「跳」过去，不是直线贴脸）
bs_x = 0; bs_y = 0;       // 这一跳的起点
bounce_t     = 0;         // 这一跳已过帧数
bounce_total = 10;        // 这一跳总帧数
bounce_arc   = 75;        // 跳跃高度（px），越大弧越高
bounce_wait  = 0;         // 找不到下一个目标 → 原地停留（淡出）计时

bounce_times = 3;    // 总计能打几只（含直线命中那一下）
chain_left   = 0;    // 这颗子弹命中后还能再弹几次
chain_ids    = [];   // 已经打过的敌人 id（防止弹射绕回同一只）
bounce_mult  = 2;
bounce_cells = 1;
slow_frames  = 0;
ice_death    = false;

// 2026-11-13：_1 与本体一样，已删；只有 2 转换 _2
// 2026-11-13 用户口径：**直射段一律用普通弹体** spr_qishui_bullet
//   只有「打完第一只之后开始弹射」的那颗（Destroy 生成、is_bounce = true）才换 spr_qishui_bullet_2
sprite_index = spr_qishui_bullet;

image_speed  = 1;
image_xscale = 1.4;
image_yscale = 1.4;
