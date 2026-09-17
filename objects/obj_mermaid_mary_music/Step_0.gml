if global.is_paused{
	image_speed = 0
	exit
}
else{
	image_speed = 1
}

x += 8

if x > 2200{
	instance_destroy()
}