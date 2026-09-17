event_inherited();
plant_id = "ymir";
obj_type = object_index;
current_level = 1;
event_user(0);

if (shape == 0)
    sprite_index = spr_ymir;
else if (shape == 1)
    sprite_index = spr_ymir_1;
else if (shape == 2)
    sprite_index = spr_ymir_2;
else if (shape == 3)
    sprite_index = spr_ymir_3;

attack_anim = 8;
idle_anim = 10;
flash_speed = 5;
plant_type = "normal";
is_slowdown = false;
target_instance = -4;
target_type = "throw";
