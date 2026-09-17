if not is_placed{
	var can_plant = (can_place_at_position(mouse_x, mouse_y, "normal","amphi","none"));
	if can_plant{
		var grid_pos = get_grid_position_from_world(mouse_x,mouse_y)
		draw_sprite_ext(sprite_index,0,grid_pos.x,grid_pos.y,1.6,1.6,0,c_white,0.5)
	}
}

if flash_value >0{
	
    draw_self()
	shader_set(hit_effect_2);
	draw_sprite_ext(sprite_index,image_index,x,y,image_xscale,image_yscale,image_angle,c_white,flash_value/200);
	shader_reset();
	
}
else{
	image_blend = c_white
	draw_self()
	
}