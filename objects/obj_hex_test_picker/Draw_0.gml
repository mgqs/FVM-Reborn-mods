/// obj_hex_test_picker Draw —— 全库自选的海克斯面板
/// 版式：顶部标题 + 筛选行 / 中间 4×4 卡片网格 / 右侧「本局已选」/ 底部操作

draw_set_alpha(1);
draw_set_font(font_yuan);

// 双保险：Step 已经会自毁，这里再拦一次，免得被异常情况下画到正式关
if (!hex_test_enabled()) exit;

// ── 收起状态：什么都不画 ──
// 入口统一走 F5（obj_battle/Draw_0 里那行「F5：海克斯自选测试」就是提示），
// 不再在画面上留展开条，避免压住左上角的 FPS / 伤害统计文字
if (collapsed) exit;

// ── 遮罩 ──
draw_set_alpha(0.78);
draw_set_color(c_black);
draw_rectangle(0, 0, room_width, room_height, false);
draw_set_alpha(1);

var _side     = picker_side_list();
var _uniq     = array_length(_side);
var _stacks   = hex_test_count();
var _ids      = picker_filter_ids();
var _total    = array_length(_ids);

// ── 标题 ──
draw_set_font(font_hei);
draw_set_valign(fa_middle);
draw_set_halign(fa_left);
draw_set_color(#E8F1F8);
draw_text(40, 58, "自选海克斯");

draw_set_font(font_yuan);
draw_set_color(#7CE38B);
draw_text(196, 60, "测试关卡专用");

draw_set_color(#8FB6D8);
draw_text(40, 88, "左键加一层（可叠加的叠到上限就停） · 右键整条移除 · 滚轮翻页 · 右上搜索 · F5 关闭");

draw_set_halign(fa_right);
draw_set_color(#9BB3C9);
draw_text(1880, 60, "已选 " + string(_uniq) + " 条 / 共 " + string(_stacks) + " 层");
draw_set_color(#6F8496);
draw_text(1880, 88, "不写入存档 · 不占 16 条上限 · 压迫指数不计入");
draw_set_halign(fa_left);

// ── 筛选行 ──
var _btn = picker_buttons();
for (var i = 0; i < array_length(_btn); i++) {
    var _b   = _btn[i];
    var _on  = picker_btn_on(_b);
    var _hov = point_in_rectangle(mouse_x, mouse_y, _b.x, _b.y, _b.x + _b.w, _b.y + _b.h);
    var _cx  = _b.x + _b.w / 2;
    var _cy  = _b.y + _b.h / 2;

    if (_on)       draw_set_color(make_color_rgb(90, 71, 34));
    else if (_hov) draw_set_color(make_color_rgb(46, 62, 78));
    else           draw_set_color(make_color_rgb(26, 36, 46));
    draw_roundrect(_b.x, _b.y, _b.x + _b.w, _b.y + _b.h, false);

    if (_on)       draw_set_color(#FFD479);
    else if (_hov) draw_set_color(#8FB6D8);
    else           draw_set_color(make_color_rgb(58, 76, 92));
    draw_roundrect(_b.x, _b.y, _b.x + _b.w, _b.y + _b.h, true);

    draw_set_halign(fa_center);
    draw_set_color(_on ? #FFF6E0 : #C6D6E4);
    draw_text(_cx, _cy, _b.label);
}
// 统计行贴着网格上沿（筛选行与网格之间只有 26px，放在这里不会被按钮压到）
draw_set_halign(fa_right);
draw_set_color(#6F8496);
draw_text(1460, 163, "共 " + string(_total) + " 条 · 已滚动 " + string(scroll) + "/" + string(max_scroll) + " 行");
draw_set_halign(fa_left);

// ── 卡片网格 ──
if (_total == 0) {
    draw_set_halign(fa_center);
    draw_set_color(#6F8496);
    draw_text(grid_x + grid_w / 2, grid_y + grid_h / 2, "没有符合当前筛选条件的词条");
    draw_set_halign(fa_left);
} else {
    var _cap = cols_show * rows_show;
    for (var g = 0; g < _cap; g++) {
        var _ai = scroll * cols_show + g;
        if (_ai >= _total) break;
        picker_draw_card(_ids[_ai], picker_card_rect(g));
    }
}

// ── 右侧「本局已选」 ──
// 卡片绘制函数结尾会把 valign 落回 fa_top，这里必须重新设成 fa_middle，
// 否则侧栏每一行文字都会贴着行的顶边往下掉半行
draw_set_valign(fa_middle);
draw_set_color(make_color_rgb(17, 25, 33));
draw_roundrect(side_x, grid_y, side_x + side_w, grid_y + grid_h, false);
draw_set_color(make_color_rgb(46, 64, 78));
draw_roundrect(side_x, grid_y, side_x + side_w, grid_y + grid_h, true);

draw_set_font(font_hei);
draw_set_halign(fa_left);
draw_set_color(#E8F1F8);
draw_text(side_x + 16, grid_y + 14, "本局已选 " + string(_uniq) + " 条");
draw_set_halign(fa_right);
draw_set_color(#6F8496);
draw_text(side_x + side_w - 16, grid_y + 14, "点 ✕ 移除");
draw_set_halign(fa_left);
draw_set_font(font_yuan);

var _rows = picker_side_rows();
for (var s = 0; s < _rows; s++) {
    var _ai2 = side_scroll + s;
    if (_ai2 >= _uniq) break;

    var _it = _side[_ai2];
    var _d2 = hex_get(_it.id);
    if (is_undefined(_d2)) continue;

    var _ry = grid_y + side_pad + s * side_row_h + side_row_h / 2;

    // 斑马纹
    if (s mod 2 == 0) {
        draw_set_color(make_color_rgb(22, 32, 42));
        draw_rectangle(side_x + 4, _ry - side_row_h / 2, side_x + side_w - 4, _ry + side_row_h / 2, false);
    }

    // 档位色点
    var _dc;
    switch (_d2.tier) {
        case 0: _dc = #C9D3DD; break;
        case 1: _dc = #FFE3A3; break;
        default: _dc = #C58BFF; break;
    }
    draw_set_color(_dc);
    draw_circle(side_x + 20, _ry, 5, false);

    // 名字
    draw_set_color(#E8F1F8);
    draw_text(side_x + 34, _ry, hex_ellipsis(_d2.name, side_w - 130));

    // 叠层
    draw_set_halign(fa_right);
    draw_set_color(#FFD479);
    var _st = "";
    if (_it.n > 1) _st = "×" + string(_it.n);
    if (_st != "") draw_text(side_x + side_w - 48, _ry, _st);

    // ✕
    var _xx = side_x + side_w - 26;
    var _hovx = point_in_rectangle(mouse_x, mouse_y, _xx - 12, _ry - 12, _xx + 12, _ry + 12);
    draw_set_color(_hovx ? #FF8B8B : #5C7488);
    draw_line_width(_xx - 6, _ry - 6, _xx + 6, _ry + 6, 2);
    draw_line_width(_xx - 6, _ry + 6, _xx + 6, _ry - 6, 2);
    draw_set_halign(fa_left);
}

if (_uniq == 0) {
    draw_set_halign(fa_center);
    draw_set_color(#5C7488);
    draw_text(side_x + side_w / 2, grid_y + grid_h / 2, "还没选任何词条");
    draw_set_halign(fa_left);
}

// ── 底部按钮 ──
var _fc_clear = point_in_rectangle(mouse_x, mouse_y, 40, 1012, 220, 1066);
draw_set_color(_fc_clear ? make_color_rgb(74, 40, 40) : make_color_rgb(44, 30, 30));
draw_roundrect(40, 1012, 220, 1066, false);
draw_set_color(_fc_clear ? #FF9E9E : #7A4A4A);
draw_roundrect(40, 1012, 220, 1066, true);
draw_set_halign(fa_center);
draw_set_color(#F6E7E7);
draw_text(130, 1039, "清空全部");

var _fc_fold = point_in_rectangle(mouse_x, mouse_y, 236, 1012, 416, 1066);
draw_set_color(_fc_fold ? make_color_rgb(40, 56, 72) : make_color_rgb(28, 38, 48));
draw_roundrect(236, 1012, 416, 1066, false);
draw_set_color(_fc_fold ? #9BC7E8 : #4A6274);
draw_roundrect(236, 1012, 416, 1066, true);
draw_set_color(#EAF4FB);
draw_text(326, 1039, "关闭面板 (F5)");
draw_set_halign(fa_left);

// ── 提示 ──
if (msg_timer > 0) {
    draw_set_alpha(min(1, msg_timer / 20));
    draw_set_color(#FF9E6B);
    draw_set_halign(fa_center);
    draw_text(960, 1039, msg_text);
    draw_set_alpha(1);
    draw_set_halign(fa_left);
}

draw_set_halign(fa_left);
draw_set_valign(fa_top);
