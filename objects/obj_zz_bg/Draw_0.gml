// ── 背景（cover 铺满 1920×1080）──
var _bw = sprite_get_width(spr_zz_bg);
var _bh = sprite_get_height(spr_zz_bg);
var _bs = max(room_width / _bw, room_height / _bh);
draw_sprite_ext(spr_zz_bg, 0, (room_width - _bw * _bs) / 2, (room_height - _bh * _bs) / 2,
	_bs, _bs, 0, c_white, 1);

draw_set_alpha(0.35);
draw_rectangle_color(0, 0, room_width, room_height, c_black, c_black, c_black, c_black, false);
draw_set_alpha(1);

// ── 机台 / 标题 / 页签 ──
zz_draw(spr_zz_machine, 90, 104 + zz_ui_dy, 900, 568, 1);
zz_draw(spr_zz_title, 456, 26, 168, 52, 1);
zz_draw(spr_zz_tab_lucky_on, 247, 212 + zz_ui_dy, 130, 38, 1);

// 保底文案
var _left = zz_pity_left();
var _pcol = (_left <= 10) ? c_lime : c_white;
zz_text("距离下次保底 剩余 " + string(_left) + " 次（下次：" + zz_pity_tier_text() + "）",
	624, 231 + zz_ui_dy, 13, _pcol, fa_center);

// ── 18 格 ──
for (var _i = 0; _i < 18; _i++) {
	var _g = zz_grid[_i];
	var _gx = 267 + _g.c * 78;
	var _gy = 250 + zz_ui_dy + _g.r * 80;
	zz_draw(zz_cell_spr[_i mod 6], _gx, _gy, 74, 74, 1);
	zz_icon(zz_cell_ids[_i], _gx + 37, _gy + 37, 56);
	if (zz_state == 1 && _i == zz_light)
		zz_draw(spr_zz_frame_sel, _gx - 4, _gy - 4, 82, 82, 1);
}

// ── 中央宝物展示 ──
draw_set_alpha(0.42);
draw_set_colour(c_black);
draw_roundrect_ext(zzpx(345), zzpy(326 + zz_ui_dy), zzpx(731), zzpy(476 + zz_ui_dy), 14 * zz_k, 14 * zz_k, false);
draw_set_colour(make_color_rgb(255, 206, 120));
draw_set_alpha(0.85);
draw_roundrect_ext(zzpx(345), zzpy(326 + zz_ui_dy), zzpx(731), zzpy(476 + zz_ui_dy), 14 * zz_k, 14 * zz_k, true);
draw_set_alpha(1);
draw_set_colour(c_white);

zz_draw(spr_zz_treasure_cap, 482, 334 + zz_ui_dy, 112, 29, 1);
for (var _s2 = 0; _s2 < 4; _s2++) {
	zz_icon(zz_showcase[_s2], 401 + _s2 * 80, 414 + zz_ui_dy, 56);
}
zz_draw(spr_zz_btn_exshop, 631, 332 + zz_ui_dy, 86, 32, 1);

// ── 三档价格按钮 ──
var _price_spr = [spr_zz_price_20000, spr_zz_price_100000, spr_zz_price_1000000];
var _price_x = [243, 443, 643];
var _pull_txt = ["1 抽", "5 抽", "50 抽"];
for (var _p = 0; _p < 3; _p++) {
	zz_draw(_price_spr[_p], _price_x[_p], 603 + zz_ui_dy, 190, 61, 1);
	zz_text(_pull_txt[_p], _price_x[_p] + 95, 585 + zz_ui_dy, 13, c_yellow, fa_center);
}

// ── 侧栏 / 钱包 / 关闭 ──
zz_draw(spr_zz_side_lucky_on, 956, 266 + zz_ui_dy, 116, 56, 1);
zz_draw(spr_zz_side_gift_off, 956, 332 + zz_ui_dy, 116, 56, 1);

zz_wallet("gold", string(global.save_data.player.gold), 985, 32, 18, c_yellow);
zz_wallet("zz_star", string(zz_star_amount()), 1058, 32, 18, c_aqua);

zz_draw(spr_zz_btn_close, 1000, 600 + zz_ui_dy, 55, 55, 1);

if (zz_state == 1)
	zz_text("点击任意处可跳过动画", 540, 654, 12, make_color_rgb(255, 235, 170), fa_center);

zz_text("消耗金币购买四叶草，就有机会获得马年生肖卡等稀有道具",
	540, 690, 13, make_color_rgb(201, 180, 240), fa_center);

// ── 提示气泡 ──
if (zz_msg_t > 0) {
	var _a = min(1, zz_msg_t / 20);
	draw_set_alpha(0.82 * _a);
	draw_set_colour(c_black);
	draw_roundrect_ext(zzpx(360), zzpy(348 + zz_ui_dy), zzpx(720), zzpy(392 + zz_ui_dy), 20 * zz_k, 20 * zz_k, false);
	draw_set_alpha(1);
	zz_text(zz_msg, 540, 370 + zz_ui_dy, 16, c_white, fa_center);
}

// ── 结果弹窗 ──
if (zz_state == 2) {
	draw_set_alpha(0.62);
	draw_rectangle_color(0, 0, room_width, room_height, c_black, c_black, c_black, c_black, false);
	draw_set_alpha(1);

	zz_draw(spr_zz_panel, 210, 110, 660, 500, 1);
	zz_draw(spr_zz_congrats, 396, 112, 288, 78, 1);
	zz_draw(spr_zz_btn_close, 792, 126, 52, 52, 1);

	// 本次消耗 / 获得幸运星
	zz_text("本次消耗", 470, 210, 12, c_white, fa_center);
	draw_set_colour(make_color_rgb(230, 220, 250));
	draw_roundrect_ext(zzpx(442), zzpy(222), zzpx(498), zzpy(278), 10 * zz_k, 10 * zz_k, false);
	zz_icon("gold", 470, 250, 44);
	zz_text(string(zz_result_cost) + " 金币" + ((zz_result_count > 1) ? "（" + string(zz_result_count) + "抽）" : ""),
		470, 294, 12, make_color_rgb(74, 59, 138), fa_center);

	zz_text("获得幸运星", 610, 210, 12, c_white, fa_center);
	draw_set_colour(make_color_rgb(230, 220, 250));
	draw_roundrect_ext(zzpx(582), zzpy(222), zzpx(638), zzpy(278), 10 * zz_k, 10 * zz_k, false);
	zz_icon("zz_star", 610, 250, 44);
	zz_text("持有 " + string(zz_star_amount()), 610, 294, 12, make_color_rgb(74, 59, 138), fa_center);

	// 奖励
	var _list = zz_result_list();
	var _n = array_length(_list);
	if (_n > 0) {
		var _per = (_n <= 8) ? _n : ceil(_n / 2);
		var _rows = ceil(_n / _per);
		var _step = min(74, 520 / _per);
		var _isz = min(56, _step - 16);
		for (var _k = 0; _k < _n; _k++) {
			var _row = _k div _per;
			var _col = _k mod _per;
			var _cnt = min(_n - _row * _per, _per);
			var _x0 = 540 - (_cnt * _step) / 2 + _step / 2;
			var _cxx = _x0 + _col * _step;
			var _cyy = 352 + _row * 78;
			draw_set_colour(make_color_rgb(246, 240, 255));
			draw_roundrect_ext(zzpx(_cxx - 31), zzpy(_cyy - 31), zzpx(_cxx + 31), zzpy(_cyy + 31),
				10 * zz_k, 10 * zz_k, false);
			if (_list[_k].pity) {
				draw_set_colour(make_color_rgb(255, 140, 60));
				draw_roundrect_ext(zzpx(_cxx - 31), zzpy(_cyy - 31), zzpx(_cxx + 31), zzpy(_cyy + 31),
					10 * zz_k, 10 * zz_k, true);
			}
			draw_set_colour(c_white);
			zz_icon(_list[_k].id, _cxx, _cyy - 2, _isz);
			zz_text_o("×" + string(_list[_k].qty), _cxx, _cyy + 39, 10,
				make_color_rgb(96, 52, 10), make_color_rgb(255, 255, 255), fa_center);
		}
	}

	// 再来一次 / 十次 / 五十次
	var _again = [spr_zz_btn_again1, spr_zz_btn_again10, spr_zz_btn_again50];
	var _again_x = [305, 467, 629];
	for (var _b = 0; _b < 3; _b++)
		zz_draw(_again[_b], _again_x[_b], 516, 146, 50, 1);
}

draw_set_colour(c_white);
draw_set_alpha(1);
