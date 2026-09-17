event_inherited();
plant_id = "juxie";
obj_type = object_index;
sprite_index = spr_juxie;
current_level = 1;
event_user(0);

if (shape == 1)
    sprite_index = spr_juxie_1;
else if (shape == 2)
    sprite_index = spr_juxie_2;

attack_anim = 9;
idle_anim = 8;
flash_speed = 5;
plant_type = "normal";
is_slowdown = false;
target_type = "track";
