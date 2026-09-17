if global.is_paused{
	exit
}
timer ++
image_index = floor(timer/5)+1
if timer >= 25{
	instance_destroy()
}