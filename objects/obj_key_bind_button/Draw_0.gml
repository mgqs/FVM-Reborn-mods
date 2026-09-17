// 绘制按钮背景
var _x1 = x - sprite_width/2;
var _y1 = y - sprite_height/2;
var _x2 = x + sprite_width/2;
var _y2 = y + sprite_height/2;

if (is_waiting) {
    image_index = 0
} else if (point_in_rectangle(mouse_x, mouse_y, _x1, _y1, _x2, _y2)) {
    image_index = 1
} else {
    image_index = 2
}

//draw_rectangle(_x1, _y1, _x2, _y2, false);
draw_set_color(c_white);
draw_set_halign(fa_center);
draw_set_valign(fa_middle);
draw_self()
draw_set_font(font_hei)
draw_text(x, y, display_text);
draw_set_font(font_yuan)
draw_text(x-600, y, key_name);

// 绘制悬停提示
if (point_in_rectangle(mouse_x, mouse_y, _x1, _y1, _x2, _y2) && tooltip_text != "") {
    draw_set_color(c_black);
    draw_set_alpha(0.8);
    var tt_width = string_width(tooltip_text) + 20;
    var tt_height = 30;
    var tt_x = mouse_x + 15;
    var tt_y = mouse_y + 15;
    
    // 确保提示框在屏幕内
    if (tt_x + tt_width > room_width) tt_x = room_width - tt_width;
    if (tt_y + tt_height > room_height) tt_y = room_height - tt_height;
    
    draw_rectangle(tt_x, tt_y, tt_x + tt_width, tt_y + tt_height, true);
    draw_set_alpha(1);
    draw_set_color(c_white);
    draw_text(tt_x + 10, tt_y + 15, tooltip_text);
}