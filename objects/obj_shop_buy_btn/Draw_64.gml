if (!instance_exists(obj_shop_bg)) exit;
if (obj_shop_bg.is_submenu_opened) exit;

var _hovered_shop_btn = noone;
var _closest_hover_dist = 1000000000;
var _shop_btn_count = instance_number(obj_shop_buy_btn);
for (var _shop_btn_index = 0; _shop_btn_index < _shop_btn_count; _shop_btn_index++) {
	var _candidate = instance_find(obj_shop_buy_btn, _shop_btn_index);
	if (!_candidate.is_disabled && !_candidate.is_attire_owned
	&& _candidate.tooltip_text != ""
	&& point_in_rectangle(mouse_x, mouse_y, _candidate.x - 280, _candidate.y - 120,
		_candidate.x - 120, _candidate.y - 20)) {
		var _hover_dist = point_distance(mouse_x, mouse_y, _candidate.x - 200, _candidate.y - 70);
		if (_hover_dist < _closest_hover_dist) {
			_closest_hover_dist = _hover_dist;
			_hovered_shop_btn = _candidate;
		}
	}
}
if (_hovered_shop_btn == id && tooltip_text != ""){
	if tooltip_text != ""{
		// 获取鼠标位置
		var tooltip_x = mouse_x - 15;
		var tooltip_y = mouse_y - 25;
		if x < 600{
			tooltip_x = mouse_x + 15;
			tooltip_y = mouse_y - 25;
		}
		
		
		draw_set_font(font_yuan)
		// 绘制提示背景
		draw_set_color(c_black);
		draw_set_alpha(0.7);
		if x >= 600{
			draw_rectangle(tooltip_x + 5, tooltip_y - 5, 
		                tooltip_x - string_width(tooltip_text)-5, tooltip_y + string_height(tooltip_text)+5, false);
		}
		else{
			draw_rectangle(tooltip_x - 5, tooltip_y - 5, 
		                tooltip_x + string_width(tooltip_text)+5, tooltip_y + string_height(tooltip_text)+5, false);
		}
        
		// 绘制提示文本
		draw_set_halign(fa_left);
		draw_set_valign(fa_top);
		draw_set_alpha(1);
		draw_set_color(c_white);
		if x >= 600{	
			draw_text(tooltip_x- string_width(tooltip_text), tooltip_y, tooltip_text);
		}
		else{
			draw_text(tooltip_x, tooltip_y, tooltip_text);
		}
	
		draw_set_valign(fa_top)
	}
}
