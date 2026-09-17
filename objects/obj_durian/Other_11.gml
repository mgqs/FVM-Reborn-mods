
if shape < 2{
	var start_pos_x = x + 13 -global.grid_cell_size_x
	var start_pos_y = y - 32 - global.grid_cell_size_y
	for(var i = 0; i < 3;i++){
		for(var j= 0 ; j < 3;j++){
			var grid_pos = get_grid_position_from_world(start_pos_x + j * global.grid_cell_size_x,start_pos_y + i * global.grid_cell_size_y)
			if grid_pos.row >= 0 && grid_pos.row < global.grid_rows && grid_pos.col >= 0 && grid_pos.col <= global.grid_cols{
				var inst = instance_create_depth(start_pos_x + j * global.grid_cell_size_x,start_pos_y + i * global.grid_cell_size_y,0,obj_durian_effect)
				inst.damage = atk
				inst.max_time = 30
				inst.target_type = target_type
				inst.shape = shape
			}
		}
	}
}
else{
	var start_pos_x = x + 13 - 2*global.grid_cell_size_x
	var start_pos_y = y - 32 - 2*global.grid_cell_size_y
	for(var i = 0; i < 5;i++){
		for(var j= 0 ; j < 5;j++){
			var grid_pos = get_grid_position_from_world(start_pos_x + j * global.grid_cell_size_x,start_pos_y + i * global.grid_cell_size_y)
			if grid_pos.row >= 0 && grid_pos.row < global.grid_rows && grid_pos.col >= 0 && grid_pos.col <= global.grid_cols{
				var inst = instance_create_depth(start_pos_x + j * global.grid_cell_size_x,start_pos_y + i * global.grid_cell_size_y,0,obj_durian_effect)
				inst.damage = atk
				inst.max_time = 30
				inst.target_type = target_type
				inst.shape = shape
			}
		}
	}
}