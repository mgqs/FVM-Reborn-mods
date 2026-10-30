// 检查输入框内容是否变化
if (input_field.text != character_name) {
    character_name = input_field.text;
}

if (sw_shown != selected_attire_index) {
	sw_from = sw_shown;
	sw_shown = selected_attire_index;
	sw_t = 0;
	if (sw_pending_dir != 0) {
		sw_dir = sw_pending_dir;
		sw_pending_dir = 0;
	} else {
		var _n = array_length(player_attire_id_list) + 1;
		var _pos_new = (selected_attire_index + 1 + _n) mod _n;
		var _pos_old = (sw_from + 1 + _n) mod _n;
		sw_dir = (((_pos_new - _pos_old) + _n) mod _n == 1) ? 1 : -1;
	}
}
if (!ui_anim_on(1)) {
	sw_t = -1;
	sw_pending_dir = 0;
}
if (sw_t >= 0) {
	sw_t++;
	if (sw_t >= sw_frames) sw_t = -1;
}

panel_anim_step(id);
if (!instance_exists(id)) exit;
