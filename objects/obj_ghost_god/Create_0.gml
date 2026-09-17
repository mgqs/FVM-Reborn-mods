event_inherited();
plant_id = "ghost_god";
event_user(0);

if (shape == 0)
    sprite_index = spr_ghost_god;
else if (shape == 1)
    sprite_index = spr_ghost_god_1;
else if (shape == 2)
    sprite_index = spr_ghost_god_2;
else if (shape == 3)
    sprite_index = spr_ghost_god_3;

attack_anim = 11;
idle_anim = 10;
flash_speed = 5;
plant_type = "normal";
is_slowdown = false;
