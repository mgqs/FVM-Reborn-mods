event_inherited();  // 继承父对象属性
plant_id = "flour_sack"; 
// 设置对象类型和精灵
obj_type = object_index;
current_level = 1
event_user(0)
sprite_index = spr_flour_sack;
if shape == 1{
	sprite_index = spr_flour_sack_1
}
else if shape == 2{
	sprite_index = spr_flour_sack_2
}

// ========== 特定属性默认值 ==========
if shape == 0{
	attack_anim = 19;
}
else{
	attack_anim = 32;
}
idle_anim = 8
flash_speed = 6
plant_type = "normal"
chspeed = 0
cvspeed = 0
invincible = true

first_target_x = 0
first_target_y = 0

origin_row = -1
origin_col = -1