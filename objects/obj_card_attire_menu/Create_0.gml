image_xscale = 1.8
image_yscale = 1.8

pop_s = 1; pop_p = 0; pop_t = 0; pop_dur = 0.20; pop_from = 0.84;
pop_kids = []; pop_mx = x; pop_my = y; pop_back_t = 0; pop_back_p = 0;

target_card_id = ""
info_got = false
card_attire_id_list = []
selected_attire_id = ""
selected_attire_index = -1 // 当前选择的时装索引

//target_current_level = 9
//target_current_shape = 0
//target_current_skill = 0

sw_shown = -2
sw_from = -1
sw_t = -1
sw_frames = 18
sw_dir = 1
sw_pending_dir = 0
sw_surf = -1
sw_win_l = x - 175
sw_win_t = y - 122
sw_win_w = 349
sw_win_h = 310

function card_attire_content_draw(_index, _dx, _dy) {
	if (_index != -1) {
		var _id = card_attire_id_list[_index]
		var _d = get_attire_info(_id)
		draw_sprite_ext(spr_slot, 0, x + _dx * pop_s, y - 10 * pop_s + _dy, 0.32 * pop_s, 0.32 * pop_s, 0, c_white, 1)
		draw_sprite_ext(_d.icon, 0, x + _dx * pop_s, y + 10 * pop_s + _dy, pop_s, pop_s, 0, c_white, 1)
		draw_set_halign(fa_center)
		draw_set_valign(fa_middle)
		draw_text(x + _dx * pop_s, y + 70 * pop_s + _dy, _d.name)
	} else {
		draw_set_halign(fa_center)
		draw_set_valign(fa_middle)
		draw_text(x + _dx * pop_s, y + 70 * pop_s + _dy, "无")
	}
}
