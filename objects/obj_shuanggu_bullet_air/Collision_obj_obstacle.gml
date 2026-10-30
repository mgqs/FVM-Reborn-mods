if target_type == "normal" && row == other.row && precise_bbox_collision(id, other){
	if burnt == 0{
		var inst = instance_create_depth(x,y,depth,obj_shuanggu_effect)
		if bullet_shape == 0{
			inst.sprite_index = spr_shuanggu_effect
		}
		else if bullet_shape == 1{
			inst.sprite_index = spr_shuanggu_effect_1
		}
		else{
			inst.sprite_index = spr_shuanggu_effect_2
		}
	}
	else if burnt == 1{
		var inst = instance_create_depth(x+25,y,depth,obj_fire_bullet_effect)
		inst.sprite_index = spr_fire_bullet_effect
	}
	instance_destroy()
}
