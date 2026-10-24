
draw_self()
ui_anim_text_alpha(id)
// 绘制标题
draw_set_color(c_white)
draw_set_font(font_yuan); // 使用菜单字体
draw_set_halign(fa_center);
draw_set_valign(fa_middle);
draw_text(x, y - 165 * pop_s, "卡片时装选择");
if (selected_attire_index != -1) selected_attire_id = card_attire_id_list[selected_attire_index]
if (sw_t < 0) {
	card_attire_content_draw(selected_attire_index, 0, 0)
} else {
	var _p = sw_t / sw_frames
	var _e = 1 - power(1 - _p, 3)
	var _shift = sw_win_w * _e
	if (!surface_exists(sw_surf)) sw_surf = surface_create(sw_win_w, sw_win_h)
	if (!surface_exists(sw_surf)) {
		card_attire_content_draw(selected_attire_index, 0, 0)
	} else {
		surface_set_target(sw_surf)
		draw_clear_alpha(c_black, 0)
		card_attire_content_draw(sw_from, -sw_dir * _shift - sw_win_l, -sw_win_t)
		card_attire_content_draw(sw_shown, sw_dir * (sw_win_w - _shift) - sw_win_l, -sw_win_t)
		surface_reset_target()
		draw_surface_part(sw_surf, 0, 0, sw_win_w, sw_win_h, sw_win_l, sw_win_t)
	}
}
draw_set_alpha(1)
