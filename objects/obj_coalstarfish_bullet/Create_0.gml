damage = 0
move_speed = 0
y_move_speed = 0
row = 0
col = 0
damage_type = "normal"
target_type = "normal"
b_type = 0
burnt = 0
bounced = false
image_xscale = 1.5;
image_yscale = 1.5;
hittable_types = get_hittable_enemy_types(target_type);
hit_interval = 3;
hit_tick = 0;

// ── 环境交互（2026-11-10）：吃火 / 可反弹 + 需要的参数都在这里声明，碰撞事件由父类 obj_bullet_parent 统一处理
hazard_rebound = { flip_y:true, judge:"none" };   // 炭烧海星：斜弹翻 y
