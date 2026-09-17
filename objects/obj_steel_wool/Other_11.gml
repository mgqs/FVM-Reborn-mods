var target_inst = noone

	
target_inst = target_enemy[0]
if instance_exists(target_inst){
	with target_inst{
		if !immune_to_ash && hp > 0{
			var inst = instance_create_depth(x,y-25,-500,obj_place_effect)
			inst.sprite_index = spr_enter_water_effect
			audio_play_sound(snd_enter_water,0,0)
			other.enemy_hitted = true
			instance_destroy()
				
		}
		else if hp > 0{
			damage_amount = other.atk
			damage_type = "pierce"
			event_user(0)
			other.enemy_hitted = true
		}
	}
}

if enemy_hitted{
	instance_destroy()
}
array_delete(target_enemy,0,array_length(target_enemy))