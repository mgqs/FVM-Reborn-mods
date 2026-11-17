zz_guard = max(0, zz_guard - 1);

// 确认框开着时，点击交给确认框（它自己会 panel_anim_close 播完再销毁）
if (instance_exists(obj_zz_buy_confirm)) exit;
if (zz_guard > 0) exit;
if (!mouse_check_button_pressed(mb_left)) exit;

// ── 关闭（右上角，判定与 spr_closemenu_btn×1.8 的可见范围一致）──
if (point_in_rectangle(mouse_x, mouse_y,
		zz_close[0] - zz_close_hit, zz_close[1] - zz_close_hit,
		zz_close[0] + zz_close_hit, zz_close[1] + zz_close_hit)) {
	audio_play_sound(snd_button, 0, 0);
	instance_destroy();
	exit;
}

// ── 翻页（与 obj_shop_page_btn 同：到头就不翻，但照样出声）──
if (zz_pg_hit(zz_pg_prev)) {
	audio_play_sound(snd_button, 0, 0);
	if (zz_page > 1) zz_page--;
	exit;
}
if (zz_pg_hit(zz_pg_next)) {
	audio_play_sound(snd_button, 0, 0);
	if (zz_page < zz_max_page) zz_page++;
	exit;
}

// ── 购买按钮 → 兑换确认框 ──
var _list = zz_shop_list();
for (var _slot = 0; _slot < zz_per_page; _slot++) {
	var _idx = zz_slot_item(zz_page, _slot, _list);
	if (_idx < 0) continue;

	var _sc = zz_slot_center(_slot);
	var _r  = zz_buy_rect(_sc[0], _sc[1]);
	if (!point_in_rectangle(mouse_x, mouse_y, _r[0], _r[1], _r[0] + _r[2], _r[1] + _r[3])) continue;

	var _it = _list[_idx];
	var _is_card = (variable_struct_exists(_it, "card") && _it.card);

	if (_is_card && zz_card_owned(_it.id)) {
		audio_play_sound(snd_button, 0, 0);
		show_notice("已拥有该卡片", 60);
		exit;
	}
	if (zz_star_amount() < _it.cost) {
		audio_play_sound(snd_button, 0, 0);
		show_notice("幸运星不足（需 " + string(_it.cost) + " 颗）", 90);
		exit;
	}

	// 确认框：与商城 obj_shop_buy_confirm 同一精灵、同一套面板动画，盖在商店上层
	audio_play_sound(snd_button, 0, 0);
	var _dlg = instance_create_depth(0, 0, depth - 1, obj_zz_buy_confirm);
	_dlg.zz_idx = _idx;
	exit;
}
