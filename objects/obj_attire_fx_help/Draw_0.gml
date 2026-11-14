// 角色信息栏「变装特效」按钮 + 说明弹窗（2026-11-13）
// 按钮：spr_attire_fx_help 3 帧（0 常态 / 1 悬停 / 2 按下），文字运行时绘制
// 弹窗：遍历 attire_fx_table()，9 组「宝石 + 套装 → 变装」，改表即可，不另存副本
if (!visible) exit;

// ── 按钮 ──
// 帧序：0 常态 / 1 悬停 / 2 按下（分层 if，别写成嵌套三元）
var _frame = 0;
if (hover) {
    _frame = 1;
    if (mouse_check_button(mb_left)) _frame = 2;
}
draw_sprite_ext(spr_attire_fx_help, _frame, x, y, image_xscale, image_yscale, 0, c_white, 1);

draw_set_font(font_yuan);
draw_set_halign(fa_center);
draw_set_valign(fa_middle);
// 底图是米色渐变（88×33 原尺寸，这里按 1.6 倍绘制）；字用深棕，先垫一层浅色做浮雕
// 字号换算：原「转职说明」四个字占 88px 里的 68px（≈ font_yuan 16px 的 1.06 倍），
// 本按钮画在 1.6 倍 → 文字取 1.7 倍才同比例
draw_set_colour(make_colour_rgb(255, 250, 232));
draw_text_transformed(x, y + 3, "变装特效", 1.7, 1.7, 0);
draw_set_colour(make_colour_rgb(104, 68, 24));
draw_text_transformed(x, y, "变装特效", 1.7, 1.7, 0);

if (!open) {
    draw_set_colour(c_white);
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
    exit;
}

// ── 弹窗 ──
var _r = attire_fx_panel_rect();
var _rows = attire_fx_table();

draw_set_alpha(0.62);
draw_rectangle_colour(0, 0, room_width, room_height, c_black, c_black, c_black, c_black, false);
draw_set_alpha(1);

// 外描边 + 深蓝面板（同角色信息面板的配色）
draw_roundrect_colour_ext(_r[0] - 5, _r[1] - 5, _r[2] + 5, _r[3] + 5, 22, 22,
    make_colour_rgb(126, 200, 255), make_colour_rgb(126, 200, 255), false);
draw_roundrect_colour_ext(_r[0], _r[1], _r[2], _r[3], 18, 18,
    make_colour_rgb(13, 42, 74), make_colour_rgb(23, 70, 112), false);

var _cx = (_r[0] + _r[2]) * 0.5;

draw_set_halign(fa_center);
draw_set_valign(fa_middle);
draw_set_font(font_yuan);
draw_set_colour(c_white);
draw_text_transformed(_cx, _r[1] + 44, "变装特效", 1.6, 1.6, 0);

// 规则说明（两行，缺一不可 + 神杖例外）
draw_set_colour(make_colour_rgb(168, 214, 255));
draw_text(_cx, _r[1] + 88, "携带对应宝石 + 穿戴对应套装，进入战斗放下人物时才会播放 —— 两者缺一不可");
draw_set_colour(make_colour_rgb(150, 196, 232));
draw_text_transformed(_cx, _r[1] + 116,
    "星之神杖本体入场特效例外：只要装备了星之神杖就会播放，与宝石、套装无关", 0.86, 0.86, 0);

// 表头
var _hx = _r[0] + 76;
var _hy = _r[1] + 152;
draw_set_font(font_yuan);
draw_set_halign(fa_left);
draw_set_colour(make_colour_rgb(150, 200, 245));
draw_text(_hx, _hy, "变装特效");
draw_set_halign(fa_center);
draw_text(_r[0] + 330, _hy, "宝石");
draw_text(_r[0] + 556, _hy, "套装");
var _hbr = attire_fx_row_rect(0);
draw_text((_hbr[0] + _hbr[2]) * 0.5, _hy, "操作");

// 9 行
var _top = _r[1] + 184;
var _step = 55;
for (var _i = 0; _i < array_length(_rows); _i++) {
    var _c = _rows[_i];
    var _y = _top + _i * _step;

    if (_i mod 2 == 1) {
        draw_set_alpha(0.14);
        var _rc = make_colour_rgb(140, 200, 255);
        draw_rectangle_colour(_r[0] + 24, _y - 25, _r[2] - 24, _y + 25,
            _rc, _rc, _rc, _rc, false);
        draw_set_alpha(1);
    }

    // 序号（右对齐）
    draw_set_font(font_yuan);
    draw_set_colour(make_colour_rgb(150, 200, 245));
    draw_set_halign(fa_right);
    draw_text(_r[0] + 56, _y, string(_i + 1) + ".");

    // 特效名
    draw_set_font(font_yuan);
    draw_set_colour(c_white);
    draw_set_halign(fa_left);
    draw_text(_hx, _y, _c.name);

    // 宝石
    var _g = get_gem_info(_c.gem);
    var _gname = is_struct(_g) ? _g.name : _c.gem;
    if (is_struct(_g)) {
        var _gi = _g.icon;
        var _gs = 30 / sprite_get_height(_gi);
        draw_sprite_ext(_gi, 0, _r[0] + 300, _y, _gs, _gs, 0, c_white, 1);
    }
    draw_set_colour(make_colour_rgb(255, 226, 150));
    draw_text(_r[0] + 326, _y, _gname);

    draw_set_colour(c_white);
    draw_set_halign(fa_center);
    draw_text(_r[0] + 500, _y, "+");

    // 套装
    var _a = get_attire_info(_c.attire);
    var _aname = is_struct(_a) ? _a.name : _c.attire;
    if (is_struct(_a)) {
        var _ai = _a.icon;
        var _as = 42 / sprite_get_height(_ai);
        draw_sprite_ext(_ai, 0, _r[0] + 530, _y, _as, _as, 0, c_white, 1);
    }
    draw_set_colour(make_colour_rgb(180, 255, 210));
    draw_set_halign(fa_left);
    draw_text(_r[0] + 556, _y, _aname);

    // ── 行尾「穿戴」按钮（2026-11-14）──
    // 三种状态：已穿戴（绿）/ 可穿戴（亮蓝）/ 缺件（灰蓝，点了只弹提示不改存档）
    var _br = attire_fx_row_rect(_i);
    var _bx = (_br[0] + _br[2]) * 0.5;
    var _by = (_br[1] + _br[3]) * 0.5;
    var _own = attire_fx_own_all(_c);
    var _worn = attire_fx_is_worn(_c);
    var _bover = point_in_rectangle(mouse_x, mouse_y, _br[0], _br[1], _br[2], _br[3]);
    var _bfill = make_colour_rgb(26, 58, 88);
    var _bline = make_colour_rgb(74, 118, 158);
    var _btxt = make_colour_rgb(150, 176, 200);
    if (_own) {
        _bfill = make_colour_rgb(30, 96, 148);
        _bline = make_colour_rgb(126, 200, 255);
        _btxt = c_white;
    }
    if (_worn) {
        _bfill = make_colour_rgb(28, 104, 80);
        _bline = make_colour_rgb(126, 235, 170);
        _btxt = make_colour_rgb(200, 255, 226);
    }
    if (_bover) {
        // 悬停提亮一档；按下再压暗（不写嵌套三元，改成顺序 if）
        _bfill = make_colour_rgb(
            min(255, color_get_red(_bfill) + 26),
            min(255, color_get_green(_bfill) + 26),
            min(255, color_get_blue(_bfill) + 26));
        if (mouse_check_button(mb_left)) _bfill = make_colour_rgb(16, 44, 68);
    }
    draw_roundrect_colour_ext(_br[0], _br[1], _br[2], _br[3], 10, 10, _bfill, _bfill, false);
    draw_roundrect_colour_ext(_br[0], _br[1], _br[2], _br[3], 10, 10, _bline, _bline, true);
    draw_set_font(font_yuan);
    draw_set_colour(_btxt);
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    if (_worn) {
        draw_text(_bx, _by, "已穿戴");
    } else {
        draw_text(_bx, _by, "穿戴");
    }
}

// 确定按钮
var _cr = attire_fx_confirm_rect();
var _bcx = (_cr[0] + _cr[2]) * 0.5;
var _bcy = (_cr[1] + _cr[3]) * 0.5;
var _bhover = point_in_rectangle(mouse_x, mouse_y, _cr[0], _cr[1], _cr[2], _cr[3]);
var _bframe = 0;
if (_bhover) {
    _bframe = 1;
    if (mouse_check_button(mb_left)) _bframe = 2;
}
mod_ui_common_btn_draw(_bframe, _bcx, _bcy, 0.75);
draw_set_font(font_yuan);
draw_set_colour(c_white);
draw_set_halign(fa_center);
draw_set_valign(fa_middle);
draw_text(_bcx, _bcy, "确定");

draw_set_colour(c_white);
draw_set_alpha(1);
draw_set_halign(fa_left);
draw_set_valign(fa_top);
