if global.is_paused{
	exit
}
timer ++
image_index = floor(timer/3)
if timer >= image_number*3{
	instance_destroy()
}