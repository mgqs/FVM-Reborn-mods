// 对空弹（target_type = air_only）不会和地面障碍判定；这里只做安全兜底
if (pierce_all) exit;

if target_type == "normal" && row == other.row && precise_bbox_collision(id, other){
	var inst = instance_create_depth(x,y,depth,obj_rongheshuanggu_effect_air)
	if bullet_shape == 0{
		inst.sprite_index = spr_rongheshuanggu_effect_air
	}
	else if bullet_shape == 1{
		inst.sprite_index = spr_rongheshuanggu_effect_air_1
	}
	else{
		inst.sprite_index = spr_rongheshuanggu_effect_air_2
	}
	instance_destroy()
}
