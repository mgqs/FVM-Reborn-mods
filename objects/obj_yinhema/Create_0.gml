event_inherited();
plant_id = "yinhema";
obj_type = object_index;
zodiac_initializing = true;
event_user(0);
zodiac_initializing = false;

plant_type = "normal";
feature_type = "normal";
sprite_index = spr_yinhema;
if (shape == 1) sprite_index = spr_yinhema_1;
else if (shape >= 2) sprite_index = spr_yinhema_2;
image_xscale = 1.8;
image_yscale = 1.8;
attack_anim = 0;
idle_anim = sprite_get_number(sprite_index)-1;
flash_speed = 5;
zodiac_timer = 0;
zodiac_age = 0;

// 常驻跟随光环特效：0转3×3范围，1/2转5×5范围
zodiac_effects = [];
var e = instance_create_depth(x,y,-3000,obj_zodiac_effect);
e.sprite_index = spr_yinhema_effect;
if (shape == 1) e.sprite_index = spr_yinhema_effect_1;
else if (shape >= 2) e.sprite_index = spr_yinhema_effect_2;
e.life = 2147483647;
e.image_index = 0;
e.image_speed = 0.5;
var halo_range = shape == 0 ? 3 : 5;
e.image_xscale = halo_range*global.grid_cell_size_x/sprite_get_width(e.sprite_index);
e.image_yscale = halo_range*global.grid_cell_size_y/sprite_get_height(e.sprite_index);
array_push(zodiac_effects,e);
if (variable_global_exists("buff_apply_id")) global.buff_apply_id++;
