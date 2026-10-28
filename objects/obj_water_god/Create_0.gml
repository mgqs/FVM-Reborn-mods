event_inherited();
plant_id = "water_god";
event_user(0);
sprite_index = spr_water_god;

if (shape == 1)
    sprite_index = spr_water_god_1;
else if (shape == 2)
    sprite_index = spr_water_god_2;
else if (shape == 3)
    sprite_index = spr_water_god_3;

// 帧布局（2026-10-28 用户）：1-12 待机 / 13-18 攻击
// 注：忒提丝神使是辅助/反弹类，本身不发射子弹（水流靠子弹碰撞它反弹触发），
//     所以只对齐帧数；攻击段留给反弹动作播。
idle_anim = 11;
attack_anim = 6;
flash_speed = 6;
flash_speed_base = 6;
plant_type = "normal";
is_slowdown = false;
