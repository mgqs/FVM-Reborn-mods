// 食灵融合页：滚轮在哪个面板上就滚哪个（整行滚），别再动强化页的 y_offset
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
