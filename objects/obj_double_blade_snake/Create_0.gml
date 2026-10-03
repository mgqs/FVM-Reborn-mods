event_inherited();
plant_id = "double_blade_snake";
obj_type = object_index;
current_level = 1;
event_user(0);

if (shape == 1)
    sprite_index = spr_shuangrenshe_1;
else if (shape == 2)
    sprite_index = spr_shuangrenshe_2;
else
    sprite_index = spr_shuangrenshe;

attack_anim = 7;
idle_anim = 11;
flash_speed = 5;
plant_type = "normal";
is_slowdown = false;
target_type = "pierce";
