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
				// 已通过 can_hit 判定（rotate 可命中 underground），允许命中钻地中的地精鼠（同鼹鼠规则）
				if (variable_instance_exists(id, "ly_dig_hittable")) ly_dig_hittable = true;
				event_user(0)
		            global.audio.play(snd_hit1,0,0)
		    }
		
	}
