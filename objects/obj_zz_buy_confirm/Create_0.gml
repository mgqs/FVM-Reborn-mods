/// 幸运星兑换 · 确认框
/// ─────────────────────────────────────────────────────────────────────────
/// 与商城 obj_shop_buy_confirm 同一个精灵、同一套面板动画、同一组按钮：
///   底板 spr_battle_escape_menu（1.5 倍，居中）/ 按钮 spr_common_button（0.75 倍）
/// 只有三处不同：标题写「兑换确认」、正文按幸运星结算、确定后调 zz_buy_shop()。
/// zz_idx 由 obj_zz_shop_bg 创建后赋值（Create 里拿不到，所以文案在 Draw 里现算）。
bg     = spr_battle_escape_menu;
width  = sprite_get_width(bg);
height = sprite_get_height(bg);

buttons = [
	[-80, "确定", 110, 40],
	[80,  "取消", 110, 40]
];

selected_button = -1;
zz_idx = -1;

// 按钮绘制缩放：spr_common_button 是 78×33，1.35 倍 → 105×45，
// 与参考稿里那对按钮（108×37）体量一致，又不至于撑破对话框下沿
zz_btn_scale = 1.35;

// 定位到屏幕中心
x = room_width / 2;
y = room_height / 2;

panel_anim_init(id, 0.18, 0.14, 0, 3);
panel_anim_kids(id, []);
pop_anim_init(id, []);

/// @desc 确认文案（按 zz_idx 现算商品名 / 价格 / 数量）
function zz_dlg_text() {
	var _list = zz_shop_list();
	if (zz_idx < 0 || zz_idx >= array_length(_list)) return "确定兑换吗？";
	var _it = _list[zz_idx];
	var _is_card = (variable_struct_exists(_it, "card") && _it.card);
	return "确定以" + string(_it.cost) + "幸运星兑换" + zz_item_name(_it.id)
		+ (_is_card ? "" : "×" + string(_it.qty)) + "吗？";
}
