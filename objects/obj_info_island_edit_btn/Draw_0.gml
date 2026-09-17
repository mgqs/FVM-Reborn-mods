if obj_info_island_bg.info_button_select == 1 and obj_info_island_bg.select_card_index!= -1{
	draw_self()
	draw_set_color(c_white)
	draw_set_font(font_yuan)
	draw_set_halign(fa_center)
	draw_set_valign(fa_middle)
	draw_text(x,y,btn_text)
}