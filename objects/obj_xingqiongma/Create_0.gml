event_inherited();
plant_id = "xingqiongma";
obj_type = object_index;
event_user(0);

plant_type = "normal";
feature_type = "normal";
sprite_index = spr_xingqiongma;
if (shape == 1) sprite_index = spr_xingqiongma_1;
else if (shape >= 2) sprite_index = spr_xingqiongma_2;
image_xscale = 1.8;
image_yscale = 1.8;
attack_anim = 0;
idle_anim = sprite_get_number(sprite_index)-1;
flash_speed = 5;
zodiac_timer = 0;
zodiac_age = 0;

var guard = get_plant_data_with_skill(plant_id,shape,current_level,skill);
zodiac_guard_duration = 900;
if (guard != undefined && is_real(guard[? "zodiac_guard_duration"]))
    zodiac_guard_duration = guard[? "zodiac_guard_duration"];
// 种下时释放对应形态的5×5范围特效：effect2 / effect2_1 / effect2_2
var xq_spr = spr_xingqiongma_effect2;
if (shape == 1) xq_spr = spr_xingqiongma_effect2_1;
else if (shape >= 2) xq_spr = spr_xingqiongma_effect2_2;
var xq_e = instance_create_depth(x,y,-3000,obj_zodiac_effect);
xq_e.sprite_index = xq_spr;
xq_e.life = max(1,sprite_get_number(xq_spr)*5);
xq_e.image_index = 0;
xq_e.image_speed = 0.5;
xq_e.image_xscale = 5*global.grid_cell_size_x/sprite_get_width(xq_spr);
xq_e.image_yscale = 5*global.grid_cell_size_y/sprite_get_height(xq_spr);
no_revive_record = true;
