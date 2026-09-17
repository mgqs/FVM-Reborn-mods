	var _x = x;
	var _y = y;
	var _range = 200

	with (obj_enemy_parent) {
		
			if (hp > 0 && point_distance(x, y, _x, _y) < _range && grid_row >= other.grid_row-1&&grid_row <= other.grid_row+1 and can_hit(other.target_type,target_type)) {
		        
		            // 对敌人造成伤害
		            hp -= other.damage;
					event_user(0)
		           
		    }
		
	}