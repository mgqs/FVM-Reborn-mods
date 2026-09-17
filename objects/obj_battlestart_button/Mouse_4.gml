if on_click and !obj_readyroom_manager.is_submenu_open{
	if deck_slot_count() > 0{
		button_pushed = true
		audio_play_sound(snd_button,0,0)
	}
	else{
		show_notice("至少需要选择一张防御卡",60)
	}
}