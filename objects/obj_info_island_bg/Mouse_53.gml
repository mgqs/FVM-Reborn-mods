//if package_button_select == 1{
//	if not is_submenu_opened{
//		if hover_card_index != -1{
//			audio_play_sound(snd_button,0,0)
//			var inst = instance_create_depth(room_width/2,room_height/2,depth-5,obj_card_edit_menu)
//			inst.target_card_index = hover_card_index
//			is_submenu_opened = true
//		}
//	}
//}
if not is_submenu_opened{
if hover_card_index != -1{
	audio_play_sound(snd_button,0,0)
	select_card_index = hover_card_index
	//view_card_shape = 0
}
}