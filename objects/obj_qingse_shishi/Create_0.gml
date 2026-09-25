event_inherited();  // 继承父对象属性
plant_id = "qingse_shishi";
// 设置对象类型和精灵
obj_type = object_index;
current_level = 1
event_user(0)

// 根据形态设置精灵贴图（必须在 event_user(0) 之后，因为 shape 在那里赋值）
sprite_index = spr_shishi;
if shape == 1{
	sprite_index = spr_shishi_1
}
else if shape == 2{
	sprite_index = spr_shishi_2
}

// ========== 特定属性默认值 ==========
// 动画参数：总帧 64（0~63）
// 闲置：第 1-13 帧（image_index 0-12，共 13 帧）
// 攻击：第 14-64 帧（image_index 13-63，共 50 帧）
// 攻击点：第 34 帧（image_index=33）、第 49 帧（image_index=48）
attack_anim = 50
idle_anim = 13
flash_speed = 6
attack_hit_count = 0  // 本次攻击已触发的次数（0/1/2）
plant_type = "normal"
invincible = false

// 目标类型：0/1转 d_fruit（陆地+地下），2转 all（追加空中）
if shape >= 2{
	target_type = "all"
}
else{
	target_type = "d_fruit"
}

// 攻击前摇帧数
attack_windup = 30
// 冷却计时器
cooldown_timer = 0
// 原始网格位置
origin_row = -1
origin_col = -1

// 柿子数量和竖向偏移（根据形态）
persimmon_count = 1
vertical_offsets = [0]
if shape == 1{
	persimmon_count = 3
	vertical_offsets = [-1, 0, 1]
}
else if shape == 2{
	persimmon_count = 5
	vertical_offsets = [-2, -1, 0, 1, 2]
}

// 命中范围（格数，3x3即半径1）
hit_radius = 1
