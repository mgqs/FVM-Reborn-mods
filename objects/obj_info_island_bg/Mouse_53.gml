//if package_button_select == 1{
//	if not is_submenu_opened{
//		if hover_card_index != -1{
//			global.audio.play(snd_button,0,0)
//			var inst = instance_create_depth(room_width/2,room_height/2,depth-5,obj_card_edit_menu)
//			inst.target_card_index = hover_card_index
//			is_submenu_opened = true
//		}
//	}
//}
if not is_submenu_opened{
if hover_card_index != -1{
	global.audio.play(snd_button,0,0)
	select_card_index = hover_card_index
	// ★ 卡片情报任务：防御卡页签（info_button_select == 1）里点开一张卡 = 看过情报
	if info_button_select == 1 && hover_card_index < array_length(info_view){
		var _view_entry = info_view[hover_card_index]
		if _view_entry >= 0 && _view_entry < ds_list_size(global.player_deck){
			card_info_task_complete(global.player_deck[| _view_entry])
		}
	}
	if (global.level_id == "test_level" && variable_global_exists("test_info_island_mode")
	    && global.test_info_island_mode && info_button_select == 2)
	{
		var test_enemy_id = info_view[hover_card_index]
		if (ds_map_exists(global.enemy_map, test_enemy_id))
		{
			global.test_mouse_picker_id = test_enemy_id
			global.test_mouse_picker_block_place = true
			global.test_mouse_picker_open = false
			global.is_paused = false
			instance_destroy()
		}
	}
	//view_card_shape = 0
}
}
