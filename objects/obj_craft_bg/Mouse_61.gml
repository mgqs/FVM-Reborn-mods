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
