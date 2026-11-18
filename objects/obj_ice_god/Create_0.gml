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
// 与同类卡（cold_drew / snowrabbit）一致：全类型。冰晶由 Other_11 按 x 排序轮流丢给全场敌人，
// 这里若留 track，场上只剩地鼠 / 幽灵时 Step 会判定"没有敌人"而不开火。
target_type = "all";
attack_timer = 0;
