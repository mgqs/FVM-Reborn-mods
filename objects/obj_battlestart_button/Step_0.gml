if button_pushed{
	timer ++
	if timer < 16{
		image_index = floor(timer / 4)
	}
	else{
		// Consume the click before requesting the room transition so it is not
		// restarted every frame while the transition is running.
		button_pushed = false
		audio_pause_sound(mus_readyroom)
		global.gui_stack.to(room_battle)
		resource_texture_prepare("bullet")
		resource_texture_prepare("effects")
		if global.map_id == "tower_cake"{
			resource_texture_prepare("enemy_tower")
		}
		else if global.map_id == "undersea_vortex"{
			resource_texture_prepare("pack_undersea_vortex")
		}
		resource_texture_prepare("time_god")
	}
}
