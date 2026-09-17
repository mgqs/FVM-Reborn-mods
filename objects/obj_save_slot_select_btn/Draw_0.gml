draw_self()
draw_set_color(c_white);
draw_set_valign(fa_middle)
draw_set_halign(fa_center)
draw_text(x,y,string(state+1))
// 在绘制自身之后添加悬停提示
if (point_in_rectangle(mouse_x, mouse_y, x-sprite_width/2, y-sprite_height/2, x+sprite_width/2, y+sprite_height/2) && tooltip_text != "") {
    draw_set_color(c_black);
    draw_set_alpha(0.5);
    var tt_width = string_width(tooltip_text) + 20;
    var tt_height = string_height(tooltip_text) + 10;
    var tt_x = mouse_x + 15;
    var tt_y = mouse_y - 15;
    
    // 确保提示框在屏幕内
    if (tt_x + tt_width > room_width) tt_x = room_width - tt_width;
    if (tt_y + tt_height > room_height) tt_y = room_height - tt_height;
    
	draw_rectangle(tt_x, tt_y - tt_height / 2, tt_x + tt_width, tt_y + tt_height/2,false);
	draw_set_alpha(1);
    draw_rectangle(tt_x, tt_y - tt_height / 2, tt_x + tt_width, tt_y + tt_height/2, true);
    draw_set_color(c_white);
	draw_set_valign(fa_middle)
	draw_set_halign(fa_left)
    draw_text(tt_x + 10 , tt_y , tooltip_text);
	draw_set_valign(fa_top)
	draw_set_halign(fa_left)
}
