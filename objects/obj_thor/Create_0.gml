event_inherited();
plant_id = "thor";
obj_type = object_index;
current_level = 1;
event_user(0);

if (shape == 0)
    sprite_index = spr_thor;
else if (shape == 1)
    sprite_index = spr_thor_1;
else if (shape == 2)
    sprite_index = spr_thor_2;
else if (shape == 3)
    sprite_index = spr_thor_3;

attack_anim = 13;
idle_anim = 13;
flash_speed = 5;
plant_type = "normal";
is_slowdown = false;
target_instance = -4;
super_bullet = 3;
target_type = "throw";
