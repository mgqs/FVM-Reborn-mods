// obj_shuanggu_bullet（蚝油双菇 · 对陆子弹）
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

// ── 环境交互（2026-11-10）：吃火 / 可反弹 + 需要的参数都在这里声明，碰撞事件由父类 obj_bullet_parent 统一处理
hazard_fire = true;      // 可被火盆 / 火神 / 金牛 / 能量喵 / 融合火盆 点燃
hazard_rebound = true;   // 可被樱桃布丁 / 布丁汪 / 水神 反弹
fire_mult = 1;           // 对象池会复用实例：不重置就会带着上一发的过火倍率出生，导致这一发点不着
