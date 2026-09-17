if global.is_paused{
	exit
}
timer++
if timer < 8*3-1{
	image_index = floor(timer/3)
}
else if timer >= 8*3-1 && timer < (8*3+60){
	image_index = 8
}
else{
	image_index = floor((timer-60)/3)
	if timer >= (14*3+60){
		instance_destroy()
	}
}