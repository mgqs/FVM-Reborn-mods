// ── 压暗底图（与商城 obj_shop_bg 同透明度）──
draw_set_alpha(0.5);
draw_set_colour(c_black);
draw_rectangle(0, 0, room_width, room_height, false);
draw_set_alpha(1);

// ── 面板 + 网格底衬 ──
draw_sprite_ext(spr_shop_bg, 0, zz_panel_x, zz_panel_y, zz_panel_s, zz_panel_s, 0, c_white, 1);
draw_sprite_ext(spr_shop_bg_2, 0, zz_panel_x, zz_panel_y + 58, 1.8, 1.8, 0, c_white, 1);

// ── 16 格固定绘制（空格子也画，与商城 4×4 完全一致）──
for (var _bg = 0; _bg < zz_per_page; _bg++) {
	var _sc = zz_slot_center(_bg);
	draw_sprite_ext(spr_shop_goods_bg, 0, _sc[0], _sc[1], 1.8, 1.8, 0, c_white, 1);
}

// ── 商品内容 ──
var _list  = zz_shop_list();
var _stars = zz_star_amount();
for (var _slot = 0; _slot < zz_per_page; _slot++) {
	var _idx = zz_slot_item(zz_page, _slot, _list);
	if (_idx < 0) continue;

	var _sc  = zz_slot_center(_slot);
	var _cx  = _sc[0];
	var _cy  = _sc[1];
	var _it  = _list[_idx];
	var _is_card = (variable_struct_exists(_it, "card") && _it.card);
	var _owned   = _is_card && zz_card_owned(_it.id);

	// ── 左侧图标区（粉红放射区，格心左移 123）──
	if (_is_card) {
		// 卡片：卡槽 + 立绘，画法与商城 / 跨服商店 / 情报岛完全一致
		//   （这些精灵画布带大量透明留白，按画布等比缩放反而会缩得很小 → 1:1 + 自身原点）
		draw_sprite_ext(spr_slot, 0, _cx - 123, _cy, 0.33, 0.33, 0, c_white, 1);
		var _cd   = deck_get_card_data(_it.id, 0);
		var _cspr = -1;
		if (_cd != noone && ds_exists(_cd, ds_type_map) && ds_map_exists(_cd, "sprite")) {
			_cspr = _cd[? "sprite"];
		}
		if (_cspr == -1) _cspr = asset_get_index("spr_" + _it.id);
		if (_cspr != -1 && sprite_exists(_cspr)) {
			draw_sprite_ext(_cspr, 0, _cx - 123, _cy + 25, 1, 1, 0, c_white, 1);
		}
		// 卡槽左下角的「火焰 + 能量消耗」（与商城同：font_number + spr_flame 0.3 倍）
		if (_cd != noone && ds_exists(_cd, ds_type_map) && ds_map_exists(_cd, "cost")) {
			draw_set_font(font_number);
			draw_set_halign(fa_left);
			draw_set_valign(fa_middle);
			draw_set_colour(c_black);
			draw_text_ext_transformed(_cx - 135, _cy + 46, string(_cd[? "cost"]), 25, 1800, 1, 1, 0);
			draw_sprite_ext(spr_flame, 0, _cx - 147, _cy + 45, 0.3, 0.3, 0, c_white, 1);
		}
	} else {
		// 材料：图标落在粉红放射区正中（80×1.8 = 144）
		//   四叶草图标本身画得满，同样 144 会顶满整个放射区 → 缩一半（72）
		var _isz = (string_pos("clover_", _it.id) == 1) ? 72 : 144;
		zz_icon_screen(_it.id, _cx - 123, _cy, _isz);
	}

	// ── 奶黄名称牌（牌面 92..222 精灵坐标，中心 = 格心 +79 / -44）──
	if (_is_card) {
		zz_stxt(zz_item_name(_it.id), _cx + 79, _cy - 44, 17, c_black, fa_center);
	} else {
		// 材料还要写 ×N：名字左移给数量让位
		zz_stxt(zz_item_name(_it.id), _cx + 52, _cy - 44, 17, c_black, fa_center);
		zz_stxt("×" + string(_it.qty), _cx + 186, _cy - 44, 16, zz_c_qty, fa_right);
	}

	// ── 深青消耗条（精灵实测：条面 x 91..221 / y 33..54，原点 113,44 → 中心 = 格心 +77 / -1）──
	//   「消耗 N」+ 幸运星图标作为一个整体居中在消耗条里（不贴左画字、不贴右画星）
	var _c_lab = "消耗 " + string(_it.cost);
	var _c_sz  = 18;
	var _c_ico = 34;
	var _c_gap = 10;
	draw_set_font(font_yuan);
	var _c_tw  = string_width(_c_lab) * (_c_sz / 16);
	var _c_rw  = _c_tw + _c_gap + _c_ico;
	var _c_x0  = _cx + 77 - _c_rw / 2;
	var _c_cy  = _cy - 1;
	zz_stxt(_c_lab, _c_x0, _c_cy, _c_sz, c_white, fa_left);
	zz_star_icon(_c_x0 + _c_tw + _c_gap + _c_ico / 2, _c_cy, _c_ico);

	// ── 已拥有的卡片：整卡压暗（先压暗，购买按钮再画在上面，跟商城一样不被盖）──
	if (_owned) {
		draw_set_alpha(0.55);
		draw_set_colour(c_black);
		draw_rectangle(_cx - 203, _cy - 80, _cx + 203, _cy + 80, false);
		draw_set_alpha(1);
	}

	// ── 购买按钮（商城原按钮；余额不足 / 已拥有置灰）──
	var _ok  = !_owned && (_stars >= _it.cost);
	var _r   = zz_buy_rect(_cx, _cy);
	var _hov = _ok && point_in_rectangle(mouse_x, mouse_y,
		_r[0], _r[1], _r[0] + _r[2], _r[1] + _r[3]);
	draw_sprite_ext(spr_shop_buy_btn, (_hov ? 1 : 0),
		_cx + zz_buy_dx, _cy + zz_buy_dy,
		zz_buy_s, zz_buy_s, 0, _ok ? c_white : c_gray, 1);

	if (_owned) zz_stxt("已拥有", _cx + zz_buy_dx, _cy + zz_buy_dy, 20, c_white, fa_center);
}

// ── 底部余额条：整条盖掉「余额：金币」换成幸运星（同色，看不出接缝）──
draw_set_colour(zz_c_bar);
draw_roundrect_ext(zz_bal[0], zz_bal[1], zz_bal[2], zz_bal[3], 12, 12, false);
var _bcy   = (zz_bal[1] + zz_bal[3]) / 2;
var _amt   = string(zz_star_amount());
var _b_lab = "幸运星";
var _b_ico = 40;
var _b_gap = 12;
// 「幸运星 + 图标 + 数量」整组贴左，图标与数量直接跟在文字后面
draw_set_font(font_yuan);
var _b_lw  = string_width(_b_lab) * (24 / 16);
var _b_x   = zz_bal[0] + 22;
zz_stxt(_b_lab, _b_x, _bcy, 24, make_color_rgb(150, 210, 240), fa_left);
var _b_ix  = _b_x + _b_lw + _b_gap + _b_ico / 2;
zz_star_icon(_b_ix, _bcy, _b_ico);
zz_stxt(_amt, _b_ix + _b_ico / 2 + 6, _bcy, 26, zz_c_gold, fa_left);

// ── 翻页（左 / 右箭头 = spr_shop_page_btn；「下一页」横向翻转，与 obj_shop_page_btn 同法）──
var _pg_ok_p = (zz_page > 1);
var _pg_ok_n = (zz_page < zz_max_page);
draw_sprite_ext(spr_shop_page_btn, (_pg_ok_p && zz_pg_hit(zz_pg_prev)) ? 1 : 0,
	zz_pg_prev[0], zz_pg_prev[1], zz_pg_s, zz_pg_s, 0, c_white, 1);
draw_sprite_ext(spr_shop_page_btn, (_pg_ok_n && zz_pg_hit(zz_pg_next)) ? 1 : 0,
	zz_pg_next[0], zz_pg_next[1], -zz_pg_s, zz_pg_s, 0, c_white, 1);
zz_stxt(string(zz_page) + "/" + string(zz_max_page), zz_pg_txt[0], zz_pg_txt[1], 24, c_white, fa_center);

// ── 关闭（右上角，跟商城 obj_closeshop_btn 同一精灵、同一位置、同一悬停帧）──
var _chov = point_in_rectangle(mouse_x, mouse_y,
	zz_close[0] - zz_close_hit, zz_close[1] - zz_close_hit,
	zz_close[0] + zz_close_hit, zz_close[1] + zz_close_hit);
draw_sprite_ext(spr_closemenu_btn, _chov ? 1 : 0, zz_close[0], zz_close[1], 1.8, 1.8, 0, c_white, 1);

draw_set_colour(c_white);
draw_set_alpha(1);
