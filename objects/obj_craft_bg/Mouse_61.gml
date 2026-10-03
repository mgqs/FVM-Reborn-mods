if button_select == 0{
	// 卡片强化标签页
	if (variable_instance_exists(id, "craft_max_y_offset")) {
		if y_offset < craft_max_y_offset - 40{
			y_offset += 40
		}
		else{
			y_offset = craft_max_y_offset
		}
	}
	else{
		if y_offset <= 96*20 - 40 - 815{
			y_offset += 40
		}
		else{
			y_offset = 96*20 - 815
		}
	}
}
else if button_select == 1{
	// 宝石强化标签页
	if (variable_instance_exists(id, "craft_gem_max_y_offset")) {
		if y_offset < craft_gem_max_y_offset - 40{
			y_offset += 40
		}
		else{
			y_offset = craft_gem_max_y_offset
		}
	}
}
