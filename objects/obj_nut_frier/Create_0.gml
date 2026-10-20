// obj_small_furnace 的 Create 事件
//plant_id = "small_fire";  // 唯一标识符
event_inherited();  // 继承父对象属性
plant_id = "nut_frier"; 
// 设置对象类型和精灵
obj_type = object_index;
sprite_index = spr_nut_frier;
current_level = 1
event_user(0)
if shape == 1{
	sprite_index = spr_nut_frier_1
}
if shape == 2{
	sprite_index = spr_nut_frier_2
}

// ========== 特定属性默认值 ==========

attack_anim = 8;
idle_anim = 12
flash_speed = 5
plant_type = "normal"
is_slowdown = false
drown_timer = 0
