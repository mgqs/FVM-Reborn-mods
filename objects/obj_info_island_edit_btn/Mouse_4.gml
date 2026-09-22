if obj_info_island_bg.info_button_select == 1 and obj_info_island_bg.select_card_index!= -1{
audio_play_sound(snd_button,0,0)
if not obj_info_island_bg.is_submenu_opened{
		
			audio_play_sound(snd_button,0,0)
			var inst = instance_create_depth(room_width/2,room_height/2,depth-5,obj_info_island_edit_menu)
			// 计算当前选中卡片的最大转职数
			var _sorted_index = obj_info_island_bg.deck_sort_order[obj_info_island_bg.select_card_index];
			var card_id = global.player_deck[| _sorted_index];
			var deck_entry = global.player_deck[| _sorted_index+1];
			var card_data_shapes = deck_entry[? "shapes"]
			var deck_max_shape = ds_list_size(card_data_shapes) - 1
			// 同时检查植物注册表中实际有多少形态，取较小值
			var plant_max_shape = 0
			var plant_data = get_plant_data(card_id)
			if plant_data != undefined{
				var shapes_map = plant_data[? "shapes"]
				// 遍历查找最大的shape索引
				for(var si = 0; si <= 10; si++){
					if ds_map_exists(shapes_map, string(si)){
						plant_max_shape = si
					}
				}
			}
			inst.view_max_shape = min(deck_max_shape, plant_max_shape)
			obj_info_island_bg.is_submenu_opened = true
		
	}
}