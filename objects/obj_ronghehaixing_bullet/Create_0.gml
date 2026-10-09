damage = 0
move_speed = 0
y_move_speed = 0
row = 0
col = 0
damage_type = "normal"
target_type = "normal"
b_type = 0
bounced = false
shape = 0
target_id = noone
has_bounced_wall = false
bullet_speed = 8
image_xscale = 1.5;
image_yscale = 1.5;
image_speed = 0;
image_index = 0;
has_hit_anim = false;
hit_anim_timer = 0;
hittable_types = get_hittable_enemy_types(target_type);
// 命中判定隔帧计数（口径与 obj_youyu_god_bullet / obj_corn_shooter_bullet 一致，
// 间隔取 global.bullet_hit_interval = 2）
hit_tick = 0;
// 错帧连发延时：初级融合「向后的子弹数量+1」的第二发用它滞后飞出
delay = 0;
// 发射方向索引（0=后 1=下 2=上 3=右上 4=右下）—— 边界规则 / 追踪资格用它
dir_index = -1;
// 深度融合（1 转起）单格溅射比例，0 = 不溅射
splash_ratio = 0;
