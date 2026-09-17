event_inherited();
plant_id = "joker";
event_user(0);

if (shape == 1)
    sprite_index = spr_joker_1;
else if (shape == 2)
    sprite_index = spr_joker_2;
else if (shape == 3)
    sprite_index = spr_joker_3;
else
    sprite_index = spr_joker_0;

attack_anim = 17;
idle_anim = 11;
flash_speed = 5;
plant_type = "normal";
is_slowdown = false;
target_type = "rotate";
cooldown = cycle;
attacking = false;
target_t = "rotate";
