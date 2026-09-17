	var _x = x;
	var _y = y;
	var _range = 200;
	var splash_ratio = 0.5
	if shape >= 1{
		splash_ratio = 0.8
	}

	with (obj_enemy_parent) {
	    if (hp > 0 && point_distance(x, y, _x, _y) < _range && grid_row == other.row && id != other.hitted_enemy and can_hit(other.target_type,target_type)) {
	        
	        // 对敌人造成溅射伤害
	        damage_amount = other.damage * splash_ratio
			damage_type = other.damage_type
			event_user(0)
	        
	    }
	}
	audio_play_sound(snd_salad_pilt_splash,0,0)