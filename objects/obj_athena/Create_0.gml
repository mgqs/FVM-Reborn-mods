event_inherited();
plant_id = "athena";
obj_type = object_index;
current_level = 1;
event_user(0);

if (shape == 0)
    sprite_index = spr_athena;
else if (shape == 1)
    sprite_index = spr_athena_1;
else if (shape == 2)
    sprite_index = spr_athena_2;

attack_anim = 30;
idle_anim = 11;
flash_speed = 5;
plant_type = "normal";
is_slowdown = false;
target_type = "track";
attack_timer = 0;
