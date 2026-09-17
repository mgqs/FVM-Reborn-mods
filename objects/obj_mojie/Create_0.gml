event_inherited();
plant_id = "mojie";
obj_type = object_index;
current_level = 1;
event_user(0);

if (shape == 0)
    sprite_index = spr_mojie;
else if (shape == 1)
    sprite_index = spr_mojie_1;
else if (shape == 2)
    sprite_index = spr_mojie_2;

max_life_timer = 1440;
life_timer = max_life_timer;

if (shape >= 1)
    attack_interval = 180;
else
    attack_interval = 240;

flash_speed = 5;
idle_anim = 13;
attack_anim = 13;
attack_duration = attack_anim * flash_speed;
idle_duration = attack_interval - attack_duration;
attack_timer = 180;
state = 0;
plant_type = "normal";
is_slowdown = false;

