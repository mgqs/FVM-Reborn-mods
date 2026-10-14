draw_set_alpha(0.5);
// 绘制半透明遮罩
draw_rectangle_color(0, 0, room_width, room_height, c_black, c_black, c_black, c_black, false);
draw_set_alpha(1);
draw_self()

// 概率强化开关（勾选框用官方合成屋素材，0=未选 1=已选）
var toggle_frame = 0
if craft_rate_settings().enabled toggle_frame = 1
draw_sprite_ext(spr_craft_rate_check, toggle_frame, rate_toggle_x, rate_toggle_y, 1.4, 1.4, 0, c_white, 1)
if rate_toggle_hover{
	draw_set_alpha(0.25)
	draw_set_colour(c_white)
	draw_rectangle(rate_toggle_x-18, rate_toggle_y-18, rate_toggle_x+18, rate_toggle_y+18, false)
	draw_set_alpha(1)
}
draw_set_font(font_yuan)
draw_set_valign(fa_middle)
draw_set_halign(fa_left)
// 文字颜色跟开关状态走（开=中绿 / 关=深红，浅底上图对比够），四向深色描边当加粗
var toggle_col = make_colour_rgb(205,40,30)
if craft_rate_settings().enabled toggle_col = make_colour_rgb(35,165,55)
draw_set_colour(c_black)
draw_text(rate_toggle_x + 26 - 1, rate_toggle_y - 1, "概率强化")
draw_text(rate_toggle_x + 26 + 1, rate_toggle_y - 1, "概率强化")
draw_text(rate_toggle_x + 26 - 1, rate_toggle_y + 1, "概率强化")
draw_text(rate_toggle_x + 26 + 1, rate_toggle_y + 1, "概率强化")
draw_set_colour(toggle_col)
draw_text(rate_toggle_x + 26, rate_toggle_y, "概率强化")
draw_set_valign(fa_top)

// 失败掉星开关（勾选框同一套官方素材，0=未选 1=已选；总开关关着时置灰）
var _rate_on = craft_rate_settings().enabled
if !_rate_on draw_set_alpha(0.45)
var dropstar_frame = 0
if craft_rate_settings().dropstar_enabled dropstar_frame = 1
draw_sprite_ext(spr_craft_rate_check, dropstar_frame, dropstar_toggle_x, dropstar_toggle_y, 1.4, 1.4, 0, c_white, 1)
if dropstar_toggle_hover && _rate_on{
	draw_set_alpha(0.25)
	draw_set_colour(c_white)
	draw_rectangle(dropstar_toggle_x-18, dropstar_toggle_y-18, dropstar_toggle_x+18, dropstar_toggle_y+18, false)
	draw_set_alpha(1)
}
draw_set_font(font_yuan)
draw_set_valign(fa_middle)
draw_set_halign(fa_left)
var dropstar_col = make_colour_rgb(205,40,30)
if craft_rate_settings().dropstar_enabled dropstar_col = make_colour_rgb(35,165,55)
draw_set_colour(c_black)
draw_text(dropstar_toggle_x + 26 - 1, dropstar_toggle_y - 1, "失败掉星")
draw_text(dropstar_toggle_x + 26 + 1, dropstar_toggle_y - 1, "失败掉星")
draw_text(dropstar_toggle_x + 26 - 1, dropstar_toggle_y + 1, "失败掉星")
draw_text(dropstar_toggle_x + 26 + 1, dropstar_toggle_y + 1, "失败掉星")
draw_set_colour(dropstar_col)
draw_text(dropstar_toggle_x + 26, dropstar_toggle_y, "失败掉星")
draw_set_colour(c_white)
draw_set_valign(fa_top)
if !_rate_on draw_set_alpha(1)

// 保险金（官方徽章 spr_craft_insure_badge：自带的"点券"已擦掉 → 底部写"金币"，中间写消耗数字）
if button_select == 0{
	// 概率强化关掉、或失败掉星关掉时，保险金都置灰（保险金必须建立在失败掉星之上）
	var _assure_off = !_rate_on || !craft_rate_settings().dropstar_enabled
	if _assure_off draw_set_alpha(0.45)
	var assure_frame = 0
	if craft_rate_settings().assure_enabled assure_frame = 1
	draw_sprite_ext(spr_craft_insure_badge, 0, assure_badge_cx, assure_badge_cy, 1.5, 1.5, 0, c_white, 1)
	if assure_toggle_hover && !_assure_off{
		draw_set_alpha(0.25)
		draw_set_colour(c_white)
		draw_rectangle(assure_badge_cx-33, assure_badge_cy-36, assure_badge_cx+33, assure_toggle_y+18, false)
		draw_set_alpha(1)
	}
	// 底部"金币"（照官方"点券"的橙色）
	draw_set_font(font_yuan)
	draw_set_valign(fa_middle)
	draw_set_halign(fa_center)
	draw_set_colour(c_black)
	draw_text(assure_badge_cx-1, assure_badge_cy+25-1, "金币")
	draw_text(assure_badge_cx+1, assure_badge_cy+25-1, "金币")
	draw_text(assure_badge_cx-1, assure_badge_cy+25+1, "金币")
	draw_text(assure_badge_cx+1, assure_badge_cy+25+1, "金币")
	draw_set_colour(make_colour_rgb(255,150,60))
	draw_text(assure_badge_cx, assure_badge_cy+25, "金币")
	draw_set_colour(c_white)
	draw_set_valign(fa_top)
	draw_set_halign(fa_left)
	draw_sprite_ext(spr_craft_rate_check, assure_frame, assure_toggle_x, assure_toggle_y, 1.4, 1.4, 0, c_white, 1)
	if _assure_off draw_set_alpha(1)
}

// 需金币（左）与成功率（右）同一排：两条都用需金币框贴图，成功率那条把自带的"需金币:"字样盖掉
draw_sprite_ext(spr_craft_gold_require_bg,0,x-350,y+300,1.8,1.8,0,c_white,1)

// 成功率栏（右条）：框 = spr_craft_gold_require_bg 换过来画 + 空白段盖掉自带"需金币:"
// 标签用官方贴图 spr_craft_rate_label（画在条内左侧，与隔壁金币条自带的"需金币:"排法一致），数值仍用字体
var rate_bar_x = x - 45
var rate_bar_y = y + 300
var rate_bar_left = rate_bar_x - 230.4      // 条子左缘（128*1.8）
var rate_bar_ix = rate_bar_left + 3.6       // 框内区左缘（2 像素 * 1.8）
var rate_bar_iy = rate_bar_y - 14.4         // 框内区上缘（内区高 16*1.8）
var rate_settings = craft_rate_settings()
var rate_base = 100
var rate_streak = 0
var rate_bonus = 0
var rate_text = "100%"
if rate_settings.enabled{
	rate_text = "--"
	if current_uprade_target_id != ""{
		if button_select == 0{
			var _rate_card_info = get_card_info_simple(current_uprade_target_id)
			if _rate_card_info != false{
				rate_base = get_card_craft_rate_base(current_uprade_target_id, _rate_card_info.max_level+1)
				rate_streak = get_card_fail_streak(current_uprade_target_id)
				rate_bonus = get_card_craft_bonus(current_uprade_target_id)
			}
		}
		else{
			rate_base = get_gem_craft_rate_base(current_uprade_target_id, get_gem_max_level(current_uprade_target_id)+1)
			rate_streak = get_gem_fail_streak(current_uprade_target_id)
			rate_bonus = get_gem_craft_bonus(current_uprade_target_id)
		}
		if rate_settings.pity_guarantee > 0 && rate_streak >= rate_settings.pity_guarantee{
			rate_text = "必成"
		}
		else if rate_bonus > 0{
			rate_text = string_format(rate_base,1,2)+"%+"+string_format(rate_bonus,1,2)+"%"
		}
		else{
			rate_text = string_format(rate_base,1,2)+"%"
		}
	}
}
draw_sprite_ext(spr_craft_gold_require_bg, 0, rate_bar_x, rate_bar_y, 1.8, 1.8, 0, c_white, 1)
// 用同一贴图的空白段（x=90 起的 4x16）把框上自带的"需金币:"盖掉 → 变成空条
draw_sprite_part_ext(spr_craft_gold_require_bg, 0, 90, 2, 4, 16, rate_bar_ix, rate_bar_iy, 28.35, 1.8, c_white, 1)
draw_sprite_ext(spr_craft_rate_label, 0, rate_bar_left + 10, rate_bar_y, 1.5, 1.5, 0, c_white, 1)
// 数值：白字 + 四向深色描边
draw_set_font(font_number)
draw_set_valign(fa_middle)
draw_set_halign(fa_center)
var rate_text_x = rate_bar_left + 150
draw_set_colour(c_black)
draw_text(rate_text_x-1, rate_bar_y-1, rate_text)
draw_text(rate_text_x+1, rate_bar_y-1, rate_text)
draw_text(rate_text_x-1, rate_bar_y+1, rate_text)
draw_text(rate_text_x+1, rate_bar_y+1, rate_text)
draw_set_colour(c_white)
draw_text(rate_text_x, rate_bar_y, rate_text)
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
	surface_set_target(card_surface)
	//绘制所有已解锁防御卡
		var card_index = 0
		hover_card_index = -1
		// 排序：普通卡在前 → 融合卡居中 → 金卡在后（参考背包排序逻辑）
		craft_sort_order = []
		var _craft_fusion_order = []
		var _craft_gold_order = []
		for(var i = 0; i < array_length(global.save_data.unlocked_cards); i++) {
			var _card_data = global.save_data.unlocked_cards[i]
			var _card_slot_data = deck_get_card_data(_card_data.id, _card_data.shape)
			if (is_fusion_card(_card_data.id)) {
				array_push(_craft_fusion_order, i)
			} else if (_card_slot_data != noone && ds_map_find_value(_card_slot_data, "is_gold") == 1) {
				array_push(_craft_gold_order, i)
			} else {
				array_push(craft_sort_order, i)
			}
		}
		for(var i = 0; i < array_length(_craft_fusion_order); i++) {
			array_push(craft_sort_order, _craft_fusion_order[i])
		}
		for(var i = 0; i < array_length(_craft_gold_order); i++) {
			array_push(craft_sort_order, _craft_gold_order[i])
		}

		// 计算实际总行数和最大滚动偏移
		var _craft_total_rows = ceil(array_length(craft_sort_order) / 7)
		if (_craft_total_rows < 20) _craft_total_rows = 20
		// surface 高度 815，约 815/96 ≈ 8.5 行可视
		craft_max_y_offset = max(0, _craft_total_rows * 96 - 815)
		if (y_offset > craft_max_y_offset) y_offset = craft_max_y_offset
		if (y_offset < 0) y_offset = 0

		//绘制右侧栏位背景
		for(var i = 0 ; i < 7 ; i++){
			for(var j = 0 ; j < _craft_total_rows ; j++){
				draw_sprite_ext(spr_package_slot_bg, 0, 42+i*84, 48+96 * j-y_offset, 0.9, 0.9, 0, c_white, 1)
			}
		}

		for(var di = 0; di < array_length(craft_sort_order); di++) {
			var i = craft_sort_order[di]
			var card_col = card_index mod 7
			var card_row = card_index div 7
			var card_data = global.save_data.unlocked_cards[i]
			var card_id = card_data.id
			var card_slot_data = deck_get_card_data(card_id,card_data.shape)
			var card_x = 42 + card_col*84
			var card_y = 48+96 * card_row - y_offset

			if (card_slot_data != noone) {
				var _craft_slot_spr = is_fusion_card(card_id) ? spr_slot_2 : ((ds_map_find_value(card_slot_data, "is_gold") == 1) ? spr_slot_1 : spr_slot);
				draw_sprite_ext(_craft_slot_spr,0,card_x,card_y-3,0.25,0.25,0,c_white,1)
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
        
		draw_set_font(font_yuan)
        // 获取鼠标位置
        var tooltip_x = mouse_x - 15;
        var tooltip_y = mouse_y - 15;
            
		// 获取提示文本
        var tooltip_text = "点击将卡片放入强化槽"
        
			
        // 绘制提示背景
        draw_set_color(c_black);
        draw_set_alpha(0.7);
        draw_rectangle(tooltip_x - string_width(tooltip_text) - 5, tooltip_y - 5, 
                        tooltip_x +5, tooltip_y + string_height(tooltip_text)+5, false);
		//绘制提示文本
		draw_set_halign(fa_left);
        draw_set_valign(fa_top);
        draw_set_alpha(1);
        draw_set_color(c_white);
		draw_set_font(font_yuan)
		draw_text(tooltip_x- string_width(tooltip_text), tooltip_y, tooltip_text);
			
            
    }
	//绘制正在强化的卡片
	if current_uprade_target_id != ""{
		var card_data = get_card_info_simple(current_uprade_target_id)
		if (card_data != false) {
			var card_id = card_data.id
			var card_slot_data = deck_get_card_data(current_uprade_target_id,card_data.shape)
			var card_x = x - 307
			var card_y = y + 103
			
			if (card_slot_data != noone) {
				var _craft_upgrade_slot = is_fusion_card(card_id) ? spr_slot_2 : ((ds_map_find_value(card_slot_data, "is_gold") == 1) ? spr_slot_1 : spr_slot);
				draw_sprite_ext(_craft_upgrade_slot,0,card_x,card_y-3,0.25,0.25,0,c_white,1)
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
			//绘制强化需要的材料
			if card_data.max_level <= 15{
				var spices_list = [0,0,0]
				var clover_list = [0,0,0]
				var craft_rule = get_card_craft_rule(string(card_data.max_level+1))
				if (!is_undefined(craft_rule)) {
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
						if _amt_len > 5 _amt_sc = 5 / _amt_len
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
					var _spices_info = get_material_info(craft_rule.spices_require)
					if (!is_undefined(_spices_info)) {
						draw_sprite_ext(spr_craft_material, _spices_info.icon, x-455, y-20, 0.9, 0.9, 0, c_white, 1)
					}
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
						var _clover_info = get_material_info(craft_rule.clover_require)
						if (!is_undefined(_clover_info)) {
							draw_sprite_ext(spr_craft_material, _clover_info.icon, x-155, y-20, 0.9, 0.9, 0, c_white, 1)
						}
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
	//绘制右侧宝石栏位（使用card_surface实现滚动裁剪）
	surface_set_target(card_surface)
	draw_clear_alpha(c_black, 0)

	// 计算宝石总行数和最大滚动偏移
	var _gem_total_count = 0
	for (var _gi = 0; _gi < array_length(global.save_data.unlocked_gems); _gi++) {
		var _gd = get_gem_info(global.save_data.unlocked_gems[_gi].id)
		if (!is_undefined(_gd)) _gem_total_count++
	}
	var _gem_total_rows = ceil(_gem_total_count / 7)
	if (_gem_total_rows < 9) _gem_total_rows = 9
	// surface 高度 815，宝石行高 88，约 815/88 ≈ 9.26 行可视
	craft_gem_max_y_offset = max(0, _gem_total_rows * 88 + 48 - 815)
	if (y_offset > craft_gem_max_y_offset) y_offset = craft_gem_max_y_offset
	if (y_offset < 0) y_offset = 0

	//绘制宝石背景格子
	for(var i = 0 ; i < 7 ; i++){
		for(var j = 0 ; j < _gem_total_rows ; j++){
			draw_sprite_ext(spr_package_slot_bg, 1, 42+i*84, 48 + 88 * j - y_offset, 0.9, 0.9, 0, c_white, 1)
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
			var gem_draw_y = 48 + row * 88 - y_offset;

			// 只绘制可视区域附近的宝石
			if (gem_draw_y > -100 && gem_draw_y < 915) {
				var gem_draw_x = 42 + col * 84;

                // 绘制宝石图标
                draw_sprite_ext(weapon_data.icon, 0, gem_draw_x, gem_draw_y, 0.7, 0.7, 0, c_white, 1);

				if get_gem_max_level(weapon_id) > 0{
					draw_sprite_ext(spr_star_slot, get_gem_max_level(weapon_id)-1, gem_draw_x-28, gem_draw_y-30, 0.7, 0.7, 0, c_white, 1)
				}

                // 检查鼠标是否悬停在宝石上（转换到屏幕坐标）
                var spr_width = 84;
                var spr_height = 88;

                // surface 绘制在 (x+196-42, y-321-48)，宝石在 surface 内的位置是 (42+col*84, 48+row*88-y_offset)
                var hover_gem_x = x + 196 + col * 84;
                var hover_gem_y = y - 321 + row * 88 - y_offset;

                if (point_in_rectangle(mouse_x, mouse_y,
                                      hover_gem_x - spr_width/2, hover_gem_y - spr_height/2,
                                      hover_gem_x + spr_width/2, hover_gem_y + spr_height/2))
				&& mouse_y > y-369 && mouse_y < y + 446 {
                    hover_gem_index = i;
                }
			}
            gem_index++;
        }
    }

	surface_reset_target()
	draw_surface(card_surface, x+196-42, y-321-48)
    
    // 绘制悬停提示
    if (hover_gem_index != -1) {
        var weapon_id = global.save_data.unlocked_gems[hover_gem_index].id;
        var weapon_data = global.gems_pool[? weapon_id];
        
        if (!is_undefined(weapon_data)) {
			draw_set_font(font_yuan)
            // 获取鼠标位置
            var tooltip_x = mouse_x - 15;
            var tooltip_y = mouse_y - 15;
            
			// 获取提示文本
            
            var tooltip_text = weapon_data.name
            var is_equipped = is_weapon_equipped(weapon_id);
            
            var slot = get_weapon_slot(weapon_id);
            tooltip_text += "\n点击将宝石放入强化槽"
            
			
            // 绘制提示背景
            draw_set_color(c_black);
            draw_set_alpha(0.7);
            draw_rectangle(tooltip_x - string_width(tooltip_text) - 5, tooltip_y - 5, 
                          tooltip_x +5, tooltip_y + string_height(tooltip_text)+5, false);
			//绘制提示文本
			draw_set_halign(fa_left);
            draw_set_valign(fa_top);
            draw_set_alpha(1);
            draw_set_color(c_white);
			draw_set_font(font_yuan)
			draw_text(tooltip_x- string_width(tooltip_text), tooltip_y, tooltip_text);
			
            
        }
    }
	//绘制正在强化的宝石
	if current_uprade_target_id != ""{
		var weapon_x = x - 305
        var weapon_y = y + 110
		var weapon_id = current_uprade_target_id
		var weapon_data = get_gem_info(weapon_id)
                
        if (!is_undefined(weapon_data)) {
            // 绘制宝石图标
            draw_sprite_ext(weapon_data.icon, 0, weapon_x, weapon_y, 0.85, 0.85, 0, c_white, 1);
                    
            if get_gem_max_level(weapon_id) > 0{
                draw_sprite_ext(spr_star_slot, get_gem_max_level(weapon_id)-1, weapon_x-28, weapon_y-30, 0.8, 0.8, 0, c_white, 1)
            }
            //绘制强化需要的材料
            if get_gem_max_level(weapon_id) <= 14{
                var craft_rule = get_gem_craft_rule(string(get_gem_max_level(weapon_id)+1))
                if (!is_undefined(craft_rule)) {
                    draw_set_font(font_number)
                    draw_set_colour(c_yellow)
                    draw_set_valign(fa_middle)
                    draw_set_halign(fa_left)
                    draw_text(x-460,y+300,string(craft_rule.gold_amount))
                    var _crystal_info = get_material_info(craft_rule.crystal_require)
                    if (!is_undefined(_crystal_info)) {
                        draw_sprite_ext(spr_craft_material, _crystal_info.icon, x-305, y-40, 0.9, 0.9, 0, c_white, 1)
                    }
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
	}
}
