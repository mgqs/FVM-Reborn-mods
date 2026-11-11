/// 弹簧虎 弹体 Create（本行直线弹，命中后 3*3 溅射，可越过岩浆与障碍）
event_inherited();

damage     = 0;
base_atk   = 0;
move_speed = 11;
row        = 0;
shape      = 0;

target_type    = "pierce";
damage_type    = "pierce";
hittable_types = ["normal", "air", "invisible", "obstacle", "dance", "underground"];

hit_tick   = 0;
hitted_enemy = noone;
has_hit    = false;

splash_ratio = 0.25;
splash_cells = 1;

if (shape == 1)      sprite_index = spr_tanhuanghu_bullet_1;
else if (shape == 2) sprite_index = spr_tanhuanghu_bullet_2;
else                 sprite_index = spr_tanhuanghu_bullet;

image_speed  = 1;
image_xscale = 1.4;
image_yscale = 1.4;
