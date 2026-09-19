if obj_info_island_bg.info_button_select == 1 and obj_info_island_bg.select_card_index!= -1{
audio_play_sound(snd_button,0,0)
if not obj_info_island_bg.is_submenu_opened{
		
			audio_play_sound(snd_button,0,0)
			var inst = instance_create_depth(room_width/2,room_height/2,depth-5,obj_info_island_edit_menu)
			// 计算当前选中卡片的最大转职数
			var card_id = global.player_deck[| obj_info_island_bg.select_card_index*2];
			var deck_entry = global.player_deck[| obj_info_island_bg.select_card_index*2+1];
			var card_data_shapes = deck_entry[? "shapes"]
			inst.view_max_shape = ds_list_size(card_data_shapes) - 1
			obj_info_island_bg.is_submenu_opened = true
		
	}
}