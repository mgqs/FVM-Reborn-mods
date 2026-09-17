if global.is_paused{
	exit
}
if global.debug{
	image_alpha = 0.5
}
var grid_pos = get_world_position_from_grid(col,row)
timer++


has_bubble = false
non_undersea_card = false
with obj_card_parent{
	var is_in_front = false
	is_in_front = grid_row == other.row && grid_col == other.col
	if is_in_front{
		if plant_id == "soda_bubble"{
			on_lava = true
			other.has_bubble = true
		}
	}
}

with obj_card_parent{
	var is_in_front = false
	is_in_front = grid_row == other.row && grid_col == other.col
	if is_in_front{
		if (plant_type != "coffee" && !invincible && array_get_index(other.ignore_list,plant_id) == -1 && !(plant_id == "player" && hp <= 0.05*max_hp)){
			other.non_undersea_card = true
			if !other.has_bubble && other.timer mod 60 == 0{ 
				hp -= 0.05*max_hp
				event_user(2)
			}
		}
	}
}

