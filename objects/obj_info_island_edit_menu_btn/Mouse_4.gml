audio_play_sound(snd_button,0,0)
if btn_type == "plus"{
	var max_value = 0
	if target_info == "level"{
		max_value = 16
	}
	else if target_info == "shape"{
		max_value = 2
	}
	else if target_info == "skill"{
		max_value = 8
	}
	if obj_info_island_edit_menu.target_current_info[? target_info] < max_value{
		obj_info_island_edit_menu.target_current_info[? target_info] += 1
	}
}
else if btn_type == "subtract"{
	if obj_info_island_edit_menu.target_current_info[? target_info] > 0{
		obj_info_island_edit_menu.target_current_info[? target_info] -= 1
	}
}
else if btn_type == "max"{
	if target_info == "level"{
		obj_info_island_edit_menu.target_current_info[? target_info] = 16
	}
	else if target_info == "shape"{
		obj_info_island_edit_menu.target_current_info[? target_info] = 2
	}
	else if target_info == "skill"{
		obj_info_island_edit_menu.target_current_info[? target_info] = 8
	}
}
else if btn_type == "min"{
	obj_info_island_edit_menu.target_current_info[? target_info] = 0
}