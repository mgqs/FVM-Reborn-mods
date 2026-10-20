// 1/2 转：子弹无限穿透，障碍也直接穿过去、不销毁
if (pierce_all) exit;

if target_type == "normal" && row == other.row && precise_bbox_collision(id, other){
	var inst = instance_create_depth(x,y,depth,obj_rongheshuanggu_effect)
	if bullet_shape == 0{
		inst.sprite_index = spr_rongheshuanggu_effect
	}
	else if bullet_shape == 1{
		inst.sprite_index = spr_rongheshuanggu_effect_1
	}
	else{
		inst.sprite_index = spr_rongheshuanggu_effect_2
	}
	instance_destroy()
}
