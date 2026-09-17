if global.is_paused{
	exit
}
timer ++
image_index = floor(timer/3)
if timer >= 15{
	instance_destroy()
}