event_inherited();
plant_id = "wugushe";
obj_type = object_index;
event_user(0);

plant_type = "normal";
feature_type = "normal";
sprite_index = spr_wugushe;
if (shape == 1) sprite_index = spr_wugushe_1;
else if (shape >= 2) sprite_index = spr_wugushe_2;
image_xscale = 1.8;
image_yscale = 1.8;
// 0-13 待机，14-27（资源第 15-28 帧）攻击。
idle_anim = 13;
attack_anim = 14;
flash_speed = 5;
zodiac_timer = 0;
zodiac_age = 0;
zodiac_shot_this_anim = false;
