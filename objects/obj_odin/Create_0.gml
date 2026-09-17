event_inherited();
plant_id = "odin";
obj_type = object_index;
sprite_index = spr_odin;
current_level = 1;
event_user(0);

if (shape == 1)
    sprite_index = spr_odin_1;
else if (shape == 2)
    sprite_index = spr_odin_2;
else if (shape == 3)
    sprite_index = spr_odin_3;

attack_anim = 11;
idle_anim = 9;
flash_speed = 4;
plant_type = "normal";
is_slowdown = false;
