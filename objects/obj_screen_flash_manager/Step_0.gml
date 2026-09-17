if global.is_paused{
	exit
}
if timer > 0{
	timer--
}
else{
	instance_destroy()
}