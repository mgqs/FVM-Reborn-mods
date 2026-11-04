event_inherited();
plant_id = "lizi_god";
obj_type = object_index;
current_level = 1;
event_user(0);

if (shape == 0)
    sprite_index = spr_lizi_god;
else if (shape == 1)
    sprite_index = spr_lizi_god_1;
else
    sprite_index = spr_lizi_god_2;

attack_anim = 12;
idle_anim = 9;
flash_speed = 5;
plant_type = "normal";
is_slowdown = false;
target_type = "throw";
target_instance = -4;
// 起手对齐生煎锅（2026-11-04 用户口径）：生煎锅是 `attack_timer == cycle - 30` 就脱手，
//   本卡脱手在攻击开始后第 45 帧（_frame >= 19 → _fi >= 9 → attack_timer >= 45），
//   所以初始冷却要少 75 帧（30 + 45）→ 首发 = (cycle-75) + 45 = cycle-30。
//   间隔不受影响：挥完 `cooldown_timer = cycle - 60`，仍是 cycle 一轮。
cooldown_timer = cycle - 75;
attacking = false;
lizi_fired = false;     // 本轮是否已经脱手（第 19 帧出弹，见 Step_0）

// 深度融合（shape>=1）：爆炸伤害 / 周期，按星级 0~16
// 数值直接写在本对象里（来源：这组卡的推荐数值和情报岛.xlsx），不走植物注册表
var _deep_boom_damage = [900, 900, 900, 900, 900, 900, 900, 900, 900, 900, 920, 930, 950, 970, 1000, 1100, 1200];
var _deep_boom_period = [7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 6, 6, 6, 5, 4, 3];
var _db_level = clamp(current_level, 0, array_length(_deep_boom_damage) - 1);
deep_boom_damage = _deep_boom_damage[_db_level];
deep_boom_period = _deep_boom_period[_db_level];

// 深度爆炸计数，0 = 本次攻击即爆炸（首次攻击即爆炸）
deep_boom_counter = 0;
