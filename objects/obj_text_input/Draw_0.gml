// obj_text_input 绘制事件
// 绘制背景
//draw_set_color(bg_color);
//draw_rectangle(x, y, x + width, y + height, false);

// 绘制边框
//if (active) {
//    draw_set_color(border_active_color);
//} else {
//    draw_set_color(border_color);
//}
//draw_rectangle(x, y, x + width, y + height, true);

// 绘制文本或占位符
if (text != "") {
    draw_set_color(text_color);
    draw_set_font(font_hei);
    draw_set_halign(fa_left);
    draw_set_valign(fa_middle);
    draw_text(x + 5, y + height/2, text);
    
    // 绘制光标（如果活动）
    if (active && cursor_visible) {
        var text_width = string_width(text);
        draw_line(x + 5 + text_width, y + 5, x + 5 + text_width, y + height - 5);
    }
} else {
    draw_set_color(placeholder_color);
    draw_set_font(font_hei);
    draw_set_halign(fa_left);
    draw_set_valign(fa_middle);
    draw_text(x + 5, y + height/2, placeholder);
}