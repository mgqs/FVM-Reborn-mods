if global.is_paused{
	exit
}
if state_timer < 20{
	state_timer++
}
else{
	state = 1
	state_timer++
}
col = get_grid_position_from_world(x,y).col
if (col >= start_col + 4)&& shape != 2{
	disabled = true
}
if timer < 4{
	timer++
}

else{
	if state == 0{
		image_index = state_timer / 5
		x -= move_speed
	}
	else{
		image_index = 4+floor(state_timer / 5) mod 3
	}
	timer = 0
}
x += move_speed
if x > 2200 or y > 1200 or x < 0 or y < 0{
	instance_destroy()
}
if disabled{
	image_alpha -= 0.1
	if image_alpha <= 0{
		instance_destroy()
	}
}