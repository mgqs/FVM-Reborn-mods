if !is_submenu_opened{
	if hover_card_index != -1{
		audio_play_sound(snd_button,0,0)
		current_uprade_target_id = global.save_data.unlocked_cards[hover_card_index].id
	}
	if hover_gem_index != -1{
		audio_play_sound(snd_button,0,0)
		current_uprade_target_id = global.save_data.unlocked_gems[hover_gem_index].id
	}
}