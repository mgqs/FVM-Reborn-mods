// Inherit the parent event
event_inherited();

if !is_derivative && shape == 2{
	//临时关闭替换放置，防止叠加
	var current_replace_option = global.replace_placement
	global.replace_placement = false
	if can_place_at_position(x,y-global.grid_cell_size_y,"lilypad","water","none"){
		var grid_pos = get_grid_position_from_world(x,y-global.grid_cell_size_y)
		var inst = instance_create_depth(x,y-global.grid_cell_size_y,depth+5,obj_wooden_plate)
		inst.is_derivative = true
		card_created(inst,grid_pos.col,grid_pos.row)
	}
	if can_place_at_position(x,y+global.grid_cell_size_y,"lilypad","water","none"){
		var grid_pos = get_grid_position_from_world(x,y+global.grid_cell_size_y)
		var inst = instance_create_depth(x,y+global.grid_cell_size_y,depth-5,obj_wooden_plate)
		inst.is_derivative = true
		card_created(inst,grid_pos.col,grid_pos.row)
	}
	global.replace_placement = current_replace_option
	is_derivative = true
}

