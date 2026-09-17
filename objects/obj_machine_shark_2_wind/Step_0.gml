if global.is_paused{
	exit
}

var grid_pos = get_grid_position_from_world(x,y)
grid_col = grid_pos.col
grid_row = grid_pos.row

timer ++
if state != "appear"{
	x += x_move_speed
	y += y_move_speed
}

if state == "appear"{
	image_index = floor(timer/5) mod 3
	if timer >= 3 * 5 - 1{
		timer = 0
		state = "move"
	}
}
if state == "move"{
	image_index = floor(timer/5) mod 8 + 3
	
	with obj_card_parent{
		if grid_col == other.grid_col && grid_row == other.grid_row && plant_id != "player" && plant_type != "coffee" && plant_id != "soda_bubble" && !invincible{
			instance_destroy()
			if hp >= max_hp{
				obj_task_manager.card_loss++
			}
		}
	}
	
	if timer >= 60{
		timer = 0
		state = "disappear"
	}
}
if state == "disappear"{
	image_index = floor(timer/5) mod 6 + 11
	if timer >= 6 * 5 - 1{
		instance_destroy()
	}
}