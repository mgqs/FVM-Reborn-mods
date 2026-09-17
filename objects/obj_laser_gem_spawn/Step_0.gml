if global.is_paused{
	exit
}
timer++
if timer < 20*5{
	image_index = floor(timer/5)
}
else{
	image_index = 19
	image_alpha -= 0.1
	if image_alpha <=0{
		instance_destroy()
	}
}
if timer == 14*5{
	var inst = instance_create_depth(x-150,y-75,-500,obj_laser_gem_effect)
	inst.row = row
}