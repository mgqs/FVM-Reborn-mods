audio_play_sound(snd_button,0,0)
instance_destroy(obj_world_map_menu)
obj_world_map_button.world_map = 0
if instance_exists(obj_player_info_ui){
	obj_player_info_ui.menu_type = 0
}
instance_destroy()