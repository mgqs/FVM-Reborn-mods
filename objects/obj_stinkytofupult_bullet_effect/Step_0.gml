if global.is_paused{
	exit
}
timer ++
image_index = (floor(timer/3) )mod 15
if timer > 180{
	disabled = true
	image_alpha = (190-timer)/10
	if timer > 190{
		instance_destroy()
	}
}
if timer mod 60 == 30 && not disabled{
	event_user(0)
}