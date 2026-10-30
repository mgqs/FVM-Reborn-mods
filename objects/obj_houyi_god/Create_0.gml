event_inherited();
plant_id = "houyi_god";
event_user(0);

if (shape == 0)
    sprite_index = spr_houyi_god;
else if (shape == 1)
    sprite_index = spr_houyi_god_1;
else if (shape == 2)
    sprite_index = spr_houyi_god_2;
else if (shape == 3)
    sprite_index = spr_houyi_god_3;

fire_mid = false;
fire_up = false;
fire_down = false;
// 帧布局（2026-10-28 用户）：1-12 待机 / 13-23 攻击，第 20 帧发射子弹
idle_anim = 11;
attack_anim = 11;
// 形态 3 的精灵只有 22 帧（0..21），攻击段只能到第 22 帧
if (shape == 3) attack_anim = 10;
flash_speed = 5;
flash_speed_base = 5;
houyi_shoot_frame = 19;      // 第 20 帧（0 起算）
houyi_fired = false;
plant_type = "normal";
is_slowdown = false;
fire_chance = 0.15;
