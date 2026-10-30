/// 画遮罩 + 面板 + 按钮
/// 所有纵向位置都用 Create 里算好的 title_y / hint_y / hwid_y / box_y / status_y，
/// 别在这里写 panel_y + 常数 —— 两处各写一份必然对不齐。
draw_set_alpha(0.62);
draw_set_color(c_black);
draw_rectangle(0, 0, room_width, room_height, false);
draw_set_alpha(1);

// ── 面板 ──
draw_set_color(make_color_rgb(246, 238, 222));
draw_roundrect_ext(panel_x, panel_y, panel_x + panel_w, panel_y + panel_h, 18, 18, false);
draw_set_color(make_color_rgb(126, 90, 46));
draw_roundrect_ext(panel_x, panel_y, panel_x + panel_w, panel_y + panel_h, 18, 18, true);
draw_set_color(make_color_rgb(198, 176, 142));
draw_roundrect_ext(panel_x + 6, panel_y + 6, panel_x + panel_w - 6, panel_y + panel_h - 6, 14, 14, true);

// ── 标题 ──
draw_set_font(font_yuan);
draw_set_halign(fa_center);
draw_set_valign(fa_middle);
draw_set_color(make_color_rgb(62, 46, 28));
draw_text_transformed(panel_x + panel_w * 0.5, title_y, "授权", 1.7, 1.7, 0);

// ── 说明 ──
draw_set_color(make_color_rgb(104, 88, 66));
var _hint = "① 点下面这行复制本机识别码　② @小Makk发送  " + kAuthCommand + " 识别码";
if (mandatory) {
    _hint = "未授权无法进入游戏　" + _hint;
}
draw_text_transformed(panel_x + panel_w * 0.5, hint_y, _hint, 1.0, 1.0, 0);

// ── 本机识别码（整行可点，点了复制）──
if (hover_hwid) {
    draw_set_color(make_color_rgb(255, 250, 232));
} else {
    draw_set_color(make_color_rgb(238, 228, 208));
}
draw_roundrect_ext(hwid_x, hwid_y, hwid_x + hwid_w, hwid_y + hwid_h, 10, 10, false);
draw_set_color(copied ? make_color_rgb(44, 132, 74) : make_color_rgb(150, 128, 96));
draw_roundrect_ext(hwid_x, hwid_y, hwid_x + hwid_w, hwid_y + hwid_h, 10, 10, true);

// 标签：左对齐贴着框内左边距。
// 原来是 fa_right 到 hwid_x + 22 —— 右对齐意味着文字往左伸出锚点，
// 5 个字直接顶到框外，看着像框被挤歪了。
draw_set_valign(fa_middle);
draw_set_halign(fa_left);
draw_set_color(make_color_rgb(104, 88, 66));
draw_text_transformed(hwid_x + 22, hwid_y + hwid_h * 0.5, "本机识别码", 1.0, 1.0, 0);

// 识别码本体：从标签右边固定位置开始，不和标签抢位
draw_set_color(make_color_rgb(48, 40, 30));
draw_text_transformed(hwid_x + 22 + hwid_label_w, hwid_y + hwid_h * 0.5,
    local_hwid_text, 1.5, 1.5, 0);

draw_set_halign(fa_right);
if (copied) {
    draw_set_color(make_color_rgb(44, 132, 74));
    draw_text_transformed(hwid_x + hwid_w - 22, hwid_y + hwid_h * 0.5, "已复制", 1.0, 1.0, 0);
} else {
    draw_set_color(make_color_rgb(140, 122, 96));
    draw_text_transformed(hwid_x + hwid_w - 22, hwid_y + hwid_h * 0.5, "点此复制", 1.0, 1.0, 0);
}

draw_set_halign(fa_center);

// ── 状态提示 / 已授权信息 ──
if (msg != "") {
    if (msg_ok) {
        draw_set_color(make_color_rgb(44, 132, 74));
    } else {
        draw_set_color(make_color_rgb(190, 62, 50));
    }
    draw_text_transformed(panel_x + panel_w * 0.5, status_y, msg, 1.0, 1.0, 0);
} else if (auth_ok()) {
    draw_set_color(make_color_rgb(70, 112, 80));
    draw_text_transformed(panel_x + panel_w * 0.5, status_y,
        auth_label() + "　（重新输入可换绑）", 1.0, 1.0, 0);
} else {
    draw_set_color(make_color_rgb(150, 136, 116));
    draw_text_transformed(panel_x + panel_w * 0.5, status_y,
        mandatory ? "未授权 · 完成绑定后才能进入游戏" : "未授权 · 部分内容需要授权后解锁",
        1.0, 1.0, 0);
}

// ── 确认按钮 ──
draw_set_color(hover_ok ? make_color_rgb(96, 152, 96) : make_color_rgb(78, 126, 78));
draw_roundrect_ext(btn_ok_x, btn_y, btn_ok_x + btn_w, btn_y + btn_h, 12, 12, false);
draw_set_color(make_color_rgb(48, 88, 48));
draw_roundrect_ext(btn_ok_x, btn_y, btn_ok_x + btn_w, btn_y + btn_h, 12, 12, true);
draw_set_color(c_white);
draw_text_transformed(btn_ok_x + btn_w * 0.5, btn_y + btn_h * 0.5, "确认绑定", 1.15, 1.15, 0);

// ── 关闭按钮（强制模式没有：未授权就得留在这）──
if (!mandatory) {
    draw_set_color(hover_no ? make_color_rgb(196, 186, 168) : make_color_rgb(178, 166, 146));
    draw_roundrect_ext(btn_no_x, btn_y, btn_no_x + btn_w, btn_y + btn_h, 12, 12, false);
    draw_set_color(make_color_rgb(120, 106, 86));
    draw_roundrect_ext(btn_no_x, btn_y, btn_no_x + btn_w, btn_y + btn_h, 12, 12, true);
    draw_set_color(make_color_rgb(50, 42, 30));
    draw_text_transformed(btn_no_x + btn_w * 0.5, btn_y + btn_h * 0.5, "稍后再说", 1.15, 1.15, 0);
}

// ── 底部：加群领码 ──
// 两段绘制是为了让群号更醒目。用 string_width 实测前缀宽度来居中，
// 不要硬编码偏移——换字/换字号就会歪。
draw_set_font(font_yuan);
draw_set_halign(fa_left);
draw_set_valign(fa_middle);
var _pre = "本游戏完全免费!!!获取授权码请加群：";
var _num = "887959479";
var _pre_w = string_width(_pre);
var _num_w = string_width(_num);
var _line_x = panel_x + panel_w * 0.5 - (_pre_w + _num_w) * 0.5;
draw_set_color(make_color_rgb(126, 108, 84));
draw_text_transformed(_line_x, group_y, _pre, 1.0, 1.0, 0);
draw_set_color(make_color_rgb(176, 88, 36));
draw_text_transformed(_line_x + _pre_w, group_y, _num, 1.0, 1.0, 0);

// 恢复默认，别污染后面的绘制
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_color(c_white);
draw_set_alpha(1);
