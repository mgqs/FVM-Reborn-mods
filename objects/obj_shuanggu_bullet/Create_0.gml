// obj_shuanggu_bullet（耗油双菇 · 对陆子弹）
damage = 0
move_speed = 0
row = 0
damage_type = "normal"
target_type = "normal"
timer = 0
burnt = 0
bounced = false
brazier_list = ds_list_create()
image_speed = 0
image_xscale = 1.8
image_yscale = 1.8
bullet_shape = 0
hittable_types = get_hittable_enemy_types(target_type)
hit_tick = 0

// 🔴 对象池复用必须重置内置显示变量（名字含 bullet → 走池，instance_change 不重置）
image_angle = 0;
image_index = 0;
image_alpha = 1;
image_blend = c_white;
