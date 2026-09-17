

	if other.hp > 0 and row == other.grid_row  and can_hit(target_type,other.target_type){
		with(other){
			
			audio_play_sound(hit_sound,0,0)
			
			damage_amount = other.damage
			damage_type = other.damage_type
			event_user(0)
	
		}
		
		var inst = instance_create_depth(x,y,depth,obj_xiaolongbao_bullet_effect)
		inst.sprite_index = spr_sausage_bullet_effect
		
		
		instance_destroy()
	}
