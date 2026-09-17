if global.is_paused{
	exit
}
timer++
if timer < 24*5{
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
	var inst = instance_create_depth(x-50,y-75,-500,obj_freeze_gem_effect)
	//audio_play_sound(snd_mouse_frozen,0,0)
	inst.row = row
}