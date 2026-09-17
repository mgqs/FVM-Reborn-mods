event_inherited();
plant_id = "chaomian";
obj_type = object_index;
current_level = 1;
event_user(0);

if (shape == 0)
    sprite_index = spr_chaomian;
else if (shape == 1)
    sprite_index = spr_chaomian_1;
else if (shape == 2)
    sprite_index = spr_chaomian_2;

attack_anim = 9;
idle_anim = 25;
flash_speed = 5;
plant_type = "normal";
is_slowdown = false;
target_instance = -4;
target_type = "pierce";
