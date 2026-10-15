// obj_ronghehuopen（融合火盆）Create 事件
// 三形态：0转 刺梨烧烤盘 / 1转 冰榴莲烤盘 / 2转 缤纷杂果冰盘
// 机制：过火增幅（子弹伤害 × atk 增幅倍率，冰弹除外）+ 啃咬反伤（咬多少弹多少）；
//       1转起每隔[寒气间隔]在周围 5*5 释放一次寒气（单次结算 = 原 8 跳合并为 1 跳、伤害 ×8，减速 4 秒）；
//       2转过火子弹按官方设定为冰弹（冰弹贴图待接入，暂时沿用火盆点燃后的火弹表现）。
//       数值取自「这组卡的推荐数值和情报岛.xlsx」新普卡-融合卡 81-89 行。
event_inherited();  // 继承父对象属性
plant_id = "ronghehuopen";
obj_type = object_index;
current_level = 1
event_user(0)
if shape == 0{
	sprite_index = spr_ronghehuopen
}
else if shape == 1{
	sprite_index = spr_ronghehuopen_1
}
else{
	sprite_index = spr_ronghehuopen_2
}

// ========== 特定属性默认值 ==========
idle_anim = 10
attack_anim = 0
flash_speed = 6
plant_type = "normal"
is_slowdown = false

// 啃咬反伤：记录上一帧血量，掉血时把掉血量等量弹给正在啃咬本卡的老鼠
current_hp_track = hp

// 寒气威力/间隔按星级查表（间隔表值为秒 ×60 转帧；星 0 表里是"/"，沿用 1 星档）
cold_dmg_table = [48, 48, 56, 64, 80, 96, 112, 136, 160, 184, 216, 248, 280, 312, 344, 376, 408];
cold_int_table = [2700, 2700, 2700, 2700, 2700, 2700, 2700, 2700, 2700, 2700, 2520, 2340, 2160, 1980, 1800, 1500, 1080];
var _cl = clamp(current_level, 0, 16);
cold_damage = cold_dmg_table[_cl];
cold_interval = cold_int_table[_cl];
cold_timer = 0

