event_inherited();
damage = 0
move_speed = 0
cvspeed = 0
cgravity = 0
row = 0
target_enemy = noone
hitted_enemy = noone
hit_enemy = false
splashed = false
shape = 0
damage_type = "throw"
target_type = "throw"
image_angle = -45
atk_modified = false
image_xscale = 1.8;
image_yscale = 1.8;
// 2026-11-07：**只要求「索敌不索障碍」**（见 obj_ronghedan_god/Step_0），
//   子弹本身仍然可以对障碍造成伤害（打偏 / 擦到铁锅照吃），所以这里不改类型表。
hittable_types = get_hittable_enemy_types(target_type);
hit_tick = 0;
has_splashed = false;
image_speed = 0;
image_index = 0;
stun_chance = 20;
stun_frames = 90;
original_damage = 0;
thrower_y = 0;
// 深度融合（1 转起）：单格 3×3 毒气伤害值（按星级查表，见 obj_ronghedan_god/Create_0）
poison_damage = 0;
// 溅射比例（三档恒定 35%）
splash_ratio = 0.35;
