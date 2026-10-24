if not is_placed{
	// 暂停菜单打开时不响应放置，避免点菜单按钮时顺手把人物放到菜单底下的格子
	if (instance_exists(obj_pause_menu)) exit;
	var logical_x = mouse_x;
	var logical_y = mouse_y;
	var platform_shift_x = 0;
	var platform_shift_y = 0;
	var plat = instance_position(mouse_x, mouse_y, obj_platform);
	if (plat != noone) {
		platform_shift_x = plat.visual_x_shift;
		platform_shift_y = plat.visual_y_shift;
		logical_x -= platform_shift_x;
		logical_y -= platform_shift_y;
	}

	var can_plant = (can_place_at_position(logical_x, logical_y, "normal","amphi","none"));
	if can_plant{
		is_placed = true
		global.is_paused = false
		var grid_pos = get_grid_position_from_world(logical_x, logical_y)
		x = grid_pos.x + platform_shift_x
		y = grid_pos.y+10 + platform_shift_y
		grid_row = grid_pos.row
		grid_col = grid_pos.col
		card_created(id,grid_col,grid_row)
		global.audio.play(snd_place1,0,0)
		instance_create_depth(x,y,-2,obj_place_effect)
		var _equipped_attire_id = card_equipped_attire_id("player");
		var _transformation_sprite = -1;
		var _equipped_items = global.save_data.equipped_items;
		var _gem_slots = [_equipped_items.main_weapon, _equipped_items.secondary_weapon, _equipped_items.super_weapon];
		for (var _slot_index = 0; _slot_index < array_length(_gem_slots); _slot_index++) {
			var _slot_gems = _gem_slots[_slot_index].gems;
			if (_equipped_attire_id == "player_attire_xingzhihuanbianshen2"
				&& array_get_index(_slot_gems, "star_wand_gem_1") != -1) {
				_transformation_sprite = spr_huan_bianshen2;
				break;
			}
			if (_equipped_attire_id == "player_attire_xingzhihuanbianshen3"
				&& array_get_index(_slot_gems, "star_wand_gem_5") != -1) {
				_transformation_sprite = spr_yao_bianshen2;
				break;
			}
			if (_equipped_attire_id == "player_attire_shouhuzhishen"
				&& array_get_index(_slot_gems, "zeus_ren_gem") != -1) {
				_transformation_sprite = spr_bianshen2;
				break;
			}
		}
		if (_transformation_sprite != -1) {
			var _transformation_effect = instance_create_depth(0, 0, -10000, obj_12yinliao_effect);
			_transformation_effect.sprite_index = _transformation_sprite;
			_transformation_effect.is_one_shot = true;
			_transformation_effect.center_screen = true;
			_transformation_effect.flash_speed = 6;
			if (_transformation_sprite != spr_bianshen2) {
				_transformation_effect.scale_multiplier = 2;
				var _entrance_effect = instance_create_depth(x, y, depth - 2, obj_place_effect);
				_entrance_effect.sprite_index = spr_ruchang;
				_entrance_effect.image_xscale = image_xscale;
				_entrance_effect.image_yscale = image_yscale;
				_entrance_effect.depth = -10001;
				_entrance_effect.custom_playback = true;
				_entrance_effect.playback_speed = 0.2;
			}
		}
		var plany_list = ds_grid_get(global.grid_plants,grid_col,grid_row)
		if global.grid_terrains[grid_row][grid_col].type == "water"{
			var card = instance_create_depth(x,y-10,depth+1,obj_wooden_plate)
			card_created(card,grid_col,grid_row)
			
		}
		var gem_index = 0
		if global.save_data.equipped_items.main_weapon.id != ""{
			var main_info = get_weapon_info(global.save_data.equipped_items.main_weapon.id)
			var main_weapon_inst = instance_create_depth(x-10,y-100,depth-1,main_info.obj)
			main_weapon_inst.parent_player = id
			main_weapon_inst.grid_row = grid_row
			main_weapon_inst.grid_col = grid_col
			cycle = main_info.cycle
			var gem_list = global.save_data.equipped_items.main_weapon.gems
			for(var i = 0 ; i < array_length(gem_list);i++){
				var gem_id = gem_list[i]
				var gem_info = get_gem_info(gem_id)
				if gem_info.obj != noone{
					var _col = floor(gem_index / 9)
					var _row = gem_index mod 9
					instance_create_depth(390+_col*80,213+_row*80,-500,gem_info.obj)
					gem_index++
				}
			}
		}
		if global.save_data.equipped_items.secondary_weapon.id != ""{
			var s_inst = instance_create_depth(x,y,depth,obj_player_shield)
			s_inst.parent_player = id
			s_inst.grid_row = grid_row
			s_inst.grid_col = grid_col
			var main_info = get_weapon_info(global.save_data.equipped_items.secondary_weapon.id)
			hp += main_info.hp_increase
			max_hp += main_info.hp_increase
			if get_gem_index("health_gem") != -1{
				hp += get_gem_info("health_gem").hp_increase * (get_gem_level("health_gem")+1)
				max_hp += get_gem_info("health_gem").hp_increase * (get_gem_level("health_gem")+1)
			}
			var sec_gem_list = global.save_data.equipped_items.secondary_weapon.gems
			for(var i = 0 ; i < array_length(sec_gem_list);i++){
				var gem_id = sec_gem_list[i]
				var gem_info = get_gem_info(gem_id)
				if gem_info.obj != noone{
					var _col = floor(gem_index / 9)
					var _row = gem_index mod 9
					instance_create_depth(390+_col*80,213+_row*80,-500,gem_info.obj)
					gem_index++
				}
			}
		}
		if global.save_data.equipped_items.super_weapon.id != ""{
			var main_info = get_weapon_info(global.save_data.equipped_items.super_weapon.id)
			var main_weapon_inst = instance_create_depth(x-10,y-100,depth-1,main_info.obj)
			main_weapon_inst.parent_player = id
			main_weapon_inst.grid_row = grid_row
			main_weapon_inst.grid_col = grid_col
			var sup_gem_list = global.save_data.equipped_items.super_weapon.gems
			for(var i = 0 ; i < array_length(sup_gem_list);i++){
				var gem_id = sup_gem_list[i]
				var gem_info = get_gem_info(gem_id)
				if gem_info.obj != noone{
					var _col = floor(gem_index / 9)
					var _row = gem_index mod 9
					instance_create_depth(390+_col*80,213+_row*80,-500,gem_info.obj)
					gem_index++
				}
			}
		}
	}
	
}
