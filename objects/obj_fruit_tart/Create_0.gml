// obj_small_furnace 的 Create 事件
//plant_id = "small_fire";  // 唯一标识符
event_inherited();  // 继承父对象属性
plant_id = "fruit_tart"; 
// 设置对象类型和精灵

event_user(0)
sprite_index = spr_fruit_tart;
if shape == 1{
	sprite_index = spr_fruit_tart_1
}
else if shape == 2{
	sprite_index = spr_fruit_tart_2
}
// ========== 特定属性默认值 ==========
attack_anim = 26;
idle_anim = 14
flash_speed = 5
plant_type = "normal"
is_slowdown = false

card_id_list = ["egg_boiler_pult"]
enhance_card_list = []
