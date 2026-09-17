event_inherited();
plant_id = "zhurong";
obj_type = object_index;
current_level = 1;
event_user(0);

if (shape == 0)
    sprite_index = spr_zhurong;
else if (shape == 1)
    sprite_index = spr_zhurong_1;
else if (shape == 2)
    sprite_index = spr_zhurong_2;
else if (shape == 3)
    sprite_index = spr_zhurong_3;

attack_anim = 12;
idle_anim = 9;
flash_speed = 5;
plant_type = "normal";
is_slowdown = false;
target_type = "throw";
target_instance = -4;
cooldown_timer = cycle;
attacking = false;
