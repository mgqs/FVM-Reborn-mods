if not obj_tower_cake_bg.is_submenu_opened{
	if btn_type == "prev"{
		if obj_tower_cake_bg.current_page > 1{
			obj_tower_cake_bg.current_page --
			obj_tower_cake_bg.level_select = -1
		}
	}
	else if btn_type == "next"{
		if obj_tower_cake_bg.current_page < obj_tower_cake_bg.total_page{
			obj_tower_cake_bg.current_page ++
			obj_tower_cake_bg.level_select = -1
		}
	}
	else if btn_type == "min"{
		obj_tower_cake_bg.current_page = 1
		obj_tower_cake_bg.level_select = -1
	}
	else if btn_type == "max"{
		obj_tower_cake_bg.current_page = obj_tower_cake_bg.total_page
		obj_tower_cake_bg.level_select = -1
	}
	audio_play_sound(snd_button,0,0)
	instance_destroy(obj_tower_cake_card_reward)
	with obj_tower_cake_bg{
		global.tower_cake_page = current_page
		refresh_level_button()
	}
	
}