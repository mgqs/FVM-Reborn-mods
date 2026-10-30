event_inherited();
plant_id = "hufa_god";
event_user(0);

if (shape == 0)
    sprite_index = spr_hufa_god;
else if (shape == 1)
    sprite_index = spr_hufa_god_1;
else if (shape == 2)
    sprite_index = spr_hufa_god_2;
else if (shape == 3)
    sprite_index = spr_hufa_god_3;

// 帧布局（2026-10-28 用户）：1-12 待机 / 13-29 攻击，第 19 帧发射子弹
idle_anim = 11;
attack_anim = 17;
flash_speed = 5;
flash_speed_base = 5;
hufa_shoot_frame = 18;      // 第 19 帧（0 起算）
hufa_fired = false;
plant_type = "normal";
feature_type = "normal";
is_slowdown = false;
