if global.is_paused{
	exit
}
grid_pos = get_grid_position_from_world(x,y)
if timer < max_time timer++
else can_destroy = true

if not can_destroy{
	if timer <= 20{
		image_index = floor(timer/5) mod 4
	}
	else{
		image_index = floor((timer-20)/5) mod 10 + 4
	}
	if timer == 20{
	
		with obj_enemy_parent{
			if (grid_col == other.grid_pos.col && grid_row == other.grid_pos.row && can_hit(other.target_type,target_type)){
				
				hp -= other.damage
				event_user(0)
				if other.shape >= 1{
					if ice_timer < 240{
						ice_timer = 240
					}
				}
				
			}
		}
	}
}
else{
	image_index = floor((timer-max_time)/5) mod 4 + 14
	timer ++
	if timer >= max_time + 20{
		instance_destroy()
	}
}