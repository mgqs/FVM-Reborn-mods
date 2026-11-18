event_inherited();
plant_id = "ice_god";
obj_type = object_index;
current_level = 1;
event_user(0);

if (shape == 0)
    sprite_index = spr_ice_god;
else if (shape == 1)
    sprite_index = spr_ice_god_1;
else if (shape == 2)
    sprite_index = spr_ice_god_2;
else if (shape == 3)
    sprite_index = spr_ice_god_3;

attack_anim = 12;
idle_anim = 10;
flash_speed = 5;
plant_type = "normal";
is_slowdown = false;
// 陆 / 空 / 地鼠（全屏打击口径）：不含 潜水·非主流·幽灵·障碍；钻地中的龙渊地精由 scatter_target_blocked 另排。
// 不能留 track：冰晶由 Other_11 按 x 排序随机丢，只剩地鼠时 Step 会判"没有敌人"而彻底不开火。
target_type = "land_air_ug";
attack_timer = 0;
