event_inherited();
plant_id = "laipishe";
obj_type = object_index;
sprite_index = spr_laipishe;
current_level = 1;
event_user(0);

if (shape == 1)
    sprite_index = spr_laipishe_1;
else if (shape == 2)
    sprite_index = spr_laipishe_2;

attack_anim = 8;
idle_anim = sprite_get_number(sprite_index);
flash_speed = 5;
plant_type = "normal";
is_slowdown = false;
attack_type = ATTACK_TYPE.SHOOTER;
target_type = "track";

// 子弹数量由形态决定
bullet_count = 1;
if (shape == 1)
    bullet_count = 2;
else if (shape >= 2)
    bullet_count = 3;

// 记录已发射的子弹引用，用于卡片销毁时清理
laipishe_bullets = ds_list_create();
