// 行门禁：只被「逻辑行 == 本障碍行」的子弹撞到才销毁（口径见 obstacle_should_block）
if (!obstacle_should_block(id, other)) exit;

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