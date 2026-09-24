event_inherited();
plant_id = "zhiyumiao";
obj_type = object_index;
event_user(0);

if (shape == 0)
    sprite_index = spr_zhiyumiao;
else if (shape == 1)
    sprite_index = spr_zhiyumiao_1;
else if (shape == 2)
    sprite_index = spr_zhiyumiao_2;

attack_anim = 8;
idle_anim = 8;
flash_speed = 5;
first_produce_delay = 60;
plant_type = "normal";
is_slowdown = false;

zhiyumiao_cast_flash = 0;
