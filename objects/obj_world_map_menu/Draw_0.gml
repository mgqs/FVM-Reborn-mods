if global.menu_screen{
	draw_set_alpha(0.5);
	draw_rectangle_color(0, 0, room_width, room_height, c_black, c_black, c_black, c_black, false);
	draw_set_alpha(1);
}
draw_self()
draw_sprite_ext(spr_world_map_name,0,x+45,y+30,1.8,1.8,0,c_white,1)