// obj_small_furnace 的 Create 事件
//plant_id = "small_fire";  // 唯一标识符
event_inherited();  // 继承父对象属性
plant_id = "rabbit_lantern"; 
// 设置对象类型和精灵

event_user(0)
sprite_index = spr_rabbit_lantern
if shape == 1{
	sprite_index = spr_rabbit_lantern_1
}
else if shape == 2{
	sprite_index = spr_rabbit_lantern_2
}
// ========== 特定属性默认值 ==========
attack_anim = 2;
idle_anim = 11
flash_speed = 5
plant_type = "normal"
is_slowdown = false
explode_timer = 240
if shape >= 2{
	explode_timer = 120
}
can_mouse_list = ["can_mouse"]