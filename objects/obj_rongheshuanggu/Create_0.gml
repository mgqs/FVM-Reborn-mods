// obj_rongheshuanggu（融合双菇）Create 事件
// 三形态：0 转 热狗蚝油双菇 / 1 转 喷壶蚝油双菇 / 2 转 糖葫芦蚝油双菇
// 机制（数值取自「这组卡的推荐数值和情报岛.xlsx」新普卡-融合卡 93-108 行）：
//   0 转：对陆 4 发 + 对空 4 发，都平射（对空子弹直接出生在空军高度）
//   1 转：对地 4 发改为「无限穿透」（连障碍一起穿），对空 4 发不变
//   2 转：对地穿透不变，对空 4 发改为「全屏追踪」（优先最靠前的空军）
// 1 转的 xlsx 对地表是「4 发合计」（112…1976 = 4 × 单发），这里 atk 按单发写（表值 ÷ 4）。
event_inherited();  // 继承父对象属性
plant_id = "rongheshuanggu";
obj_type = object_index;
current_level = 1
event_user(0)
if shape == 0{
	sprite_index = spr_rongheshuanggu
}
else if shape == 1{
	sprite_index = spr_rongheshuanggu_1
}
else{
	sprite_index = spr_rongheshuanggu_2
}

// 36 帧素材与本体同构：待机 1-12 / 对陆 13-18（17 开火）/ 对空 19-29（24 开火）/ 齐射 30-36（34 开火）
// 三段动画长度不同 → attack_anim = 0，攻击段 image_index 由本卡 Step 自己推
idle_anim = 11
attack_anim = 0
flash_speed = 5
plant_type = "normal"
feature_type = "normal"
is_slowdown = false
attack_type = ATTACK_TYPE.SHOOTER
target_type = "air"

// 每次攻击的子弹数：两路都是 4 发
shots_land = 4
shots_air = 4

// 1 转起对地子弹无限穿透；2 转起对空子弹全屏追踪
pierce_land = (shape >= 1)
homing_air = (shape >= 2)

// 对空单发伤害表：0/1 转用初级融合的，2 转用灵魂融合的（对空伤害 = atk * 倍率）
air_atk_table = (shape >= 2)
	? [55, 127, 139, 150, 169, 192, 215, 253, 299, 368, 423, 492, 561, 630, 785, 860, 945]
	: [55, 87, 95, 102, 117, 132, 147, 177, 207, 260, 295, 340, 385, 430, 475, 520, 565];
var _lv = clamp(current_level, 0, 16);
air_atk_ratio = air_atk_table[_lv] / max(1, atk);

// 本次攻击的动画种类：0 = 只打对陆 / 1 = 只打对空 / 2 = 齐射
atk_kind = 2
atk_start_frame = 29
atk_fire_frame = 33
atk_end_frame = 35
atk_len = 7
atk_t = 0
salvo_total = 4
salvo_gap = 5
// 三个形态的第 19 帧（对空段首帧、也是 13/19/30/36 共用的中立姿势）素材上都带了一簇下菇火焰；
// 只打空军时下菇不该有火 → 对空动画统一从第 20 帧（index 19）起播
air_start_frame = 19

in_attack = false
fired_this_attack = false
salvo_index = 0
salvo_timer = 0

// 索敌结果（供 with(obj_enemy_parent) 里用 other.xxx 回写）
has_land = false
has_air = false
