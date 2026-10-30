// 目标类型：敌人碰撞事件会读 other.target_type（如 obj_ly_gaoqiao 的舞步守卫），
// 缺这个字段会直接崩「not set before reading it」。本子弹的命中/销毁走自己的逻辑，
// 不消费 can_target_on，标 normal 只影响「被敌人侧读到时按普通弹处理」。
target_type = "normal";
target_enemy = -4;
explode_timer = 10;
timer = 0;
image_speed = 3;
image_xscale = 1.2;
image_yscale = 1.2;
