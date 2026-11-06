// obj_dangdanghu_fire（落点灼烧格）Create
// 10 跳 × 12 帧（0.2 秒），每跳造成 damage/10；范围 0/1 转 3×3 十字、2 转 3×3 方块
image_speed = 0;
image_index = 0;
image_alpha = 0.9;
image_blend = c_white;
image_xscale = 1.8;
image_yscale = 1.8;

grid_col = 0;
grid_row = 0;
shape = 0;
damage = 0;
ticks = 0;
tick_timer = 0;
total_ticks = 10;   // 由 obj_dangdanghu_bullet 按注册表 custom 覆盖
tick_gap = 12;
