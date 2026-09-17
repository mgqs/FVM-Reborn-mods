// obj_small_furnace 的 Create 事件
//plant_id = "small_fire";  // 唯一标识符
event_inherited();  // 继承父对象属性
plant_id = "firework_dragon"; 
// 设置对象类型和精灵
obj_type = object_index;

flame_produce = 25;
event_user(0)
if shape == 1{
	sprite_index = spr_firework_dragon_1
}
else if shape == 2{
	sprite_index = spr_firework_dragon_2
}
else{
	sprite_index = spr_firework_dragon;
}


// ========== 特定属性默认值 ==========

attack_anim = 23;
idle_anim = 10
first_produce_delay = 60;
plant_type = "normal"
invincible = true
