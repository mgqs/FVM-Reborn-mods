// Draw GUI：商品卡悬停提示（2026-10-28 第四版，照 obj_shop_buy_btn/Draw_64 的做法）
//   · 每个按钮自己画，但先做一次「最近命中选举」：遍历同类实例，只让离卡片中心最近的那个画 → 永不叠字；
//   · 用 mouse_x / mouse_y（GUI 层尺寸 = 房间尺寸，跟普通商店一致），不再用 device_mouse_x_to_gui；
//   · 逐行排版（进化凭证的提示是「卡名 / 进化路线 / 描述 / 用途」四行）；
//   · 框按按钮所在半屏选左右、再夹在屏幕内，不会像之前那样被左边缘截掉。
if (!instance_exists(obj_gods_store_bg)) exit;
if (obj_gods_store_bg.is_submenu_opened) exit;      // 购买确认窗开着 → 不显示
if (tooltip_text == "") exit;

// ── 命中判定：卡片真实范围（卡片 227×90 压 1.8 倍，中心在按钮左侧 80 / 上方 57）──
//     x-284 .. x+124   /   y-138 .. y+24
var _hovered = noone;
var _best    = 1000000000;
var _n = instance_number(obj_gods_store_buy_btn);
for (var _i = 0; _i < _n; _i++) {
    var _c = instance_find(obj_gods_store_buy_btn, _i);
    if (!point_in_rectangle(mouse_x, mouse_y, _c.x - 284, _c.y - 138, _c.x + 124, _c.y + 24)) continue;
    var _d = point_distance(mouse_x, mouse_y, _c.x - 80, _c.y - 57);
    if (_d < _best) { _best = _d; _hovered = _c; }
}
if (_hovered != id) exit;

// ── 排版 ──
draw_set_font(font_yuan);
var _lines = string_split(tooltip_text, "\n");
var _tw = 0;
var _th = 0;
for (var _li = 0; _li < array_length(_lines); _li++) {
    var _ln = _lines[_li];
    if (_ln == "") _ln = " ";
    _tw = max(_tw, string_width(_ln));
    _th += string_height(_ln);
}

var _pad = 6;
var _bw  = _tw + _pad * 2;
var _bh  = _th + _pad * 2;
var _bx1, _by1;
if (x < room_width * 0.5) {
    _bx1 = mouse_x + 14;                            // 按钮在左半屏 → 框放鼠标右边
} else {
    _bx1 = mouse_x - 14 - _bw;                      // 右半屏 → 框放鼠标左边
}
_by1 = mouse_y - 24;
_bx1 = clamp(_bx1, 4, room_width - _bw - 4);        // 夹在屏幕内（之前被左边缘截掉就是这个）
_by1 = clamp(_by1, 4, room_height - _bh - 4);

draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_color(c_black);
draw_set_alpha(0.7);
draw_rectangle(_bx1, _by1, _bx1 + _bw, _by1 + _bh, false);
draw_set_alpha(1);
draw_set_color(c_white);
var _ty = _by1 + _pad;
for (var _lj = 0; _lj < array_length(_lines); _lj++) {
    var _l2 = _lines[_lj];
    if (_l2 == "") _l2 = " ";
    draw_text(_bx1 + _pad, _ty, _l2);
    _ty += string_height(_l2);
}
draw_set_alpha(1);
draw_set_color(c_white);
draw_set_valign(fa_top);
