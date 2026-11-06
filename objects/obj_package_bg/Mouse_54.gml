if package_button_select == 1{
	if not is_submenu_opened{
		if hover_card_index != -1{
			global.audio.play(snd_button,0,0)
			var inst = instance_create_depth(1380,room_height/2,depth-5,obj_info_island_bg)
			inst.select_card_index = hover_card_index
			// 2026-11-06：只把卡 id 带过去，让情报岛定位到这张卡；
			//   星级/转职/技能不再自动同步（用户口径：要同步就点面板上的「同步背包」按钮）
			var _fi = -1
			if (variable_instance_exists(id, "deck_sort_order") && hover_card_index >= 0 && hover_card_index < array_length(deck_sort_order)){
				_fi = deck_sort_order[hover_card_index]
			}
			inst.open_focus_id = (_fi >= 0) ? global.player_deck[| _fi] : ""
			instance_destroy()
		}
	}
}
if package_button_select == 2{
	if not is_submenu_opened{
		if hover_gem_index != -1{
			global.audio.play(snd_button,0,0)
			var inst = instance_create_depth(room_width/2,room_height/2,depth-5,obj_gem_edit_menu)
			inst.target_card_index = hover_gem_index
			is_submenu_opened = true
		}
	}
}