if global.is_paused{
	exit
}
timer++
if timer >= 20*5{
	instance_destroy()
}
image_index = floor(timer/5)