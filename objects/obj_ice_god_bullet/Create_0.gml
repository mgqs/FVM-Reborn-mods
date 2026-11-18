// 目标类型：直击走 with(target_instance) 不判类型，这个值只给两处用 ——
//   ① Destroy 里 1 转起的 3*3 溅射筛类型（can_target_on）
//   ② 敌人碰撞事件读 other.target_type（如 obj_ly_gaoqiao 的舞步守卫）
target_type = "land_air_ug";
damage_type = "normal";
damage = 0;
target_enemy = -4;
hitted_enemy = -4;
move_speed = 0;
row = 0;
col = 0;
image_xscale = 1;
image_yscale = 1;
