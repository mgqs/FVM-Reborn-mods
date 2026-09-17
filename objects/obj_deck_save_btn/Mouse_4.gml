if obj_readyroom_manager.selected_custom_deck == deck_index && !obj_readyroom_manager.is_submenu_open{
	audio_play_sound(snd_button,0,0)
	save_to_custom_deck(deck_index-1,"卡组"+string(deck_index))
	show_notice("卡组已保存",60)
}