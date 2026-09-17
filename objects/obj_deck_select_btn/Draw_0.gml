draw_self()
draw_set_color(c_black)
draw_set_font(font_yuan)
draw_set_halign(fa_center)
draw_set_valign(fa_middle)
if obj_readyroom_manager.selected_custom_deck != deck_index{
	draw_text(x,y,deck_name)
}
else{
	draw_text(x+20,y,deck_name)
}
draw_set_halign(fa_left)
draw_set_valign(fa_top)