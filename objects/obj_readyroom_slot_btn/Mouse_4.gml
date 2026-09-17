if type == "prev"{
	if obj_readyroom_manager.deck_first_slot_index >= 10{
		obj_readyroom_manager.deck_first_slot_index -= 10
	}
	else{
		obj_readyroom_manager.deck_first_slot_index = 10
	}
}
else{
	if obj_readyroom_manager.deck_first_slot_index < 10{
		obj_readyroom_manager.deck_first_slot_index += 10
	}
	else{
		obj_readyroom_manager.deck_first_slot_index = 0
	}
}
audio_play_sound(snd_button,0,0)