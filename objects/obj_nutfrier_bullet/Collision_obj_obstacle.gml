if target_type == "normal"{
	if burnt == 0{
		var inst = instance_create_depth(x,y,depth,obj_coke_bomb_explode)
		if sprite_index == spr_nut_frier_bullet{
			inst.sprite_index = spr_nut_frier_bullet_effect
		}
		else if sprite_index == spr_nut_frier_bullet_1{
			inst.sprite_index = spr_nut_frier_bullet_effect_1
		}
		else if sprite_index == spr_nut_frier_bullet_2{
			inst.sprite_index = spr_nut_frier_bullet_effect_2
		}
	}
	else{
		var inst = instance_create_depth(x+25,y,depth,obj_fire_bullet_effect)
		inst.sprite_index = spr_fire_bullet_effect
	}
	instance_destroy()
}