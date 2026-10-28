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

// 帧布局（2026-10-28 用户）：1-14 待机 / 15-26 攻击，第 22 帧发射子弹
idle_anim = 13;
attack_anim = 12;
flash_speed = 5;
flash_speed_base = 5;
laipishe_shoot_frame = 21;      // 第 22 帧（0 起算）
laipishe_fired = false;
plant_type = "normal";
is_slowdown = false;
attack_type = ATTACK_TYPE.SHOOTER;
target_type = "track";

// 子弹数量：所有形态均为一发
bullet_count = 1;

// 伤害倍率由形态决定
// 0转：100%伤害，1转：200%伤害，2转：300%伤害
damage_multiplier = 1;
if (shape == 1)
    damage_multiplier = 2;
else if (shape >= 2)
    damage_multiplier = 3;

// 记录已发射的子弹引用，用于卡片销毁时清理
laipishe_bullets = ds_list_create();
