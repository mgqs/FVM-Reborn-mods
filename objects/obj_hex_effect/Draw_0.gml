/// obj_hex_effect Draw —— 两栏（对卡片 / 对老鼠），每栏独立裁剪

// ── 遮罩 ──
draw_set_alpha(0.62);
draw_set_color(c_black);
draw_rectangle(0, 0, room_width, room_height, false);
draw_set_alpha(1);

// ── 面板 ──
draw_set_color(make_color_rgb(16, 20, 26));
draw_roundrect(px, py, px + w, py + h, false);
draw_set_color(make_color_rgb(70, 92, 112));
draw_roundrect(px, py, px + w, py + h, true);

// ── 标题 ──
draw_set_font(font_yuan);
draw_set_halign(fa_left);
draw_set_valign(fa_middle);
draw_set_color(#E8F1F8);
draw_text(px + 30, py + 36, "海克斯效果");
var _title_w = string_width("海克斯效果");

draw_set_font(font_hei);
draw_set_color(#7E93A8);
var _n_run = 0;
var _n_pst = 0;
if (variable_global_exists("hex_state") && is_struct(global.hex_state)) {
    _n_run = array_length(global.hex_state.picked);
    _n_pst = array_length(global.hex_state.persist);
}
draw_text(px + 30 + _title_w + 24, py + 38,
    "本局 " + string(_n_run) + " 条 / 永久 " + string(_n_pst) + " 条");

// 关闭
draw_set_font(font_yuan);
draw_set_halign(fa_center);
draw_set_color(close_hover ? #FF9E9E : #8AA2B8);
draw_text(px + w - 38, py + 34, "X");

// ── 两栏标题条 ──
draw_set_halign(fa_left);
draw_set_color(make_color_rgb(28, 36, 46));
draw_roundrect(col_x0, view_y, col_x0 + col_w, view_y + head_h, false);
draw_roundrect(col_x1, view_y, col_x1 + col_w, view_y + head_h, false);

draw_set_color(#8CE0A8);
draw_text(col_x0 + 16, view_y + head_h / 2, "对卡片");
draw_set_color(#FF9E9E);
draw_text(col_x1 + 16, view_y + head_h / 2, "对老鼠");

draw_set_font(font_hei);
draw_set_color(#7E93A8);
draw_set_halign(fa_right);
draw_text(col_x0 + col_w - 16, view_y + head_h / 2, string(array_length(rows.card)) + " 项");
draw_text(col_x1 + col_w - 16, view_y + head_h / 2, string(array_length(rows.enemy)) + " 项");
draw_set_halign(fa_left);

// ── 两栏列表（各画进一张离屏表面再整张贴回，表面尺寸天然裁剪）──
hex_effect_draw_col(0);
hex_effect_blit(0, col_x0);

hex_effect_draw_col(1);
hex_effect_blit(1, col_x1);

// ── 滚动条 ──
var _list_total = hex_effect_list_h();
if (_list_total > list_h) {
    var _bar_x = px + w - 14;
    draw_set_color(make_color_rgb(34, 42, 52));
    draw_rectangle(_bar_x, list_y, _bar_x + 6, list_y + list_h, false);

    var _frac    = list_h / _list_total;
    var _thumb_h = max(40, list_h * _frac);
    var _pos     = (scroll_target / max(1, _list_total - list_h)) * (list_h - _thumb_h);
    draw_set_color(make_color_rgb(96, 124, 148));
    draw_rectangle(_bar_x, list_y + _pos, _bar_x + 6, list_y + _pos + _thumb_h, false);
}

// ── 底部提示 ──
draw_set_font(font_hei);
draw_set_color(#7E93A8);
draw_set_halign(fa_left);
draw_set_valign(fa_middle);
draw_text(px + pad, py + h - 26, "数值为本局实际生效值,含永久词条与压迫 PI");

draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_alpha(1);
