if (!is_submenu_opened && global.debug == 1)
    show_debug_message("鼠标位置： " + string(mouse_x) + "，" + string(mouse_y));

// 转职凭证页：价格右边的小箭头 = 自定义购买数量（2026-10-28）
//   箭头中心在按钮坐标 x+100（「兑换」按钮 80×31，半宽只有 40）→ 落在按钮 sprite 之外，
//   按钮自己的 Mouse 事件收不到，所以在背景的左键事件里统一判
if (!is_submenu_opened && shop_button_select == 2 && mouse_check_button_pressed(mb_left)) {
	with (obj_gods_store_buy_btn) {
		if (btn_type == "tvoucher" && !is_disabled
			&& credit_price_arrow_hit_at(mouse_x, mouse_y, x + 100, y - 58)) {
			credit_trade_open_buy(transfer_credit_id(target_item, target_shape),
				is_string(cost) ? real(cost) : cost, "oracle", "神石", depth - 3);
			other.is_submenu_opened = true;
			break;
		}
	}
}
