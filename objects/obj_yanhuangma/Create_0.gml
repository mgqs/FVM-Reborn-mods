event_inherited();
plant_id = "yanhuangma";
obj_type = object_index;
event_user(0);

plant_type = "normal";
feature_type = "lava";
sprite_index = spr_yanhuangma;
if (shape == 1) sprite_index = spr_yanhuangma_1;
else if (shape >= 2) sprite_index = spr_yanhuangma_2;
image_xscale = 1.8;
image_yscale = 1.8;
// 0-13待机 14-20攻击，所有形态均在第18帧召唤炎凰
idle_anim = 12;
attack_anim = 7;
flash_speed = 5;
zodiac_timer = 0;
zodiac_age = 0;
zodiac_shot_this_anim = false;
zodiac_vertical_timer = 0;
