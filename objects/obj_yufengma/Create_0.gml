event_inherited();
plant_id = "yufengma";
obj_type = object_index;
event_user(0);

plant_type = "normal";
feature_type = "normal";
sprite_index = spr_yufengma;
if (shape == 1) sprite_index = spr_yufengma_1;
else if (shape >= 2) sprite_index = spr_yufengma_2;
image_xscale = 1.8;
image_yscale = 1.8;
attack_anim = 0;
idle_anim = sprite_get_number(sprite_index)-1;
flash_speed = 5;
zodiac_timer = 0;
zodiac_age = 0;
