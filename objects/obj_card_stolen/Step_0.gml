if global.is_paused{
	exit
}
y -= 15
if y <= -200{
	instance_destroy()
}