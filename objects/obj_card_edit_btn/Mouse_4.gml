audio_play_sound(snd_button,0,0)
var card_id = global.player_deck[| obj_card_edit_menu.target_card_index*2];
if btn_type == "plus"{
	var max_value = 0
	if target_info == "level"{
		max_value = get_card_info_simple(card_id).max_level
	}
	else if target_info == "shape"{
		max_value = get_card_info_simple(card_id).max_shape
	}
	else if target_info == "skill"{
		max_value = global.save_data.unlocked_items.max_skill_level
	}
	if obj_card_edit_menu.target_current_info[? target_info] < max_value{
		obj_card_edit_menu.target_current_info[? target_info] += 1
	}
}
else if btn_type == "subtract"{
	if obj_card_edit_menu.target_current_info[? target_info] > 0
	obj_card_edit_menu.target_current_info[? target_info] -= 1
}
else if btn_type == "max"{
	if target_info == "level"{
		obj_card_edit_menu.target_current_info[? target_info] = get_card_info_simple(card_id).max_level
	}
	else if target_info == "shape"{
		obj_card_edit_menu.target_current_info[? target_info] = get_card_info_simple(card_id).max_shape
	}
	else if target_info == "skill"{
		obj_card_edit_menu.target_current_info[? target_info] = global.save_data.unlocked_items.max_skill_level
	}
}
else if btn_type == "min"{
	obj_card_edit_menu.target_current_info[? target_info] = 0
}