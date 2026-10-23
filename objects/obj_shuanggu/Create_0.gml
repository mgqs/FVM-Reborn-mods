// obj_shuanggu（蚝油双菇）Create 事件
// 三形态：0 转 蚝油双菇 / 1 转 伯爵蚝油双菇 / 2 转 皇家蚝油双菇
// 机制：对陆（矮菇前探）与对空（高菇抬头）两路分开发射
//       · 两路都有敌人 → 齐射：一次打一发对陆 + 一发对空
//       · 只有一路有人 → 只让那一路的菇头动、只打那一路
//       0 转 对陆 2 + 对空 2 / 1 转 对陆 2 + 对空 3 / 2 转 对陆 3 + 对空 3
// 数值取自「这组卡的推荐数值和情报岛.xlsx」与 spr_shuanggu/米苏.jpg
event_inherited();  // 继承父对象属性
plant_id = "shuanggu";
obj_type = object_index;
current_level = 1
event_user(0)
if shape == 0{
	sprite_index = spr_shuanggu
}
else if shape == 1{
	sprite_index = spr_shuanggu_1
}
else{
	sprite_index = spr_shuanggu_2
}

// ===== 36 帧素材的真实分段（三形态完全同构，已逐帧核对包围盒）=====
//   待机      1-12   （image_index 0-11，左右轻微摇摆）
//   对陆单发  13-18  （image_index 12-17，矮菇前探；开火在 17 帧 = index 16）
//   对空单发  19-29  （image_index 18-28，高菇抬头前探；开火在 24 帧 = index 23）
//   齐射      30-36  （image_index 29-35，两个菇同时前探；开火在 34 帧 = index 33）
// 三段动画长度不同，父对象的单段攻击动画驱动不够用 → attack_anim = 0，
// 攻击段的 image_index 由本卡 Step 自己推（state 仍用 CARD_STATE.ATTACK）。
idle_anim = 11
attack_anim = 0
flash_speed = 5
plant_type = "normal"
feature_type = "normal"
is_slowdown = false
attack_type = ATTACK_TYPE.SHOOTER
// 本体索敌口径：normal + air（"air" 这个类型在 can_target_on 里两种都认）
target_type = "air"

// 每次攻击的子弹数（对陆 / 对空）
shots_land = (shape >= 2) ? 3 : 2
shots_air  = (shape >= 1) ? 3 : 2

// 攻击力两张表（0~16 星）。注册值 atk = 对地攻击力；
// 对空子弹伤害 = atk * (对空表 / 对地表)，这样星级与增幅都能同时吃到。
land_atk_table = [28, 34, 40, 46, 52, 58, 64, 70, 76, 86, 96, 106, 116, 136, 156, 176, 216];
air_atk_table  = [55, 60, 65, 70, 80, 90, 100, 120, 140, 170, 200, 230, 260, 290, 320, 350, 380];
var _lv = clamp(current_level, 0, 16);
air_atk_ratio = air_atk_table[_lv] / max(1, land_atk_table[_lv]);

// 本次攻击的动画种类：0 = 只打对陆 / 1 = 只打对空 / 2 = 齐射
// ⚠️ 2 转素材的第 19 帧（对空段的首帧、也是共享中立姿势）上带了一簇「下菇火焰」，
//    0/1 转同一帧没有 —— 只有下面真的开火时才该有火，所以 2 转的对空动画从第 20 帧起跳（index 19）。
atk_kind = 2
atk_start_frame = 29
atk_fire_frame = 33
atk_end_frame = 35
atk_len = 7
atk_t = 0
salvo_total = 2
air_start_frame = (shape >= 2) ? 19 : 18

// 本次攻击是否已开火；本次攻击已齐射到第几组
in_attack = false
fired_this_attack = false
salvo_index = 0
salvo_timer = 0

// 索敌结果（供 with(obj_enemy_parent) 里用 other.xxx 回写）
has_land = false
has_air = false
