if global.is_paused{
	exit
}
x += 50
if x > 2200 or y > 1200 or x < 0 or y < 0{
	instance_destroy()
}