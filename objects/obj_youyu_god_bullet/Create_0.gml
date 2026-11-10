event_inherited();
damage = 0;
move_speed = 8;
move_x = move_speed;
move_y = 0;
shape = 0;
target_id = noone;
base_atk = 0;
timer = 0;
max_life = 600;
has_hit = false;
damage_type = "normal";
target_type = "normal";
hitted_enemy = ds_list_create();
hittable_types = get_hittable_enemy_types(target_type);
hit_tick = 0;
row = 0;
burnt = 0;
bounced = false;
can_burn = false;
delay = 0;
brazier_list = ds_list_create();
image_xscale = 1.6;
image_yscale = 1.6;

// ── 环境交互（2026-11-10）：吃火 / 可反弹 + 需要的参数都在这里声明，碰撞事件由父类 obj_bullet_parent 统一处理
hazard_fire = { scale:0 };   // 游鱼神：斜向双分量
hazard_rebound = { axis:"move_x" };   // 游鱼神：斜向双分量
fire_mult = 1;           // 对象池会复用实例：不重置就会带着上一发的过火倍率出生，导致这一发点不着
