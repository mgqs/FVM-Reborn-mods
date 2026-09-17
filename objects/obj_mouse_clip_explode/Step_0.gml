if global.is_paused{
	image_speed = 0
	exit
}
else{
	image_speed = 1
}
if can_destroy{
	image_index = 8
	image_speed = 0
	timer--
	image_alpha = timer / 10
	if timer < 0 {
		instance_destroy()
	}
}
