if global.is_paused{	
	image_speed = 0
	exit
}
image_speed = 1
if not instance_exists(parent_card){
	instance_destroy()
}