if package_button_select == 1{
	if not is_submenu_opened{
		if hover_card_index != -1{
			global.audio.play(snd_button,0,0)
			var inst = instance_create_depth(room_width/2,room_height/2,depth-5,obj_card_edit_menu)
			inst.target_card_index = deck_sort_order[hover_card_index] / 2
			var deck_entry = global.player_deck[| deck_sort_order[hover_card_index]+1];
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
			global.audio.play(snd_button,0,0)
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
			global.audio.play(snd_button,0,0)
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
else if package_button_select == 3{
	if not is_submenu_opened{
		if hover_material_index != -1{
			var _mat_list = ds_map_keys_to_array(global.material_pool)
			var _mat_id = _mat_list[hover_material_index]
			var _price = get_material_sell_price(_mat_id)
			var _amount = get_material_amount(_mat_id)
			if _price > 0 && _amount > 0{
				global.audio.play(snd_button,0,0)
				var _mat_data = get_material_info(_mat_id)
				var inst = instance_create_depth(room_width/2,room_height/2,depth-5,obj_material_sell_confirm)
				inst.sell_material_id = _mat_id
				inst.sell_material_name = _mat_data.name
				inst.sell_material_icon = _mat_data.icon
				if (_mat_id == "cross_server_gold_medal") {
					inst.sell_material_spr = spr_mod_cs_xunzhang
				} else if (_mat_id == "cross_server_silver_medal") {
					inst.sell_material_spr = spr_mod_cs_silver_medal
				} else {
					inst.sell_material_spr = (_mat_id == "oracle_stone") ? spr_oriacle_stone : spr_craft_material
				}
				inst.max_amount = _amount
				inst.unit_price = _price
				is_submenu_opened = true
			}
		}
	}
}

// 凭证页（第 4 页签）：点凭证格子 → 回收（2026-10-27；统一 500 威望/个）
//   单价 / 规则 / 窗字段全在 scripts/transfer_credit：credit_trade_open_recycle + transfer_credit_recycle
//   这里只负责「点到哪个凭证」；进化凭证（evo）不是转职凭证，不回收
else if package_button_select == 4{
	if not is_submenu_opened{
		if hover_transfer_index != -1{
			var _tab_it = transfer_credit_tab_collect()
			var _items_it = _tab_it.items
			if hover_transfer_index < array_length(_items_it){
				var _it = _items_it[hover_transfer_index]
				if _it.kind == "transfer"{
					global.audio.play(snd_button,0,0)
					credit_trade_open_recycle(_it.id, _it.amount, depth-5)
					is_submenu_opened = true
				}
				else{
					show_notice("进化凭证不能回收", 60)
				}
			}
		}
	}
}
