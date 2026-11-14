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

// 敌方子弹：**不声明** hazard_fire / hazard_rebound。
//   否则玩家的火盆会把倍率乘到它的伤害上，布丁反弹还会把玩家攻击力加进来 —— 等于帮敌人。
//   父类 obj_bullet_parent 的过火/反弹入口默认是关的，不写就是全关。
