// 目标类型：敌人碰撞事件会读 other.target_type（如 obj_ly_gaoqiao 的舞步守卫），
// 缺这个字段会直接崩「not set before reading it」。本子弹的命中/销毁走自己的逻辑，
// 不消费 can_target_on，标 normal 只影响「被敌人侧读到时按普通弹处理」。
target_type = "normal";
image_speed = 0;
state = "start";
target_x = -1;
target_y = -1;
row = 0;
can_mouse_list = ["can_mouse"];
damage = 900;
timer = 0;
shape_bullet = 0;
image_xscale = 1.8;
image_yscale = 1.8;
