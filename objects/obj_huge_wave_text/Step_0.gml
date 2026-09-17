if global.is_paused{
	exit
}
if timer < 20{
	timer ++
	scale += 0.05
	image_alpha +=0.05
}
else if timer < 30{
	timer ++
	scale -= 0.02
	
}
else if timer > 90{
	image_alpha -= 0.1
	if image_alpha <= 0{
		instance_destroy()
	}
}
else {
	timer ++
}


image_xscale = 1.8 * scale
image_yscale = 1.8 * scale