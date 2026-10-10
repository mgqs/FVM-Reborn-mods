event_inherited();
plant_id = "youyu_god";
event_user(0);
if (shape == 0) sprite_index = spr_youyu_god;
else if (shape == 1) sprite_index = spr_youyu_god_1;
else sprite_index = spr_youyu_god_2;

// 攻击动画 = sprite 第 14~24 帧（image_index 13~23）
// 父对象 obj_card_parent/Step_0 按 IDLE 0~idle_anim / ATTACK idle_anim+1 ~ idle_anim+attack_anim 划段：
//   idle_anim   = 12 → 空闲段止于第 13 帧（image_index 12）
//   attack_anim = 11 → 攻击段止于第 24 帧（image_index 23）
idle_anim = 12;
attack_anim = 11;
flash_speed = 5;
plant_type = "normal";
is_slowdown = false;
target_type = "track";

// 本次攻击是否已开火（开火时机绑在攻击动画第 20 帧，见 Step_0）
fired_this_attack = false;
