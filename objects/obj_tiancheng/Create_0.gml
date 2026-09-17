event_inherited();
plant_id = "tiancheng";
event_user(0);

if (shape == 0)
    sprite_index = spr_tiancheng;
else if (shape == 1)
    sprite_index = spr_tiancheng_1;
else if (shape == 2)
    sprite_index = spr_tiancheng_2;

attack_anim = 11;
idle_anim = 12;
flash_speed = 5;
plant_type = "normal";
is_slowdown = false;
b_count = 0;
