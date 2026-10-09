event_inherited();
plant_id = "ronghehaixing";
event_user(0);
if (shape == 0) sprite_index = spr_ronghehaixing;
else if (shape == 1) sprite_index = spr_ronghehaixing_1;
else sprite_index = spr_ronghehaixing_2;

// 攻击动画：sprite 33 帧，第 24 帧（image_index 23）是「星星出现」的发射帧
// 父对象划段：IDLE = 0~idle_anim / ATTACK = idle_anim+1 ~ idle_anim+attack_anim
//   idle_anim = 13  → 攻击段从第 15 帧（image_index 14）起
//   attack_anim = 12 → 攻击段止于第 27 帧（image_index 25），覆盖发射帧
// 从攻击段起点到发射帧共 9 个动画步 = 45 帧，最小 cycle（0 转高星 48）也够
idle_anim = 13;
attack_anim = 12;
flash_speed = 5;
plant_type = "normal";
is_slowdown = false;

// 本次攻击是否已发射（发射帧见 Step_0）
fired_this_attack = false;

// 深度融合（1 转起）：单格溅射比例，按星级 0~16
// 数值来源：这组卡的推荐数值和情报岛.xlsx「深度溅射伤害」行（0 / 7% / 8% … / 50%）
var _splash_by_star = [0, 0.07, 0.08, 0.09, 0.10, 0.11, 0.12, 0.13, 0.14, 0.15, 0.16, 0.17, 0.18, 0.20, 0.25, 0.35, 0.50];
splash_ratio = _splash_by_star[clamp(current_level, 0, array_length(_splash_by_star) - 1)];
