event_inherited();
plant_id = "power_god";
obj_type = object_index;
sprite_index = spr_power_god;
current_level = 1;
event_user(0);

if (shape == 1)
    sprite_index = spr_power_god_1;
else if (shape == 2)
    sprite_index = spr_power_god_2;
else if (shape == 3)
    sprite_index = spr_power_god_3;

attack_anim = 17;
idle_anim = 13;
flash_speed = 5;
plant_type = "normal";
is_slowdown = false;
target_type = "track";
