event_inherited();  // 继承父对象属性
plant_id = "soda_bubble"; 
// 设置对象类型和精灵
obj_type = object_index;


is_derivative = false
on_lava = false


event_user(0)

// ========== 特定属性默认值 ==========
attack_anim = 0;
flash_speed = 5
idle_anim = 8
plant_type = "coffee"
spr_list = []
hole_count = 1
if shape == 0{
	sprite_index = spr_soda_bubble_0_0
	spr_list = [spr_soda_bubble_0_0,spr_soda_bubble_0_1,spr_soda_bubble_0_2]
}
else if shape == 1{
	sprite_index = spr_soda_bubble_1_0
	spr_list = [spr_soda_bubble_1_0,spr_soda_bubble_1_1,spr_soda_bubble_1_2]
}
if card_equipped_attire_id(plant_id) == "bubble_maltose"{
	idle_anim = 12
	if shape == 0{
		sprite_index = spr_bubble_maltose_0_0
		spr_list = [spr_bubble_maltose_0_0,spr_bubble_maltose_0_1,spr_bubble_maltose_0_1]
	}
	else if shape == 1{
		sprite_index = spr_bubble_maltose_1_0
		spr_list = [spr_bubble_maltose_1_0,spr_bubble_maltose_1_1,spr_bubble_maltose_1_1]
	}
}
remove_timer = 0

