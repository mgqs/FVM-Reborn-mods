event_inherited();
plant_id = "moon_god";
obj_type = object_index;
sprite_index = spr_moon_god;
current_level = 1;
event_user(0);

if (shape == 0)
    sprite_index = spr_moon_god;
else if (shape == 1)
    sprite_index = spr_moon_god_1;
else if (shape == 2)
    sprite_index = spr_moon_god_2;
else if (shape == 3)
    sprite_index = spr_moon_god_3;

attack_anim = 11;
idle_anim = 7;
flash_speed = 5;
plant_type = "normal";
is_slowdown = false;
target_type = "track";
