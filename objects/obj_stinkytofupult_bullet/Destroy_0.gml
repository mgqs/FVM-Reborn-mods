	var _x = x;
	var _y = y;
	var _range = 200;
	//var splash_ratio = 0.35
	

	with (obj_enemy_parent) {
	    if (health > 0 && point_distance(x, y, _x, _y) < _range && grid_row == other.row && id != other.hitted_enemy) {
	        
	        // 对敌人造成溅射伤害
	        //hp -= other.damage * splash_ratio;
			//event_user(0)
	        
	    }
	}
	//audio_play_sound(snd_salad_pilt_splash,0,0)