if global.menu_screen{
	if world_map == 0 {
		if instance_exists(obj_player_info_ui){
			if obj_player_info_ui.menu_type != 0{
				exit
			}
		}
		audio_play_sound(snd_button,0,0)
		world_map = 1
		instance_create_depth(room_width/2,room_height/2,-5,obj_world_map_menu)
		if instance_exists(obj_player_info_ui){
			obj_player_info_ui.menu_type = 3
		}
		image_index = 0
	}
}
