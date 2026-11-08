/// 魔塔蛋糕 · 转职凭证格：命中判定 + 点击
/// 没有 sprite（不占图集），命中用 credit_size 的方形热区，坐标跟鼠标同为房间坐标
if (!instance_exists(obj_tower_cake_bg)) exit;

if (obj_tower_cake_bg.is_submenu_opened){
	hovered = false;
	exit;
}

var _hw = credit_size * 0.5;
hovered = point_in_rectangle(mouse_x, mouse_y, x - _hw, y - _hw, x + _hw, y + _hw + 22);   // 22 = 下面那行小字也算

// 悬停的那一格提到最前，否则提示条会被同深度的邻格卡面压住
depth = obj_tower_cake_bg.depth - (hovered ? 5 : 2);

if (hovered && mouse_check_button_released(mb_left)){
	// 已转职的格子不给再买（同款卡已经到/max 形态了，买了也没用）
	if (transfer_credit_is_transferred(card_id, card_shape)){
		show_notice("已转职，无需再买", 60);
		exit;
	}
	// 一条路：爬塔门槛 / 已转职 / 余额 → 提示；都过 → 跟商店同一个购买确认窗
	transfer_credit_tower_click(goods_id, id);
}
