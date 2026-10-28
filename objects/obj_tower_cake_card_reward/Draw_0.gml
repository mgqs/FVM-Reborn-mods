draw_self()

draw_set_halign(fa_center)
draw_set_valign(fa_middle)

// ── 威望格（2026-10-27 起魔塔奖励全部是威望，不再有卡片）────────────────
if (reward_kind != ""){
	// ① 图标：落在底板画面区中央
	draw_sprite_ext(spr_prestige_icon, 0, x, y-10, 1.6, 1.6, 0, c_white, 1);
	// ② 数字：压在底板那条白条上（跟原来「阳光消耗」同一行，黑字）
	draw_set_font(font_number)
	draw_set_colour(c_black)
	draw_text(x, y+43, string(prestige_amount));
	// ③ 首通 / 次通：原来「点击领取」那一行
	draw_set_font(font_yuan)
	draw_set_colour(c_white)
	draw_text(x, y+83, (reward_kind == "first") ? "首通" : "重复通关");

	if (dimmed){
		draw_set_alpha(0.5)
		draw_set_colour(c_black)
		draw_rectangle(x-sprite_width/2, y-sprite_height/2, x+sprite_width/2, y+sprite_height/2, 0)
		draw_set_alpha(1)
	}
	else if (on_click){
		draw_set_alpha(0.5)
		draw_set_colour(c_white)
		draw_rectangle(x-sprite_width/2, y-sprite_height/2, x+sprite_width/2, y+sprite_height/2, 0)
		draw_set_alpha(1)
	}

	// 悬停提示
	if (on_click){
		var _tooltip = ((reward_kind == "first") ? "首通奖励：" : "重复通关奖励：")
			+ string(prestige_amount) + " 威望"
			+ (dimmed ? "\n（首通威望已发放）" : "\n通关后自动发放");
		var tooltip_x = mouse_x - 15;
		var tooltip_y = mouse_y - 15;
		draw_set_font(font_yuan)
		draw_set_color(c_black)
		draw_set_alpha(0.7)
		draw_rectangle(tooltip_x - string_width(_tooltip) - 5, tooltip_y - 5,
		               tooltip_x + 5, tooltip_y + string_height(_tooltip) + 5, false)
		draw_set_halign(fa_left)
		draw_set_valign(fa_top)
		draw_set_alpha(1)
		draw_set_color(c_white)
		draw_text(tooltip_x - string_width(_tooltip), tooltip_y, _tooltip)
	}

	draw_set_colour(c_white)
	draw_set_halign(fa_left)
	draw_set_valign(fa_top)
	exit
}
