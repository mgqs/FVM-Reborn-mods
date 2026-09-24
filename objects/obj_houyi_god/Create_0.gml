event_inherited();
plant_id = "houyi_god";
event_user(0);

if (shape == 0)
    sprite_index = spr_houyi_god;
else if (shape == 1)
    sprite_index = spr_houyi_god_1;
else if (shape == 2)
    sprite_index = spr_houyi_god_2;
else if (shape == 3)
    sprite_index = spr_houyi_god_3;

fire_mid = false;
fire_up = false;
fire_down = false;
attack_anim = 13;
idle_anim = 15;
flash_speed = 5;
plant_type = "normal";
is_slowdown = false;
fire_chance = 0.15;
