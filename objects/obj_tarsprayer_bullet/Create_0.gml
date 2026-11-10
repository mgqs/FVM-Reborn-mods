damage = 0
move_speed = 8
row = 0
col = 0
start_col = 0
hitted_enemy = ds_list_create()
brazier_list = ds_list_create()
shape = 0
burnt = 0
damage_type = "pierce"
target_type = "pierce"
disabled = false
image_speed = 0
image_index = 0
image_alpha = 1
image_angle = 0
image_blend = c_white
timer = 0
image_xscale = 1.8;
image_yscale = 1.8;
hittable_types = get_hittable_enemy_types(target_type);
hit_tick = 0;

// ── 环境交互（2026-11-10）：吃火 / 可反弹 + 需要的参数都在这里声明，碰撞事件由父类 obj_bullet_parent 统一处理
hazard_fire = true;      // 可被火盆 / 火神 / 金牛 / 能量喵 / 融合火盆 点燃
