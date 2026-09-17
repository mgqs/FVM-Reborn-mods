
if instance_exists(parent_plant){
	if parent_plant.flash_value >0{
	
	    draw_self()
		shader_set(hit_effect_2);
		draw_sprite_ext(sprite_index,image_index,x,y,image_xscale,image_yscale,image_angle,c_white,parent_plant.flash_value/200);
		shader_reset();
	
	}
	else if parent_plant.is_slowdown{
		image_blend = merge_color(c_white,c_blue,0.5)
		draw_self()
	}
	else{
		image_blend = c_white
		draw_self()
	}
}