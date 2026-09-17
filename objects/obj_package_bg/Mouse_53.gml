if package_button_select == 1{
	if not is_submenu_opened{
		if hover_card_index != -1{
			audio_play_sound(snd_button,0,0)
			var inst = instance_create_depth(room_width/2,room_height/2,depth-5,obj_card_edit_menu)
			inst.target_card_index = hover_card_index
			var deck_entry = global.player_deck[| hover_card_index*2+1];
			var card_data_shapes = deck_entry[? "shapes"]
			view_max_shapes = ds_list_size(card_data_shapes)-1
			//show_debug_message(view_max_shapes)
			inst.view_max_shape = view_max_shapes
			is_submenu_opened = true
		}
	}
}
// 鼠标按下事件
if (package_button_select == 2) {
	if not is_submenu_opened{
	    // 武器背包标签页
	    if (hover_weapon_index != -1) {
			audio_play_sound(snd_button,0,0)
	        var weapon_id = global.save_data.unlocked_weapons[hover_weapon_index].id;
			var weapon_info = get_weapon_info(weapon_id)
	        var is_equipped = is_weapon_equipped(weapon_id);
        
	        if (is_equipped) {
	            // 如果已装备，则卸下
	            var slot = get_weapon_slot(weapon_id);
	            remove_weapon(slot);
	        } else {
	            // 如果未装备，则装备到对应武器槽
	            equip_weapon(weapon_id, weapon_info.slot);
	        }
	    }
		if (hover_gem_index != -1) {
			audio_play_sound(snd_button,0,0)
	        var weapon_id = global.save_data.unlocked_gems[hover_gem_index].id;
			var weapon_info = get_gem_info(weapon_id)
	        var is_equipped = (get_gem_index(weapon_id) != -1);
        
	        if (is_equipped) {
	            //如果已装备，则卸下
	            remove_gem(weapon_id)
	        } else {
	            // 如果未装备，则装备到对应武器槽
	            equip_gem(weapon_id);
	        }
	    }
	}
}