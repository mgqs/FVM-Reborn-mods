if global.is_paused{
	exit
}
timer++
if state == "start"{
	image_index = floor(timer/5) mod 4
	y -= 15
	if y <= -200{
		var target_pos = get_world_position_from_grid(target_col,target_row)
		x = target_pos.x 
		y = target_pos.y - room_height
		state = "drop"
	}
}
if state == "drop"{
	image_index = floor(timer/5) mod 4 + 4
	var target_pos = get_world_position_from_grid(target_col,target_row)
	y += 15
	if y >= (target_pos.y-15){
		instance_create_depth(x+15,y-15,-200,obj_chocolatecannon_bullet_effect)
		instance_destroy()
	}
}