// obj_small_furnace 的 Create 事件
//plant_id = "small_fire";  // 唯一标识符
event_inherited();  // 继承父对象属性
plant_id = "durian"; 
// 设置对象类型和精灵
obj_type = object_index;
current_level = 1
event_user(0)
if shape == 0{
	sprite_index = spr_durian
}
else if shape == 1{
	sprite_index = spr_durian_1
}
else if shape == 2{
	sprite_index = spr_durian_2
}

// ========== 特定属性默认值 ==========

attack_anim = 11;
idle_anim = 7
flash_speed = 5
plant_type = "normal"
is_slowdown = false
target_type = "rotate"

anim_timer = 0
awake_anim = 0
wake_timer = 0
max_time = cycle
destroy_timer = 0
cycle = 60