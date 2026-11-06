draw_set_alpha(1)
if (obj_info_island_bg.info_button_select == 1 && obj_info_island_bg.select_card_index != -1){
	draw_self()
	ui_anim_text_alpha(id)
	draw_set_color(c_white)
	draw_set_font(font_yuan)
	draw_set_halign(fa_center)
	draw_set_valign(fa_middle)
	// 四个字比「编辑」宽，缩到 0.8 才塞得进按钮
	draw_text_transformed(x, y, btn_text, 0.8, 0.8, 0)
}
draw_set_alpha(1)
