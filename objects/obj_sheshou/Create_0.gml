event_inherited();
plant_id = "sheshou";
event_user(0);

if (shape == 0)
    sprite_index = spr_sheshou;
else if (shape == 1)
    sprite_index = spr_sheshou_1;
else if (shape == 2)
    sprite_index = spr_sheshou_2;

fire_mid = false;
fire_up = false;
fire_down = false;
attack_anim = 13;
idle_anim = 15;
flash_speed = 5;
plant_type = "normal";
is_slowdown = false;
