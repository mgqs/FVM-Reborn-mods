event_inherited();
plant_id = "shuangyu";
obj_type = object_index;
current_level = 1;
event_user(0);

if (shape == 0)
    sprite_index = spr_shuangyu;
else if (shape == 1)
    sprite_index = spr_shuangyu_1;
else if (shape == 2)
    sprite_index = spr_shuangyu_2;

attack_anim = 13;
idle_anim = 13;
flash_speed = 5;
fire_advance = 35;
plant_type = "normal";
is_slowdown = false;
target_instance = -4;
target_type = "throw";
