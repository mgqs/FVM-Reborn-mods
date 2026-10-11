event_inherited();
plant_id = "starrabbit";
obj_type = object_index;
event_user(0);

plant_type = "normal";
feature_type = "normal";
sprite_index = spr_starrabbit;
if (shape == 1) sprite_index = spr_starrabbit_1;
else if (shape >= 2) sprite_index = spr_starrabbit_2;
image_xscale = 1.8;
image_yscale = 1.8;
idle_anim = 14;
attack_anim = 8;
flash_speed = 5;
zodiac_timer = 0;
zodiac_age = 0;
zodiac_shot_this_anim = false;
