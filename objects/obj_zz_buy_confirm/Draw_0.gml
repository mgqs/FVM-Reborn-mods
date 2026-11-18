// 与 obj_shop_buy_confirm 的绘制同构：面板动画 → 半透明背景 → 对话框 → 标题 / 正文 → 按钮
// （按钮也是同一写法：把中心坐标直接喂给 spr_common_button 的原点，0.75 倍，见 Create 的说明）
panel_anim_step(id);
if (!instance_exists(id)) exit;
var _a = ui_anim_alpha(id);

// 半透明背景
draw_set_alpha(0.5 * _a);
draw_set_colour(c_black);
draw_rectangle(0, 0, room_width, room_height, false);
draw_set_alpha(_a);

// 对话框本体（spr_battle_escape_menu，1.5 倍，居中）
draw_sprite_ext(bg, 0, x, y, 1.5 * pop_s, 1.5 * pop_s, 0, c_white, _a);

// 标题 + 正文
draw_set_font(font_yuan);
draw_set_halign(fa_center);
draw_set_valign(fa_middle);
draw_set_colour(c_white);
draw_set_alpha(_a);
draw_text(x, y - 112 * pop_s, "兑换确认");
draw_text(x, y - 10 * pop_s, zz_dlg_text());

// 按钮（spr_common_button 三帧：0 常态 / 1 悬停 / 2 按下）
//   与商城 obj_shop_buy_confirm 同写法：坐标就是按钮中心，缩放交给精灵原点
for (var i = 0; i < array_length(buttons); i++) {
	var btn   = buttons[i];
	var btn_x = x + btn[0] * pop_s;
	var btn_y = y + 70 * pop_s;

	var frame = 0;
	if (selected_button == i) frame = mouse_check_button_pressed(mb_left) ? 2 : 1;

	draw_sprite_ext(spr_common_button, frame, btn_x, btn_y,
		zz_btn_scale * pop_s, zz_btn_scale * pop_s, 0, c_white, _a);

	draw_set_font(font_yuan);
	draw_set_halign(fa_center);
	draw_set_valign(fa_middle);
	draw_set_colour(c_white);
	draw_set_alpha(_a);
	draw_text(btn_x, btn_y, btn[1]);
}

draw_set_alpha(1);
draw_set_colour(c_white);
