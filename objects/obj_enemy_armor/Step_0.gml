if global.is_paused{
	exit
}
if can_destroy{
	image_alpha -= 0.1
	if image_alpha<=0{
		instance_destroy()
	}
}
else{
	if type == "helmet"{
		image_angle -= 5
	}
	else if type == "shield"{
		image_angle += 5
	}
	x += x_speed
	y += y_speed
	y_speed += cgravity
	if water{
		image_alpha -= 0.04
		if type == "shield"{
			image_alpha -= 0.04
		}
		if image_alpha<=0{
			instance_destroy()
		}
	}
	if y >= ground_y && !water{
		can_destroy = true
	}
}