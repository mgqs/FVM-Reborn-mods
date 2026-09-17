event_inherited();
plant_id = "tianxie";
obj_type = object_index;
current_level = 1;
event_user(0);

if (shape == 0)
    sprite_index = spr_tianxie;
else if (shape == 1)
    sprite_index = spr_tianxie_1;
else if (shape == 2)
    sprite_index = spr_tianxie_2;

attack_anim = 7;
idle_anim = 11;
flash_speed = 5;
plant_type = "normal";
is_slowdown = false;
