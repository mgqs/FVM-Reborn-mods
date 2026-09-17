

	if other.hp > 0 and target_enemy == other.id  and can_hit(target_type,other.target_type){
		with(other){
			
			audio_play_sound(hit_sound,0,0)
			
			damage_amount = other.damage
			damage_type = other.damage_type
			event_user(0)
	
		}

			instance_create_depth(x,y,depth,obj_takoyaki_bullet_effect)
		
		instance_destroy()
	}
