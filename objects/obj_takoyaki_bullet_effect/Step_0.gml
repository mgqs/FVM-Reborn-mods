if global.is_paused{
	exit
}
timer ++
image_index = floor(timer/3)
if timer >= 9{
	instance_destroy()
}