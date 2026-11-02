// obj_tangchaolizi_bullet_effect（落地灼烧）Create 事件
// 精灵与子弹共用：8~13 爆开、14 起火焰到倒数第 2 帧（末尾 1 帧空帧）。
// 灼烧 10 跳 × 0.2s（12 步一跳），每跳 = 攻击力；范围 0 转 3×3 十字、1·2 转 3×3 全格（见 Other_10）。
image_speed = 0;
image_index = 0;
timer = 0;

damage = 0;
damage_corner = 0;   // 四角格伤害；0 = 跟 damage 一样
grid_row = 0;
grid_col = 0;
shape = 0;
target_type = "throw";
damage_type = "throw";

// 与生煎锅落地特效同一口径
image_xscale = 1.8;
image_yscale = 1.8;
