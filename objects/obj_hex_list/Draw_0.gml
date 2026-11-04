/// obj_hex_list Draw —— 面板、页签、视口内列表、滚动条

// 遮罩
draw_set_alpha(0.62);
draw_set_color(c_black);
draw_rectangle(0, 0, room_width, room_height, false);
draw_set_alpha(1);

// 面板
draw_set_color(make_color_rgb(16, 20, 26));
draw_roundrect(px, py, px + w, py + h, false);
draw_set_color(make_color_rgb(70, 92, 112));
draw_roundrect(px, py, px + w, py + h, true);

// 标题
draw_set_font(font_yuan);
draw_set_halign(fa_left);
draw_set_valign(fa_middle);
draw_set_color(#E8F1F8);
var _total_ids = array_length(global.hex_ids);
draw_text(px + 30, py + 36, "已有词条 " + string(hex_unlocked_total()) + " / " + string(_total_ids));

// 关闭
draw_set_halign(fa_center);
draw_set_color(close_hover ? #FF9E9E : #8AA2B8);
draw_text(px + w - 38, py + 34, "X");

// 页签（几何来自 Create 的 tab_* 变量，Step 的点击区用的是同一套）
draw_set_color(tab == 0 ? make_color_rgb(60, 86, 108) : make_color_rgb(30, 38, 48));
draw_roundrect(tab_x0, tab_y0, tab_x0 + tab_w, tab_y1, false);
draw_set_color(tab == 0 ? #EAF4FB : #7E93A8);
draw_text(tab_x0 + tab_w / 2, (tab_y0 + tab_y1) / 2, "已解锁");

draw_set_color(tab == 1 ? make_color_rgb(60, 86, 108) : make_color_rgb(30, 38, 48));
draw_roundrect(tab_x1, tab_y0, tab_x1 + tab_w, tab_y1, false);
draw_set_color(tab == 1 ? #EAF4FB : #7E93A8);
draw_text(tab_x1 + tab_w / 2, (tab_y0 + tab_y1) / 2, "本局");

if (tab == 1) {
    draw_set_font(font_hei);
    draw_set_color(#7E93A8);
    draw_set_halign(fa_left);
    draw_text(tab_x1 + tab_w + 44, (tab_y0 + tab_y1) / 2, "通关后加入[已解锁]");
} else {
    draw_set_font(font_hei);
    draw_set_color(#7E93A8);
    draw_set_halign(fa_left);
    draw_text(tab_x1 + tab_w + 44, (tab_y0 + tab_y1) / 2, "已解锁的词条永久生效");
}

// 视口背景
draw_set_alpha(1);
draw_set_color(make_color_rgb(12, 15, 20));
draw_rectangle(view_x, view_y, view_x + view_w, view_y + view_h, false);

// ══════════ 列表 ══════════
// 先画进离屏表面再整张贴回：超出视口的部分会被表面尺寸自动裁掉，
// 不会像直接 draw_text 那样溢到标题/底部文字上去。
if (!surface_exists(view_surf)) view_surf = surface_create(view_w, view_h);
if (surface_exists(view_surf)) {
    surface_set_target(view_surf);
    draw_clear_alpha(c_black, 0);
    draw_set_alpha(1);

    var _n = array_length(rows);
    for (var i = 0; i < _n; i++) {
        var _row = rows[i];
        var _ry  = _row.y - scroll_y;
        if (_ry + _row.h < 0 || _ry > view_h) continue;      // 完全在视口外，跳过

        // 隔行底色
        if (i mod 2 == 0) {
            draw_set_color(make_color_rgb(18, 22, 29));
            draw_rectangle(0, _ry, view_w, _ry + _row.h, false);
        }

        var _c1;
        switch (_row.tier) {
            case 0:  _c1 = #C9D3DD; break;
            case 1:  _c1 = #FFE3A3; break;
            default: _c1 = #B891FF; break;
        }

        draw_set_alpha(1);

        // 左侧稀有度色条：跟着这一行的实际高度走
        draw_set_color(_c1);
        draw_rectangle(8, _ry + 12, 12, _ry + _row.h - 12, false);

        // ── 第一行：名字 + 稀有度 + 右侧标记 ──
        draw_set_font(font_yuan);
        draw_set_halign(fa_left);
        draw_set_valign(fa_middle);
        draw_set_color(#EEF4FA);
        draw_text(row_pad_x, _ry + row_head_h / 2, _row.name);
        var _name_w = string_width(_row.name);

        // 稀有度
        draw_set_font(font_hei);
        draw_set_color(_c1);
        draw_text(row_pad_x + _name_w + 14, _ry + row_head_h / 2, hex_tier_name(_row.tier));

        // 右侧标记：永久生效 / 本局叠层数
        var _tag = "";
        if (variable_struct_exists(_row, "persist") && _row.persist) _tag = "永久";
        else if (_row.times > 0) _tag = "x" + string(_row.times);
        if (_tag != "") {
            draw_set_color(#9BB3C9);
            draw_set_halign(fa_right);
            draw_text(view_w - 16, _ry + row_head_h / 2, _tag);
            draw_set_halign(fa_left);
        }

        // ── 效果：两段改成纵向堆叠，各自按宽度换行，不会再左右撞在一起 ──
        var _fc = (_row.form == "C") ? make_color_rgb(255, 110, 110) : make_color_rgb(124, 227, 139);
        draw_set_font(font_yuan);
        draw_set_halign(fa_left);
        draw_set_valign(fa_middle);

        draw_set_color(_fc);
        var _cd_h = hex_draw_lines(_row.card_lines, row_pad_x, _ry + row_head_h,
                                   row_line_h, row_max_lines, row_text_w);

        draw_set_color(make_color_rgb(176, 194, 208));
        hex_draw_lines(_row.enemy_lines, row_pad_x, _ry + row_head_h + _cd_h,
                       row_line_h, row_max_lines, row_text_w);
    }

    surface_reset_target();
    draw_set_alpha(1);
    draw_set_color(c_white);
    draw_surface(view_surf, view_x, view_y);
} else {
    // 表面创建失败的兜底：直接画（可能溢出视口，但至少内容还在）
    var _n2 = array_length(rows);
    for (var k = 0; k < _n2; k++) {
        var _r2  = rows[k];
        var _ry2 = view_y + _r2.y - scroll_y;
        if (_ry2 + _r2.h < view_y || _ry2 > view_y + view_h) continue;
        draw_set_font(font_yuan);
        draw_set_halign(fa_left);
        draw_set_valign(fa_middle);
        draw_set_color(#EEF4FA);
        draw_text(view_x + row_pad_x, _ry2 + row_head_h / 2, _r2.name);
    }
}

// 空列表提示
if (array_length(rows) == 0) {
    draw_set_font(font_yuan);
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    draw_set_color(#6C7C8C);
    if (tab == 0) {
        draw_text(view_x + view_w / 2, view_y + view_h / 2 - 12, "还没有解锁任何词条");
        draw_set_font(font_hei);
        draw_set_color(#54646F);
        draw_text(view_x + view_w / 2, view_y + view_h / 2 + 20, "在海克斯模式里通关一局,本局拿到的词条就会记进来");
    } else {
        draw_text(view_x + view_w / 2, view_y + view_h / 2, "本局还没有拿到词条");
    }
    draw_set_halign(fa_left);
}

// 滚动条
var _list_h = list_total_h;
if (_list_h > view_h) {
    var _bar_x = view_x + view_w + 6;
    draw_set_color(make_color_rgb(34, 42, 52));
    draw_rectangle(_bar_x, view_y, _bar_x + 6, view_y + view_h, false);

    var _frac = view_h / _list_h;
    var _thumb_h = max(40, view_h * _frac);
    var _pos = (scroll_target / max(1, _list_h - view_h)) * (view_h - _thumb_h);
    draw_set_color(make_color_rgb(96, 124, 148));
    draw_rectangle(_bar_x, view_y + _pos, _bar_x + 6, view_y + _pos + _thumb_h, false);
}

// 底部：收集进度
draw_set_font(font_hei);
draw_set_color(#7E93A8);
draw_set_halign(fa_left);
draw_set_valign(fa_middle);
draw_text(view_x, py + h - 26,
    "共 " + string(_total_ids) + " 条,已解锁 " + string(hex_unlocked_total()) + " 条");

draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_alpha(1);
