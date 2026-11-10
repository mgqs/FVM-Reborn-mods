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
image_xscale = 1.8
image_yscale = 1.8

brazier_list = ds_list_create()

// ── 环境交互（2026-11-10）：吃火 / 可反弹 + 需要的参数都在这里声明，碰撞事件由父类 obj_bullet_parent 统一处理
hazard_fire = { scale:0 };   // 坚果炒锅：斜弹，反弹时竖直分量一起翻
hazard_rebound = { flip_y:true, judge:"none" };   // 坚果炒锅：斜弹，反弹时竖直分量一起翻
