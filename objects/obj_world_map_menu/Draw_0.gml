panel_anim_step(id)
if (!instance_exists(id)) { exit }
if global.menu_screen{
	draw_set_alpha(0.5 * ui_anim_alpha(id));
	draw_rectangle_color(0, 0, room_width, room_height, c_black, c_black, c_black, c_black, false);
	draw_set_alpha(1);
}
panel_anim_begin(id)
draw_self()
draw_sprite_ext(spr_world_map_name,0,x+45,y+30,1.8,1.8,0,c_white,1)
panel_anim_end_slide(id, 260)
