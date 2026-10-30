/// obj_hex_effect —— 「效果」面板
/// 入口：对局内 ESC → 暂停菜单 → 效果
/// 内容：把当前所有生效的海克斯整理成两栏 —— 左「对卡片」、右「对老鼠」。
///       数据源是 hex_effect_rows()，读的是 hex_state / global 出口，
///       和战斗里实际使用的那一份同源，不另维护说明表。

depth = -7000;

w = 1040;
h = 680;
px = x - w / 2;
py = y - h / 2;

pad     = 22;
col_gap = 20;
col_w   = (w - pad * 2 - col_gap) / 2;
col_x0  = px + pad;
col_x1  = col_x0 + col_w + col_gap;

view_y  = py + 96;          // 两栏标题条的顶部
head_h  = 44;
list_y  = view_y + head_h;  // 列表区顶部
list_h  = h - (list_y - py) - 48;
item_h  = 44;

if (!hex_active()) {        // 测试关卡 / 非海克斯模式不显示
    instance_destroy();
    exit;
}

rows          = hex_effect_rows();
scroll_y      = 0;
scroll_target = 0;
surf_card     = -1;
surf_enemy    = -1;
close_hover   = false;
drag          = false;
drag_off      = 0;

/// @function hex_effect_list_h()
/// @desc 两栏共用一条滚动量，取较长的一栏
function hex_effect_list_h() {
    return max(array_length(rows.card), array_length(rows.enemy)) * item_h;
}

/// @function hex_effect_draw_col(_side)
/// @desc 把某一栏画进它自己的离屏表面（0 = 对卡片 / 1 = 对老鼠）。
///       表面尺寸就是视口尺寸，超出部分自动裁掉，不会压到标题与底部提示。
function hex_effect_draw_col(_side) {
    var _arr  = (_side == 0) ? rows.card : rows.enemy;
    var _surf = (_side == 0) ? surf_card : surf_enemy;

    if (!surface_exists(_surf)) {
        _surf = surface_create(col_w, list_h);
        if (_side == 0) surf_card = _surf; else surf_enemy = _surf;
    }
    if (!surface_exists(_surf)) return false;

    surface_set_target(_surf);
    draw_clear_alpha(c_black, 0);
    draw_set_alpha(1);

    var _n = array_length(_arr);
    for (var i = 0; i < _n; i++) {
        var _row = _arr[i];
        var _ry  = i * item_h - scroll_y;
        if (_ry + item_h < 0 || _ry > list_h) continue;

        if (i mod 2 == 0) {
            draw_set_color(make_color_rgb(18, 22, 29));
            draw_rectangle(0, _ry, col_w, _ry + item_h, false);
        }

        // 左侧色标
        draw_set_color(make_color_rgb(58, 74, 90));
        draw_rectangle(10, _ry + 11, 14, _ry + item_h - 11, false);

        // 名称
        draw_set_font(font_yuan);
        draw_set_halign(fa_left);
        draw_set_valign(fa_middle);
        draw_set_color(#EEF4FA);
        draw_text(26, _ry + item_h / 2, _row.label);

        // 数值：0% 灰；老鼠侧「变大」才是坏消息，颜色与卡片侧相反
        var _v     = _row.value;
        var _first = string_char_at(_v, 1);
        var _col   = make_color_rgb(143, 166, 186);
        if (_first != "0") {
            var _neg = (_first == "-");
            if (_side == 1) _col = _neg ? make_color_rgb(124, 227, 139) : make_color_rgb(255, 158, 158);
            else            _col = _neg ? make_color_rgb(255, 158, 158) : make_color_rgb(124, 227, 139);
        }
        draw_set_color(_col);
        draw_set_halign(fa_right);
        draw_text(col_w - 14, _ry + item_h / 2, _v);
        draw_set_halign(fa_left);
    }

    surface_reset_target();
    draw_set_alpha(1);
    draw_set_color(c_white);
    return true;
}

/// @function hex_effect_blit(_side, _dx)
/// @desc 把某一栏的表面贴回面板，并处理空栏提示
function hex_effect_blit(_side, _dx) {
    var _surf = (_side == 0) ? surf_card : surf_enemy;
    var _arr  = (_side == 0) ? rows.card : rows.enemy;
    if (surface_exists(_surf)) {
        draw_set_alpha(1);
        draw_set_color(c_white);
        draw_surface(_surf, _dx, list_y);
    }
    if (array_length(_arr) == 0) {
        draw_set_font(font_yuan);
        draw_set_halign(fa_center);
        draw_set_valign(fa_middle);
        draw_set_color(#6C7C8C);
        draw_text(_dx + col_w / 2, list_y + 60, "当前没有任何该侧加成");
        draw_set_halign(fa_left);
    }
}

audio_play_sound(snd_button, 0, 0);
