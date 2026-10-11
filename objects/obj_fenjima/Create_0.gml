event_inherited();
plant_id = "fenjima";
obj_type = object_index;
event_user(0);

plant_type = "normal";
feature_type = "normal";
sprite_index = spr_fenjima;
if (shape == 1) sprite_index = spr_fenjima_1;
else if (shape >= 2) sprite_index = spr_fenjima_2;
image_xscale = 1.8;
image_yscale = 1.8;
// 0-10 待机，11-21 攻击；攻击动画第 18 帧发射子弹。
attack_anim = 11;
// 三种形态统一使用资源第 0-10 帧作为待机动画。
idle_anim = 10;
flash_speed = 5;
zodiac_timer = 0;
zodiac_age = 0;
zodiac_shot_this_anim = false;
