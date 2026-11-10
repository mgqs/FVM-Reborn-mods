damage = 0
source_card_id = ""
move_speed = 0
row = 0
damage_type = "normal"
target_type = "normal"
burnt = 0
bounced = false
brazier_list = ds_list_create()
image_xscale = 1.8;
image_yscale = 1.8;
hittable_types = get_hittable_enemy_types(target_type);
hit_tick = 0;

// ── 环境交互（2026-11-10）：吃火 / 可反弹 + 需要的参数都在这里声明，碰撞事件由父类 obj_bullet_parent 统一处理
hazard_fire = { src_gate:"gatlin_ice_long_bao" };   // 冰冻长枪：只有本卡打出的那颗吃火
hazard_rebound = true;   // 可被樱桃布丁 / 布丁汪 / 水神 反弹
