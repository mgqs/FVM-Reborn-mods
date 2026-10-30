// 敌人侧的 Collision_obj_bullet_parent 会读 other.target_type（不论本对象自己有没有碰撞事件），
// 缺字段会崩「not set before reading it」，这里给特效弹补上普通弹标记。
target_type = "normal";
image_speed = 0;
timer = 0;
image_xscale = 1.8;
image_yscale = 1.8;
