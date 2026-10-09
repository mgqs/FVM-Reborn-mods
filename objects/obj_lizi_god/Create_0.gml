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
cooldown_timer = cycle;
attacking = false;

// 深度融合（shape>=1）：爆炸伤害 / 周期，按星级 0~16
// 数值直接写在本对象里（来源：这组卡的推荐数值和情报岛.xlsx），不走植物注册表
var _deep_boom_damage = [900, 900, 900, 900, 900, 900, 900, 900, 900, 900, 920, 930, 950, 970, 1000, 1100, 1200];
var _deep_boom_period = [7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 6, 6, 6, 5, 4, 3];
var _db_level = clamp(current_level, 0, array_length(_deep_boom_damage) - 1);
deep_boom_damage = _deep_boom_damage[_db_level];
deep_boom_period = _deep_boom_period[_db_level];

// 深度爆炸计数，0 = 本次攻击即爆炸（首次攻击即爆炸）
deep_boom_counter = 0;
