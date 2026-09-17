if on_click and obj_player_info_ui.menu_type == 0{
	global.fullscreen = not window_get_fullscreen()
	window_set_fullscreen(global.fullscreen)
	audio_play_sound(snd_button,0,0)
}