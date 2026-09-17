//绘制悬停提示
	if (hover_slot_index != -1 && !is_submenu_open && !deck_slot_is_empty(hover_slot_index)) {
		var card_id = global.selected_deck[| hover_slot_index][? "card_id"]
		var card_shape = global.selected_deck[| hover_slot_index][? "shape"]
		var card_data = global.selected_deck[| hover_slot_index][? "data"]
		var tooltip_text = "点击取消"
		//view_max_shapes = ds_list_size(card_data_shapes)-1
           
		tooltip_text = card_data[? "description"]
        // 获取鼠标位置
        var tooltip_x = mouse_x - 15;
        var tooltip_y = mouse_y - 25;
		
		
        
        // 绘制提示背景
        draw_set_color(c_black);
        draw_set_alpha(0.7);
        draw_rectangle(tooltip_x + 5, tooltip_y - 5, 
                      tooltip_x - string_width(tooltip_text)-5, tooltip_y + string_height(tooltip_text)+5, false);
        
        // 绘制提示文本
		draw_set_halign(fa_left);
		draw_set_valign(fa_top);
        draw_set_alpha(1);
        draw_set_color(c_white);
        draw_text(tooltip_x- string_width(tooltip_text), tooltip_y, tooltip_text);
    }