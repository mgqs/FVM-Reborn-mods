event_inherited();
plant_id = "donut";
event_user(0);

if (shape == 1)
    sprite_index = spr_donut_1;
else if (shape == 2)
    sprite_index = spr_donut_2;
else
    sprite_index = spr_donut;

attack_anim = 11;
idle_anim = 11;
flash_speed = 5;
plant_type = "normal";
is_slowdown = false;
target_type = "air";
cooldown = cycle;
attacking = false;
target_t = "normal";
