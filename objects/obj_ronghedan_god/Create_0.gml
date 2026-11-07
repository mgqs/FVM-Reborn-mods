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
// 定身概率(%) / 定身时间(s) 走注册表 custom（mod_cards_init 三形态的 info_custom），
//   情报岛文案直接写 {定身概率} / {定身时间}；这里换算成帧存 stun_frames（同彩虹蛇 / 电鳗口径）。
// 深度毒气伤害仍按星级查表 —— 投掷类但 2026-11-07 用户确认「毒气故意固定」，不跟 atk 增幅。
var _poison_by_star = [0, 20, 23, 27, 36, 47, 57, 68, 81, 95, 114, 135, 156, 177, 198, 219, 243];
var _cl = clamp(current_level, 0, array_length(_poison_by_star) - 1);
poison_damage = _poison_by_star[_cl];

var _sk   = variable_instance_exists(id, "skill") ? skill : 0;
var _info = get_plant_data_with_skill("ronghedan_god", shape, clamp(current_level, 0, 16), _sk);
stun_chance = 20;   // 兜底：17 级满
stun_time   = 3.6;  // 秒
if (_info != undefined){
    if (ds_map_exists(_info, "定身概率")) stun_chance = _info[? "定身概率"];
    if (ds_map_exists(_info, "定身时间")) stun_time   = _info[? "定身时间"];
}
stun_frames = round(stun_time * 60);
// 溅射比例：三档恒定 35%（表里只给了本体档「3*3范围35%溅射」）
splash_ratio = 0.35;
