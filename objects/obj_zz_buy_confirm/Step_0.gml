// 与 obj_shop_buy_confirm 同构：悬停选中 → 抬起执行；ESC 关闭
if (variable_instance_exists(id, "pnl_closing") && pnl_closing) exit
selected_button = -1;

for (var i = 0; i < array_length(buttons); i++) {
	var btn   = buttons[i];
	var btn_x = x + btn[0] * pop_s;
	var btn_y = y + 70 * pop_s;
	var btn_w = btn[2];
	var btn_h = btn[3];

	if (point_in_rectangle(mouse_x, mouse_y,
		btn_x - btn_w / 2, btn_y - btn_h / 2,
		btn_x + btn_w / 2, btn_y + btn_h / 2)) {

		selected_button = i;

		if (mouse_check_button_released(mb_left)) {
			audio_play_sound(snd_button, 0, 0);

			if (i == 0) {
				// 确定：真的扣幸运星 / 解锁卡片（数值与判定全在 zz_buy_shop）
				var _res = zz_buy_shop(zz_idx);
				show_notice(_res.msg, _res.ok ? 100 : 80);
				if (_res.ok) audio_play_sound(snd_win, 0, 0);
				panel_anim_close(id);
			} else {
				instance_destroy();
			}
			exit;
		}
		break;
	}
}

if (keyboard_check_pressed(vk_escape)) {
	panel_anim_close(id);
}
if (!instance_exists(id)) exit
pop_anim_step(id)
