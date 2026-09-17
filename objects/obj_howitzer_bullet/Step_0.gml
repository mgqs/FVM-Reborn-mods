if global.is_paused{
	image_speed = 0
	exit
	
}
image_speed = 1

var target_pos = get_world_position_from_grid(target_col,row)

if not pos_set{
	x = target_pos.x
	y = target_pos.y - room_height
	y += y_offset
	image_alpha = 1
	pos_set = 1
}

if y < target_pos.y{
	y += 20
}
else{
	instance_destroy()
}