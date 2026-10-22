panel_anim_step(id)
if (!instance_exists(id)) { exit }
draw_set_alpha(0.5 * ui_anim_alpha(id));
// 绘制半透明遮罩
draw_rectangle_color(0, 0, room_width, room_height, c_black, c_black, c_black, c_black, false);
draw_set_alpha(1);
// 基底（外框 + 面板底色）：固定不动、不参与滑动，所以画在 surface 之前（在遮罩之上、三层之下）
draw_sprite_ext(spr_craft_bg_base, 0, x, y, image_xscale, image_yscale, 0, c_white, image_alpha * ui_anim_alpha(id))
panel_anim_begin(id)
// 背景拆成三层（外框在基底里，收尾时另外画，不参与滑动）
draw_sprite_ext(spr_craft_bg_left,  0, x, y, image_xscale, image_yscale, 0, c_white, image_alpha)
draw_sprite_ext(spr_craft_bg_right, 0, x, y, image_xscale, image_yscale, 0, c_white, image_alpha)
draw_sprite_ext(spr_craft_bg_bar,   0, x, y, image_xscale, image_yscale, 0, c_white, image_alpha)

// 强化选项固定显示在合成面板顶部，不随卡片列表滚动。
var _rate_settings = craft_rate_settings()
var _rate_on = _rate_settings.enabled
var _toggle_frame = _rate_on ? 1 : 0
draw_sprite_ext(spr_craft_rate_check, _toggle_frame, rate_toggle_x, rate_toggle_y, 1.4, 1.4, 0, c_white, 1)
if (rate_toggle_hover) {
    draw_set_alpha(0.25)
    draw_rectangle(rate_toggle_x - 18, rate_toggle_y - 18, rate_toggle_x + 18, rate_toggle_y + 18, false)
    draw_set_alpha(1)
}
draw_set_font(font_yuan)
draw_set_valign(fa_middle)
draw_set_halign(fa_left)
var _rate_color = _rate_on ? make_colour_rgb(35, 165, 55) : make_colour_rgb(205, 40, 30)
draw_set_colour(c_black)
draw_text(rate_toggle_x + 25, rate_toggle_y + 1, "概率强化")
draw_set_colour(_rate_color)
draw_text(rate_toggle_x + 26, rate_toggle_y, "概率强化")

draw_set_colour(c_white)
draw_set_valign(fa_top)
draw_set_halign(fa_left)

if (button_select == 0) {
    var _assure_off = !_rate_on
    if (_assure_off) draw_set_alpha(0.45)
    var _assure_frame = _rate_settings.assure_enabled ? 1 : 0
    draw_sprite_ext(spr_craft_insure_badge, 0, assure_badge_cx, assure_badge_cy, 1.5, 1.5, 0, c_white, 1)
    if (assure_toggle_hover && !_assure_off) {
        draw_set_alpha(0.25)
        draw_rectangle(assure_badge_cx - 33, assure_badge_cy - 36, assure_badge_cx + 33, assure_toggle_y + 18, false)
        draw_set_alpha(1)
    }
    draw_set_font(font_yuan)
    draw_set_valign(fa_middle)
    draw_set_halign(fa_center)
    draw_set_colour(c_black)
    draw_text(assure_badge_cx + 1, assure_badge_cy + 26, "金币")
    draw_set_colour(make_colour_rgb(255, 150, 60))
    draw_text(assure_badge_cx, assure_badge_cy + 25, "金币")
    draw_set_colour(c_white)
    draw_set_valign(fa_top)
    draw_set_halign(fa_left)
    draw_sprite_ext(spr_craft_rate_check, _assure_frame, assure_toggle_x, assure_toggle_y, 1.4, 1.4, 0, c_white, 1)
    if (_assure_off) draw_set_alpha(1)
}

// 需金币（左）与成功率（右）同一排：两条都用 spr_craft_gold_require_bg 贴图（原点在右端）
draw_sprite_ext(spr_craft_gold_require_bg,0,x-350,y+300,1.8,1.8,0,c_white,1)

// 成功率栏（右条）：框 = spr_craft_gold_require_bg 换过来画 + 空白段盖掉自带"需金币:"
// 标签用 spr_craft_rate_label（条内左侧，与隔壁金币条自带的"需金币:"排法一致），数值仍用字体
var _rr_bar_x = x - 45
var _rr_bar_y = y + 300
var _rr_bar_left = _rr_bar_x - 230.4      // 条子左缘（128*1.8，原点在右端）
var _rr_bar_ix = _rr_bar_left + 3.6       // 框内区左缘（2 像素 * 1.8）
var _rr_bar_iy = _rr_bar_y - 18           // 框内区上缘（整条高 20*1.8）
var _rr_set = craft_rate_settings()
var _rr_base = 100
var _rr_streak = 0
var _rr_bonus = 0
var _rr_text = "100%"
if _rr_set.enabled{
	_rr_text = "--"
	if current_uprade_target_id != ""{
		if button_select == 0{
			var _rr_card = get_card_info_simple(current_uprade_target_id)
			if _rr_card != false{
				_rr_base = get_card_craft_rate_base(current_uprade_target_id, _rr_card.max_level+1)
				_rr_streak = get_card_fail_streak(current_uprade_target_id)
				_rr_bonus = get_card_craft_bonus(current_uprade_target_id)
			}
		}
		else{
			_rr_base = get_gem_craft_rate_base(current_uprade_target_id, get_gem_max_level(current_uprade_target_id)+1)
			_rr_streak = get_gem_fail_streak(current_uprade_target_id)
			_rr_bonus = get_gem_craft_bonus(current_uprade_target_id)
		}
		if _rr_set.pity_guarantee > 0 && _rr_streak >= _rr_set.pity_guarantee{
			_rr_text = "必成"
		}
		else if _rr_bonus > 0{
			_rr_text = string_format(_rr_base,1,2)+"%+"+string_format(_rr_bonus,1,2)+"%"
		}
		else{
			_rr_text = string_format(_rr_base,1,2)+"%"
		}
	}
}
draw_sprite_ext(spr_craft_gold_require_bg, 0, _rr_bar_x, _rr_bar_y, 1.8, 1.8, 0, c_white, 1)
// 用同一贴图的空白段（x=90 起的 4x20 整列）把框上自带的"需金币:"盖掉 → 变成空条
// 横向拉到 88 像素（＝90-2）宽，左端留 2 像素不盖，保住左边的圆角描边
draw_sprite_part_ext(spr_craft_gold_require_bg, 0, 90, 0, 4, 20, _rr_bar_ix, _rr_bar_iy, 39.6, 1.8, c_white, 1)
draw_sprite_ext(spr_craft_rate_label, 0, _rr_bar_left + 10, _rr_bar_y, 1.5, 1.5, 0, c_white, 1)
// 数值：白字 + 四向深色描边
draw_set_font(font_number)
draw_set_valign(fa_middle)
draw_set_halign(fa_center)
var _rr_text_x = _rr_bar_left + 150
draw_set_colour(c_black)
draw_text(_rr_text_x-1, _rr_bar_y-1, _rr_text)
draw_text(_rr_text_x+1, _rr_bar_y-1, _rr_text)
draw_text(_rr_text_x-1, _rr_bar_y+1, _rr_text)
draw_text(_rr_text_x+1, _rr_bar_y+1, _rr_text)
draw_set_colour(c_white)
draw_text(_rr_text_x, _rr_bar_y, _rr_text)
draw_set_colour(c_white)
draw_set_valign(fa_top)
draw_set_halign(fa_left)

draw_set_font(font_number)
draw_set_colour(c_yellow)
draw_set_valign(fa_middle)
draw_set_halign(fa_left)
//draw_text(x-160,y+300,"300")
draw_set_halign(fa_right)
draw_text(x+758,y+473,string(global.save_data.player.gold))
draw_set_colour(c_white)
draw_set_valign(fa_top)
draw_set_halign(fa_left)
for(var i = 0 ; i < 10 ; i++){
    draw_sprite_ext(spr_package_slot_bg, 1, x-752+i*84, y + 454, 0.9, 0.9, 0, c_white, 1)
}

if button_select == 0{
	//绘制卡片强化UI背景
	draw_sprite_ext(spr_craft_slot_bg,0,x-305,y+100,1.8,1.8,0,c_white,1)
	draw_sprite_ext(spr_craft_material_bg,0,x-455,y-20,1.8,1.8,0,c_white,1)
	draw_sprite_ext(spr_craft_material_bg,0,x-155,y-20,1.8,1.8,0,c_white,1)
	draw_sprite_ext(spr_craft_slot_text,0,x-305,y+100,1.8,1.8,0,c_white,1)
	draw_sprite_ext(spr_craft_slot_text,1,x-455,y-20,1.8,1.8,0,c_white,1)
	draw_sprite_ext(spr_craft_slot_text,2,x-155,y-20,1.8,1.8,0,c_white,1)
	//绘制卡片强化材料
	for(var i = 0 ; i < array_length(card_material_id_list) ; i++){
		var material_id = card_material_id_list[i]
		var material_info = get_material_info(material_id)
		var material_amount = get_material_amount(material_id)
		draw_sprite_ext(spr_craft_material, material_info.icon, x-752+i*84, y + 454, 0.9, 0.9, 0, c_white, 1)
		draw_set_halign(fa_right);
		draw_set_valign(fa_bottom);
		draw_set_colour(c_white)
		draw_set_font(font_number)
		if get_material_amount(material_id) < 10000{
			draw_text(x-752+i*84+40,y + 454+42,string(get_material_amount(material_id)))
		}
		else{
			draw_text(x-752+i*84+40,y + 454+42,string(floor(get_material_amount(material_id)/10000))+"w")
		}
		
	}
	// 排序：普卡 → 融合卡 → 金卡（类型内保持存档原顺序）。craft_sort_order 是实例变量，
	// Mouse_53 点卡时也要用它把 hover_card_index 换算回 unlocked_cards 的下标
	craft_sort_order = []
	var _craft_fusion_order = []
	var _craft_gold_order = []
	for(var _csi = 0; _csi < array_length(global.save_data.unlocked_cards); _csi++){
		var _sort_card = global.save_data.unlocked_cards[_csi]
		var _sort_slot = deck_get_card_data(_sort_card.id, _sort_card.shape)
		if (_sort_slot != noone && ds_map_find_value(_sort_slot, "is_fusion") == 1){
			array_push(_craft_fusion_order, _csi)
		}
		else if (_sort_slot != noone && ds_map_find_value(_sort_slot, "is_gold") == 1){
			array_push(_craft_gold_order, _csi)
		}
		else{
			array_push(craft_sort_order, _csi)
		}
	}
	for(var _csi = 0; _csi < array_length(_craft_fusion_order); _csi++){
		array_push(craft_sort_order, _craft_fusion_order[_csi])
	}
	for(var _csi = 0; _csi < array_length(_craft_gold_order); _csi++){
		array_push(craft_sort_order, _craft_gold_order[_csi])
	}

	// 行数按卡数动态算（至少 20 行＝原样式），滚动上限同步，避免卡多了滚不到
	var _craft_rows = max(20, ceil(array_length(craft_sort_order) / 7))
	craft_max_y_offset = max(0, 96 * _craft_rows - 815)
	// 卡数变少（或换档）时把滚动夹回上限，避免停在空白区
	y_offset_target = clamp(y_offset_target, 0, craft_max_y_offset)
	y_offset = clamp(y_offset, 0, craft_max_y_offset)
	if (!surface_exists(card_surface)){ card_surface = surface_create(600,815) }   // 保证配对，别 set 到不存在的 surface
	surface_set_target(card_surface)
	//绘制右侧栏位
	for(var i = 0 ; i < 7 ; i++){
        for(var j = 0 ; j < _craft_rows ; j++){
            draw_sprite_ext(spr_package_slot_bg, 0, 42+i*84, 48+96 * j-y_offset, 0.9, 0.9, 0, c_white, 1)
        }
    }
	//绘制所有已解锁防御卡
	var card_index = 0
	hover_card_index = -1
	for(var di = 0 ; di < array_length(craft_sort_order);di++){
		var i = craft_sort_order[di]
		var card_col = card_index mod 7
		var card_row = card_index div 7
		var card_data = global.save_data.unlocked_cards[i]
		var card_id = card_data.id
		var card_slot_data = deck_get_card_data(card_id,card_data.shape)
		var card_x = 42 + card_col*84
		var card_y = 48+96 * card_row - y_offset

		if (card_slot_data != noone) {
			// 卡底：融合卡 spr_slot_2 > 金卡 spr_slot_1 > 普通 spr_slot（与其它列表界面同一口径）
			var _base_spr = is_fusion_card(card_id) ? spr_slot_2 : ((ds_map_find_value(card_slot_data, "is_gold") == 1) ? spr_slot_1 : spr_slot)
			draw_sprite_ext(_base_spr,0,card_x,card_y-3,0.25,0.25,0,c_white,1)
			draw_sprite_ext(card_slot_data[? "sprite"],0,card_x,card_y+15,0.7,0.7,0,c_white,1)
			draw_set_color(c_black);
			draw_set_halign(fa_center);
			draw_set_valign(fa_bottom);
			draw_set_font(font_pixel)
			draw_text(card_x,card_y+37,card_slot_data[? "cost"])
			if card_data.max_level > 0{
				draw_sprite_ext(spr_star_slot,  card_data.max_level - 1,  card_x-25,  card_y-35, 0.7, 0.7, 0, c_white, 1);
			}
		}
		
		// 检查鼠标是否悬停在卡片上
        var spr_width = 84;
        var spr_height = 96;
		
		var hover_card_x = x + 196 + card_col*84
		var hover_card_y = y - 321 + 96 * card_row - y_offset
		
		if mouse_y > y-321-48 && mouse_y < y + 450{
                
	        if (point_in_rectangle(mouse_x, mouse_y, 
	                                hover_card_x - spr_width/2, hover_card_y - spr_height/2,
	                                hover_card_x + spr_width/2, hover_card_y + spr_height/2)) {
	            hover_card_index = card_index;
	        }
		}
		card_index++
	}
	surface_reset_target()
	draw_surface(card_surface,x+196-42,y-321-48)
	
	//绘制悬停提示
	if (hover_card_index != -1) {
        
		draw_set_font(font_yuan);
			tooltip_set(mouse_x - 15, mouse_y - 15, "点击将卡片放入强化槽", -1);
			
            
    }
	//绘制正在强化的卡片
	if current_uprade_target_id != ""{
		var card_data = get_card_info_simple(current_uprade_target_id)
		var card_id = card_data.id
		var card_slot_data = deck_get_card_data(current_uprade_target_id,card_data.shape)
		var card_x = x - 307
		var card_y = y + 103
		
		var _slot_base_spr = is_fusion_card(current_uprade_target_id) ? spr_slot_2 : ((ds_map_find_value(card_slot_data, "is_gold") == 1) ? spr_slot_1 : spr_slot)
		draw_sprite_ext(_slot_base_spr,0,card_x,card_y-3,0.25,0.25,0,c_white,1)
		draw_sprite_ext(card_slot_data[? "sprite"],0,card_x,card_y+15,0.7,0.7,0,c_white,1)
		draw_set_color(c_black);
		draw_set_halign(fa_center);
		draw_set_valign(fa_bottom);
		draw_set_font(font_pixel)
		draw_text(card_x,card_y+37,card_slot_data[? "cost"])
		if card_data.max_level > 0{
			draw_sprite_ext(spr_star_slot,  card_data.max_level - 1,  card_x-25,  card_y-35, 0.7, 0.7, 0, c_white, 1);
		}
		//绘制强化需要的材料
		if card_data.max_level <= 15{
			var spices_list = [0,0,0]
			var clover_list = [0,0,0]
			var craft_rule = get_card_craft_rule(string(card_data.max_level+1))
			draw_set_font(font_number)
			draw_set_colour(c_yellow)
			draw_set_valign(fa_middle)
			draw_set_halign(fa_left)
			draw_text(x-460,y+300,string(craft_rule.gold_amount))
			// 保险金消耗数字（画在徽章中间；不够钱时转红）——只要总开关「概率强化」开着就显示
			// 金额最多 6 位：基准字号放得下 5 位，超过 5 位按位数等比缩小
			if craft_rate_settings().enabled{
				var _assure_cost = craft_assure_gold(card_data.max_level)
				var _amt_txt = string(_assure_cost)
				var _amt_len = string_length(_amt_txt)
				var _amt_sc = 1
				if (_amt_len > 5) _amt_sc = 5 / _amt_len
				draw_set_valign(fa_middle)
				draw_set_halign(fa_center)
				draw_set_colour(c_black)
				draw_text_transformed(assure_badge_cx-1, assure_badge_cy+4-1, _amt_txt, _amt_sc, _amt_sc, 0)
				draw_text_transformed(assure_badge_cx+1, assure_badge_cy+4-1, _amt_txt, _amt_sc, _amt_sc, 0)
				draw_text_transformed(assure_badge_cx-1, assure_badge_cy+4+1, _amt_txt, _amt_sc, _amt_sc, 0)
				draw_text_transformed(assure_badge_cx+1, assure_badge_cy+4+1, _amt_txt, _amt_sc, _amt_sc, 0)
				draw_set_colour(c_white)
				if global.save_data.player.gold < _assure_cost draw_set_colour(c_red)
				draw_text_transformed(assure_badge_cx, assure_badge_cy+4, _amt_txt, _amt_sc, _amt_sc, 0)
				draw_set_colour(c_white)
				draw_set_halign(fa_left)
			}
			draw_sprite_ext(spr_craft_material, get_material_info(craft_rule.spices_require).icon, x-455, y-20, 0.9, 0.9, 0, c_white, 1)
			draw_set_halign(fa_center)
			draw_set_colour(c_black)
			//如果低级材料不足，尝试获取高级材料
			var display_spices_amount = 0
			var use_enhanced_spices = false
			if get_material_amount(craft_rule.spices_require) < craft_rule.spices_amount{
				for(var i = array_get_index(spices_use_order,craft_rule.spices_require);i < array_length(spices_use_order);i++){
					display_spices_amount += get_material_amount(spices_use_order[i])
					if display_spices_amount>= craft_rule.spices_amount{
						use_enhanced_spices = true
						break
					}
				}
			}
			else{
				display_spices_amount = get_material_amount(craft_rule.spices_require)
			}
			draw_text(x-455,y+35,string(display_spices_amount)+"/"+string(craft_rule.spices_amount))
			draw_set_font(font_yuan)
			if use_enhanced_spices{
				draw_set_colour(c_red)
				draw_text(x-455,y+60,"使用了高级香料")
			}
			if craft_rule.clover_require != "none"{
				//如果低级材料不足，尝试获取高级材料
				var display_clover_amount = 0
				var use_enhanced_clover = false
				if get_material_amount(craft_rule.clover_require) < craft_rule.clover_amount{
					for(var i = array_get_index(clover_use_order,craft_rule.clover_require);i < array_length(clover_use_order);i++){
						display_clover_amount += get_material_amount(clover_use_order[i])
						if display_clover_amount>= craft_rule.clover_amount{
							use_enhanced_clover = true
							break
						}
					}
				}
				else{
					display_clover_amount = get_material_amount(craft_rule.clover_require)
				}
				draw_sprite_ext(spr_craft_material, get_material_info(craft_rule.clover_require).icon, x-155, y-20, 0.9, 0.9, 0, c_white, 1)
				draw_set_halign(fa_center)
				draw_set_colour(c_black)
				draw_set_font(font_number)
				draw_text(x-155,y+35,string(display_clover_amount)+"/"+string(craft_rule.clover_amount))
				draw_set_font(font_yuan)
				if use_enhanced_clover{
					draw_set_colour(c_red)
					draw_text(x-155,y+60,"使用了高级四叶草")
				}
			}
		}
	}
	
	
    
}
else if button_select == 1{
	//绘制宝石强化UI背景
	draw_sprite_ext(spr_package_gem_bg, 0, x-305, y+110, 0.9, 0.9, 0, c_white, 1)
	draw_sprite_ext(spr_craft_material_bg,0,x-305,y-40,1.8,1.8,0,c_white,1)
	draw_sprite_ext(spr_craft_slot_text,3,x-305,y+110,1.8,1.8,0,c_white,1)
	draw_sprite_ext(spr_craft_slot_text,4,x-305,y-40,1.8,1.8,0,c_white,1)
	//绘制宝石强化材料
	for(var i = 0 ; i < array_length(gem_material_id_list) ; i++){
		var material_id = gem_material_id_list[i]
		var material_info = get_material_info(material_id)
		var material_amount = get_material_amount(material_id)
		draw_sprite_ext(spr_craft_material, material_info.icon, x-752+i*84, y + 454, 0.9, 0.9, 0, c_white, 1)
		draw_set_halign(fa_right);
		draw_set_valign(fa_bottom);
		draw_set_colour(c_white)
		draw_set_font(font_number)
		if get_material_amount(material_id) < 10000{
			draw_text(x-752+i*84+40,y + 454+42,string(get_material_amount(material_id)))
		}
		else{
			draw_text(x-752+i*84+40,y + 454+42,string(floor(get_material_amount(material_id)/10000))+"w")
		}
	}
	//绘制右侧栏位
	for(var i = 0 ; i < 7 ; i++){
        for(var j = 0 ; j < 9 ; j++){
            draw_sprite_ext(spr_package_slot_bg, 1, x+196+i*84, y - 324 + 88 * j, 0.9, 0.9, 0, c_white, 1)
        }
    }
	//绘制所有宝石
	var gem_index = 0
	hover_gem_index = -1
	
	for(var i = 0; i < array_length(global.save_data.unlocked_gems); i++) {
        var weapon_id = global.save_data.unlocked_gems[i].id;
        var weapon_data = get_gem_info(weapon_id)
        
        if (!is_undefined(weapon_data)) {
            // 计算宝石位置
            var row = gem_index div 7
            var col = gem_index mod 7
            
            if (row < 10) {
                var weapon_x = x + 196 + col * 84;
                var weapon_y = y - 324 + row * 88;
                
                // 绘制宝石图标
                draw_sprite_ext(weapon_data.icon, 0, weapon_x, weapon_y, 0.7, 0.7, 0, c_white, 1);
                
				if get_gem_max_level(weapon_id) > 0{
					draw_sprite_ext(spr_star_slot, get_gem_max_level(weapon_id)-1, weapon_x-28, weapon_y-30, 0.7, 0.7, 0, c_white, 1)
				}
                
                // 检查鼠标是否悬停在宝石上
                var spr_width = 84;
                var spr_height = 88;
                
                if (point_in_rectangle(mouse_x, mouse_y, 
                                      weapon_x - spr_width/2, weapon_y - spr_height/2,
                                      weapon_x + spr_width/2, weapon_y + spr_height/2)) {
                    hover_gem_index = i;
                }
                
                gem_index++;
            }
        }
    }
    
    // 绘制悬停提示
    if (hover_gem_index != -1) {
        var weapon_id = global.save_data.unlocked_gems[hover_gem_index].id;
        var weapon_data = global.gems_pool[? weapon_id];
        
        if (!is_undefined(weapon_data)) {
			draw_set_font(font_yuan)
            var tooltip_text = weapon_data.name + "\n点击将宝石放入强化槽";
            	draw_set_font(font_yuan);
            	tooltip_set(mouse_x - 15, mouse_y - 15, tooltip_text, -1);
			
            
        }
    }
	//绘制正在强化的宝石
	if current_uprade_target_id != ""{
		var weapon_x = x - 305
        var weapon_y = y + 110
		var weapon_id = current_uprade_target_id
		var weapon_data = get_gem_info(weapon_id)
                
        // 绘制宝石图标
        draw_sprite_ext(weapon_data.icon, 0, weapon_x, weapon_y, 0.85, 0.85, 0, c_white, 1);
                
		if get_gem_max_level(weapon_id) > 0{
			draw_sprite_ext(spr_star_slot, get_gem_max_level(weapon_id)-1, weapon_x-28, weapon_y-30, 0.8, 0.8, 0, c_white, 1)
		}
		//绘制强化需要的材料
		if get_gem_max_level(weapon_id) <= 14{
			var craft_rule = get_gem_craft_rule(string(get_gem_max_level(weapon_id)+1))
			draw_set_font(font_number)
			draw_set_colour(c_yellow)
			draw_set_valign(fa_middle)
			draw_set_halign(fa_left)
			draw_text(x-460,y+300,string(craft_rule.gold_amount))
			draw_sprite_ext(spr_craft_material, get_material_info(craft_rule.crystal_require).icon, x-305, y-40, 0.9, 0.9, 0, c_white, 1)
			draw_set_halign(fa_center)
			draw_set_colour(c_black)
			//如果低级材料不足，尝试获取高级材料
			var display_crystal_amount = 0
			var use_enhanced_crystal = false
			if get_material_amount(craft_rule.crystal_require) < craft_rule.crystal_amount{
				for(var i = array_get_index(crystal_use_order,craft_rule.crystal_require);i < array_length(crystal_use_order);i++){
					display_crystal_amount += get_material_amount(crystal_use_order[i])
					if display_crystal_amount>= craft_rule.crystal_amount{
						use_enhanced_crystal = true
						break
					}
				}
			}
			else{
				display_crystal_amount = get_material_amount(craft_rule.crystal_require)
			}
			draw_text(x-305,y+15,string(display_crystal_amount)+"/"+string(craft_rule.crystal_amount))
			draw_set_font(font_yuan)
			if use_enhanced_crystal{
				draw_set_colour(c_red)
				draw_text(x-305,y+40,"使用了高级水晶")
			}
		}
	}
}

// ── 卡片网格滚动条（与 obj_info_island_bg / GridList 用同一个精灵和同一套交互）──────
// 卡片画进 card_surface（600×815）、贴回在 (x+196-42, y-321-48)。必须在
// panel_anim_end_parts 之前画：那之后面板 surface 已贴回，再画就录不进去了。
{
    var _sb_scl = 2.2
    var _sb_w   = sprite_get_width(spr_info_island_scroll_bar)  * _sb_scl
    var _sb_h   = sprite_get_height(spr_info_island_scroll_bar) * _sb_scl
    var _sb_l   = x + 196 - 42
    var _sb_t   = y - 321 - 48
    // 精灵原点是左上角 → x 是「按钮左边缘」，补半个按钮宽让中心落在凹槽线上
    var _sb_x   = _sb_l + 600 - _sb_w + 28 + _sb_w * 0.5
    var _sb_vh  = 815                                    // 视口高 = card_surface 高度
    var _sb_max = craft_max_y_offset                     // 与 Mouse_61 同一上限（按解锁卡数动态算）
    // 滚动平滑趋近：滚轮与点轨道只改目标值，这里每帧非线性逼近（等级 1；等级 0 直接到位）
    if (ui_anim_on(1)) {
        y_offset += (y_offset_target - y_offset) * 0.28
        if (abs(y_offset_target - y_offset) < 0.5) y_offset = y_offset_target
    } else {
        y_offset = y_offset_target
    }

    if (_sb_max > 0 && _sb_vh > _sb_h) {
        var _sb_travel = _sb_vh - _sb_h
        var _sb_y = _sb_t + clamp(y_offset / _sb_max, 0, 1) * _sb_travel
        draw_sprite_ext(spr_info_island_scroll_bar, 0, _sb_x, _sb_y, _sb_scl, _sb_scl, 0, c_white, 1)
        if (mouse_check_button_pressed(mb_left)) {
            if (point_in_rectangle(mouse_x, mouse_y, _sb_x, _sb_y, _sb_x + _sb_w, _sb_y + _sb_h)) {
                sb_dragging = true
                sb_drag_y = mouse_y
                sb_drag_offset = y_offset
            } else if (point_in_rectangle(mouse_x, mouse_y, _sb_x, _sb_t, _sb_x + _sb_w, _sb_t + _sb_vh)) {
                y_offset_target = clamp((mouse_y - _sb_t - _sb_h * 0.5) / _sb_travel * _sb_max, 0, _sb_max)
            }
        }
        if (sb_dragging && mouse_check_button(mb_left)) {
            y_offset = clamp(sb_drag_offset + (mouse_y - sb_drag_y) * (_sb_max / _sb_travel), 0, _sb_max)
            y_offset_target = y_offset
        }
        if (mouse_check_button_released(mb_left)) sb_dragging = false
    }
}

// 提示框：推进尺寸/消失动画并绘制（每帧一次）
tooltip_draw();
panel_anim_end_parts(id, craft_parts, 260)
