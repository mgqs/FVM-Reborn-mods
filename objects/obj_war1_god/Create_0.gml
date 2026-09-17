event_inherited();
plant_id = "war_god";
event_user(0);

if (shape == 0)
    sprite_index = spr_war_god;
else if (shape == 1)
    sprite_index = spr_war_god_1;
else if (shape == 2)
    sprite_index = spr_war_god_2;
else if (shape == 3)
    sprite_index = spr_war_god_3;

attack_anim = 10;
idle_anim = 11;
flash_speed = 5;
plant_type = "normal";
is_slowdown = false;
super_bullet = 4;