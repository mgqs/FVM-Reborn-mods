event_inherited();
plant_id = "lingrong_god";
obj_type = object_index;

is_derivative = false
on_lava = false

event_user(0)

attack_anim = 0;
flash_speed = 8
idle_anim = 15
image_speed = 0
plant_type = "coffee"
remove_timer = 0
hole_count = 1
spawn_init = false
is_clone = false

anim_frame = 0
anim_timer = 0
placed = false
// 帧布局（用户口径 1 起算 → 这里换成 image_index 的 0 起算）：
//   nowater：1~4 变身（0~3）、5~16 待机循环（4~15），共 16 帧
//   water  ：1~5 变身（0~4）、6~14 待机循环（5~13），共 14 帧
// 先按陆地版初始化，真正的形态由 Step_0 每帧按脚下地形切换。
f_place_end = 3
f_idle_start = 4
f_idle_end = 15

sprite_index = lingrong_god_sprite(false, shape)
image_index = 0
