damage = 0;
move_speed = 0;
row = 0;
hitted_enemy = ds_list_create();
shape = 0;
burnt = 0;
bounced = false;
damage_type = "pierce";
target_type = "normal";
brazier_list = ds_list_create();
image_xscale = 1.8;
image_yscale = 1.8;
hittable_types = get_hittable_enemy_types(target_type);
hit_tick = 0;

// ── 环境交互（2026-11-10）：吃火 / 可反弹 + 需要的参数都在这里声明，碰撞事件由父类 obj_bullet_parent 统一处理
hazard_rebound = { judge:"col" };   // 饿鬼神三向弹：按列判定
fire_mult = 1;           // 对象池会复用实例：不重置就会带着上一发的过火倍率出生，导致这一发点不着
