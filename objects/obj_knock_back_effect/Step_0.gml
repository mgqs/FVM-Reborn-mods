if global.is_paused{
	exit
}
x += x_speed
y += y_speed
//y_speed += cgravity
image_angle -= 10
if x > 2200 or y > 1200 or x < 0 or y < 0{
	instance_destroy()
}