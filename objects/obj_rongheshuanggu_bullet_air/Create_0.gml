// obj_rongheshuanggu_bullet_air（融合双菇 · 对空子弹）
damage = 0
move_speed = 0
row = 0
damage_type = "normal"
target_type = "air_only"
timer = 0
burnt = 0
bounced = false
brazier_list = ds_list_create()
image_speed = 0
image_xscale = 1.8
image_yscale = 1.8
bullet_shape = 0
// pierce_all / hited_enemy：对空弹本身不穿透，但障碍碰撞脚本会读这两个变量
pierce_all = false
hited_enemy = ds_list_create()
// homing —— 2 转（糖葫芦）：全屏追踪，优先场上最靠前的空军
homing = false
target_enemy = -4
hittable_types = get_hittable_enemy_types(target_type)
hit_tick = 0

// 🔴 对象池复用必须重置内置显示变量（名字含 bullet → 走池，instance_change 不重置）
image_angle = 0;
image_index = 0;
image_alpha = 1;
image_blend = c_white;
