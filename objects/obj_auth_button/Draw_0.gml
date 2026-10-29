/// 纯绘制的小胶囊按钮：未授权=金色，已授权=绿色
var _ok = auth_ok();

if (_ok) {
    draw_set_color(hover ? make_color_rgb(104, 162, 118) : make_color_rgb(88, 140, 102));
} else {
    draw_set_color(hover ? make_color_rgb(222, 176, 92) : make_color_rgb(200, 156, 76));
}
draw_roundrect_ext(x, y, x + btn_w, y + btn_h, 14, 14, false);

if (_ok) {
    draw_set_color(make_color_rgb(52, 92, 64));
} else {
    draw_set_color(make_color_rgb(122, 88, 40));
}
draw_roundrect_ext(x, y, x + btn_w, y + btn_h, 14, 14, true);

draw_set_font(font_yuan);
draw_set_halign(fa_center);
draw_set_valign(fa_middle);
draw_set_color(c_white);
draw_text_transformed(x + btn_w * 0.5, y + btn_h * 0.5, _ok ? "已授权" : "授权", 1.2, 1.2, 0);

draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_color(c_white);
