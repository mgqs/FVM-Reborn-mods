event_inherited();
plant_id = "yinghuoshe";
obj_type = object_index;
event_user(0);

plant_type = "normal";
feature_type = "normal";
sprite_index = sp_yinghuoshe;
if (shape == 1) sprite_index = sp_yinghuoshe_1;
else if (shape >= 2) sprite_index = sp_yinghuoshe_2;
image_xscale = 1.8;
image_yscale = 1.8;
idle_anim = 12;
attack_anim = 11;
flash_speed = 5;
zodiac_timer = 0;
zodiac_age = 0;
zodiac_shot_this_anim = false;
zodiac_firefly_hit_ids = [];
