event_inherited();
plant_id = "water_god";
event_user(0);
sprite_index = spr_water_god;

if (shape == 1)
    sprite_index = spr_water_god_1;
else if (shape == 2)
    sprite_index = spr_water_god_2;
else if (shape == 3)
    sprite_index = spr_water_god_3;

attack_anim = 26;
idle_anim = 9;
flash_speed = 6;
plant_type = "normal";
is_slowdown = false;
