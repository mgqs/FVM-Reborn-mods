event_inherited();
plant_id = "yanyantu";
obj_type = object_index;
event_user(0);

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

// 常驻跟随光环特效（无范围拉伸，原尺寸播放）
zodiac_effects = [];
var e = instance_create_depth(x,y,-3000,obj_zodiac_effect);
e.sprite_index = spr_yanyantu_effect;
if (shape == 1) e.sprite_index = spr_yanyantu_effect_1;
else if (shape >= 2) e.sprite_index = spr_yanyantu_effect_2;
e.life = 2147483647;
e.image_index = 0;
e.image_speed = 0.5;
array_push(zodiac_effects,e);
if (variable_global_exists("buff_apply_id")) global.buff_apply_id++;
