// obj_ronghedan_god 的 Create 事件
event_inherited();  // 继承父对象属性
plant_id = "ronghedan_god"; 
// 设置对象类型和精灵
obj_type = object_index;
current_level = 1
event_user(0)
if shape == 0{
	sprite_index = spr_ronghedan_god
}
else if shape == 1{
	sprite_index = spr_ronghedan_god_1
}
else if shape >= 2{
	sprite_index = spr_ronghedan_god_2
}

// ========== 特定属性默认值 ==========

attack_anim = 13;
idle_anim = 13
flash_speed = 5
plant_type = "normal"
is_slowdown = false
target_instance = noone
target_type = "throw"
has_fired = false

// ========== 融合数据（按星级查表，取自「这组卡的推荐数值和情报岛.xlsx」） ==========
// 星 0~16 逐档：定身概率(%) / 定身时间(tick, 表里是秒×60) / 深度毒气伤害
var _stun_chance_by_star = [0, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20];
var _stun_time_by_star   = [0, 126, 126, 132, 132, 138, 138, 144, 144, 150, 150, 156, 168, 180, 192, 204, 216];
var _poison_by_star      = [0, 20, 23, 27, 36, 47, 57, 68, 81, 95, 114, 135, 156, 177, 198, 219, 243];
var _cl = clamp(current_level, 0, array_length(_poison_by_star) - 1);
stun_chance = _stun_chance_by_star[_cl];
stun_duration = _stun_time_by_star[_cl];
poison_damage = _poison_by_star[_cl];
// 溅射比例：三档恒定 35%（表里只给了本体档「3*3范围35%溅射」）
splash_ratio = 0.35;
