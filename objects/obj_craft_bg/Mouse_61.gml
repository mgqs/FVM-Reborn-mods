// 食灵融合页：滚轮在哪个面板上就滚哪个（整行滚），别再动强化页的 y_offset
// 神级进化页：滚轮只滚右侧列表（整行滚，上限 Draw 每帧算）
// 不写这段的话滚轮会一路漏到下面的强化页 y_offset_target（2026-10-27 补）
if craft_top_tab == 3{
	evo_scroll_target = clamp(evo_scroll_target +1, 0, evo_rows_max)
	exit
}
// 卡片转职页：滚轮只滚右侧卡列表
if craft_top_tab == 2{
	tg_scroll_target = clamp(tg_scroll_target +1, 0, tg_rows_max)
	exit
}
if craft_top_tab == 1{
	if point_in_rectangle(mouse_x, mouse_y, fusion_in_l, fusion_in_t1, fusion_in_r, fusion_in_b1){
		fusion_recipe_scroll_t = clamp(fusion_recipe_scroll_t + 1, 0, fusion_rows_recipe_max)
	}
	else if point_in_rectangle(mouse_x, mouse_y, fusion_in_l, fusion_in_t2, fusion_in_r, fusion_in_b2){
		fusion_card_scroll_t = clamp(fusion_card_scroll_t + 1, 0, fusion_rows_card_max)
	}
	exit
}
if button_select == 0{
	// 卡片强化标签页
	if (variable_instance_exists(id, "craft_max_y_offset")) {
		y_offset_target = min(craft_max_y_offset, y_offset_target + 40)
	}
	else{
		y_offset_target = min(96 * 20 - 815, y_offset_target + 40)
	}
}
else if button_select == 1{
	// 宝石强化标签页
	if (variable_instance_exists(id, "craft_gem_max_y_offset")) {
		y_offset_target = min(craft_gem_max_y_offset, y_offset_target + 40)
	}
}
