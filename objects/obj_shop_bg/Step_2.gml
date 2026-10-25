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
