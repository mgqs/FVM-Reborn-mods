/// 金马盛典 · 幸运星兑换商店
/// ─────────────────────────────────────────────────────────────────────────
/// 版式**整份照抄工程里的「商城」obj_shop_bg**，全部用现成精灵，一行手绘都没有：
///   spr_shop_bg        1880×1084  面板（缎带「商城」/ 内面板 / 底部余额条 / 页码凹槽全烘焙在图里）
///   spr_shop_bg_2       918×383   网格底衬（深蓝），(面板中心, y+58)、1.8 倍
///   spr_shop_goods_bg   226×89    商品卡：4 列 × 4 行 = 16 格**固定绘制**（没商品的格子也画）
///   spr_shop_buy_btn     81×23    「购买」按钮（两字烘焙在图里），1.8 倍，格心 +77 / +60
///   spr_shop_page_btn    23×31    翻页箭头，1.8 倍；「下一页」用 image_xscale = -1 翻转（同 obj_shop_page_btn）
///   spr_closemenu_btn    34×34    关闭，1.8 倍，右上角（与 obj_closeshop_btn 同位置）
/// 点「购买」→ obj_zz_buy_confirm（与 obj_shop_buy_confirm 同一个精灵、同一套面板动画）确认后才扣星。
image_speed = 0;
image_alpha = 0;

parent_gui = -1;
zz_guard = 1;                     // 创建当帧不吃点击（这一下属于「兑换商城」按钮）

// ── 底板（与 obj_shop_bg 同：居中、0.9 倍、精灵原点 940,542）──
zz_panel_x = room_width / 2;
zz_panel_y = room_height / 2;
zz_panel_s = 0.9;

/// 底板精灵坐标 → 屏幕坐标
function zz_pan_sx(_sx) { return zz_panel_x + (_sx - 940) * zz_panel_s; }
function zz_pan_sy(_sy) { return zz_panel_y + (_sy - 542) * zz_panel_s; }

// ── 4×4 网格：坐标逐像素照抄 obj_shop_bg 的 x-618+411*col / y-190+165*row ──
zz_per_page = 16;
zz_col_x = [
	zz_panel_x - 618,   // 342
	zz_panel_x - 207,   // 753
	zz_panel_x + 204,   // 1164
	zz_panel_x + 615    // 1575
];
zz_row_y = [
	zz_panel_y - 190,   // 350
	zz_panel_y - 25,    // 515
	zz_panel_y + 140,   // 680
	zz_panel_y + 305    // 845
];

/// @desc 第 _slot 格（0..15，行优先）的中心 [cx, cy]
function zz_slot_center(_slot) {
	return [zz_col_x[_slot mod 4], zz_row_y[_slot div 4]];
}

/// @desc 第 _page 页第 _slot 格对应的商品下标；空格子返回 -1
function zz_slot_item(_page, _slot, _list) {
	var _idx = (_page - 1) * zz_per_page + _slot;
	if (_idx < 0 || _idx >= array_length(_list)) return -1;
	return _idx;
}

// ── 分页 ──
zz_page     = 1;
zz_max_page = max(1, ceil(array_length(zz_shop_list()) / zz_per_page));

// ── 购买按钮：位置 / 缩放与 obj_shop_buy_btn 完全一致（格心 +77 / +60、1.8 倍、原点居中）──
zz_buy_s  = 1.8;
zz_buy_w  = 81 * zz_buy_s;        // 145.8
zz_buy_h  = 23 * zz_buy_s;        // 41.4
zz_buy_dx = 77;
zz_buy_dy = 60;

/// @desc 购买按钮矩形 [x, y, w, h]（屏幕坐标）
function zz_buy_rect(_cx, _cy) {
	return [_cx + zz_buy_dx - zz_buy_w / 2, _cy + zz_buy_dy - zz_buy_h / 2, zz_buy_w, zz_buy_h];
}

// ── 翻页按钮 / 页码：与 obj_shop_page_btn、页码文字同一位置（面板中心 +285 / +485 / +387）──
zz_pg_s    = 1.8;
zz_pg_prev = [zz_panel_x + 285, zz_panel_y + 435];
zz_pg_next = [zz_panel_x + 485, zz_panel_y + 435];
zz_pg_txt  = [zz_panel_x + 387, zz_panel_y + 435];

/// @desc 鼠标是否在某个翻页按钮上（23×31 压 1.8 → 41×56，留点余量）
function zz_pg_hit(_p) {
	return point_in_rectangle(mouse_x, mouse_y, _p[0] - 24, _p[1] - 32, _p[0] + 24, _p[1] + 32);
}

// ── 关闭（与 obj_closeshop_btn 同：面板中心 +800 / -430）──
zz_close     = [zz_panel_x + 800, zz_panel_y - 430];
zz_close_hit = 34;                // 34×1.8 = 61 → 判定半径 30.6，用 34 留点余量

// ── 底部余额条（底板上烘焙的是「余额：金币 ▢ G」，整条盖掉换幸运星）──
zz_bal = [zz_pan_sx(0), zz_pan_sy(998), zz_pan_sx(450), zz_pan_sy(1054)];

// ── 配色 ──
zz_c_bar  = make_color_rgb(3, 43, 80);         // 底条深蓝（与 spr_shop_bg 里那条完全同色）
zz_c_gold = make_color_rgb(255, 232, 140);
zz_c_qty  = make_color_rgb(140, 78, 20);       // 名称牌右侧「×N」的棕字

/// @desc 以屏幕坐标绘制材料图标（_gsz = 屏幕像素直径）
function zz_icon_screen(_id, _gx, _gy, _gsz) {
	if (_id == "gold") {
		draw_sprite_ext(spr_zz_coin, 0, _gx - _gsz / 2, _gy - _gsz / 2,
			_gsz / sprite_get_width(spr_zz_coin), _gsz / sprite_get_height(spr_zz_coin),
			0, c_white, 1);
		return;
	}
	var _s = _gsz / 88;
	draw_sprite_ext(spr_craft_material, zz_mat_frame(_id), _gx, _gy, _s, _s, 0, c_white, 1);
}

/// @desc 幸运星图标（spr_craft_material 第 23 帧）
function zz_star_icon(_cx, _cy, _sz) {
	var _s = _sz / 88;
	draw_sprite_ext(spr_craft_material, zz_mat_frame("zz_star"), _cx, _cy, _s, _s, 0, c_white, 1);
}

/// @desc 文字（_size = 屏幕字号，font_yuan 基准 16）
function zz_stxt(_txt, _x, _y, _size, _col, _ha) {
	draw_set_font(font_yuan);
	draw_set_halign(_ha);
	draw_set_valign(fa_middle);
	draw_set_colour(_col);
	var _s = _size / 16;
	draw_text_transformed(_x, _y, _txt, _s, _s, 0);
	draw_set_colour(c_white);
}
