event_inherited();
plant_id = "fire_god";
event_user(0);
sprite_index = spr_fire_god;

if (shape == 1)
    sprite_index = spr_fire_god_1;
else if (shape == 2)
    sprite_index = spr_fire_god_2;
else if (shape == 3)
    sprite_index = spr_fire_god_3;

attack_anim = 26;
idle_anim = 11;
flash_speed = 5;
plant_type = "normal";
is_slowdown = false;
