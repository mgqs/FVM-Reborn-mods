/// 金马盛典 · 转转主界面
/// 布局基准：预览稿 output/zz_preview/index.html（1080×720），
/// 房间 1920×1080 → 统一换算 gx = 150 + px*1.5 / gy = py*1.5。
/// 改版式只动下面的常量与各 Draw 里的 px 值，别在别处硬编码。
image_speed = 0;
image_alpha = 0;          // 本对象不画自身精灵，全部手绘

zz_k  = 1.5;
zz_ox = 150;
zz_oy = 0;

zz_state = 0;             // 0 主界面 / 1 抽奖跑灯 / 2 结果弹窗
zz_light = -1;            // 当前点亮格
zz_light_t = 0;
zz_light_delay = 2;
zz_light_left = 0;
zz_spin_t = 0;            // 跑灯已进行帧数（用于「点击跳过」的最小延迟）

/// 机台整块相对预览稿的垂直微调（-22 预览单位 = -33 屏幕像素）
/// 只有机台、格子、宝物区、三档按钮、侧栏、关闭按钮吃这个偏移；
/// 标题 / 钱包 / 底部说明留在原位。改这里必须同步 Step_0 的命中判定。
zz_ui_dy = -22;
zz_items = [];
zz_result_cost = 0;
zz_result_count = 0;
zz_msg = "";
zz_msg_t = 0;

zz_save_init();

// ── 18 格布局：7 / 2 / 2 / 7 ──
zz_grid = [];
for (var _c = 0; _c < 7; _c++) array_push(zz_grid, {c:_c, r:0});
array_push(zz_grid, {c:0, r:1});
array_push(zz_grid, {c:6, r:1});
array_push(zz_grid, {c:0, r:2});
array_push(zz_grid, {c:6, r:2});
for (var _c2 = 0; _c2 < 7; _c2++) array_push(zz_grid, {c:_c2, r:3});

// 格子展示内容（纯展示，不参与抽奖判定）
zz_cell_ids = ["clover_1","clover_2","clover_3","clover_4","clover_5","clover_6",
               "clover_s","clover_ss","zz_star","gold","clover_5","clover_1",
               "clover_3","clover_4","clover_6","clover_2","clover_s","gold"];
zz_cell_spr = [spr_zz_cell_pink, spr_zz_cell_green, spr_zz_cell_blue,
               spr_zz_cell_orange, spr_zz_cell_purple, spr_zz_cell_red];

// 宝物展示区的 4 个示例图标
zz_showcase = ["clover_5","clover_6","clover_s","clover_ss"];

// ── 坐标换算 ──
function zzpx(_p) { return zz_ox + _p * zz_k; }
function zzpy(_p) { return zz_oy + _p * zz_k; }
function zzsz(_p) { return _p * zz_k; }

/// 按「预览稿矩形」绘制精灵（精灵原点为左上角）
function zz_draw(_spr, _px, _py, _pw, _ph, _a) {
	draw_sprite_ext(_spr, 0, zzpx(_px), zzpy(_py),
		zzsz(_pw) / sprite_get_width(_spr),
		zzsz(_ph) / sprite_get_height(_spr), 0, c_white, _a);
}

/// 命中测试（同一套预览稿坐标）
function zz_hit(_px, _py, _pw, _ph) {
	return point_in_rectangle(mouse_x, mouse_y,
		zzpx(_px), zzpy(_py), zzpx(_px + _pw), zzpy(_py + _ph));
}

/// 以中心点绘制道具图标（游戏坐标 + 游戏像素尺寸）
function zz_icon_g(_id, _gx, _gy, _gsz) {
	if (_id == "gold") {
		draw_sprite_ext(spr_zz_coin, 0, _gx - _gsz / 2, _gy - _gsz / 2,
			_gsz / sprite_get_width(spr_zz_coin), _gsz / sprite_get_height(spr_zz_coin), 0, c_white, 1);
		return;
	}
	var _s = _gsz / 88;   // spr_craft_material 88×88，原点在中心
	draw_sprite_ext(spr_craft_material, zz_mat_frame(_id), _gx, _gy, _s, _s, 0, c_white, 1);
}

/// 以中心点绘制道具图标（预览稿坐标）
function zz_icon(_id, _pcx, _pcy, _psize) {
	zz_icon_g(_id, zzpx(_pcx), zzpy(_pcy), zzsz(_psize));
}

/// 钱包条目：文字右对齐到 _right_px，图标按文字宽度自动顶在左侧（不会压字）
function zz_wallet(_id, _txt, _right_px, _pcy, _size, _col) {
	draw_set_font(font_yuan);
	var _sc = (_size / 16) * zz_k;
	var _tw = string_width(_txt) * _sc;
	var _rx = zzpx(_right_px);
	zz_icon_g(_id, _rx - _tw - zzsz(_size) * 0.65, zzpy(_pcy), zzsz(_size));
	draw_set_halign(fa_right);
	draw_set_valign(fa_middle);
	draw_set_colour(_col);
	draw_text_transformed(_rx, zzpy(_pcy), _txt, _sc, _sc, 0);
	draw_set_colour(c_white);
}

/// 文字：_size 为预览稿字号（font_yuan 基准 16）
function zz_text(_txt, _px, _py, _size, _col, _ha) {
	draw_set_font(font_yuan);
	draw_set_halign(_ha);
	draw_set_valign(fa_middle);
	draw_set_colour(_col);
	var _s = (_size / 16) * zz_k;
	draw_text_transformed(zzpx(_px), zzpy(_py), _txt, _s, _s, 0);
	draw_set_colour(c_white);
}

/// 带描边的文字（奖励数量用：小字号压在浅色底格上也要看清）
function zz_text_o(_txt, _px, _py, _size, _col, _ocol, _ha) {
	draw_set_font(font_yuan);
	draw_set_halign(_ha);
	draw_set_valign(fa_middle);
	var _s  = (_size / 16) * zz_k;
	var _gx = zzpx(_px);
	var _gy = zzpy(_py);
	var _d  = max(1, _s * 0.9);
	draw_set_colour(_ocol);
	draw_text_transformed(_gx - _d, _gy, _txt, _s, _s, 0);
	draw_text_transformed(_gx + _d, _gy, _txt, _s, _s, 0);
	draw_text_transformed(_gx, _gy - _d, _txt, _s, _s, 0);
	draw_text_transformed(_gx, _gy + _d, _txt, _s, _s, 0);
	draw_set_colour(_col);
	draw_text_transformed(_gx, _gy, _txt, _s, _s, 0);
	draw_set_colour(c_white);
}

/// 开始一次抽奖（扣费 + 生成结果 + 跑灯）
function zz_start_pull(_tier) {
	var _res = zz_pull_batch(_tier);
	if (!_res.ok) {
		zz_msg = _res.msg;
		zz_msg_t = 90;
		return false;
	}
	zz_items = _res.items;
	zz_result_cost = _res.cost;
	zz_result_count = _res.count;
	zz_state = 1;
	zz_light = 0;
	zz_light_t = 0;
	zz_light_delay = 2;
	zz_light_left = 36 + 12 + irandom(17);
	zz_spin_t = 0;
	return true;
}

/// 结果列表（>10 抽按品类合并）
function zz_result_list() {
	if (zz_result_count > 10) return zz_aggregate(zz_items);
	return zz_items;
}
