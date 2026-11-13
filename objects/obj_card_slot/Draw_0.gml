// DRAW 事件


    


draw_self()
// 绘制价格
draw_set_halign(fa_left);
draw_set_valign(fa_middle);
draw_set_color(c_black);
draw_set_font(font_number);
// 2026-11-13：能量不守恒的卡（场上每多一张 +50）在能耗后面带 +
//   plus_card_map 的 N = 从几转开始「能量守恒」，cshape < N 才还会涨 → 才显示
var _cost_txt = string(current_cost);
if (ds_exists(global.plus_card_map, ds_type_map)){
    var _plus_info = ds_map_find_value(global.plus_card_map, card_id);
    if (_plus_info != undefined && cshape < _plus_info[1]) _cost_txt += "+";
}
draw_text_ext_transformed(x-12, y+44, _cost_txt,25,1800,1,1,0);
draw_sprite_ext(spr_flame, 0, x-24, y+43, 0.3, 0.3, 0, c_white, 1);
draw_set_halign(fa_left);
draw_set_valign(fa_top);
// 绘制植物图标
if card_id == "magic_chicken" && global.last_placed_card_id != ""{
	draw_sprite_ext(spr_magic_chicken_icon, 0, x, y+18,0.9,0.9,0,c_white,0.5);
}
if card_equipped_attire_id(card_id) != -1{
	var _card_info = get_card_info_simple(card_id)
	if _card_info != false{
		var spr_list = get_attire_info(card_equipped_attire_id(card_id)).card_slot_icon
		card_spr = spr_list[_card_info.shape]
		var place_list = get_attire_info(card_equipped_attire_id(card_id)).spr
		place_preview = place_list[_card_info.shape]
	}
}
draw_sprite_ext(card_spr, 0, x, y+18,0.9,0.9,0,c_white,1);
//绘制星级

if clevel > 0{
	draw_sprite_ext(spr_star_slot,  clevel - 1,  x-30,  y-43, 0.8, 0.8, 0, c_white, 1);
}


// 
if (is_selected) {
    
}
// 绘制冷却进度条
// 卡槽区域尺寸
var slot_width = sprite_width
var slot_height = sprite_height
var slot_x1 = x - sprite_width/2
var slot_y1 = y - sprite_height/2

// 绘制深灰色覆盖层（所有不可用状态）
if (!is_ready || is_selected) &&  cooldown_timer >= cooldown{
    draw_set_alpha(0.6)
    draw_set_color(make_color_rgb(0, 0,0))
    draw_rectangle(slot_x1, slot_y1, slot_x1 + slot_width, slot_y1 + slot_height, false)
    draw_set_alpha(1)
}

// 绘制冷却进度条
if (cooldown_timer < cooldown) {
    // 计算冷却进度百分比
    var progress = 1.0 - (cooldown_timer / cooldown)
    var progress_height = slot_height * progress
    
    // 绘制冷却进度条
    draw_set_alpha(0.8)
    draw_set_color(make_color_rgb(0, 0, 0))
    draw_rectangle(slot_x1, slot_y1 + slot_height - progress_height, 
                   slot_x1 + slot_width, slot_y1 + slot_height, false)
	draw_set_alpha(0.6)
	draw_set_color(make_color_rgb(0,0,0))
	draw_rectangle(slot_x1, slot_y1  , 
                   slot_x1 + slot_width, slot_y1 +slot_height - progress_height, false)
    draw_set_alpha(1)
}  

// 绘制冷却时间显示
if (cooldown_timer < cooldown) {
    // 计算剩余时间（秒）
    var time_left = (cooldown - cooldown_timer) / 60;
    
    // 准备显示的文本
    var display_text = "";
    
    // 根据剩余时间选择显示格式
    if (time_left < 2) {
        // 低于2秒时显示1位小数
        display_text = string_format(time_left, 1, 1);
    } else {
        // 其他情况显示整数秒（向上取整）
        display_text = string(floor(time_left));
    }
    
    // 绘制文本
    draw_set_color(c_white);
	draw_set_font(font_number);
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    draw_text(x, y, display_text);
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
}
//快捷键提示（槽位越界时没有键位，回退 vk_nokey，避免 undefined 崩溃）
var slot_key = vk_nokey;
if (variable_global_exists("keybind_map") && ds_exists(global.keybind_map, ds_type_map)) {
    var _slot_key_name = "卡槽" + string(slot_index);
    if (ds_map_exists(global.keybind_map, _slot_key_name)) {
        slot_key = global.keybind_map[? _slot_key_name];
    }
}
draw_set_color(c_black);
draw_set_font(font_song);
draw_set_halign(fa_center);
draw_set_valign(fa_middle);
draw_sprite_ext(spr_hotkey_prompt,0,x+33,y-46,1,1,0,c_white,1)
if (slot_key != vk_nokey) {
    draw_text(x+33,y-48,keyboard_get_string(slot_key))
}
draw_set_halign(fa_left);
draw_set_valign(fa_top);

// 海克斯「食指的指令」：这张就是被标记的可种植卡，右上角挂个标记图案
if (hex_enabled() && variable_global_exists("hex_state") && is_struct(global.hex_state)
    && variable_struct_exists(global.hex_state, "b3_mark_on") && global.hex_state.b3_mark_on
    && variable_struct_exists(global.hex_state, "b3_mark_card")
    && global.hex_state.b3_mark_card == card_id) {
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    hex_b3_mark_icon(x + 30, y - 40, 34);
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
}




