/// 窃蛋龙 弹体 Create（投掷弹：抛物线飞行，命中或落地都会爆炸）
event_inherited();

damage     = 0;
base_atk   = 0;
move_speed = 0;
cvspeed    = 0;
cgravity   = 0;
row        = 0;
shape      = 0;

target_type    = "throw";
damage_type    = "throw";
hittable_types = get_hittable_enemy_types(target_type);

hit_enemy    = false;
hitted_enemy = noone;
has_splashed = false;
hit_tick     = 0;

splash_ratio = 0.35;
splash_cells = 1;

thrower_y = 0;
land_y    = 0;

image_speed = 0;
image_index = 0;
image_angle = -45;

if (shape == 1)      sprite_index = spr_qiedanlong_bullet_1;
else if (shape == 2) sprite_index = spr_qiedanlong_bullet_2;
else                 sprite_index = spr_qiedanlong_bullet;

image_xscale = 1.4;
image_yscale = 1.4;
