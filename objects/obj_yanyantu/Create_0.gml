event_inherited();
plant_id = "yanyantu";
obj_type = object_index;
zodiac_initializing = true;
event_user(0);
zodiac_initializing = false;

plant_type = "normal";
feature_type = "normal";
sprite_index = spr_yanyantu;
if (shape == 1) sprite_index = spr_yanyantu_1;
else if (shape >= 2) sprite_index = spr_yanyantu_2;
image_xscale = 1.8;
image_yscale = 1.8;
attack_anim = 0;
idle_anim = sprite_get_number(sprite_index)-1;
flash_speed = 5;
zodiac_timer = 0;
zodiac_age = 0;

zodiac_effects = [];
if (variable_global_exists("buff_apply_id")) global.buff_apply_id++;
