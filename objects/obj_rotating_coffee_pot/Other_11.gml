var _x = x;
	var _y = y;
	var _range = 220
	if shape == 2{
		_range = 350
	}

	with (obj_enemy_parent) {
		
			if (hp > 0 && point_distance(x, y, _x, _y) < _range && grid_row >= other.grid_row-other.range&&grid_row <= other.grid_row+other.range&&can_hit(other.target_type,target_type)) {
		        
		            damage_amount = other.atk;
				damage_type = "true";
				damage_source_object = other.object_index;
				event_user(0)
		            global.audio.play(snd_hit1,0,0)
		    }
		
	}
