/// obj_hex_hud Draw —— 左侧：压迫 PI（上）+ 共鸣栏（下）
/// 配色原则：全部用高明度色 + 深色描边，压在任何地形上都读得清

if (!hex_active()) exit;     // 测试关卡不画（双保险，Step 已经会自毁）
if (!variable_global_exists("hex_state")) exit;

var _s   = global.hex_state;
var _cfg = hex_cfg();

// ── 文字描边工具 ──
/// @function hex_hud_text(_x, _y, _str, _col)
function hex_hud_text(_x, _y, _str, _col) {
    draw_set_color(c_black);
    draw_set_alpha(0.9);
    draw_text(_x + 1, _y + 1, _str);
    draw_set_alpha(1);
    draw_set_color(_col);
    draw_text(_x, _y, _str);
}

var _px = bond_bx;
var _py = bond_by - 150;

// ══════════ 底板：先铺一块深色半透明，字才不会糊进背景 ══════════
var _rows_h = array_length(bond_rows) * bond_row_h;
var _bg_x1  = _px - 16;
var _bg_y1  = _py - 26;
var _bg_x2  = _px + bond_hit_w + 14;
var _bg_y2  = bond_by + max(0, _rows_h) + 14;

draw_set_alpha(0.62);
draw_set_color(make_color_rgb(8, 14, 10));
draw_roundrect_ext(_bg_x1, _bg_y1, _bg_x2, _bg_y2, 10, 10, false);
draw_set_alpha(0.9);
draw_set_color(make_color_rgb(70, 120, 84));
draw_roundrect_ext(_bg_x1, _bg_y1, _bg_x2, _bg_y2, 10, 10, true);
draw_set_alpha(1);

// ══════════ 压迫 PI ══════════
var _pct = round((global.pi_enemy_mult - 1) * 100);
var _thr = 999;
if (_s.pi_value < 10)      { _thr = 10; }
else if (_s.pi_value < 18) { _thr = 18; }
else if (_s.pi_value < 26) { _thr = 26; }
else if (_s.pi_value < 32) { _thr = 32; }
var _near_threshold = (_s.pi_value >= _thr - 2);

var _c = _near_threshold ? make_color_rgb(255, 150, 120) : make_color_rgb(150, 255, 170);
if (_near_threshold && (current_time div 400) mod 2 == 0) {
    _c = make_color_rgb(255, 235, 190);
}

draw_set_font(font_yuan);
draw_set_halign(fa_left);
draw_set_valign(fa_middle);

hex_hud_text(_px, _py, "压迫 PI " + string(_s.pi_value), _c);
hex_hud_text(_px, _py + 24, "老鼠全属性 +" + string(_pct) + "%",
             make_color_rgb(255, 226, 160));

// 鼠潮预告
if (global.pi_elite_extra > 0) {
    hex_hud_text(_px, _py + 48, "每波额外精英 +" + string(global.pi_elite_extra),
                 make_color_rgb(255, 196, 120));
}
if (global.pi_boss_escort) {
    hex_hud_text(_px, _py + 70, "BOSS 波有护卫",
                 make_color_rgb(255, 160, 140));
}

// 距离下一档的进度条
if (_thr < 900) {
    var _w = 190;
    var _yy = (_s.pi_value >= 26) ? _py + 92 : _py + 92;
    draw_set_color(make_color_rgb(26, 40, 30));
    draw_rectangle(_px, _yy, _px + _w, _yy + 7, false);
    var _ratio = clamp(_s.pi_value / _thr, 0, 1);
    draw_set_color(_c);
    draw_rectangle(_px, _yy, _px + _w * _ratio, _yy + 7, false);
}

// ══════════ 共鸣栏 ══════════
var _bx = bond_bx;
var _by = bond_by;

draw_set_halign(fa_left);
draw_set_valign(fa_middle);
draw_set_font(font_yuan);
var _bond_head = "共鸣";
var _pn = hex_persist_count();
if (_pn > 0) _bond_head += "    永久 " + string(_pn) + " 种";
hex_hud_text(_bx, _by - 26, _bond_head, make_color_rgb(170, 255, 190));

for (var i = 0; i < array_length(bond_rows); i++) {
    var _row = bond_rows[i];
    var _y   = _by + i * bond_row_h;
    var _hov = (bond_hover == i);

    // 悬停：整行提亮
    if (_hov) {
        draw_set_color(make_color_rgb(30, 62, 40));
        draw_set_alpha(0.92);
        draw_rectangle(_bx - 12, _y - bond_row_h * 0.5,
                       _bx + bond_hit_w, _y + bond_row_h * 0.5, false);
        draw_set_color(make_color_rgb(140, 240, 165));
        draw_set_alpha(1);
        draw_rectangle(_bx - 12, _y - bond_row_h * 0.5,
                       _bx + bond_hit_w, _y + bond_row_h * 0.5, true);
        draw_set_alpha(1);
    }

    // 档位点：已达成的亮绿，未达成的暗绿
    for (var p = 0; p < 3; p++) {
        var _on = (p < _row.tier);
        draw_set_color(_on ? make_color_rgb(170, 255, 190) : make_color_rgb(58, 92, 66));
        draw_circle(_bx + 5 + p * 11, _y + 9, 3.4, false);
    }

    // 名字 + 计数：达成用亮绿，未达成用次亮绿
    var _line = _row.name + "  " + string(_row.count) + "/" + string(_row.next);
    var _lc = (_row.tier > 0) ? make_color_rgb(170, 255, 190) : make_color_rgb(140, 220, 158);
    hex_hud_text(_bx + 42, _y, _line, _lc);

    if (_row.tier > 0) {
        var _tagx = _row.done ? "MAX" : ("Lv" + string(_row.tier));
        hex_hud_text(_bx + 42 + string_width(_line) + 12, _y, _tagx,
                     make_color_rgb(255, 226, 160));
    }

    // 悬停说明：当前档效果，未达成则写下档还差几张
    if (_hov) {
        var _idx  = (_row.tier > 0) ? _row.tier - 1 : 0;
        var _eff  = hex_bond_effect_text(_row.name, _idx);
        var _head = _row.name;
        if (_row.tier > 0) _head += "  Lv" + string(_row.tier);
        else               _head += "  未达成";

        var _sub;
        if (_row.tier > 0) {
            _sub = _eff;
            if (!_row.done) _sub += "   下一档 " + string(_row.next) + " 张";
        } else {
            _sub = "达成后(" + string(_row.next) + " 张): " + _eff;
        }

        var _tw = max(string_width(_head), string_width(_sub)) + 26;
        var _th = 54;
        var _tx = _bx + bond_hit_w + 14;
        if (_tx + _tw > room_width) _tx = room_width - _tw - 8;

        draw_set_color(make_color_rgb(14, 26, 18));
        draw_set_alpha(0.95);
        draw_rectangle(_tx, _y - _th * 0.5, _tx + _tw, _y + _th * 0.5, false);
        draw_set_alpha(1);
        draw_set_color(make_color_rgb(140, 240, 165));
        draw_rectangle(_tx, _y - _th * 0.5, _tx + _tw, _y + _th * 0.5, true);

        hex_hud_text(_tx + 13, _y - 12, _head, make_color_rgb(190, 255, 205));
        hex_hud_text(_tx + 13, _y + 12, _sub,  make_color_rgb(236, 248, 238));
    }
}

// ══════════ 开局提示：对局内怎么选卡 ══════════
if (hint_timer > 0 && !global.hex_pick_open) {
    var _ha = min(1, hint_timer / 60);
    draw_set_alpha(_ha);
    draw_set_color(make_color_rgb(10, 18, 12));
    draw_rectangle(_bg_x1, _bg_y2 + 10, _bg_x2, _bg_y2 + 42, false);
    draw_set_color(make_color_rgb(255, 226, 160));
    draw_text(_bg_x1 + 12, _bg_y2 + 26, "击杀老鼠有概率触发选卡");
    draw_set_alpha(1);
}

draw_set_halign(fa_left);
draw_set_valign(fa_top);
