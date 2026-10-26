// 绘制事件
panel_anim_step(id)
if (!instance_exists(id)) exit
draw_set_alpha(0.5 * ui_anim_alpha(id));
// 绘制半透明遮罩
draw_rectangle_color(0, 0, room_width, room_height, c_black, c_black, c_black, c_black, false);
draw_set_alpha(1);
panel_anim_begin(id)
draw_self()

// 绘制背包格子背景
draw_sprite_ext(spr_package_bg_2, 0, 530, room_height/2, 0.9, 0.9, 0, c_white, 1)

// 绘制玩家金币数量
draw_set_font(font_number); 
draw_set_color(c_yellow);
draw_set_halign(fa_right);
draw_set_valign(fa_bottom);
draw_text(x - 180, y + 406, string(global.save_data.player.gold));

draw_set_color(c_white);
draw_set_halign(fa_left);
draw_set_valign(fa_bottom);
draw_set_font(font_yuan)
if (pg_t_l >= 0) {
	pg_t_l++;
	if (pg_t_l > pg_frames) pg_t_l = -1;
}
var _pg_alpha_l = (pg_t_l >= 0) ? 1 - power(1 - pg_t_l / pg_frames, 3) : 1;
draw_set_alpha(_pg_alpha_l);
if info_button_select == 1{
	//绘制武器栏位文字
	draw_set_halign(fa_left);
	draw_set_valign(fa_middle);
	draw_set_color(c_white);
	draw_text(x - 1220, y - 380, "主武器");
	draw_text(x - 1220, y -120, "副武器");
	draw_text(x - 1220, y + 140, "超级武器");
	draw_set_color(c_white);
	draw_set_halign(fa_left);
	draw_set_valign(fa_bottom);
	draw_set_font(font_yuan)
	//绘制武器栏位
	for(var i = 0;i < 3; i++){
		draw_sprite_ext(spr_package_weapon_bg, 0, x-1180, y-320+260*i, 1, 1, 0, c_white, 1)
		for(var j = 0; j < 4 ; j++){
			draw_sprite_ext(spr_package_gem_bg, 0, x-1180+200*j, y-220+260*i, 0.9, 0.9, 0, c_white, 1)
		}
	}
	if global.save_data.equipped_items.main_weapon.id != ""{
		var main_weapon_icon = get_weapon_info(global.save_data.equipped_items.main_weapon.id).icon
		draw_sprite_ext(main_weapon_icon,0,x-1180,y-320,1,1,0,c_white,1)
		var gem_list = global.save_data.equipped_items.main_weapon.gems
		for(var i = 0 ; i < array_length(gem_list);i++){
			var gem_icon = get_gem_info(gem_list[i]).icon
			var _gs = 88 * 0.85 / sprite_get_width(gem_icon)
			draw_sprite_ext(gem_icon,0,x-1180+200*i,y-220,_gs,_gs,0,c_white,1)
			if get_gem_level(gem_list[i]) > 0{
				draw_sprite_ext(spr_star_slot, get_gem_level(gem_list[i])-1, x-1205+200*i, y-246, 0.8, 0.8, 0, c_white, 1)
			}
		}
	}
	if global.save_data.equipped_items.secondary_weapon.id != ""{
		var main_weapon_icon = get_weapon_info(global.save_data.equipped_items.secondary_weapon.id).icon
		draw_sprite_ext(main_weapon_icon,0,x-1180,y-60,1,1,0,c_white,1)
		var gem_list = global.save_data.equipped_items.secondary_weapon.gems
		for(var i = 0 ; i < array_length(gem_list);i++){
			var gem_icon = get_gem_info(gem_list[i]).icon
			var _gs = 88 * 0.85 / sprite_get_width(gem_icon)
			draw_sprite_ext(gem_icon,0,x-1180+200*i,y+40,_gs,_gs,0,c_white,1)
			if get_gem_level(gem_list[i]) > 0{
				draw_sprite_ext(spr_star_slot, get_gem_level(gem_list[i])-1, x-1205+200*i, y+14, 0.8, 0.8, 0, c_white, 1)
			}
		}
	}
	if global.save_data.equipped_items.super_weapon.id != ""{
		var main_weapon_icon = get_weapon_info(global.save_data.equipped_items.super_weapon.id).icon
		draw_sprite_ext(main_weapon_icon,0,x-1180,y+200,1,1,0,c_white,1)
		var gem_list = global.save_data.equipped_items.super_weapon.gems
		for(var i = 0 ; i < array_length(gem_list);i++){
			var gem_icon = get_gem_info(gem_list[i]).icon
			var _gs = 88 * 0.85 / sprite_get_width(gem_icon)
			draw_sprite_ext(gem_icon,0,x-1180+200*i,y+300,_gs,_gs,0,c_white,1)
			if get_gem_level(gem_list[i]) > 0{
				draw_sprite_ext(spr_star_slot, get_gem_level(gem_list[i])-1, x-1205+200*i, y+274, 0.8, 0.8, 0, c_white, 1)
			}
		}
	}
	//draw_sprite_ext(spr_attack_gem,0,x-1180,y-220,1.5,1.5,0,c_white,1)
}
else if info_button_select == 2{
	//绘制解锁信息
	draw_set_halign(fa_left);
	draw_set_valign(fa_middle);
	draw_set_color(c_white);
	draw_text(x - 1220, y - 380, "等级："+string(global.save_data.player.level));
	draw_text(x - 1220, y - 320, "最大技能等级："+string(global.save_data.unlocked_items.max_skill_level));
	draw_text(x - 1220, y - 260, "卡槽数："+string(global.save_data.unlocked_items.max_slot));
	draw_text(x - 1220, y - 200, "铲子："+string(global.save_data.unlocked_items.shovel));
	draw_set_color(c_white);
	draw_set_halign(fa_left);
	draw_set_valign(fa_bottom);
	draw_set_font(font_yuan)
}
else if info_button_select == 3{
	//绘制解锁信息
	draw_set_halign(fa_left);
	draw_set_valign(fa_middle);
	draw_set_color(c_white);
	if global.save_data.player.crown_version != "0.0.0"{
		draw_sprite_ext(spr_player_crown_icon,0,x-1180,y-350,1.8,1.8,0,c_white,1)
		draw_text(x - 1120, y - 350,$"你在v{global.save_data.player.crown_version}通关了全部魔塔关卡。");
	}
	else{
		draw_text(x - 1220, y - 380, "你还没有完成全部魔塔关卡。");
	}
	draw_set_color(c_white);
	draw_set_halign(fa_left);
	draw_set_valign(fa_bottom);
	draw_set_font(font_yuan)
}
draw_set_alpha(1);
if (pg_t_r >= 0) {
	pg_t_r++;
	if (pg_t_r > pg_frames) pg_t_r = -1;
}
var _pg_alpha_r = (pg_t_r >= 0) ? 1 - power(1 - pg_t_r / pg_frames, 3) : 1;
if package_button_select == 1 {
	if surface_exists(package_surface){
		surface_set_target(package_surface)
		draw_clear_alpha(c_black,0)
	}
    
    // 绘制所有已注册的植物卡片
    var card_index = 0;
    hover_card_index = -1; // 重置悬停卡片索引

    // 计算排序索引：普通卡在前 → 融合卡居中 → 金卡集中放最后
    deck_sort_order = []
    var _fusion_order = []
    var _gold_order = []
    for(var si = 0; si < ds_list_size(global.player_deck); si += 2) {
        if (global.player_deck[| si] == "lihe" && !is_random_gift_mode()) continue;
        var _entry = global.player_deck[| si+1]
        var _shapes = _entry[? "shapes"]
        var _data = _shapes[| 0]
        if (is_fusion_card(global.player_deck[| si])) {
            array_push(_fusion_order, si)
        } else if (ds_map_find_value(_data, "is_gold") == 1) {
            array_push(_gold_order, si)
        } else {
            array_push(deck_sort_order, si)
        }
    }
    for(var si = 0; si < array_length(_fusion_order); si++) {
        array_push(deck_sort_order, _fusion_order[si])
    }
    for(var si = 0; si < array_length(_gold_order); si++) {
        array_push(deck_sort_order, _gold_order[si])
    }

    // 计算实际总行数
    var _total_card_rows = ceil(array_length(deck_sort_order) / package_cols)
    if (_total_card_rows < package_rows) _total_card_rows = package_rows
    // 计算最大滚动偏移
    max_y_offset_1 = max(0, (_total_card_rows - 8) * 96)
    // 限制 y_offset 在有效范围内
    if (y_offset > max_y_offset_1) y_offset = max_y_offset_1
    if (y_offset < 0) y_offset = 0

    // 绘制背景格子
    for(var i = 0 ; i < package_cols ; i++){
        for(var j = 0 ; j < _total_card_rows ; j++){
            draw_sprite_ext(spr_package_slot_bg, 0, 42+i*84,  48+96 * j-y_offset, 0.9, 0.9, 0, c_white, 1)
        }
    }

    for(var di = 0; di < array_length(deck_sort_order); di++) {
        var i = deck_sort_order[di]
        var card_id = global.player_deck[| i];
        var deck_entry = global.player_deck[| i+1];
		var card_data_shapes = deck_entry[? "shapes"]
		var card_data = {}
		var card_shape = 0
		//view_max_shapes = ds_list_size(card_data_shapes)-1
        
        // 计算卡片位置
        var row = card_index div package_cols;
        var col = card_index mod package_cols;
        
        // 只绘制可视区域附近的卡片（优化性能，但允许滚动显示所有卡片）
        var _card_draw_y = 48 + 2 + row * 96 - y_offset;
        if (_card_draw_y > -100 && _card_draw_y < 875) {
            var card_x = 42 + col * 84;
            var card_y = _card_draw_y;
            
            // 检查卡片是否已解锁
            var is_unlocked = false;
            for(var k = 0; k < array_length(global.save_data.unlocked_cards); k++) {
                if (global.save_data.unlocked_cards[k].id == card_id) {
                    is_unlocked = true;
					card_shape = global.save_data.unlocked_cards[k].shape
					if (card_shape >= ds_list_size(card_data_shapes)) card_shape = ds_list_size(card_data_shapes) - 1;
					card_data = card_data_shapes[| card_shape]
                    break;
                }
            }
            
            // 绘制卡片
            if (is_unlocked) {
                // 已解锁的卡片正常绘制
				var _slot_spr = is_fusion_card(card_id) ? spr_slot_2 : ((ds_map_find_value(card_data, "is_gold") == 1) ? spr_slot_1 : spr_slot);
				draw_sprite_ext(_slot_spr, 0, card_x, card_y-3, 0.25, 0.25, 0, c_white, 1);
                draw_sprite_ext(card_data[? "sprite"], 0, card_x, card_y+15, 0.7, 0.7, 0, c_white, 1);
				draw_set_color(c_black);
				draw_set_halign(fa_center);
				draw_set_valign(fa_bottom);
				draw_set_font(font_pixel)
				draw_text(card_x,card_y+37,card_data[? "cost"])
				draw_set_font(font_yuan)
				var length = array_length(global.save_data.unlocked_cards)
				var info_index = 0
				for (var j = 0;j < length;j++){
					if global.save_data.unlocked_cards[j].id == card_id{
						info_index = j
						break
					}
				}
				var level = global.save_data.unlocked_cards[info_index].level
				if level > 0{
					draw_sprite_ext(spr_star_slot,  level - 1,  card_x-25,  card_y-35, 0.7, 0.7, 0, c_white, 1);
				}
                // 检查鼠标是否悬停在卡片上
                var spr_width = 84;
                var spr_height = 96;
                
				var hover_card_x = x-354 + col * 84;
				var hover_card_y = y-359+row * 96 - y_offset;
				
                if (point_in_rectangle(mouse_x, mouse_y, 
                                      hover_card_x - spr_width/2, hover_card_y - spr_height/2,
                                      hover_card_x + spr_width/2, hover_card_y + spr_height/2))
				&& mouse_y > y-405 && mouse_y < y + 385{
                    hover_card_index = card_index;
                }
            } else {
                // 未解锁的卡片使用灰色滤镜
                card_data = card_data_shapes[| card_shape]
				var _slot_spr2 = is_fusion_card(card_id) ? spr_slot_2 : ((ds_map_find_value(card_data, "is_gold") == 1) ? spr_slot_1 : spr_slot);
				draw_sprite_ext(_slot_spr2, 0, card_x, card_y-3, 0.25, 0.25, 0, c_gray, 1);
                draw_sprite_ext(card_data[? "sprite"], 0, card_x, card_y+15, 0.7, 0.7, 0, c_gray, 1);
            }
        }
        
        card_index++;
    }
	
	surface_reset_target()
	draw_surface_ext(package_surface,x-354-42,y-361-48,1,1,0,c_white,_pg_alpha_r)
    
    // 绘制悬停提示
    if (hover_card_index != -1 && !instance_exists(obj_craft_bg)) {
        // 获取鼠标位置
        var tooltip_x = mouse_x + 15;
        var tooltip_y = mouse_y + 15;
		
		var tooltip_text = "左键点击调节卡片\n右键点击查看情报"
        
        draw_set_font(font_yuan);
        tooltip_set(tooltip_x, tooltip_y, tooltip_text, 1);
    }
}
else if package_button_select == 2 {
	if surface_exists(package_surface){
		surface_set_target(package_surface)
		draw_clear_alpha(c_black,0)
	}

	hover_weapon_index = -1
	hover_gem_index = -1

	// 需要分组显示的mod武器：每把武器单独一格子，同列下方放该武器的专属宝石
	var _mod_weapon_ids = ["zeus_bolt","master_shield","hades_scythe","aladdin_lamp","rose_shield","star_wand"]
	var _group_col = 0
	var _group_end_row = 0
	var _drawn_gem_indices = []

	// === 先计算总行数 ===
	var _calc_group_end_row = 0
	var _calc_flat_weapon_count = 0
	var _calc_flat_gem_count = 0

	// 计算分组区最大行数
	for (var cwi = 0; cwi < array_length(_mod_weapon_ids); cwi++) {
		var _cw_id = _mod_weapon_ids[cwi]
		var _cuw_idx = -1
		for (var ck = 0; ck < array_length(global.save_data.unlocked_weapons); ck++) {
			if (global.save_data.unlocked_weapons[ck].id == _cw_id) { _cuw_idx = ck; break; }
		}
		if (_cuw_idx == -1) continue
		var _cgem_count = 0
		for (var cgi = 0; cgi < array_length(global.save_data.unlocked_gems); cgi++) {
			var _cgem_id = global.save_data.unlocked_gems[cgi].id
			var _cgem_data = get_gem_info(_cgem_id)
			if (is_undefined(_cgem_data)) continue
			if (!variable_struct_exists(_cgem_data, "allowed_weapons")) continue
			var _cbelongs = false
			for (var caw = 0; caw < array_length(_cgem_data.allowed_weapons); caw++) {
				if (_cgem_data.allowed_weapons[caw] == _cw_id) { _cbelongs = true; break; }
			}
			if (_cbelongs) _cgem_count++
		}
		var _ccol_height = 1 + _cgem_count
		if (_ccol_height > _calc_group_end_row) _calc_group_end_row = _ccol_height
	}
	// 计算平铺区武器数量
	for (var ci = 0; ci < array_length(global.save_data.unlocked_weapons); ci++) {
		var _cw_id = global.save_data.unlocked_weapons[ci].id
		var _cis_mod = false
		for (var cmi = 0; cmi < array_length(_mod_weapon_ids); cmi++) {
			if (_mod_weapon_ids[cmi] == _cw_id) { _cis_mod = true; break; }
		}
		if (!_cis_mod) _calc_flat_weapon_count++
	}
	// 计算平铺区宝石数量
	for (var cgi2 = 0; cgi2 < array_length(global.save_data.unlocked_gems); cgi2++) {
		var _cgem_id2 = global.save_data.unlocked_gems[cgi2].id
		var _cgem_data2 = get_gem_info(_cgem_id2)
		if (is_undefined(_cgem_data2)) continue
		if (!variable_struct_exists(_cgem_data2, "allowed_weapons")) {
			_calc_flat_gem_count++
			continue
		}
		var _cis_mod_gem = false
		for (var caw2 = 0; caw2 < array_length(_cgem_data2.allowed_weapons); caw2++) {
			for (var cmi2 = 0; cmi2 < array_length(_mod_weapon_ids); cmi2++) {
				if (_cgem_data2.allowed_weapons[caw2] == _mod_weapon_ids[cmi2]) {
					_cis_mod_gem = true
					break
				}
			}
			if (_cis_mod_gem) break
		}
		if (!_cis_mod_gem) _calc_flat_gem_count++
	}
	var _calc_total_flat = _calc_flat_weapon_count + _calc_flat_gem_count
	var _calc_total_rows_2 = _calc_group_end_row + ceil(_calc_total_flat / package_cols)
	if (_calc_total_rows_2 < package_rows) _calc_total_rows_2 = package_rows
	// 计算最大滚动偏移并限制 y_offset
	max_y_offset_2 = max(0, (_calc_total_rows_2 - 9) * 88)
	if (y_offset > max_y_offset_2) y_offset = max_y_offset_2
	if (y_offset < 0) y_offset = 0

	// 绘制武器背包格子背景
	for(var i = 0 ; i < package_cols ; i++){
		for(var j = 0 ; j < _calc_total_rows_2 ; j++){
			draw_sprite_ext(spr_package_slot_bg, 1, 42+i*84, 44 + 88 * j - y_offset, 0.9, 0.9, 0, c_white, 1)
		}
	}

	// 分组区：mod武器 + 其专属宝石（按列分组）
	for (var wi = 0; wi < array_length(_mod_weapon_ids); wi++) {
		var _w_id = _mod_weapon_ids[wi]
		// 查找该武器是否已解锁
		var _uw_idx = -1
		for (var k = 0; k < array_length(global.save_data.unlocked_weapons); k++) {
			if (global.save_data.unlocked_weapons[k].id == _w_id) { _uw_idx = k; break; }
		}
		if (_uw_idx == -1) continue

		var _weapon_data = global.weapon_pool[? _w_id]
		if (is_undefined(_weapon_data)) continue

		var _col = _group_col
		var _row = 0
		var _wx = 42 + _col * 84
		var _wy = 44 + _row * 88 - y_offset

		var _is_equipped = is_weapon_equipped(_w_id)
		if (_is_equipped) {
			draw_sprite_ext(spr_package_slot_bg, 1, _wx, _wy, 0.9, 0.9, 0, c_yellow, 1)
			draw_sprite_ext(_weapon_data.icon, 0, _wx, _wy, 1, 1, 0, c_white, 1)
		} else {
			draw_sprite_ext(spr_package_slot_bg, 1, _wx, _wy, 0.9, 0.9, 0, c_white, 1)
			draw_sprite_ext(_weapon_data.icon, 0, _wx, _wy, 1, 1, 0, c_white, 1)
		}
		// 武器悬停检测
		var _hw_x = x - 354 + _col * 84
		var _hw_y = y - 368 + _row * 88 - y_offset
		if (point_in_rectangle(mouse_x, mouse_y, _hw_x - 42, _hw_y - 44, _hw_x + 42, _hw_y + 44))
		&& mouse_y > y-405 && mouse_y < y + 385 {
			hover_weapon_index = _uw_idx
		}

		// 该武器的专属宝石（同列，逐行向下放置）
		var _gem_row = 1
		for (var gi = 0; gi < array_length(global.save_data.unlocked_gems); gi++) {
			var _gem_id = global.save_data.unlocked_gems[gi].id
			var _gem_data = get_gem_info(_gem_id)
			if (is_undefined(_gem_data)) continue
			if (!variable_struct_exists(_gem_data, "allowed_weapons")) continue
			var _belongs = false
			for (var aw = 0; aw < array_length(_gem_data.allowed_weapons); aw++) {
				if (_gem_data.allowed_weapons[aw] == _w_id) { _belongs = true; break; }
			}
			if (!_belongs) continue

			array_push(_drawn_gem_indices, gi)
			var _gx = 42 + _col * 84
			var _gy = 44 + _gem_row * 88 - y_offset
			var _gs = 88 * 0.7 / sprite_get_width(_gem_data.icon)
			var _g_equipped = (get_gem_index(_gem_id) != -1)
			var _can_equip = can_equip_gem(_gem_id)
			if (_g_equipped) {
				draw_sprite_ext(spr_package_slot_bg, 1, _gx, _gy, 0.9, 0.9, 0, c_yellow, 1)
				draw_sprite_ext(_gem_data.icon, 0, _gx, _gy, _gs, _gs, 0, c_white, 1)
			} else if (!_can_equip) {
				draw_sprite_ext(spr_package_slot_bg, 1, _gx, _gy, 0.9, 0.9, 0, c_dkgray, 1)
				draw_sprite_ext(_gem_data.icon, 0, _gx, _gy, _gs, _gs, 0, c_gray, 1)
			} else {
				draw_sprite_ext(spr_package_slot_bg, 1, _gx, _gy, 0.9, 0.9, 0, c_white, 1)
				draw_sprite_ext(_gem_data.icon, 0, _gx, _gy, _gs, _gs, 0, c_white, 1)
			}
			if (get_gem_level(_gem_id) > 0) {
				draw_sprite_ext(spr_star_slot, get_gem_level(_gem_id)-1, _gx-28, _gy-30, 0.7, 0.7, 0, c_white, 1)
			}
			// 宝石悬停检测
			var _hg_x = x - 354 + _col * 84
			var _hg_y = y - 368 + _gem_row * 88 - y_offset
			if (point_in_rectangle(mouse_x, mouse_y, _hg_x - 42, _hg_y - 44, _hg_x + 42, _hg_y + 44))
			&& mouse_y > y-405 && mouse_y < y + 385 {
				hover_gem_index = gi
			}
			_gem_row++
		}

		if (_gem_row > _group_end_row) _group_end_row = _gem_row
		_group_col++
	}

	// 平铺区：其余武器（非mod武器），紧接分组区下方
	var _flat_index = 0
	for (var i = 0; i < array_length(global.save_data.unlocked_weapons); i++) {
		var _w_id = global.save_data.unlocked_weapons[i].id
		var _is_mod = false
		for (var mi = 0; mi < array_length(_mod_weapon_ids); mi++) {
			if (_mod_weapon_ids[mi] == _w_id) { _is_mod = true; break; }
		}
		if (_is_mod) continue

		var _weapon_data = global.weapon_pool[? _w_id]
		if (is_undefined(_weapon_data)) continue

		var _row = _group_end_row + (_flat_index div package_cols)
		var _col = _flat_index mod package_cols
		var _wy = 44 + _row * 88 - y_offset

		// 只绘制可视区域附近的武器
		if (_wy > -100 && _wy < 875) {
		var _wx = 42 + _col * 84
		var _is_equipped = is_weapon_equipped(_w_id)
		if (_is_equipped) {
			draw_sprite_ext(spr_package_slot_bg, 1, _wx, _wy, 0.9, 0.9, 0, c_yellow, 1)
			draw_sprite_ext(_weapon_data.icon, 0, _wx, _wy, 1, 1, 0, c_white, 1)
		} else {
			draw_sprite_ext(spr_package_slot_bg, 1, _wx, _wy, 0.9, 0.9, 0, c_white, 1)
			draw_sprite_ext(_weapon_data.icon, 0, _wx, _wy, 1, 1, 0, c_white, 1)
		}
		var _hw_x = x - 354 + _col * 84
		var _hw_y = y - 368 + _row * 88 - y_offset
		if (point_in_rectangle(mouse_x, mouse_y, _hw_x - 42, _hw_y - 44, _hw_x + 42, _hw_y + 44))
		&& mouse_y > y-405 && mouse_y < y + 385 {
			hover_weapon_index = i
		}
		} // 可视区域判断结束
		_flat_index++
	}

	// 平铺区：其余宝石（非mod专属宝石）
	for (var i = 0; i < array_length(global.save_data.unlocked_gems); i++) {
		var _already_drawn = false
		for (var di = 0; di < array_length(_drawn_gem_indices); di++) {
			if (_drawn_gem_indices[di] == i) { _already_drawn = true; break; }
		}
		if (_already_drawn) continue

		var _gem_id = global.save_data.unlocked_gems[i].id
		var _gem_data = get_gem_info(_gem_id)
		if (is_undefined(_gem_data)) continue

		var _row = _group_end_row + (_flat_index div package_cols)
		var _col = _flat_index mod package_cols
		var _gy = 44 + _row * 88 - y_offset

		// 只绘制可视区域附近的宝石
		if (_gy > -100 && _gy < 875) {
		var _gx = 42 + _col * 84
		var _gs = 88 * 0.7 / sprite_get_width(_gem_data.icon)
		var _g_equipped = (get_gem_index(_gem_id) != -1)
		var _can_equip = can_equip_gem(_gem_id)
		if (_g_equipped) {
			draw_sprite_ext(spr_package_slot_bg, 1, _gx, _gy, 0.9, 0.9, 0, c_yellow, 1)
			draw_sprite_ext(_gem_data.icon, 0, _gx, _gy, _gs, _gs, 0, c_white, 1)
		} else if (!_can_equip) {
			draw_sprite_ext(spr_package_slot_bg, 1, _gx, _gy, 0.9, 0.9, 0, c_dkgray, 1)
			draw_sprite_ext(_gem_data.icon, 0, _gx, _gy, _gs, _gs, 0, c_gray, 1)
		} else {
			draw_sprite_ext(spr_package_slot_bg, 1, _gx, _gy, 0.9, 0.9, 0, c_white, 1)
			draw_sprite_ext(_gem_data.icon, 0, _gx, _gy, _gs, _gs, 0, c_white, 1)
		}
		if (get_gem_level(_gem_id) > 0) {
			draw_sprite_ext(spr_star_slot, get_gem_level(_gem_id)-1, _gx-28, _gy-30, 0.7, 0.7, 0, c_white, 1)
		}
		var _hg_x = x - 354 + _col * 84
		var _hg_y = y - 368 + _row * 88 - y_offset
		if (point_in_rectangle(mouse_x, mouse_y, _hg_x - 42, _hg_y - 44, _hg_x + 42, _hg_y + 44))
		&& mouse_y > y-405 && mouse_y < y + 385 {
			hover_gem_index = i
		}
		} // 可视区域判断结束
		_flat_index++
	}

	surface_reset_target()
	draw_surface_ext(package_surface,x-354-42,y-368-44,1,1,0,c_white,_pg_alpha_r)

	// 绘制悬停提示
	if (hover_weapon_index != -1) {
		var weapon_id = global.save_data.unlocked_weapons[hover_weapon_index].id;
		var weapon_data = global.weapon_pool[? weapon_id];

		if (!is_undefined(weapon_data)) {
			// 获取鼠标位置
			var tooltip_x = mouse_x - 15;
			var tooltip_y = mouse_y - 15;

			// 获取提示文本

			var tooltip_text = ""
			var is_equipped = is_weapon_equipped(weapon_id);
			if (is_equipped) {
				var slot = get_weapon_slot(weapon_id);
				tooltip_text = weapon_data.description + "\n已装备\n左键点击卸下"
			} else {
				tooltip_text = weapon_data.description + "\n左键点击装备"
			}

			draw_set_font(font_yuan);
			tooltip_set(tooltip_x, tooltip_y, tooltip_text, -1);


		}
	}
	if (hover_gem_index != -1) {
		var weapon_id = global.save_data.unlocked_gems[hover_gem_index].id;
		var weapon_data = get_gem_info(weapon_id)

		if (!is_undefined(weapon_data)) {
			// 获取鼠标位置
			var tooltip_x = mouse_x - 15;
			var tooltip_y = mouse_y - 15;

			// 获取提示文本

			var tooltip_text = ""
			var is_equipped = (get_gem_index(weapon_id) != -1)
			var _can_equip = can_equip_gem(weapon_id)
			if (is_equipped) {
				tooltip_text = weapon_data.description + "\n左键点击卸下\n右键点击编辑"
			} else if (!_can_equip) {
				tooltip_text = weapon_data.description + "\n需要装备专属武器才能携带"
			} else {
				tooltip_text = weapon_data.description + "\n左键点击镶嵌\n右键点击编辑"
			}

			draw_set_font(font_yuan);
			tooltip_set(tooltip_x, tooltip_y, tooltip_text, -1);


		}
	}


}
else if package_button_select == 3{
	if surface_exists(package_surface){
		surface_set_target(package_surface)
		draw_clear_alpha(c_black,0)
	}
	// 绘制所有道具
    var material_index = 0;
    hover_material_index = -1; // 重置悬停道具索引
	var material_list = ds_map_keys_to_array(global.material_pool)

	// 计算道具的最大行号
	var _max_mat_row = package_rows - 1
	for (var mi = 0; mi < array_length(material_list); mi++) {
		var _mat_id_tmp = material_list[mi]
		var _mat_data_tmp = get_material_info(_mat_id_tmp)
		if (!is_undefined(_mat_data_tmp)) {
			if (_mat_data_tmp.pos_y > _max_mat_row) _max_mat_row = _mat_data_tmp.pos_y
		}
	}
	var _total_rows_3 = _max_mat_row + 1
	if (_total_rows_3 < package_rows) _total_rows_3 = package_rows
	// 计算最大滚动偏移并限制 y_offset
	max_y_offset_3 = max(0, (_total_rows_3 - 9) * 88)
	if (y_offset > max_y_offset_3) y_offset = max_y_offset_3
	if (y_offset < 0) y_offset = 0

	// 绘制道具背包格子背景
    for(var i = 0 ; i < package_cols ; i++){
        for(var j = 0 ; j < _total_rows_3 ; j++){
            draw_sprite_ext(spr_package_slot_bg, 1, 42+i*84, 44 + 88 * j-y_offset, 0.9, 0.9, 0, c_white, 1)
        }
    }

    for(var i = 0; i < array_length(material_list); i++) {
        var material_id = material_list[i]
        var material_data = get_material_info(material_id)

        if (!is_undefined(material_data)) {
            // 计算道具位置
            var row = material_data.pos_y;
            var col = material_data.pos_x;
            var material_y = 44 + row * 88 - y_offset;

            // 只绘制可视区域附近的道具
            if (material_y > -100 && material_y < 875) {
                var material_x = 42 + col * 84;

                // 跨服徽章使用专属精灵，其他道具使用道具图标
                if (material_id == "cross_server_gold_medal") {
                    draw_sprite_ext(spr_mod_cs_xunzhang, 0, material_x, material_y, 0.9, 0.9, 0, c_white, 1);
                } else if (material_id == "cross_server_silver_medal") {
                    draw_sprite_ext(spr_mod_cs_silver_medal, 0, material_x, material_y, 0.9, 0.9, 0, c_white, 1);
                } else if (material_id == "prestige") {
                    // 威望（转职凭证货币）：独立 44×44 图标，1.8 缩放≈79px，
                    // 跟其它道具（spr_craft_material 88×88 @0.9）视觉尺寸对齐
                    draw_sprite_ext(spr_prestige_icon, 0, material_x, material_y, 1.8, 1.8, 0, c_white, 1);
                } else {
                    var _mat_spr = (material_id == "oracle_stone") ? spr_oriacle_stone :spr_craft_material ;
                    var _mat_idx = (material_id == "oracle_stone") ? 0 : material_data.icon;
                    draw_sprite_ext(_mat_spr, _mat_idx,  material_x,  material_y, 0.9, 0.9,  0,  c_white,  1);
                }
				draw_set_halign(fa_right);
				draw_set_valign(fa_bottom);
				draw_set_colour(c_white)
				draw_set_font(font_number)
				var _display_amount = get_material_amount(material_id);
				if _display_amount < 10000{
					draw_text(material_x+40,material_y+42,string(_display_amount))
				}
				else{
					draw_text(material_x+40,material_y+42,string(floor(_display_amount/10000))+"w")
				}

                // 检查鼠标是否悬停在道具上
                var spr_width = 84;
                var spr_height = 88;

				var hover_material_x = x - 354 + col * 84;
                var hover_material_y = y - 368 + row * 88 - y_offset;

                if (point_in_rectangle(mouse_x, mouse_y,
                                      hover_material_x - spr_width/2, hover_material_y - spr_height/2,
                                      hover_material_x + spr_width/2, hover_material_y + spr_height/2))

				&& mouse_y > y-405 && mouse_y < y + 385{
                    hover_material_index = i;
                }

                material_index++;
            }
        }
    }
	surface_reset_target()
	draw_surface_ext(package_surface,x-354-42,y-368-44,1,1,0,c_white,_pg_alpha_r)
	// 绘制悬停提示
    if (hover_material_index != -1) {
		material_list = ds_map_keys_to_array(global.material_pool)
        var material_id = material_list[hover_material_index]
        var material_data = get_material_info(material_id)

        if (!is_undefined(material_data)) {
            // 获取鼠标位置
            var tooltip_x = mouse_x - 15;
            var tooltip_y = mouse_y - 15;

			// 获取提示文本

            var tooltip_text = ""

			var _tooltip_amount = get_material_amount(material_id);
			tooltip_text = material_data.description + "\n数量："+string(_tooltip_amount)
			// 获取出售价格
			var _sell_price = get_material_sell_price(material_id)
			if _sell_price > 0 && _tooltip_amount > 0{
				tooltip_text += "\n出售价格：" + string(_sell_price) + "G/个"
				tooltip_text += "\n左键点击出售"
			}


			draw_set_font(font_yuan);
			tooltip_set(tooltip_x, tooltip_y, tooltip_text, -1);


        }
    }
}
// 转职凭证页（第 4 页签）
else if package_button_select == 4{
	if surface_exists(package_surface){
		surface_set_target(package_surface)
		draw_clear_alpha(c_black,0)
	}
	// 只列背包里持有（数量 > 0）的凭证，不遍历 material_pool
	var _tc_list = transfer_credit_owned_ids()
	var _tc_n = array_length(_tc_list)
	// 方案 B：一转段画完**强制换行**，二转段从下一行第 1 格开始（中间不空行）
	var _tc_split = transfer_credit_split_index(_tc_list)
	var _tc_two_start = ceil(_tc_split / package_cols) * package_cols
	var _tc_cells = _tc_two_start + (_tc_n - _tc_split)
	var _tc_rows = max(1, ceil(_tc_cells / package_cols))
	if (_tc_rows < package_rows) _tc_rows = package_rows
	max_y_offset_4 = max(0, (_tc_rows - 9) * 88)
	if (y_offset > max_y_offset_4) y_offset = max_y_offset_4
	if (y_offset < 0) y_offset = 0

	// 格子底
	for (var i = 0; i < package_cols; i++) {
		for (var j = 0; j < _tc_rows; j++) {
			draw_sprite_ext(spr_package_slot_bg, 1, 42+i*84, 44 + 88*j - y_offset, 0.9, 0.9, 0, c_white, 1)
		}
	}

	hover_transfer_index = -1
	for (var i = 0; i < _tc_n; i++) {
		var _tid = _tc_list[i]
		// 格位下标（不是列表下标）：二转段整体后移一个整行
		var _slot_i = (i < _tc_split) ? i : (_tc_two_start + i - _tc_split)
		var _col = _slot_i mod package_cols
		var _row = _slot_i div package_cols
		var _tx = 42 + _col * 84
		var _ty = 44 + _row * 88 - y_offset
		if (_ty > -100 && _ty < 875) {
			// ⚠️ _tx/_ty 是**格子中心**（跟道具页同一套坐标：42+i*84 / 44+88*j）
			//    transfer_credit_draw 的 (x,y) 是左上角 → 中心减半格（74/2=37）
			//    74 而不是铺满的 88：四周留 ~5px 边，跟道具页图标（79）同尺寸感
			transfer_credit_draw_id(_tx - 37, _ty - 37, _tid, 74)

			draw_set_halign(fa_right)
			draw_set_valign(fa_bottom)
			draw_set_colour(c_white)
			draw_set_font(font_number)
			var _amt = get_material_amount(_tid)
			if _amt < 10000 draw_text(_tx + 40, _ty + 42, string(_amt))
			else draw_text(_tx + 40, _ty + 42, string(floor(_amt / 10000)) + "w")

			var _hx = x - 354 + _col * 84
			var _hy = y - 368 + _row * 88 - y_offset
			if (point_in_rectangle(mouse_x, mouse_y, _hx - 42, _hy - 44, _hx + 42, _hy + 44))
			&& mouse_y > y-405 && mouse_y < y + 385{
				hover_transfer_index = i
			}
		}
	}
	surface_reset_target()
	draw_surface_ext(package_surface, x - 354 - 42, y - 368 - 44, 1, 1, 0, c_white, _pg_alpha_r)

	// 悬停提示
	if (hover_transfer_index != -1 && hover_transfer_index < _tc_n) {
		var _hid = _tc_list[hover_transfer_index]
		var _hp = transfer_credit_parse(_hid)
		if (!is_undefined(_hp)) {
			// 不写「数量」：凭证上限按最大持有 1（2026-10-26 用户），格子里右下角已经有数字
			var _tt = transfer_credit_name(_hp.card_id, _hp.shape) + "\n"
				+ "转职凭证：在合成屋-卡片转职中使用"
			draw_set_font(font_yuan)
			tooltip_set(mouse_x - 15, mouse_y - 15, _tt, -1)
		}
	}
}

// 重置绘制设置
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_alpha(1);
tooltip_draw();
var _sb_scl = 2.2;
var _sb_w = sprite_get_width(spr_info_island_scroll_bar) * _sb_scl;
var _sb_h = sprite_get_height(spr_info_island_scroll_bar) * _sb_scl;
var _sb_l = x - 354 - 42;
var _sb_t = (package_button_select == 1) ? (y - 361 - 48) : (y - 368 - 44);
var _sb_x = _sb_l + 756 - _sb_w + 28 + _sb_w * 0.5;
var _sb_vh = 775;
var _sb_max = 0;
if (package_button_select == 1) {
	_sb_max = variable_instance_exists(id, "max_y_offset_1") ? max_y_offset_1 : max(0, (package_rows - 8) * 96);
} else if (package_button_select == 2) {
	_sb_max = variable_instance_exists(id, "max_y_offset_2") ? max_y_offset_2 : max(0, (package_rows - 9) * 88);
} else if (package_button_select == 4) {
	_sb_max = variable_instance_exists(id, "max_y_offset_4") ? max_y_offset_4 : max(0, (package_rows - 9) * 88);
} else {
	_sb_max = variable_instance_exists(id, "max_y_offset_3") ? max_y_offset_3 : max(0, (package_rows - 9) * 88);
}
if (ui_anim_on(1)) {
	y_offset += (y_offset_target - y_offset) * 0.28;
	if (abs(y_offset_target - y_offset) < 0.5) y_offset = y_offset_target;
} else {
	y_offset = y_offset_target;
}
if (_sb_max > 0 && _sb_vh > _sb_h) {
	var _sb_travel = _sb_vh - _sb_h;
	var _sb_y = _sb_t + clamp(y_offset / _sb_max, 0, 1) * _sb_travel;
	draw_sprite_ext(spr_info_island_scroll_bar, 0, _sb_x, _sb_y, _sb_scl, _sb_scl, 0, c_white, 1);
	if (mouse_check_button_pressed(mb_left)) {
		if (point_in_rectangle(mouse_x, mouse_y, _sb_x, _sb_y, _sb_x + _sb_w, _sb_y + _sb_h)) {
			sb_dragging = true;
			sb_drag_y = mouse_y;
			sb_drag_offset = y_offset;
		} else if (point_in_rectangle(mouse_x, mouse_y, _sb_x, _sb_t, _sb_x + _sb_w, _sb_t + _sb_vh)) {
			y_offset_target = clamp((mouse_y - _sb_t - _sb_h * 0.5) / _sb_travel * _sb_max, 0, _sb_max);
		}
	}
	if (sb_dragging && mouse_check_button(mb_left)) {
		y_offset = clamp(sb_drag_offset + (mouse_y - sb_drag_y) * (_sb_max / _sb_travel), 0, _sb_max);
		y_offset_target = y_offset;
	}
	if (mouse_check_button_released(mb_left)) sb_dragging = false;
}
panel_anim_end_split(id, 951, 260)
