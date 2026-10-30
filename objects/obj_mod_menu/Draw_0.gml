draw_set_font(font_yuan);
draw_set_alpha(0.78);
draw_set_color(c_black);
draw_rectangle(0, 0, room_width, room_height, false);
draw_set_alpha(1);
draw_set_color(#17314C);
draw_roundrect(x - 470, y - 335, x + 470, y + 335, false);
draw_set_color(#9DCFEC);
draw_roundrect(x - 450, y - 250, x + 450, y + 250, false);

draw_set_halign(fa_center);
draw_set_valign(fa_middle);
draw_set_color(c_white);
draw_text(x, y - 320, "Mod管理");
draw_set_color(#D9F3FF);
draw_roundrect(x - 420, y - 305, x - 245, y - 270, false);
draw_roundrect(x - 230, y - 305, x - 35, y - 270, false);
draw_roundrect(x + 405, y - 305, x + 465, y - 270, false);
draw_set_color(#17314C);
draw_text(x - 332, y - 287, "导入Mod");
draw_text(x - 132, y - 287, "打开目录");
draw_text(x + 435, y - 287, "关闭");

draw_set_halign(fa_left);
draw_set_color(#17314C);
draw_text(x - 420, y - 232, "Mod名称");
draw_text(x + 255, y - 232, "状态");
for (var i = 0; i < array_length(mods); i++) {
    var row_y = list_top + i * row_height - scroll_offset + 26;
    if (row_y - 25 < list_top || row_y + 25 > list_bottom) continue;
    draw_set_color(i mod 2 == 0 ? #BEE5F4 : #ACD5E6);
    draw_rectangle(x - 430, row_y - 25, x + 430, row_y + 25, false);
    draw_set_color(#17314C);
    var display_name = mods[i].name;
    while (string_length(display_name) > 0 && string_width(display_name) > 620) {
        display_name = string_delete(display_name, string_length(display_name), 1);
    }
    if (display_name != mods[i].name) display_name += "…";
    draw_text(x - 410, row_y - 10, display_name);
    var load_status = mods[i].enabled ? "已开启，重启后生效" : "已关闭，重启后生效";
    if (mods[i].enabled && variable_global_exists("external_mod_errors") && variable_struct_exists(global.external_mod_errors, mods[i].folder)) {
        draw_set_color(#A52929);
    }
    draw_text(x - 410, row_y + 13, load_status);
    draw_set_color(mods[i].enabled ? #6BCB77 : #9CA3AF);
    draw_roundrect(x + 245, row_y - 17, x + 325, row_y + 17, false);
    draw_set_color(c_white);
    draw_set_halign(fa_center);
    draw_text(x + 285, row_y, mods[i].enabled ? "开启" : "关闭");
    draw_set_color(#E58B8B);
    draw_roundrect(x + 335, row_y - 17, x + 415, row_y + 17, false);
    draw_set_color(c_white);
    draw_text(x + 375, row_y, "删除");
    draw_set_halign(fa_left);
}

var content_height = list_bottom - list_top;
var total_height = max(content_height, array_length(mods) * row_height);
var track_x = x + 430;
draw_set_color(#7BA7B8);
draw_rectangle(track_x, list_top, track_x + 10, list_bottom, false);
var thumb_height = max(35, content_height * content_height / total_height);
var thumb_y = list_top + (content_height - thumb_height) * (scroll_offset / max(1, total_height - content_height));
draw_set_color(#17314C);
draw_rectangle(track_x, thumb_y, track_x + 10, thumb_y + thumb_height, false);
draw_set_color(#17314C);
draw_set_halign(fa_center);
if (array_length(mods) == 0) draw_text(x, y, "还没有安装 Mod");
if (status_text != "") {
    draw_set_valign(fa_top);
    var footer_text = string_replace_all(status_text, "\n", " ");
    while (string_length(footer_text) > 0 && string_width(footer_text) > 880) {
        footer_text = string_delete(footer_text, string_length(footer_text), 1);
    }
    if (footer_text != string_replace_all(status_text, "\n", " ")) footer_text += "…";
    draw_text(x, y + 270, footer_text);
}
draw_set_halign(fa_left);
draw_set_valign(fa_top);
