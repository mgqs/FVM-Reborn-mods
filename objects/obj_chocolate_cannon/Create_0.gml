// obj_small_furnace 的 Create 事件
//plant_id = "small_fire";  // 唯一标识符
event_inherited();  // 继承父对象属性
plant_id = "chocolate_cannon"; 
// 设置对象类型和精灵
obj_type = object_index;
current_level = 1
event_user(0)
if shape == 0{
	sprite_index = spr_chocolate_cannon
}
else if shape == 1{
	sprite_index = spr_chocolate_cannon_1
}
else if shape == 2{
	sprite_index = spr_chocolate_cannon_2
}

// ========== 特定属性默认值 ==========

attack_anim = 10;
idle_anim = 10
flash_speed = 5
plant_type = "normal"
is_slowdown = false
target_type = "throw"
attack_timer = cycle - 60