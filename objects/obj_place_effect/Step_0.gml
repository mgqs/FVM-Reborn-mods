if global.is_paused{
	image_speed = 0
	exit
}
else{
	image_speed = 1
}
if timer <= 18{
	timer ++
}
else{
	instance_destroy()
}