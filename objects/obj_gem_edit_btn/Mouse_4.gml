audio_play_sound(snd_button,0,0)
if btn_type == "plus"{
	var max_value = 0
	if target_info == "level"{
		max_value = global.save_data.unlocked_gems[obj_gem_edit_menu.target_card_index].max_level
		if obj_gem_edit_menu.target_current_info < max_value obj_gem_edit_menu.target_current_info++
	}
}
else if btn_type == "subtract"{
	if obj_gem_edit_menu.target_current_info > 0
	obj_gem_edit_menu.target_current_info -= 1
}
else if btn_type == "max"{
	if target_info == "level"{
		obj_gem_edit_menu.target_current_info = global.save_data.unlocked_gems[obj_gem_edit_menu.target_card_index].max_level
	}
}
else if btn_type == "min"{
	obj_gem_edit_menu.target_current_info = 0
}