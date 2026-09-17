if global.is_paused{
	exit
}
timer ++

if state == "appear"{
	image_index = (floor(timer/5))mod 4
	if timer == 4 * 5 - 1{
		timer = 0
		state = "act"
		disabled = false
	}
}
if state == "act"{
	image_index = (floor(timer/5))mod 8 + 4
	if timer >= 120{
		timer = 0
		state = "disappear"
		disabled = true
	}
}
if state == "disappear"{
	image_index = (floor(timer/5))mod 5 + 12
	if timer >= 5 * 5 - 1{
		instance_destroy()
	}
}
if timer mod 12 == 1 && not disabled{
	event_user(0)
}