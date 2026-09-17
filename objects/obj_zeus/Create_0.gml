event_inherited();
plant_id = "zeus";
obj_type = object_index;
current_level = 1;
event_user(0);

if (shape == 0)
    sprite_index = spr_zeus;
else if (shape == 1)
    sprite_index = spr_zeus_1;
else if (shape == 2)
    sprite_index = spr_zeus_2;
else if (shape == 3)
    sprite_index = spr_zeus_3;

attack_anim = 30;
idle_anim = 11;
flash_speed = 5;
plant_type = "normal";
is_slowdown = false;
target_type = "track";
attack_timer = 0;
