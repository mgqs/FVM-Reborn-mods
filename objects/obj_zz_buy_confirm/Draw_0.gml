// 与 obj_shop_buy_confirm 的绘制同构：面板动画 → 半透明背景 → 对话框 → 标题 / 正文 → 按钮
// （唯一差异：按钮按「画布中心」定位，不吃 spr_common_button 那个已偏移的原点，保证文字正压在按钮上）
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
for (var i = 0; i < array_length(buttons); i++) {
	var btn   = buttons[i];
	var btn_x = x + btn[0] * pop_s;
	var btn_y = y + 70 * pop_s;

	var frame = 0;
	if (selected_button == i) frame = mouse_check_button_pressed(mb_left) ? 2 : 1;

	var _bs = zz_btn_scale * pop_s;
	var _bw = sprite_get_width(spr_common_button) * _bs;
	var _bh = sprite_get_height(spr_common_button) * _bs;
	draw_sprite_ext(spr_common_button, frame, btn_x - _bw / 2, btn_y - _bh / 2, _bs, _bs, 0, c_white, _a);

	draw_set_font(font_yuan);
	draw_set_halign(fa_center);
	draw_set_valign(fa_middle);
	draw_set_colour(c_white);
	draw_set_alpha(_a);
	draw_text(btn_x, btn_y, btn[1]);
}

draw_set_alpha(1);
draw_set_colour(c_white);
