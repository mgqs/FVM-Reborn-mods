// Inherit the parent event
if global.is_paused{
	exit
}

remove_timer ++

if remove_timer == 1{
	with obj_card_parent{
		if grid_row == other.grid_row && grid_col == other.grid_col && plant_id == "soda_bubble" && id != other.id{
			instance_destroy()
		}
	}
}

event_inherited();

if hp <= 0.33 * max_hp{
	sprite_index = spr_list[2]
}
else if hp <= 0.67 * max_hp{
	sprite_index = spr_list[1]
}
else{
	sprite_index = spr_list[0]
}

if card_equipped_attire_id(plant_id) != "bubble_maltose"{
	depth = calculate_plant_depth(grid_col,grid_row,"coffee")
}
else{
	depth = calculate_plant_depth(grid_col,grid_row,"lilypad")
}

if on_lava && global.grid_terrains[grid_row][grid_col].type != "obstacle"{
	plant_type = "lilypad"
}