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
// 父对象约定：待机 = 0~idle_anim（共 idle_anim+1 帧），攻击 = idle_anim+1 起共 attack_anim 帧
// 御风马素材 25 帧：0~11 待机（12 帧），12~24 攻击（13 帧）
attack_anim = 13;
idle_anim = 11;
flash_speed = 5;
zodiac_timer = 0;
zodiac_age = 0;
yf_atk_timer = 0;
