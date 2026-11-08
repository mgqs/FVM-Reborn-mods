/// 魔塔蛋糕 · 转职凭证格：绘制
/// ① 底板 + 卡面统一走 transfer_credit_draw（别在这里另写画法）
/// ② 已转职 → 整张卡套 sh_fusion_gray 去色 + 中腰盖「已转职」条（2026-11-08 用户定：保持这个呈现）
/// ③ 格下小字 = 「油灯-一转」，字体跟商店那句黑色小字一致（font_pixel、纯黑）
draw_set_alpha(1);
draw_set_colour(c_white);
var _s        = credit_size;
var _half     = _s * 0.5;
var _transferred = transfer_credit_is_transferred(card_id, card_shape);

// 底板 + 卡面：一律走统一绘制（灰色态用去色 shader，跟合成屋未持有格同一套）
var _shader_on = false;
if (_transferred){
	shader_set(sh_fusion_gray);
	_shader_on = true;
}
transfer_credit_draw(x - _half, y - _half, card_id, card_shape, _s, slot_index, 1);
if (_shader_on) shader_reset();

// 悬停：卡框描一圈白（很轻，只做「点得到」的反馈）
if (hovered and !_transferred){
	draw_set_alpha(0.5);
	draw_set_colour(c_white);
	draw_rectangle(x - _half + 1, y - _half + 1, x + _half - 1, y + _half - 1, true);
	draw_set_alpha(1);
}

// 已转职：中腰盖一条深色底 + 灰白字
if (_transferred){
	var _bw = _s * 0.39;
	draw_set_alpha(0.78);
	draw_set_colour(make_color_rgb(26, 32, 46));
	draw_roundrect(x - _bw, y - 13, x + _bw, y + 13, false);
	draw_set_alpha(1);
	draw_set_colour(make_color_rgb(212, 218, 228));
	draw_set_font(font_yuan);
	draw_set_halign(fa_center);
	draw_set_valign(fa_middle);
	draw_text_transformed(x, y, "已转职", 0.82, 0.82, 0);
}

// 格下小字不在这里画：卡面立绘会往上溢出格子，同层画会被下一行立绘盖住
//   → 统一由 obj_tower_cake_credit_label（深度 bg-3）从 bg.credit_labels 里取数据画

// 悬停提示：贴在格子正上方（放不下就挪到下方），整块夹在右侧面板里 ——
//   跟着鼠标走会压住下面的卡名，靠近左边缘时还会被裁掉半截（2026-11-08 用户反馈）
if (hovered && !_transferred){
	var _tip = label_text + "\n" + credit_price_label(cost, coin_type) + " · 点击购买";
	draw_set_font(font_yuan);
	var _tw = string_width(_tip);
	var _th = string_height(_tip);
	var _bw = _tw + 14;
	var _bh = _th + 10;
	var _bgx = obj_tower_cake_bg.x;
	var _bgy = obj_tower_cake_bg.y - 92;
	var _tx = clamp(x - _bw * 0.5, _bgx + 378, _bgx + 848 - _bw);
	var _ty = y - _half - _bh - 8;
	if (_ty < _bgy) _ty = y + _half + 26;
	draw_set_alpha(0.78);
	draw_set_colour(make_color_rgb(20, 26, 38));
	draw_rectangle(_tx, _ty, _tx + _bw, _ty + _bh, false);
	draw_set_alpha(1);
	draw_set_colour(c_white);
	draw_set_halign(fa_left);
	draw_set_valign(fa_top);
	draw_text(_tx + 7, _ty + 5, _tip);
}

draw_set_colour(c_white);
draw_set_alpha(1);
draw_set_halign(fa_left);
draw_set_valign(fa_top);
