damage = 0;
move_speed = 8;
bounced = false;
row = 0;
direction = 0;
damage_type = "normal";
can_ignite = false;
hit_enemies = ds_list_create();
image_speed = 1;
target_type = "all";
image_xscale = 1.2;
image_yscale = 1.2;
hittable_types = get_hittable_enemy_types(target_type);
hit_tick = 0;

// ── 环境交互（2026-11-10）：吃火 / 可反弹 + 需要的参数都在这里声明，碰撞事件由父类 obj_bullet_parent 统一处理
hazard_rebound = { dir_guard:true };   // 玫瑰盾：水平/垂直弹只看本行
