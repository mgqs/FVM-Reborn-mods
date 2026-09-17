with obj_enemy_parent{
		if place_meeting(x,y,other) && hp > 0  && grid_row == other.grid_row && can_hit(other.target_type,target_type){
			hp -= other.atk
			event_user(0)
			audio_play_sound(snd_hit1,0,0)
			if other.shape == 2 && ice_timer < 720{
				ice_timer = 720
			}
		}
	}