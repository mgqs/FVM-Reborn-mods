if global.save_slot != state{
	if (point_in_rectangle(mouse_x, mouse_y, x-sprite_width/2, y-sprite_height/2, x+sprite_width/2, y+sprite_height/2)) {
	    image_index = 1
	} else {
	    image_index = 0
	}
}
else{
	image_index = 2
}