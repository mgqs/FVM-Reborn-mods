damage = 0;
move_speed = 0;
row = 0;
damage_type = "normal";
target_type = "normal";
timer = 0;
target_row = -1;
start_y = 0;
target_y_calculated = false;
burnt = 0;
bounced = false;
shape = 0;
target_enemy = -4;
hitted_enemy = -4;
hit_enemy = false;
splashed = false;
shape = 0;
brazier_list = ds_list_create();
image_xscale = 1.6;
image_yscale = 1.6;
hittable_types = get_hittable_enemy_types(target_type);
hit_tick = 0;

// ── 环境交互（2026-11-10）：吃火 / 可反弹 + 需要的参数都在这里声明，碰撞事件由父类 obj_bullet_parent 统一处理
hazard_fire = true;      // 可被火盆 / 火神 / 金牛 / 能量喵 / 融合火盆 点燃
hazard_rebound = true;   // 可被樱桃布丁 / 布丁汪 / 水神 反弹
fire_mult = 1;           // 对象池会复用实例：不重置就会带着上一发的过火倍率出生，导致这一发点不着
