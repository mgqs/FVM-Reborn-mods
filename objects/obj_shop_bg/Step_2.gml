// 转职凭证页：左上角分类页签点击（一转 / 二转 / 全部）
// 放在 End Step 里统一判定，不和商品购买按钮的 Mouse 事件抢同一帧
if (shop_button_select == 6 && !is_submenu_opened && mouse_check_button_pressed(mb_left)) {
	var _hit = -1;
	// 三个页签的实际绘制范围（中心 x-740 / x-616 / x-517，y-307，缩放 1.6）
	//   一转 67×21 → 107×34；二转 同；全部 37×22 → 59×35
	if (point_in_rectangle(mouse_x, mouse_y, x - 796, y - 326, x - 684, y - 288)) _hit = 1;
	else if (point_in_rectangle(mouse_x, mouse_y, x - 672, y - 326, x - 560, y - 288)) _hit = 2;
	else if (point_in_rectangle(mouse_x, mouse_y, x - 549, y - 326, x - 485, y - 288)) _hit = 0;
	if (_hit != -1 && _hit != credit_tab) {
		credit_tab = _hit;
		current_page = 1;
		shop_list_recharge();
		global.audio.play(snd_button, 0, 0);
	}
}

// 凭证页：价格右边的小箭头 = 自定义购买数量（2026-10-28）
//   箭头画在「购买」按钮 sprite 之外（价格行 y-62；按钮 81×23 只覆盖按钮本体），
//   按钮自己的 Mouse 事件收不到 → 跟上面的分类页签一样，在 End Step 里统一判
//   （点按钮本体仍然是「买 1 个 + 老确认框」，两条路互不影响）
if (shop_button_select == 6 && !is_submenu_opened && mouse_check_button_pressed(mb_left)) {
	with (obj_shop_buy_btn) {
		if (variable_instance_exists(id, "credit_shape") && credit_shape > 0 && !is_disabled
			&& credit_price_arrow_hit(mouse_x, mouse_y, x, y - 62, credit_price_label(cost, coin_type))) {
			credit_trade_open_buy(target_item,
				is_string(cost) ? real(cost) : cost,
				coin_type,
				(coin_type == "prestige") ? "威望" : "G",
				depth - 3);
			other.is_submenu_opened = true;
			break;
		}
	}
}
