if global.is_paused{
	exit
}
timer++
if state == "appear"{
	image_index = floor(timer/5) mod 9
	if timer >= 9 * 5{
		state = "idle"
	}
}
if state == "idle"{
	image_index = 8
}

if timer == 50{
	var i = 0
	instance_create_depth(x-15,y+10,depth,enemy_list[i])
}


var grid_pos = get_grid_position_from_world(x,y)

if timer >= 120{
	image_alpha -= 0.1	
}
if image_alpha <=0{
	var g_pos = get_grid_position_from_world(x,y)
	if current_grid_type != ""{
		global.grid_terrains[g_pos.row][g_pos.col].type = current_grid_type
	}
	instance_destroy()
}

grid_col = grid_pos.col
grid_row = grid_pos.row

//if global.grid_terrains[grid_pos.row][grid_pos.col].type != "obstacle"{
//	current_grid_type = global.grid_terrains[grid_pos.row][grid_pos.col].type
//	global.grid_terrains[grid_pos.row][grid_pos.col].type = "obstacle"
//}