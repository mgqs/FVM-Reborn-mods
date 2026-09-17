function screen_flash(color,time){
	var inst = instance_create_depth(0,0,-5000,obj_screen_flash_manager)
	inst.flash_color = color
	inst.start_timer = time
	inst.timer = time
}