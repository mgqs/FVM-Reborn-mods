damage = 0;
row = 0;
bounced = false;
move_speed_x = 0;
move_speed_y = 0;
damage_type = "pierce";
target_type = "normal";
image_speed = 0;
anim_timer = 0;
hit_anim_timer = 0;
hitted_enemy = ds_list_create();
bullet_hit = false;
image_xscale = 1.2;
image_yscale = 1.2;
hittable_types = get_hittable_enemy_types(target_type);

// ── 环境交互（2026-11-10）：吃火 / 可反弹 + 需要的参数都在这里声明，碰撞事件由父类 obj_bullet_parent 统一处理
hazard_rebound = { axis:"move_speed_x", judge:"none" };   // 里格：只反水平分量
fire_mult = 1;           // 对象池会复用实例：不重置就会带着上一发的过火倍率出生，导致这一发点不着
