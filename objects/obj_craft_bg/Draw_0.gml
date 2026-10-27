panel_anim_step(id)
if (!instance_exists(id)) { exit }
draw_set_alpha(0.5 * ui_anim_alpha(id));
// 绘制半透明遮罩
draw_rectangle_color(0, 0, room_width, room_height, c_black, c_black, c_black, c_black, false);
draw_set_alpha(1);
// 基底（外框 + 面板底色）：固定不动、不参与滑动，所以画在 surface 之前（在遮罩之上、三层之下）
draw_sprite_ext(spr_craft_bg_base, 0, x, y, image_xscale, image_yscale, 0, c_white, image_alpha * ui_anim_alpha(id))
panel_anim_begin(id)
// 背景拆成三层（外框在基底里，收尾时另外画，不参与滑动）
draw_sprite_ext(spr_craft_bg_left,  0, x, y, image_xscale, image_yscale, 0, c_white, image_alpha)
draw_sprite_ext(spr_craft_bg_right, 0, x, y, image_xscale, image_yscale, 0, c_white, image_alpha)
draw_sprite_ext(spr_craft_bg_bar,   0, x, y, image_xscale, image_yscale, 0, c_white, image_alpha)

// 顶部页签：卡片宝石 / 神级进化 / 食灵融合（精灵 2 帧：0 = 亮（选中）/ 1 = 暗）
draw_sprite_ext(spr_craft_tab_cardgem, craft_top_tab == 0 ? 0 : 1, tab_cardgem_x, tab_cardgem_y, craft_tab_scale, craft_tab_scale, 0, c_white, 1)
draw_sprite_ext(spr_craft_tab_evo,     craft_top_tab == 3 ? 0 : 1, tab_evo_x,     tab_evo_y,     craft_tab_scale, craft_tab_scale, 0, c_white, 1)
draw_sprite_ext(spr_craft_tab_fusion,  craft_top_tab == 1 ? 0 : 1, tab_fusion_x,  tab_fusion_y,  craft_tab_scale, craft_tab_scale, 0, c_white, 1)

// ── 神级进化页（craft_top_tab == 3，2026-10-26）──
if (craft_top_tab == 3) {
	if (evo_list_dirty) evo_rebuild();
	// 列表滚动平滑（跟转职页 / 强化页一个手感）
	if (ui_anim_on(1)) {
		evo_scroll += (evo_scroll_target - evo_scroll) * 0.28;
		if (abs(evo_scroll_target - evo_scroll) < 0.5) evo_scroll = evo_scroll_target;
	} else {
		evo_scroll = evo_scroll_target;
	}
	var _chk_e = evo_check();

	// ① 左侧「金卡进化」竖排按钮（神级进化页目前只有这一个子页）
	draw_sprite_ext(spr_evo_left_on, 0, evo_left_x, evo_left_y, 1.8, 1.8, 0, c_white, 1);

	// ② 三个槽：星座卡 / 普通卡 / 进化凭证（空槽用官方「二转·星座卡 / 二转·普通卡 / 进化·凭证」文字）
	for (var _i = 0; _i < 3; _i++) {
		var _cx = evo_slot_x[_i];
		var _cy = evo_slot_y;
		if (_i < 2) {
			draw_sprite_ext(spr_evo_slot_card, 0, _cx, _cy, 1.8, 1.8, 0, c_white, 1);
			var _cid = evo_cards[_i];
			if (_cid != "") {
				if (variable_struct_exists(evo_meta, _cid)) {
					var _m = evo_meta[$ _cid];
					// 用户口径（2026-10-27）：只有「未拥有」才上灰 —— 未达转职不灰，卡照常彩色
					draw_sprite_ext(spr_slot, 0, _cx, _cy - 3, 0.25, 0.25, 0, c_white, 1);
					if (_m.sprite != -1) draw_sprite_ext(_m.sprite, 0, _cx, _cy + 15, 0.7, 0.7, 0, c_white, 1);
					if (_m.level > 0) draw_sprite_ext(spr_star_slot, _m.level - 1, _cx - 25, _cy - 35, 0.7, 0.7, 0, c_white, 1);
				}
			} else if (evo_miss[_i] != "") {
				// 缺卡占位（照融合页做法）：画「表要求的那一形态」的卡 + 灰滤镜，不可点
				var _mid   = evo_miss[_i];
				var _mneed = mod_evo_slot_need(evo_target, _i);
				var _md    = deck_get_card_data(_mid, (_mneed >= 0) ? _mneed : 0);
				shader_set(sh_fusion_gray);
				draw_sprite_ext(spr_slot, 0, _cx, _cy - 3, 0.25, 0.25, 0, c_white, 1);
				if (_md != noone && ds_map_exists(_md, "sprite")) {
					draw_sprite_ext(_md[? "sprite"], 0, _cx, _cy + 15, 0.7, 0.7, 0, c_white, 1);
				}
				shader_reset();
			} else {
				var _lab = (_i == 0) ? spr_evo_label_star : spr_evo_label_normal;
				draw_sprite_ext(_lab, 0, _cx, _cy, 1.8, 1.8, 0, c_white, 0.9);
			}
		} else {
			// 进化凭证槽：跟另外两个槽同一条水平线（原来整体 +5 偏下，2026-10-27 修）
			draw_sprite_ext(spr_evo_slot_prop, 0, _cx, _cy, 1.8, 1.8, 0, c_white, 1);
			if (evo_target != "") {
				// 凭证图标 = 金色底板 + 该金卡立绘（绘制细节在 mod/craft 的金卡表里）
				mod_evo_draw_credit(evo_target, _cx, _cy, mod_evo_has_credit(evo_target));
			} else {
				draw_sprite_ext(spr_evo_label_credit, 0, _cx, _cy, 1.8, 1.8, 0, c_white, 0.9);
			}
		}
	}

	// ③ 下箭头
	draw_sprite_ext(spr_evo_arrow, 0, evo_arrow_x, evo_arrow_y, 1.8, 1.8, 0, c_white, 1);

	// ④ 结果槽：有目标 → 直接画能进化成的金卡；没有 → 问号
	draw_sprite_ext(spr_evo_slot_result, 0, evo_res_x, evo_res_y, 1.8, 1.8, 0, c_white, 1);
	if (evo_target != "") {
		// 结果槽也照「卡片强化」页比例：卡底 0.25 / 卡面 0.7
		draw_sprite_ext(spr_slot_1, 0, evo_res_x, evo_res_y - 3, 0.25, 0.25, 0, c_white, 1);
		var _mt = deck_get_card_data(evo_target, 0);
		if (_mt != noone && ds_map_exists(_mt, "sprite")) {
			draw_sprite_ext(_mt[? "sprite"], 0, evo_res_x, evo_res_y + 15, 0.7, 0.7, 0, c_white, 1);
		}
	} else {
		draw_sprite_ext(spr_evo_question, 0, evo_res_x, evo_res_y, 2.2, 2.2, 0, c_white, 1);
	}

	// ⑤ 进化按钮：三态 0 = 常态 / 1 = 悬停 / 2 = 按下（素材 DefineButton2_813）
	//    按钮下方不放任何说明文字（用户明确要求）
	var _bs = 1.8 * ((evo_btn_press > 0) ? 0.96 : 1);
	var _bframe = (evo_btn_press > 0) ? 2 : (point_in_rectangle(mouse_x, mouse_y, evo_btn_x - 73, evo_btn_y - 36, evo_btn_x + 73, evo_btn_y + 36) ? 1 : 0);
	draw_sprite_ext(spr_evo_btn, _bframe, evo_btn_x, evo_btn_y, _bs, _bs, 0, c_white, 1);

	// ⑥ 右列表「防御卡」栏头（2026-10-27 用户：跟融合页一样补一个）
	//    同一张 spr_fusion_panel_title（第 1 帧 = 防御卡），位置口径也照融合页：
	//    横向 = 格子左边缘 + 33*1.8；纵向 = 格子顶边往上 21*1.8（融合页那块同一套数）
	draw_sprite_ext(spr_fusion_panel_title, 1,
		evo_list_x - 44 + 33 * 1.8, evo_list_y - 52 - 21 * 1.8, 1.8, 1.8, 0, c_white, 1);

	// ⑥' 右侧防御卡列表（只列可进化系列里已拥有的卡）
	//    滚动口径跟转职页 / 强化页一致：整行滚、0.28 平滑；卡数不超过 8 行时 evo_rows_max = 0（滚不动）
	var _n = array_length(evo_list);
	var _rows = max(1, ceil(_n / evo_gcols));
	evo_rows_max = max(0, _rows - evo_grows);
	evo_scroll_target = clamp(evo_scroll_target, 0, evo_rows_max);
	evo_hover_card = -1;
	var _off = floor(evo_scroll);
	for (var _r = 0; _r < evo_grows; _r++) {
		for (var _c = 0; _c < evo_gcols; _c++) {
			var _ci = (_r + _off) * evo_gcols + _c;
			var _gx = evo_list_x + _c * evo_gpx;
			var _gy = evo_list_y + _r * evo_gpy;
			draw_sprite_ext(spr_package_slot_bg, 0, _gx, _gy, 0.9, 0.9, 0, c_white, 1);
			if (_ci >= _n) continue;
			var _cid2 = evo_list[_ci];
			if (_cid2 == evo_cards[0] || _cid2 == evo_cards[1]) continue;   // 进槽的原位留空
			var _m3 = evo_meta[$ _cid2];
			if (variable_struct_exists(evo_meta, _cid2)) {
				// 右侧列表不套灰（用户 2026-10-26：变灰只发生在槽位里，列表照常显示）
				draw_sprite_ext(spr_slot, 0, _gx, _gy - 3, 0.25, 0.25, 0, c_white, 1);
				if (_m3.sprite != -1) draw_sprite_ext(_m3.sprite, 0, _gx, _gy + 15, 0.7, 0.7, 0, c_white, 1);
				draw_set_font(font_pixel);
				draw_set_colour(c_black);
				draw_set_halign(fa_center);
				draw_set_valign(fa_bottom);
				draw_text(_gx, _gy + 37, _m3.cost);
				if (_m3.level > 0) draw_sprite_ext(spr_star_slot, _m3.level - 1, _gx - 25, _gy - 35, 0.7, 0.7, 0, c_white, 1);
			}
			if (point_in_rectangle(mouse_x, mouse_y, _gx - 42, _gy - 48, _gx + 42, _gy + 48)) evo_hover_card = _ci;
		}
	}
	if (evo_hover_card != -1) {
		draw_set_font(font_yuan);
		tooltip_set(mouse_x - 15, mouse_y - 15, "点击放入进化槽", -1);
	}

	// ⑦ 余额（金币，与转职页同一位置）
	draw_set_font(font_number);
	draw_set_halign(fa_right);
	draw_set_valign(fa_middle);
	draw_set_colour(c_yellow);
	draw_text(x + 758, y + 473, string(global.save_data.player.gold));

	draw_set_halign(fa_left);
	draw_set_valign(fa_top);
	draw_set_colour(c_white);

	// ⑧ 进化特效（55 帧，逐帧播；素材原点左上角，按画布中心对齐结果槽）
	if (evo_fx) {
		var _ff = clamp(floor(evo_fx_t), 0, evo_fx_frames - 1);
		var _fw = sprite_get_width(spr_evo_fx) * 1.8;
		var _fh = sprite_get_height(spr_evo_fx) * 1.8;
		draw_sprite_ext(spr_evo_fx, _ff, evo_res_x - _fw * 0.5, evo_res_y - _fh * 0.5,
			1.8, 1.8, 0, c_white, 1);
	}

	tooltip_draw();
	panel_anim_end_parts(id, craft_parts, 260);
	exit;
}

// ── 卡片转职页（craft_top_tab == 2，2026-10-25）──
// 几何/状态全来自 Create_0 的 tg_*，这里只管画
if (craft_top_tab == 2) {
	// 列表滚动平滑（跟强化页一个手感）
	if (ui_anim_on(1)) {
		tg_scroll += (tg_scroll_target - tg_scroll) * 0.28;
		if (abs(tg_scroll_target - tg_scroll) < 0.5) tg_scroll = tg_scroll_target;
	} else {
		tg_scroll = tg_scroll_target;
	}
	// 列表 + 卡元数据：**只在变化时重建**（2026-10-26 性能修，原来每帧重建 → 卡成幻灯片）
	if (tg_list_dirty) tg_rebuild();
	var _n = array_length(tg_list);

	var _shape = (tg_card == "") ? 0 : tg_target_shape(tg_card);
	var _tier = (tg_card == "") ? 0 : transfer_credit_tier(tg_card, _shape);   // 普卡 1/2，金卡 3/4/5
	var _full = (tg_card != "" && _shape > transfer_credit_card_shapes_max(tg_card));
	var _chk = tg_check();

	// ① 三个凭证槽：屏幕顺序 左A / 中C / 右B（底板 slot 参数 A=0 / C=2 / B=1）
	//    有凭证 → 亮；没凭证 → sh_fusion_gray 灰（去色，不用 alpha 压暗）；不适用（一转时的中槽、满转、空卡）→ 只画槽名
	//    中槽只有「一转」不显示（一转只有 A/B 两张底板），二转起 / 金卡三转起都是三张
	var _slot_bg = [0, 2, 1];
	var _slot_lab = [spr_transfer_slot_a, spr_transfer_slot_c, spr_transfer_slot_b];
	for (var _i = 0; _i < 3; _i++) {
		var _cx = tg_slot_x[_i];
		draw_sprite_ext(spr_craft_material_bg, 0, _cx, tg_slot_y, 1.8, 1.8, 0, c_white, 1);
		var _use = (tg_card != "") && !_full && !((_tier == 1) && _i == 1);
		if (_use) {
			// 未持有 = 跟融合页「未拥有」**同款灰**（sh_fusion_gray：去色 + 轻压暗）
			// 不要用 alpha 0.45 —— 那等于在深色面板上盖一层黑，八芒星底板会整片看不见（用户 2026-10-25）
			var _has = transfer_credit_has(tg_card, _shape);
			if (!_has) shader_set(sh_fusion_gray);
			transfer_credit_draw(_cx - 37, tg_slot_y - 37, tg_card, _shape, 74, _slot_bg[_i], 1);
			if (!_has) shader_reset();
		} else {
			draw_sprite_ext(_slot_lab[_i], 0, _cx, tg_slot_y, 1.8, 1.8, 0, c_white, 1);
		}
	}

	// ② 主卡槽：空 → 槽底 +「主卡」小字；有卡 → 一整格卡（卡底 0.25 + 卡面 0.7 + 星级 + 造价）
	draw_sprite_ext(spr_craft_slot_bg, 0, tg_main_x + 2, tg_main_y - 3, 1.8, 1.8, 0, c_white, 1);
	if (tg_card == "") {
		draw_sprite_ext(spr_craft_slot_text, 0, tg_main_x + 2, tg_main_y - 3, 1.8, 1.8, 0, c_white, 1);
	} else {
		// 主卡槽那张卡：直接查元数据（不再每帧扫 unlocked_cards + deck_get_card_data）
		var _m = tg_meta_get(tg_card);
		if (!is_undefined(_m)) {
			var _lv = _m.level;
			var _base = _m.is_gold ? spr_slot_1 : spr_slot;
			draw_sprite_ext(_base, 0, tg_main_x, tg_main_y - 3, 0.25, 0.25, 0, c_white, 1);
			if (_m.sprite != -1) draw_sprite_ext(_m.sprite, 0, tg_main_x, tg_main_y + 15, 0.7, 0.7, 0, c_white, 1);
			draw_set_color(c_black);
			draw_set_halign(fa_center);
			draw_set_valign(fa_bottom);
			draw_set_font(font_pixel);
			draw_text(tg_main_x, tg_main_y + 37, _m.cost);
			if (_lv > 0) draw_sprite_ext(spr_star_slot, _lv - 1, tg_main_x - 25, tg_main_y - 35, 0.7, 0.7, 0, c_white, 1);
		}
	}

	// ③ 保险金：徽章 +「金币」+ 价格 + 勾选框（与强化页同一处几何，开关是独立的 tg_assure）
	//    文案口径照强化页：黑字偏 +1/+26 打底、橙色 (255,150,60) 为主色、fa_middle
	var _ac = tg_assure_cost(_tier > 0 ? _tier : 1);
	draw_sprite_ext(spr_craft_insure_badge, 0, assure_badge_cx, assure_badge_cy, 1.5, 1.5, 0, c_white, 1);
	draw_set_font(font_yuan);
	draw_set_halign(fa_center);
	draw_set_valign(fa_middle);
	draw_set_colour(c_black);
	draw_text(assure_badge_cx + 1, assure_badge_cy + 26, "金币");
	draw_set_colour(make_colour_rgb(255, 150, 60));
	draw_text(assure_badge_cx, assure_badge_cy + 25, "金币");
	// 价格：白字 + 四向深色描边（跟强化页保险金同一个口径）
	draw_set_font(font_number);
	draw_set_valign(fa_middle);
	var _atxt = string(_ac);
	draw_set_colour(c_black);
	draw_text(assure_badge_cx - 1, assure_badge_cy + 3, _atxt);
	draw_text(assure_badge_cx + 1, assure_badge_cy + 3, _atxt);
	draw_text(assure_badge_cx - 1, assure_badge_cy + 5, _atxt);
	draw_text(assure_badge_cx + 1, assure_badge_cy + 5, _atxt);
	draw_set_colour(c_yellow);
	draw_text(assure_badge_cx, assure_badge_cy + 4, _atxt);
	draw_sprite_ext(spr_craft_rate_check, tg_assure ? 1 : 0, assure_toggle_x, assure_toggle_y, 1.4, 1.4, 0, c_white, 1);

	// ④ 需金币条（左）＋ 成功率条（右）
	//    需金币数字：**照强化页原样**（`font_number` + `c_yellow` + `fa_left`，落点 (x-460, y+300)）
	//    —— 强化页是 `draw_text(x-460,y+300,string(craft_rule.gold_amount))`，转职页原来画在条右端-61，位置不对
	draw_sprite_ext(spr_craft_gold_require_bg, 0, tg_gold_x, tg_bar_y, 1.8, 1.8, 0, c_white, 1);
	draw_sprite_ext(spr_craft_rate_bar, 0, tg_rate_x, tg_bar_y, 1.8, 1.8, 0, c_white, 1);
	draw_set_font(font_number);
	draw_set_valign(fa_middle);
	draw_set_halign(fa_left);
	draw_set_colour(c_yellow);
	draw_text(x - 460, y + 300, string(_chk.gold));

	// 成功率数字：与强化页同一个口径（四向深色描边，中心 = 条右端 - 61）
	var _rtxt = string(_chk.rate) + "%";
	draw_set_halign(fa_center);
	var _tx2 = tg_rate_x - 61;
	draw_set_colour(c_black);
	draw_text(_tx2 - 1, tg_bar_y - 1, _rtxt);
	draw_text(_tx2 + 1, tg_bar_y - 1, _rtxt);
	draw_text(_tx2 - 1, tg_bar_y + 1, _rtxt);
	draw_text(_tx2 + 1, tg_bar_y + 1, _rtxt);
	draw_set_colour(c_white);
	draw_text(_tx2, tg_bar_y, _rtxt);

	// ⑤ 转职按钮（素材只有一帧：按下缩 0.96 做手感）
	//    不做「不可转就变灰」的暗色滤镜（用户 2026-10-25：看着怪怪的）——
	//    永远按原色画，条件不满足时点它由 tg_do() 弹 reason 提示
	//    按钮下方**不再写「转职成功/失败」飘字**（用户 2026-10-26：结果只走屏幕中上的 show_notice）；
	//    结果只走屏幕中上的 show_notice（2026-10-26 已清掉按钮下的飘字状态）
	var _bsc = 1.8 * ((tg_btn_press > 0) ? 0.96 : 1);
	draw_sprite_ext(spr_transfer_btn, 0, tg_btn_x, tg_btn_y, _bsc, _bsc, 0, c_white, 1);

	// ⑥ 右侧卡列表：跟强化页同一套格子（0.9 倍 / 84×96 / 7 列），直接画、不走 surface
	var _rows = max(1, ceil(_n / tg_gcols));
	tg_rows_max = max(0, _rows - tg_grows);
	tg_scroll_target = clamp(tg_scroll_target, 0, tg_rows_max);
	tg_hover_card = -1;
	var _off = floor(tg_scroll);
	for (var _r = 0; _r < tg_grows; _r++) {
		for (var _c = 0; _c < tg_gcols; _c++) {
			var _ci = (_r + _off) * tg_gcols + _c;
			var _gx = tg_list_x + _c * tg_gpx;
			var _gy = tg_list_y + _r * tg_gpy;
			draw_sprite_ext(spr_package_slot_bg, 0, _gx, _gy, 0.9, 0.9, 0, c_white, 1);
			if (_ci >= _n) continue;
			var _cid = tg_list[_ci];
			// 已放进主卡槽的那张：列表里**原位留空**（用户 2026-10-25：卡进槽后右边那张消失、格子空着）
			// 旧做法是原位画卡 + 盖 35% 黑罩，现在整格不画（只留空槽底）
			if (_cid == tg_card) continue;
			// 格子内容直接查元数据（2026-10-26 性能修：原来每格都扫一遍 unlocked_cards
			// 再 deck_get_card_data（内部线性扫 player_deck），56 格 × 188 张 = 每帧上万次）
			var _m2 = tg_meta_get(_cid);
			if (!is_undefined(_m2)) {
				var _b2 = _m2.is_gold ? spr_slot_1 : spr_slot;
				draw_sprite_ext(_b2, 0, _gx, _gy - 3, 0.25, 0.25, 0, c_white, 1);
				if (_m2.sprite != -1) draw_sprite_ext(_m2.sprite, 0, _gx, _gy + 15, 0.7, 0.7, 0, c_white, 1);
				draw_set_color(c_black);
				draw_set_halign(fa_center);
				draw_set_valign(fa_bottom);
				draw_set_font(font_pixel);
				draw_text(_gx, _gy + 37, _m2.cost);
				if (_m2.level > 0) draw_sprite_ext(spr_star_slot, _m2.level - 1, _gx - 25, _gy - 35, 0.7, 0.7, 0, c_white, 1);
			}
			if (point_in_rectangle(mouse_x, mouse_y, _gx - 42, _gy - 48, _gx + 42, _gy + 48)) tg_hover_card = _ci;
		}
	}
	if (tg_hover_card != -1) {
		draw_set_font(font_yuan);
		tooltip_set(mouse_x - 15, mouse_y - 15, "点击放入转职槽", -1);
	}

	// ⑦ 余额：只画金币（右下角，跟强化页同一位置）
	//    威望不画 —— 用户 2026-10-26：转职界面右下角不需要显示威望
	draw_set_font(font_number);
	draw_set_halign(fa_right);
	draw_set_valign(fa_middle);
	draw_set_colour(c_yellow);
	draw_text(x + 758, y + 473, string(global.save_data.player.gold));

	draw_set_halign(fa_left);
	draw_set_valign(fa_top);
	draw_set_colour(c_white);

	// ── 转职成功特效（2026-10-26）：tg_fx_frames 帧逐帧播，**卡片框包在主卡槽外一圈** ──
	//    对齐原理：素材 287×196 里「卡片框」的中心在 (tg_fx_card_cx, tg_fx_card_cy)，
	//    把这一点钉到 (tg_fx_ox, tg_fx_oy)（主卡槽卡面中心）→ 框就正好套在卡上。
	//    ⚠️ 不要再用「画布中心对齐」—— 素材上方留了放光效的空间，按画布居中会整体偏上（用户 2026-10-26 报的错位）
	if (tg_fx) {
		var _fxfr = clamp(floor(tg_fx_t), 0, tg_fx_frames - 1);
		draw_sprite_ext(spr_transfer_success_fx, _fxfr,
			x + tg_fx_ox - tg_fx_card_cx * tg_fx_scale,
			y + tg_fx_oy - tg_fx_card_cy * tg_fx_scale,
			tg_fx_scale, tg_fx_scale, 0, c_white, 1);
	}

	tooltip_draw();
	panel_anim_end_parts(id, craft_parts, 260);
	// 确认窗画在 panel_anim_end_parts 之后 = 盖在面板最上层（跟融合页同一写法）
	if (tg_confirm) tg_confirm_draw();
	exit;
}


if (craft_top_tab == 1) {
	// ── 食灵融合页：官方整窗底图（928 921x582）+ 左侧场景拉满左区 + 右侧两块卡槽列表 ──
	// 几何全部来自 Create_0 的 fusion_* 实例变量（Draw / Step 共用一套，别各算一份）
	draw_sprite_ext(spr_fusion_window, 0, fusion_wx, fusion_wy, fusion_ws, fusion_ws, 0, c_white, 1);

	// 左侧场景：按左区矩形(928 x14~535 / y64~500)拉满，上下不留白
	draw_sprite_ext(spr_fusion_bg, 0, fusion_lx, fusion_ly, fusion_ssx, fusion_ssy, 0, c_white, 1);
	draw_sprite_ext(spr_craft_fusion_panel, 0, fusion_ppx, fusion_ppy, fusion_ssx, fusion_ssy, 0, c_white, 1);

	// 左侧四档：右移 6 像素贴场景左缘
	var _lv_spr = [spr_fusion_lv_initial, spr_fusion_lv_deep, spr_fusion_lv_soul];
	var _lvx = fusion_lx + 6 * fusion_ssx;
	var _lvs = fusion_ssy;
	for (var _li = 0; _li < 3; _li++){
		draw_sprite_ext(_lv_spr[_li], (fusion_level == _li + 1) ? 0 : 1,
			_lvx, fusion_ly + (100 + _li*55)*_lvs, _lvs, _lvs, 0, c_white, 1);
	}
	draw_sprite_ext(spr_fusion_lv_upgrade, fusion_up_hover ? 0 : 1,
		_lvx, fusion_ly + 265*_lvs, _lvs, _lvs, 0, c_white, 1);

	var _lvcfg = fusion_levels[fusion_level - 1];
	var _shape = _lvcfg.shape;
	var _loaded = (fusion_stage >= 1);            // 主卡/副卡在位
	var _ready = (fusion_stage == 1);             // 菜谱 + 融合剂还在 = 可以开融合
	var _sub_id = "";
	if (_loaded) _sub_id = fusion_sub_card(fusion_loaded_id).id;   // 当前档位的副卡

	// ── 四个槽：空 = 空槽 + 槽内小字（不显示问号）；装了卡 = 空槽 + 卡/图标 ──
	// 融合菜谱(0) / 融合剂(3) 装的是「道具」不是卡 → 用 58x58 方槽；主卡 / 副卡才是竖卡槽
	var _lbl_frame = [0, 1, 2, 3 + (fusion_level - 1)];
	for (var _si = 0; _si < 4; _si++){
		var _is_prop = (_si == 0 || _si == 3);
		var _slx = fusion_ppx + fusion_slot_x[_si] * fusion_ssx;
		var _sly = fusion_ppy + (_is_prop ? fusion_slot_prop_y : fusion_slot_y) * fusion_ssy;
		var _slot_spr = _is_prop ? spr_fusion_slot_prop : spr_fusion_slot_card;
		var _filled = false;
		if (_si == 1) _filled = _ready;
		else if (_si == 2) _filled = (_ready && _sub_id != "");
		else _filled = _ready;                     // 菜谱 / 融合剂：成功融合后就消耗掉了
		// 槽底一律用「无问号」帧（帧1），空槽只显示槽内小字，不显示问号
		var _frame = 1;
		draw_sprite_ext(_slot_spr, _frame, _slx, _sly, fusion_ssx, fusion_ssy, 0, c_white, 1);

		// 槽内小字（融合菜谱 / 主卡 / 融合副卡 / xx融合剂）
		// 44x40 画布里的字形不在正中（偏右 3~5.5px、偏下 1px），按字形包围盒中心兜回来
		if (!_filled){
			var _lsc = 0.95 * fusion_ssx;
			var _lf = _lbl_frame[_si];
			draw_sprite_ext(spr_fusion_slot_label, _lf,
				_slx + fusion_slot_inner*fusion_ssx - fusion_lbl_cx[_lf]*_lsc,
				_sly + (_is_prop ? fusion_slot_inner : fusion_card_inner)*fusion_ssy - fusion_lbl_cy*_lsc,
				_lsc, _lsc, 0, c_white, 1);
		}

		// 槽内内容
		if (_filled){
			var _box = 46 * fusion_ssx;
			var _icon_spr = -1, _icon_sub = 0, _base_cd = noone;
			var _faded = false;      // true = 没练到「食谱要求的那一形态」→ 卡底 + 卡面一起套灰（只是提示，不阻止融合）
			if (_si == 0){                                  // 菜谱：凭证图标
				var _rs = fusion_recipe_spr(fusion_loaded_id, _shape);
				_icon_spr = _rs[0]; _icon_sub = _rs[1];
			}
			else if (_si == 1){                             // 主卡：画「食谱要求的那一形态」（need 由食谱决定，0 = 本体）
				var _mainq = fusion_main_req();
				if (_mainq.id != ""){
					var _cd = deck_get_card_data(_mainq.id, _mainq.need);
					if (_cd != noone){ _icon_spr = _cd[? "sprite"]; _base_cd = _cd; }
					_faded = (fusion_owned_max_shape(_mainq.id) < _mainq.need);
				}
			}
			else if (_si == 2){                             // 副卡：同一口径（need 从副卡表来，不再写死二转）
				var _subq = fusion_sub_card(fusion_loaded_id);
				if (_subq.id != ""){
					var _scd = deck_get_card_data(_subq.id, _subq.need);
					if (_scd != noone){ _icon_spr = _scd[? "sprite"]; _base_cd = _scd; }
					_faded = (fusion_owned_max_shape(_subq.id) < _subq.need);
				}
			}
			else{                                           // 融合剂
				_icon_spr = spr_craft_material;
				_icon_sub = get_material_info(_lvcfg.mat).icon;
			}
			if (_icon_spr != -1){
				var _scx = _slx + fusion_slot_inner*fusion_ssx;
				var _scy = _sly + (_is_prop ? fusion_slot_inner : fusion_card_inner)*fusion_ssy;
				if (_base_cd != noone){
					// 卡槽：**跟「卡片强化」页 / 右边防御卡列表完全同一套画法**
					//   卡底 0.25 + 卡面 0.7 + 星级 0.7(-25,-35) + 造价 font_pixel(+37)
					//   不再按最长边归一化（那会把 41x76 的卡撑到跟 107x97 一样大，才看着「大小不一」）
					var _card_id = (_si == 1) ? fusion_main_card_id() : _sub_id;
					fusion_card_block(_base_cd, _icon_spr, _icon_sub, _card_id, _scx, _scy + 3, _faded);
				}
				else{
					// 道具槽（融合菜谱 / 融合剂）：图标按最大边缩到 box（第 4 槽缩到 40，给底下「当前/需求」让位）
					var _icon_box = (_si == 3) ? fusion_mat_icon * fusion_ssx : _box;
					fusion_draw_center(_icon_spr, _icon_sub, _scx, _scy, _icon_box, _faded);
				}
			}
		}
	}

	// ── 结果槽：同款空槽底 + 产物卡（融合完成后出现，停一会就飞进防御卡格）──
	var _rcx = fusion_ppx + fusion_res_x*fusion_ssx;
	var _rcy = fusion_ppy + fusion_res_y*fusion_ssy;
	fusion_draw_center_slot(_rcx, _rcy);
	var _rcd = (fusion_stage == 2) ? deck_get_card_data(fusion_loaded_id, _shape) : noone;
	var _rbase = spr_slot;
	if (_rcd != noone) _rbase = is_fusion_card(fusion_loaded_id) ? spr_slot_2 : ((ds_map_exists(_rcd, "is_gold") && _rcd[? "is_gold"] == 1) ? spr_slot_1 : spr_slot);
	if (_rcd != noone && !fusion_result_out && fusion_phase != 1){
		// 跟另外几个槽同一格画法（卡底 0.25 + 卡面 0.7 + 造价 + 星级）
		fusion_card_block(_rcd, _rcd[? "sprite"], 0, fusion_loaded_id, _rcx, _rcy + 3, false);
	}
	// 飞卡：结果槽 → 防御卡格。飞到 24 帧落地后**就停在那格**（跟列表里其它卡一样画），
	// 直到列表刷新（选新菜谱 / 卸载 / 切档 / 切页签）才消失 —— 不是飞完就没了
	if (_rcd != noone && fusion_result_out){
		// 落点 = 结果卡在「防御卡」列表里那一格；列表里没有（初级档：融合卡不进列表）→ 落到第一个空位
		var _flist = fusion_card_list(fusion_level);
		var _fidx = -1;
		for (var _fi2 = 0; _fi2 < array_length(_flist); _fi2++){
			if (_flist[_fi2].id == fusion_loaded_id){ _fidx = _fi2; break; }
		}
		if (_fidx < 0) _fidx = array_length(_flist);
		var _ftx = fusion_g2x + (_fidx mod fusion_gcols)*fusion_gpx;
		var _fty = fusion_g2y + (_fidx div fusion_gcols - floor(fusion_card_scroll))*fusion_gpy;
		if (fusion_fly_t < 24){
			// 飞行中：位移 + 缩小（不淡出 —— 落地要无缝接上完整卡格，淡出会闪）
			var _fp = clamp(fusion_fly_t / 24, 0, 1);
			_fp = _fp * _fp * (3 - 2*_fp);
			var _fx = lerp(_rcx, _ftx, _fp);
			var _fy = lerp(_rcy, _fty, _fp);
			var _fb = lerp(358 * fusion_card_base_s, 32 * fusion_ssy, _fp);
			fusion_draw_center(_rbase, 0, _fx, _fy, _fb);
			fusion_draw_center(_rcd[? "sprite"], 0, _fx, _fy - 3*_fp*fusion_ssy, _fb*0.76);
		}
		else if (_fidx >= array_length(_flist)){
			// 落地：列表里本来没有这张卡（初级档）→ 补画一格，跟列表其它卡完全同款；
			// 深度 / 灵魂档它已经由列表自己画了，这里不重复（否则造价数字会被叠画两遍）
			fusion_card_block(_rcd, _rcd[? "sprite"], 0, fusion_loaded_id, _ftx, _fty, false);
		}
	}

	// ── 演出：三档各自的官方融合特效（25 帧铺在 62 帧的演出时长上）──
	if (fusion_phase == 1) {
		var _fxspr = fusion_fx_sprites[fusion_level - 1];
		// 速度：fusion_fx_speed = 0.5 时，25 帧铺到 t=0~100（原来 t=0~50）；_ft 是折算回「原速」的 tick
		var _ft   = fusion_t * fusion_fx_speed;
		var _fxfr = clamp(floor(_ft * fusion_fx_frames / 51), 0, fusion_fx_frames - 1);
		// 落位：整张特效画布当成「四格面板的覆盖层」—— 水平居中（面板 528 宽）、顶部对齐面板上沿。
		// 实测这样才对：闪电正好罩住四槽、爆点落在结果槽上（按「画布中心对结果槽」放会整体掉到成功率条下面）
		var _fxx = fusion_ppx + (528 - sprite_get_width(_fxspr)) * 0.5 * fusion_ssx;
		var _fxy = fusion_ppy;
		draw_sprite_ext(_fxspr, _fxfr, _fxx, _fxy, fusion_ssx, fusion_ssy, 0, c_white, 1);
		if (_ft >= 50) {
			draw_set_alpha((_ft - 50) / 10 * 0.75);
			draw_set_colour(c_white);
			draw_rectangle(fusion_lx, fusion_ly, fusion_lx + fusion_lw, fusion_ly + fusion_lh, false);
			draw_set_alpha(1);
		}
	}

	// ── 成功率条：装了 = 100%（整条绿），没装 = 把绿条盖成空槽色 + 0% ──
	// 没有真成功率：装了食谱就是 100%、没装就是 0%，只是「文字 + 盖条」两态切换
	var _bar_x0 = fusion_ppx + fusion_bar_l * fusion_ssx;
	var _bar_x1 = fusion_ppx + fusion_bar_r * fusion_ssx;
	var _bar_y  = fusion_ppy + fusion_bar_y * fusion_ssy;
	if (!_ready){
		draw_set_alpha(0.92);
		draw_set_colour(make_colour_rgb(24, 20, 38));
		draw_rectangle(_bar_x0, _bar_y - 8*fusion_ssy, _bar_x1, _bar_y + 8*fusion_ssy, false);
		draw_set_alpha(1);
	}
	draw_set_font(font_number);
	draw_set_halign(fa_center);
	draw_set_valign(fa_middle);
	var _rate_txt = _ready ? "100%" : "0%";
	draw_set_colour(c_black);
	draw_text_transformed(_bar_x0 + (_bar_x1-_bar_x0)/2 + 1, _bar_y + 1, _rate_txt, 1.4, 1.4, 0);
	draw_set_colour(c_white);
	draw_text_transformed(_bar_x0 + (_bar_x1-_bar_x0)/2, _bar_y, _rate_txt, 1.4, 1.4, 0);

	// ── 需金币 ──
	if (fusion_stage >= 1){
		var _gold_txt = string(_lvcfg.gold);
		draw_set_colour(c_black);
		draw_text_transformed(fusion_ppx + fusion_gold_cx*fusion_ssx + 1, fusion_ppy + fusion_gold_y*fusion_ssy + 1, _gold_txt, 1.4, 1.4, 0);
		draw_set_colour(make_colour_rgb(255, 242, 180));
		draw_text_transformed(fusion_ppx + fusion_gold_cx*fusion_ssx, fusion_ppy + fusion_gold_y*fusion_ssy, _gold_txt, 1.4, 1.4, 0);
	}

	// ── 融合按钮：前置统一走 fusion_check()（缺食谱 / 缺卡 / 金币 / 融合剂，Step_0 用同一份给提示词）──
	var _can_fuse = fusion_check().ok;
	draw_sprite_ext(spr_fusion_fuse_btn, _can_fuse ? 0 : 1,
		fusion_ppx + fusion_btn_x*fusion_ssx, fusion_ppy + fusion_btn_y*fusion_ssy,
		fusion_ssx, fusion_ssy, 0, c_white, (_can_fuse && fusion_phase != 1) ? 1 : 0.85);

	// ── 右侧两块：官方标题字 + 跟「卡片强化」页同一套卡槽格（0.9 倍 / 7 列 / 间距 84x96）──
	draw_sprite_ext(spr_fusion_panel_title, 0, fusion_wx + 600*fusion_ws - 33*fusion_ws,
		fusion_wy + 69.5*fusion_ws - 9*fusion_ws, fusion_ws, fusion_ws, 0, c_white, 1);
	draw_sprite_ext(spr_fusion_panel_title, 1, fusion_wx + 600*fusion_ws - 24*fusion_ws,
		fusion_wy + 299*fusion_ws - 9*fusion_ws, fusion_ws, fusion_ws, 0, c_white, 1);

	// 滚动平滑：滚轮在 Mouse_60/61 改 *_scroll_t，上限在 Step_0 算
	if (ui_anim_on(1)){
		fusion_recipe_scroll += (fusion_recipe_scroll_t - fusion_recipe_scroll) * 0.28;
		if (abs(fusion_recipe_scroll_t - fusion_recipe_scroll) < 0.02) fusion_recipe_scroll = fusion_recipe_scroll_t;
		fusion_card_scroll += (fusion_card_scroll_t - fusion_card_scroll) * 0.28;
		if (abs(fusion_card_scroll_t - fusion_card_scroll) < 0.02) fusion_card_scroll = fusion_card_scroll_t;
	}
	else{
		fusion_recipe_scroll = fusion_recipe_scroll_t;
		fusion_card_scroll = fusion_card_scroll_t;
	}

	// ① 融合菜谱：只列「还拥有」的食谱（形态已经到位的不再出现）
	var _rcp_ids = fusion_recipe_list(_shape);
	var _rcp_n = array_length(_rcp_ids);
	fusion_rows_recipe_max = max(0, ceil(_rcp_n / fusion_gcols) - fusion_grows1);
	for (var _r1 = 0; _r1 < fusion_grows1; _r1++){
		for (var _c1 = 0; _c1 < fusion_gcols; _c1++){
			draw_sprite_ext(spr_package_slot_bg, 0, fusion_g1x + _c1*fusion_gpx, fusion_g1y + _r1*fusion_gpy,
				fusion_gcscl, fusion_gcscl, 0, c_white, 1);
		}
	}
	var _r_off = floor(fusion_recipe_scroll);
	for (var _i1 = _r_off*fusion_gcols; _i1 < min(_rcp_n, (_r_off + fusion_grows1)*fusion_gcols); _i1++){
		var _rid1 = _rcp_ids[_i1];
		if (fusion_stage >= 1 && _rid1 == fusion_loaded_id) continue;      // 已进槽 → 原位留空（不往前挪）
		var _rcx1 = fusion_g1x + (_i1 mod fusion_gcols)*fusion_gpx;
		var _rcy1 = fusion_g1y + (_i1 div fusion_gcols - _r_off)*fusion_gpy;
		var _rs2 = fusion_recipe_spr(_rid1, _shape);
		// 凭证图两种尺寸：形态 0 是 44x44（无边框、图案占满，box 70 就跟格子一样满），
		// 形态 1/2 是 70x70 的金框凭证（四周有留白，按 70/82 都显得比初级小）→ 撑满到 88
		var _rbox = (_shape == 0) ? 70 : 88;
		fusion_draw_center(_rs2[0], _rs2[1], _rcx1, _rcy1 - 6, _rbox);
		// 悬停提示：融合菜谱（卡名）/ 主卡：xx（本体·一转·二转，看这道食谱的 need）/ 副卡：同上
		if (point_in_rectangle(mouse_x, mouse_y, _rcx1 - fusion_gpx*0.5, _rcy1 - fusion_gpy*0.5,
				_rcx1 + fusion_gpx*0.5, _rcy1 + fusion_gpy*0.5)){
			// ⚠️ tooltip 会捕获「当前字体」，这里一直是 font_number（无中文字形）→ 必须切 font_yuan 再 set
			draw_set_font(font_yuan);
			tooltip_set(mouse_x - 15, mouse_y - 15, fusion_recipe_tip(_rid1), -1);
			draw_set_font(font_number);
		}
	}

	// ② 防御卡：主卡 + 副卡 + 本档融合卡（每条自带该画的形态；见 fusion_card_list）
	//    顺序固定 = 白卡 → 金卡 → 融合卡（融合卡永远排最后），排序在 fusion_card_list() 里做，这里只管画
	var _card_ids = fusion_card_list(fusion_level);
	var _card_n = array_length(_card_ids);
	fusion_rows_card_max = max(0, ceil(_card_n / fusion_gcols) - fusion_grows2);
	for (var _r2 = 0; _r2 < fusion_grows2; _r2++){
		for (var _c2 = 0; _c2 < fusion_gcols; _c2++){
			draw_sprite_ext(spr_package_slot_bg, 0, fusion_g2x + _c2*fusion_gpx, fusion_g2y + _r2*fusion_gpy,
				fusion_gcscl, fusion_gcscl, 0, c_white, 1);
		}
	}
	var _k_off = floor(fusion_card_scroll);
	draw_set_font(font_pixel);
	draw_set_halign(fa_center);
	draw_set_valign(fa_bottom);
	draw_set_colour(c_black);
	for (var _i2 = _k_off*fusion_gcols; _i2 < min(_card_n, (_k_off + fusion_grows2)*fusion_gcols); _i2++){
		var _kid  = _card_ids[_i2].id;
		var _kshp = _card_ids[_i2].shape;
		// 已进槽的主卡 / 副卡 → 原位留空（不把后面的卡往前挪）
		if (fusion_stage == 1 && (_kid == fusion_main_card_id() || (_sub_id != "" && _kid == _sub_id))) continue;
		var _kcd = deck_get_card_data(_kid, _kshp);
		if (_kcd == noone) continue;
		var _kx2 = fusion_g2x + (_i2 mod fusion_gcols)*fusion_gpx;
		var _ky2 = fusion_g2y + (_i2 div fusion_gcols - _k_off)*fusion_gpy;
		// 卡底：融合卡 spr_slot_2 / 金卡 spr_slot_1 / 普卡 spr_slot（跟强化页一口径）
		var _kbase = is_fusion_card(_kid) ? spr_slot_2
			: ((ds_map_exists(_kcd, "is_gold") && _kcd[? "is_gold"] == 1) ? spr_slot_1 : spr_slot);
		draw_sprite_ext(_kbase, 0, _kx2, _ky2 - 3, 0.25, 0.25, 0, c_white, 1);
		draw_sprite_ext(_kcd[? "sprite"], 0, _kx2, _ky2 + 15, 0.7, 0.7, 0, c_white, 1);
		// 星级：跟强化页同一位置（卡底左上角），没升过级（max_level 0）就不画
		var _kinfo = get_card_info_simple(_kid);
		if (_kinfo != false && _kinfo.max_level > 0){
			var _kfrm = min(_kinfo.max_level, sprite_get_number(spr_star_slot)) - 1;
			draw_sprite_ext(spr_star_slot, _kfrm, _kx2 - 25, _ky2 - 35, 0.7, 0.7, 0, c_white, 1);
		}
		draw_text(_kx2, _ky2 + 37, _kcd[? "cost"]);
	}

	draw_set_colour(c_white);
	draw_set_halign(fa_left);
	draw_set_valign(fa_top);

	// 滚动条（内容放得下 → 半透明铺满整条）
	fusion_sb_draw(fusion_sb1y, fusion_sb1h, fusion_recipe_scroll, fusion_rows_recipe_max, fusion_grows1, false);
	fusion_sb_draw(fusion_sb2y, fusion_sb2h, fusion_card_scroll, fusion_rows_card_max, fusion_grows2, false);

	// ── 底部道具栏（自绘圆角格 + 7 种材料）──
	var _bar_x = fusion_wx + 20*fusion_ws;
	var _tbar_y = fusion_wy + 522*fusion_ws;
	var _bar_w = 504*fusion_ws;
	var _bar_h = fusion_cell_h*fusion_ws;      // 84px @1.8：跟强化页 spr_package_slot_bg 0.9 倍格子等高
	var _bar_pitch = _bar_w / 10;
	var _cell_w = _bar_pitch - 3;
	for (var _bi = 0; _bi < 10; _bi++){
		var _bx1 = _bar_x + _bi * _bar_pitch;
		draw_set_alpha(1);
		draw_set_colour(make_colour_rgb(9, 58, 102));
		draw_roundrect_ext(_bx1, _tbar_y, _bx1 + _cell_w, _tbar_y + _bar_h, 4*fusion_ws, 4*fusion_ws, false);
		draw_set_colour(make_colour_rgb(0, 26, 52));
		draw_roundrect_ext(_bx1, _tbar_y, _bx1 + _cell_w, _tbar_y + _bar_h, 4*fusion_ws, 4*fusion_ws, true);
	}
	// 🔴 spr_craft_material 的原点是「正中心」，不能走 fusion_draw_center（那个按左上角原点减半宽高）
	// 缩放倍率跟强化页底部道具栏一致（那里就是 0.9）；原来按「缩到 32*ws」算，图标比强化页小一圈
	var _ic_scl = 0.9;
	for (var _mj = 0; _mj < array_length(card_material_id_list); _mj++){
		var _mid = card_material_id_list[_mj];
		var _ccx = _bar_x + _mj*_bar_pitch + _cell_w*0.5;
		draw_sprite_ext(spr_craft_material, get_material_info(_mid).icon,
			_ccx, _tbar_y + _bar_h*0.47, _ic_scl, _ic_scl, 0, c_white, 1);
		var _mamt = get_material_amount(_mid);
		var _mamt_txt = (_mamt < 10000) ? string(_mamt) : string(floor(_mamt/10000)) + "w";
		draw_set_font(font_number);
		draw_set_halign(fa_right);
		draw_set_valign(fa_middle);
		draw_set_colour(c_black);
		draw_text_transformed(_ccx + _cell_w*0.5 - 3 + 1, _tbar_y + _bar_h - 9 + 1, _mamt_txt, 1, 1, 0);
		draw_set_colour(c_white);
		draw_text_transformed(_ccx + _cell_w*0.5 - 3, _tbar_y + _bar_h - 9, _mamt_txt, 1, 1, 0);
	}

	// ── 融合剂槽（第 4 槽）内贴底：「当前/需求」
	//    只有「装着」（stage == 1）才画：融合完 stage 变 2、槽已空，数字再留着就会卡在空槽上
	//    ⚠️ 位置必须在画出之前算好：_rt_cx / _rt_cy / _rt_txt 少一个就是「not set before reading」
	if (fusion_stage == 1 && fusion_phase != 1){
		var _rt_cx = fusion_ppx + fusion_slot_x[3]*fusion_ssx + 29*fusion_ssx;
		var _rt_cy = fusion_ppy + fusion_slot_prop_y*fusion_ssy + fusion_need_txt_y*fusion_ssy;
		var _rt_txt = string(get_material_amount(_lvcfg.mat)) + "/" + string(_lvcfg.mat_n);
		draw_set_font(font_number);
		draw_set_halign(fa_center);
		draw_set_valign(fa_middle);
		draw_set_colour(c_black);
		// 四向描边：压在金框 / 图标边上也能看清（比单层 +1 阴影清楚得多）
		draw_text_transformed(_rt_cx - 1, _rt_cy, _rt_txt, 1.05, 1.05, 0);
		draw_text_transformed(_rt_cx + 1, _rt_cy, _rt_txt, 1.05, 1.05, 0);
		draw_text_transformed(_rt_cx, _rt_cy - 1, _rt_txt, 1.05, 1.05, 0);
		draw_text_transformed(_rt_cx, _rt_cy + 1, _rt_txt, 1.05, 1.05, 0);
		draw_set_colour(c_white);
		draw_text_transformed(_rt_cx, _rt_cy, _rt_txt, 1.05, 1.05, 0);
	}
	draw_set_colour(c_white);
	draw_set_halign(fa_left);
	draw_set_valign(fa_top);

	// ── 右下角金币 ──
	draw_set_font(font_number);
	draw_set_halign(fa_right);
	draw_set_valign(fa_middle);
	draw_set_colour(c_white);
	draw_text_transformed(fusion_wx + 867*fusion_ws, fusion_wy + 554*fusion_ws,
		string(global.save_data.player.gold), 1.1, 1.1, 0);

	draw_set_colour(c_white);
	draw_set_valign(fa_top);
	draw_set_halign(fa_left);

	// 顶部页签：补在最上层，免得被整窗底图挡掉（0 = 亮 / 1 = 暗）
	draw_sprite_ext(spr_craft_tab_cardgem, 1, tab_cardgem_x, tab_cardgem_y, craft_tab_scale, craft_tab_scale, 0, c_white, 1);
	draw_sprite_ext(spr_craft_tab_evo,     1, tab_evo_x,     tab_evo_y,     craft_tab_scale, craft_tab_scale, 0, c_white, 1);
	draw_sprite_ext(spr_craft_tab_fusion, 0, tab_fusion_x, tab_fusion_y, craft_tab_scale, craft_tab_scale, 0, c_white, 1);

	if (!fusion_confirm) tooltip_draw();
	panel_anim_end_parts(id, craft_parts, 260);
	// 确认弹窗画在面板贴回之后 → 盖在整页最上层（surface 录制期间画会被裁进面板）
	if (fusion_confirm) fusion_confirm_draw();
	exit;
}



// 强化选项固定显示在合成面板顶部，不随卡片列表滚动。
var _rate_settings = craft_rate_settings()
var _rate_on = _rate_settings.enabled
var _toggle_frame = _rate_on ? 1 : 0
draw_sprite_ext(spr_craft_rate_check, _toggle_frame, rate_toggle_x, rate_toggle_y, 1.4, 1.4, 0, c_white, 1)
if (rate_toggle_hover) {
    draw_set_alpha(0.25)
    draw_rectangle(rate_toggle_x - 18, rate_toggle_y - 18, rate_toggle_x + 18, rate_toggle_y + 18, false)
    draw_set_alpha(1)
}
draw_set_font(font_yuan)
draw_set_valign(fa_middle)
draw_set_halign(fa_left)
var _rate_color = _rate_on ? make_colour_rgb(35, 165, 55) : make_colour_rgb(205, 40, 30)
draw_set_colour(c_black)
draw_text(rate_toggle_x + 25, rate_toggle_y + 1, "概率强化")
draw_set_colour(_rate_color)
draw_text(rate_toggle_x + 26, rate_toggle_y, "概率强化")

draw_set_colour(c_white)
draw_set_valign(fa_top)
draw_set_halign(fa_left)

if (button_select == 0) {
    var _assure_off = !_rate_on
    if (_assure_off) draw_set_alpha(0.45)
    var _assure_frame = _rate_settings.assure_enabled ? 1 : 0
    draw_sprite_ext(spr_craft_insure_badge, 0, assure_badge_cx, assure_badge_cy, 1.5, 1.5, 0, c_white, 1)
    if (assure_toggle_hover && !_assure_off) {
        draw_set_alpha(0.25)
        draw_rectangle(assure_badge_cx - 33, assure_badge_cy - 36, assure_badge_cx + 33, assure_toggle_y + 18, false)
        draw_set_alpha(1)
    }
    draw_set_font(font_yuan)
    draw_set_valign(fa_middle)
    draw_set_halign(fa_center)
    draw_set_colour(c_black)
    draw_text(assure_badge_cx + 1, assure_badge_cy + 26, "金币")
    draw_set_colour(make_colour_rgb(255, 150, 60))
    draw_text(assure_badge_cx, assure_badge_cy + 25, "金币")
    draw_set_colour(c_white)
    draw_set_valign(fa_top)
    draw_set_halign(fa_left)
    draw_sprite_ext(spr_craft_rate_check, _assure_frame, assure_toggle_x, assure_toggle_y, 1.4, 1.4, 0, c_white, 1)
    if (_assure_off) draw_set_alpha(1)
}

// 需金币（左）与成功率（右）同一排：两条都用 spr_craft_gold_require_bg 贴图（原点在右端）
draw_sprite_ext(spr_craft_gold_require_bg,0,x-350,y+300,1.8,1.8,0,c_white,1)

// 成功率栏（右条）：框 = spr_craft_gold_require_bg 换过来画 + 空白段盖掉自带"需金币:"
// 标签用 spr_craft_rate_label（条内左侧，与隔壁金币条自带的"需金币:"排法一致），数值仍用字体
var _rr_bar_x = x - 45
var _rr_bar_y = y + 300
var _rr_bar_left = _rr_bar_x - 230.4      // 条子左缘（128*1.8，原点在右端）
var _rr_bar_ix = _rr_bar_left + 3.6       // 框内区左缘（2 像素 * 1.8）
var _rr_bar_iy = _rr_bar_y - 18           // 框内区上缘（整条高 20*1.8）
var _rr_set = craft_rate_settings()
var _rr_base = 100
var _rr_streak = 0
var _rr_bonus = 0
var _rr_text = "100%"
if _rr_set.enabled{
	_rr_text = "0%"
	if current_uprade_target_id != ""{
		if button_select == 0{
			var _rr_card = get_card_info_simple(current_uprade_target_id)
			if _rr_card != false{
				_rr_base = get_card_craft_rate_base(current_uprade_target_id, _rr_card.max_level+1)
				_rr_streak = get_card_fail_streak(current_uprade_target_id)
				_rr_bonus = get_card_craft_bonus(current_uprade_target_id)
			}
		}
		else{
			_rr_base = get_gem_craft_rate_base(current_uprade_target_id, get_gem_max_level(current_uprade_target_id)+1)
			_rr_streak = get_gem_fail_streak(current_uprade_target_id)
			_rr_bonus = get_gem_craft_bonus(current_uprade_target_id)
		}
		if _rr_set.pity_guarantee > 0 && _rr_streak >= _rr_set.pity_guarantee{
			_rr_text = "必成"
		}
		else if _rr_bonus > 0{
			_rr_text = string_format(_rr_base,1,2)+"%+"+string_format(_rr_bonus,1,2)+"%"
		}
		else{
			_rr_text = string_format(_rr_base,1,2)+"%"
		}
	}
}
// 成功率条：直接用官方素材 spr_craft_rate_bar（自带「成功率：」+ 右侧空白字段，原点在右端）
draw_sprite_ext(spr_craft_rate_bar, 0, _rr_bar_x, _rr_bar_y, 1.8, 1.8, 0, c_white, 1)
// 2026-10-23 按用户要求去掉绿色进度填充，只留条 + 数字
var _rr_fill_l = _rr_bar_left + 111.6
// 数值：白字 + 四向深色描边
draw_set_font(font_number)
draw_set_valign(fa_middle)
draw_set_halign(fa_center)
var _rr_text_x = _rr_fill_l + 57.6
draw_set_colour(c_black)
draw_text(_rr_text_x-1, _rr_bar_y-1, _rr_text)
draw_text(_rr_text_x+1, _rr_bar_y-1, _rr_text)
draw_text(_rr_text_x-1, _rr_bar_y+1, _rr_text)
draw_text(_rr_text_x+1, _rr_bar_y+1, _rr_text)
draw_set_colour(c_white)
draw_text(_rr_text_x, _rr_bar_y, _rr_text)
draw_set_colour(c_white)
draw_set_valign(fa_top)
draw_set_halign(fa_left)

draw_set_font(font_number)
draw_set_colour(c_yellow)
draw_set_valign(fa_middle)
draw_set_halign(fa_left)
//draw_text(x-160,y+300,"300")
draw_set_halign(fa_right)
draw_text(x+758,y+473,string(global.save_data.player.gold))
draw_set_colour(c_white)
draw_set_valign(fa_top)
draw_set_halign(fa_left)
for(var i = 0 ; i < 10 ; i++){
    draw_sprite_ext(spr_package_slot_bg, 1, x-752+i*84, y + 454, 0.9, 0.9, 0, c_white, 1)
}

if button_select == 0{
	//绘制卡片强化UI背景
	draw_sprite_ext(spr_craft_slot_bg,0,x-305,y+100,1.8,1.8,0,c_white,1)
	draw_sprite_ext(spr_craft_material_bg,0,x-455,y-20,1.8,1.8,0,c_white,1)
	draw_sprite_ext(spr_craft_material_bg,0,x-155,y-20,1.8,1.8,0,c_white,1)
	draw_sprite_ext(spr_craft_slot_text,0,x-305,y+100,1.8,1.8,0,c_white,1)
	draw_sprite_ext(spr_craft_slot_text,1,x-455,y-20,1.8,1.8,0,c_white,1)
	draw_sprite_ext(spr_craft_slot_text,2,x-155,y-20,1.8,1.8,0,c_white,1)
	//绘制卡片强化材料
	for(var i = 0 ; i < array_length(card_material_id_list) ; i++){
		var material_id = card_material_id_list[i]
		var material_info = get_material_info(material_id)
		var material_amount = get_material_amount(material_id)
		draw_sprite_ext(spr_craft_material, material_info.icon, x-752+i*84, y + 454, 0.9, 0.9, 0, c_white, 1)
		draw_set_halign(fa_right);
		draw_set_valign(fa_bottom);
		draw_set_colour(c_white)
		draw_set_font(font_number)
		if get_material_amount(material_id) < 10000{
			draw_text(x-752+i*84+40,y + 454+42,string(get_material_amount(material_id)))
		}
		else{
			draw_text(x-752+i*84+40,y + 454+42,string(floor(get_material_amount(material_id)/10000))+"w")
		}
		
	}
	// 排序：普卡 → 融合卡 → 金卡（类型内保持存档原顺序）。craft_sort_order 是实例变量，
	// Mouse_53 点卡时也要用它把 hover_card_index 换算回 unlocked_cards 的下标
	craft_sort_order = []
	var _craft_fusion_order = []
	var _craft_gold_order = []
	for(var _csi = 0; _csi < array_length(global.save_data.unlocked_cards); _csi++){
		var _sort_card = global.save_data.unlocked_cards[_csi]
		var _sort_slot = deck_get_card_data(_sort_card.id, _sort_card.shape)
		if (_sort_slot != noone && ds_map_find_value(_sort_slot, "is_fusion") == 1){
			array_push(_craft_fusion_order, _csi)
		}
		else if (_sort_slot != noone && ds_map_find_value(_sort_slot, "is_gold") == 1){
			array_push(_craft_gold_order, _csi)
		}
		else{
			array_push(craft_sort_order, _csi)
		}
	}
	for(var _csi = 0; _csi < array_length(_craft_fusion_order); _csi++){
		array_push(craft_sort_order, _craft_fusion_order[_csi])
	}
	for(var _csi = 0; _csi < array_length(_craft_gold_order); _csi++){
		array_push(craft_sort_order, _craft_gold_order[_csi])
	}

	// 行数按卡数动态算（至少 20 行＝原样式），滚动上限同步，避免卡多了滚不到
	var _craft_rows = max(20, ceil(array_length(craft_sort_order) / 7))
	craft_max_y_offset = max(0, 96 * _craft_rows - 815)
	// 卡数变少（或换档）时把滚动夹回上限，避免停在空白区
	y_offset_target = clamp(y_offset_target, 0, craft_max_y_offset)
	y_offset = clamp(y_offset, 0, craft_max_y_offset)
	if (!surface_exists(card_surface)){ card_surface = surface_create(600,815) }   // 保证配对，别 set 到不存在的 surface
	surface_set_target(card_surface)
	//绘制右侧栏位
	for(var i = 0 ; i < 7 ; i++){
        for(var j = 0 ; j < _craft_rows ; j++){
            draw_sprite_ext(spr_package_slot_bg, 0, 42+i*84, 48+96 * j-y_offset, 0.9, 0.9, 0, c_white, 1)
        }
    }
	//绘制所有已解锁防御卡
	var card_index = 0
	hover_card_index = -1
	for(var di = 0 ; di < array_length(craft_sort_order);di++){
		var i = craft_sort_order[di]
		var card_col = card_index mod 7
		var card_row = card_index div 7
		var card_data = global.save_data.unlocked_cards[i]
		var card_id = card_data.id
		var card_slot_data = deck_get_card_data(card_id,card_data.shape)
		var card_x = 42 + card_col*84
		var card_y = 48+96 * card_row - y_offset

		if (card_slot_data != noone) {
			// 卡底：融合卡 spr_slot_2 > 金卡 spr_slot_1 > 普通 spr_slot（与其它列表界面同一口径）
			var _base_spr = is_fusion_card(card_id) ? spr_slot_2 : ((ds_map_find_value(card_slot_data, "is_gold") == 1) ? spr_slot_1 : spr_slot)
			draw_sprite_ext(_base_spr,0,card_x,card_y-3,0.25,0.25,0,c_white,1)
			draw_sprite_ext(card_slot_data[? "sprite"],0,card_x,card_y+15,0.7,0.7,0,c_white,1)
			draw_set_color(c_black);
			draw_set_halign(fa_center);
			draw_set_valign(fa_bottom);
			draw_set_font(font_pixel)
			draw_text(card_x,card_y+37,card_slot_data[? "cost"])
			if card_data.max_level > 0{
				draw_sprite_ext(spr_star_slot,  card_data.max_level - 1,  card_x-25,  card_y-35, 0.7, 0.7, 0, c_white, 1);
			}
		}
		
		// 检查鼠标是否悬停在卡片上
        var spr_width = 84;
        var spr_height = 96;
		
		var hover_card_x = x + 196 + card_col*84
		var hover_card_y = y - 321 + 96 * card_row - y_offset
		
		if mouse_y > y-321-48 && mouse_y < y + 450{
                
	        if (point_in_rectangle(mouse_x, mouse_y, 
	                                hover_card_x - spr_width/2, hover_card_y - spr_height/2,
	                                hover_card_x + spr_width/2, hover_card_y + spr_height/2)) {
	            hover_card_index = card_index;
	        }
		}
		card_index++
	}
	surface_reset_target()
	draw_surface(card_surface,x+196-42,y-321-48)
	
	//绘制悬停提示
	if (hover_card_index != -1) {
        
		draw_set_font(font_yuan);
			tooltip_set(mouse_x - 15, mouse_y - 15, "点击将卡片放入强化槽", -1);
			
            
    }
	//绘制正在强化的卡片
	if current_uprade_target_id != ""{
		var card_data = get_card_info_simple(current_uprade_target_id)
		var card_id = card_data.id
		var card_slot_data = deck_get_card_data(current_uprade_target_id,card_data.shape)
		var card_x = x - 307
		var card_y = y + 103
		
		var _slot_base_spr = is_fusion_card(current_uprade_target_id) ? spr_slot_2 : ((ds_map_find_value(card_slot_data, "is_gold") == 1) ? spr_slot_1 : spr_slot)
		draw_sprite_ext(_slot_base_spr,0,card_x,card_y-3,0.25,0.25,0,c_white,1)
		draw_sprite_ext(card_slot_data[? "sprite"],0,card_x,card_y+15,0.7,0.7,0,c_white,1)
		draw_set_color(c_black);
		draw_set_halign(fa_center);
		draw_set_valign(fa_bottom);
		draw_set_font(font_pixel)
		draw_text(card_x,card_y+37,card_slot_data[? "cost"])
		if card_data.max_level > 0{
			draw_sprite_ext(spr_star_slot,  card_data.max_level - 1,  card_x-25,  card_y-35, 0.7, 0.7, 0, c_white, 1);
		}
		//绘制强化需要的材料
		if card_data.max_level <= 15{
			var spices_list = [0,0,0]
			var clover_list = [0,0,0]
			var craft_rule = get_card_craft_rule(string(card_data.max_level+1))
			draw_set_font(font_number)
			draw_set_colour(c_yellow)
			draw_set_valign(fa_middle)
			draw_set_halign(fa_left)
			draw_text(x-460,y+300,string(craft_rule.gold_amount))
			// 保险金消耗数字（画在徽章中间；不够钱时转红）——只要总开关「概率强化」开着就显示
			// 金额最多 6 位：基准字号放得下 5 位，超过 5 位按位数等比缩小
			if craft_rate_settings().enabled{
				var _assure_cost = craft_assure_gold(card_data.max_level)
				var _amt_txt = string(_assure_cost)
				var _amt_len = string_length(_amt_txt)
				var _amt_sc = 1
				if (_amt_len > 5) _amt_sc = 5 / _amt_len
				draw_set_valign(fa_middle)
				draw_set_halign(fa_center)
				draw_set_colour(c_black)
				draw_text_transformed(assure_badge_cx-1, assure_badge_cy+4-1, _amt_txt, _amt_sc, _amt_sc, 0)
				draw_text_transformed(assure_badge_cx+1, assure_badge_cy+4-1, _amt_txt, _amt_sc, _amt_sc, 0)
				draw_text_transformed(assure_badge_cx-1, assure_badge_cy+4+1, _amt_txt, _amt_sc, _amt_sc, 0)
				draw_text_transformed(assure_badge_cx+1, assure_badge_cy+4+1, _amt_txt, _amt_sc, _amt_sc, 0)
				draw_set_colour(c_white)
				if global.save_data.player.gold < _assure_cost draw_set_colour(c_red)
				draw_text_transformed(assure_badge_cx, assure_badge_cy+4, _amt_txt, _amt_sc, _amt_sc, 0)
				draw_set_colour(c_white)
				draw_set_halign(fa_left)
			}
			draw_sprite_ext(spr_craft_material, get_material_info(craft_rule.spices_require).icon, x-455, y-20, 0.9, 0.9, 0, c_white, 1)
			draw_set_halign(fa_center)
			draw_set_colour(c_black)
			//如果低级材料不足，尝试获取高级材料
			var display_spices_amount = 0
			var use_enhanced_spices = false
			if get_material_amount(craft_rule.spices_require) < craft_rule.spices_amount{
				for(var i = array_get_index(spices_use_order,craft_rule.spices_require);i < array_length(spices_use_order);i++){
					display_spices_amount += get_material_amount(spices_use_order[i])
					if display_spices_amount>= craft_rule.spices_amount{
						use_enhanced_spices = true
						break
					}
				}
			}
			else{
				display_spices_amount = get_material_amount(craft_rule.spices_require)
			}
			draw_text(x-455,y+35,string(display_spices_amount)+"/"+string(craft_rule.spices_amount))
			draw_set_font(font_yuan)
			if use_enhanced_spices{
				draw_set_colour(c_red)
				draw_text(x-455,y+60,"使用了高级香料")
			}
			if craft_rule.clover_require != "none"{
				//如果低级材料不足，尝试获取高级材料
				var display_clover_amount = 0
				var use_enhanced_clover = false
				if get_material_amount(craft_rule.clover_require) < craft_rule.clover_amount{
					for(var i = array_get_index(clover_use_order,craft_rule.clover_require);i < array_length(clover_use_order);i++){
						display_clover_amount += get_material_amount(clover_use_order[i])
						if display_clover_amount>= craft_rule.clover_amount{
							use_enhanced_clover = true
							break
						}
					}
				}
				else{
					display_clover_amount = get_material_amount(craft_rule.clover_require)
				}
				draw_sprite_ext(spr_craft_material, get_material_info(craft_rule.clover_require).icon, x-155, y-20, 0.9, 0.9, 0, c_white, 1)
				draw_set_halign(fa_center)
				draw_set_colour(c_black)
				draw_set_font(font_number)
				draw_text(x-155,y+35,string(display_clover_amount)+"/"+string(craft_rule.clover_amount))
				draw_set_font(font_yuan)
				if use_enhanced_clover{
					draw_set_colour(c_red)
					draw_text(x-155,y+60,"使用了高级四叶草")
				}
			}
		}
	}
	
	
    
}
else if button_select == 1{
	//绘制宝石强化UI背景
	draw_sprite_ext(spr_package_gem_bg, 0, x-305, y+110, 0.9, 0.9, 0, c_white, 1)
	draw_sprite_ext(spr_craft_material_bg,0,x-305,y-40,1.8,1.8,0,c_white,1)
	draw_sprite_ext(spr_craft_slot_text,3,x-305,y+110,1.8,1.8,0,c_white,1)
	draw_sprite_ext(spr_craft_slot_text,4,x-305,y-40,1.8,1.8,0,c_white,1)
	//绘制宝石强化材料
	for(var i = 0 ; i < array_length(gem_material_id_list) ; i++){
		var material_id = gem_material_id_list[i]
		var material_info = get_material_info(material_id)
		var material_amount = get_material_amount(material_id)
		draw_sprite_ext(spr_craft_material, material_info.icon, x-752+i*84, y + 454, 0.9, 0.9, 0, c_white, 1)
		draw_set_halign(fa_right);
		draw_set_valign(fa_bottom);
		draw_set_colour(c_white)
		draw_set_font(font_number)
		if get_material_amount(material_id) < 10000{
			draw_text(x-752+i*84+40,y + 454+42,string(get_material_amount(material_id)))
		}
		else{
			draw_text(x-752+i*84+40,y + 454+42,string(floor(get_material_amount(material_id)/10000))+"w")
		}
	}
	//绘制右侧栏位
	for(var i = 0 ; i < 7 ; i++){
        for(var j = 0 ; j < 9 ; j++){
            draw_sprite_ext(spr_package_slot_bg, 1, x+196+i*84, y - 324 + 88 * j, 0.9, 0.9, 0, c_white, 1)
        }
    }
	//绘制所有宝石
	var gem_index = 0
	hover_gem_index = -1
	
	for(var i = 0; i < array_length(global.save_data.unlocked_gems); i++) {
        var weapon_id = global.save_data.unlocked_gems[i].id;
        var weapon_data = get_gem_info(weapon_id)
        
        if (!is_undefined(weapon_data)) {
            // 计算宝石位置
            var row = gem_index div 7
            var col = gem_index mod 7
            
            if (row < 10) {
                var weapon_x = x + 196 + col * 84;
                var weapon_y = y - 324 + row * 88;
                
                // 绘制宝石图标
                draw_sprite_ext(weapon_data.icon, 0, weapon_x, weapon_y, 0.7, 0.7, 0, c_white, 1);
                
				if get_gem_max_level(weapon_id) > 0{
					draw_sprite_ext(spr_star_slot, get_gem_max_level(weapon_id)-1, weapon_x-28, weapon_y-30, 0.7, 0.7, 0, c_white, 1)
				}
                
                // 检查鼠标是否悬停在宝石上
                var spr_width = 84;
                var spr_height = 88;
                
                if (point_in_rectangle(mouse_x, mouse_y, 
                                      weapon_x - spr_width/2, weapon_y - spr_height/2,
                                      weapon_x + spr_width/2, weapon_y + spr_height/2)) {
                    hover_gem_index = i;
                }
                
                gem_index++;
            }
        }
    }
    
    // 绘制悬停提示
    if (hover_gem_index != -1) {
        var weapon_id = global.save_data.unlocked_gems[hover_gem_index].id;
        var weapon_data = global.gems_pool[? weapon_id];
        
        if (!is_undefined(weapon_data)) {
			draw_set_font(font_yuan)
            var tooltip_text = weapon_data.name + "\n点击将宝石放入强化槽";
            	draw_set_font(font_yuan);
            	tooltip_set(mouse_x - 15, mouse_y - 15, tooltip_text, -1);
			
            
        }
    }
	//绘制正在强化的宝石
	if current_uprade_target_id != ""{
		var weapon_x = x - 305
        var weapon_y = y + 110
		var weapon_id = current_uprade_target_id
		var weapon_data = get_gem_info(weapon_id)
                
        // 绘制宝石图标
        draw_sprite_ext(weapon_data.icon, 0, weapon_x, weapon_y, 0.85, 0.85, 0, c_white, 1);
                
		if get_gem_max_level(weapon_id) > 0{
			draw_sprite_ext(spr_star_slot, get_gem_max_level(weapon_id)-1, weapon_x-28, weapon_y-30, 0.8, 0.8, 0, c_white, 1)
		}
		//绘制强化需要的材料
		if get_gem_max_level(weapon_id) <= 14{
			var craft_rule = get_gem_craft_rule(string(get_gem_max_level(weapon_id)+1))
			draw_set_font(font_number)
			draw_set_colour(c_yellow)
			draw_set_valign(fa_middle)
			draw_set_halign(fa_left)
			draw_text(x-460,y+300,string(craft_rule.gold_amount))
			draw_sprite_ext(spr_craft_material, get_material_info(craft_rule.crystal_require).icon, x-305, y-40, 0.9, 0.9, 0, c_white, 1)
			draw_set_halign(fa_center)
			draw_set_colour(c_black)
			//如果低级材料不足，尝试获取高级材料
			var display_crystal_amount = 0
			var use_enhanced_crystal = false
			if get_material_amount(craft_rule.crystal_require) < craft_rule.crystal_amount{
				for(var i = array_get_index(crystal_use_order,craft_rule.crystal_require);i < array_length(crystal_use_order);i++){
					display_crystal_amount += get_material_amount(crystal_use_order[i])
					if display_crystal_amount>= craft_rule.crystal_amount{
						use_enhanced_crystal = true
						break
					}
				}
			}
			else{
				display_crystal_amount = get_material_amount(craft_rule.crystal_require)
			}
			draw_text(x-305,y+15,string(display_crystal_amount)+"/"+string(craft_rule.crystal_amount))
			draw_set_font(font_yuan)
			if use_enhanced_crystal{
				draw_set_colour(c_red)
				draw_text(x-305,y+40,"使用了高级水晶")
			}
		}
	}
}

// ── 卡片网格滚动条（与 obj_info_island_bg / GridList 用同一个精灵和同一套交互）──────
// 卡片画进 card_surface（600×815）、贴回在 (x+196-42, y-321-48)。必须在
// panel_anim_end_parts 之前画：那之后面板 surface 已贴回，再画就录不进去了。
{
    var _sb_scl = 2.2
    var _sb_w   = sprite_get_width(spr_info_island_scroll_bar)  * _sb_scl
    var _sb_h   = sprite_get_height(spr_info_island_scroll_bar) * _sb_scl
    var _sb_l   = x + 196 - 42
    var _sb_t   = y - 321 - 48
    // 精灵原点是左上角 → x 是「按钮左边缘」，补半个按钮宽让中心落在凹槽线上
    var _sb_x   = _sb_l + 600 - _sb_w + 28 + _sb_w * 0.5
    var _sb_vh  = 815                                    // 视口高 = card_surface 高度
    var _sb_max = craft_max_y_offset                     // 与 Mouse_61 同一上限（按解锁卡数动态算）
    // 滚动平滑趋近：滚轮与点轨道只改目标值，这里每帧非线性逼近（等级 1；等级 0 直接到位）
    if (ui_anim_on(1)) {
        y_offset += (y_offset_target - y_offset) * 0.28
        if (abs(y_offset_target - y_offset) < 0.5) y_offset = y_offset_target
    } else {
        y_offset = y_offset_target
    }

    if (_sb_max > 0 && _sb_vh > _sb_h) {
        var _sb_travel = _sb_vh - _sb_h
        var _sb_y = _sb_t + clamp(y_offset / _sb_max, 0, 1) * _sb_travel
        draw_sprite_ext(spr_info_island_scroll_bar, 0, _sb_x, _sb_y, _sb_scl, _sb_scl, 0, c_white, 1)
        if (mouse_check_button_pressed(mb_left)) {
            if (point_in_rectangle(mouse_x, mouse_y, _sb_x, _sb_y, _sb_x + _sb_w, _sb_y + _sb_h)) {
                sb_dragging = true
                sb_drag_y = mouse_y
                sb_drag_offset = y_offset
            } else if (point_in_rectangle(mouse_x, mouse_y, _sb_x, _sb_t, _sb_x + _sb_w, _sb_t + _sb_vh)) {
                y_offset_target = clamp((mouse_y - _sb_t - _sb_h * 0.5) / _sb_travel * _sb_max, 0, _sb_max)
            }
        }
        if (sb_dragging && mouse_check_button(mb_left)) {
            y_offset = clamp(sb_drag_offset + (mouse_y - sb_drag_y) * (_sb_max / _sb_travel), 0, _sb_max)
            y_offset_target = y_offset
        }
        if (mouse_check_button_released(mb_left)) sb_dragging = false
    }
}

// 提示框：推进尺寸/消失动画并绘制（每帧一次）
tooltip_draw();
panel_anim_end_parts(id, craft_parts, 260)
