event_inherited();  // 继承父对象属性
plant_id = "wooden_plate"; 
// 设置对象类型和精灵
obj_type = object_index;


is_derivative = false


event_user(0)

// ========== 特定属性默认值 ==========
attack_anim = 0;
flash_speed = 8
idle_anim = 8
plant_type = "lilypad"
if shape == 0{
	sprite_index = spr_wooden_plate
}
else if shape == 1{
	sprite_index = spr_wooden_plate_1
}
else if shape == 2{
	sprite_index = spr_wooden_plate_2
}