/// obj_hex_panel Draw —— 遮罩 + 三张卡 + 底部按钮
/// 原则：不看文字 0.3 秒能区分三档（银"静"、金"暖"、彩"动"）

// ── 遮罩 ──
draw_set_alpha(0.62);
draw_set_color(c_black);
draw_rectangle(0, 0, room_width, room_height, false);
draw_set_alpha(1);

// ── 顶部信息 ──
var _s   = global.hex_state;
var _cfg = hex_cfg();
draw_set_font(font_yuan);
draw_set_halign(fa_center);
draw_set_valign(fa_middle);

draw_set_color(#E8F1F8);
draw_set_alpha(0.55 + 0.45 * min(1, t / 10));
draw_text(room_width / 2, base_y - 96, "第 " + string(_s.picks + 1) + " 次选择");
draw_set_alpha(1);

draw_set_color(#8FB6D8);
draw_text(room_width / 2, base_y - 56,
    "已持有 " + string(hex_taken_count()) + " / " + string(_cfg.max_hex));

// ── 三张卡 ──
for (var i = 0; i < array_length(offer); i++) {
    var _id = offer[i];
    var _d  = hex_get(_id);
    if (is_undefined(_d)) continue;

    var _r  = hex_panel_card_rect(i);
    var _cx = (_r.x1 + _r.x2) / 2;
    var _cy = (_r.y1 + _r.y2) / 2;

    // 依次翻牌：每张晚 5 帧
    var _a = clamp((t - i * 5) / 10, 0, 1);
    if (_a <= 0) continue;
    var _ease = 1 - (1 - _a) * (1 - _a);

    var _sel  = (sel_idx == i);
    var _lift = (hover_idx == i) ? -10 : 0;
    if (_sel) _lift = -14;

    // 底色
    var _bg;
    var _bc1, _bc2;
    switch (_d.tier) {
        case 0:
            _bg = make_color_rgb(18, 22, 28);
            _bc1 = #C9D3DD; _bc2 = #7C8A99;
            break;
        case 1:
            _bg = make_color_rgb(32, 25, 14);
            _bc1 = #FFE3A3; _bc2 = #C98A2E;
            break;
        default:
            _bg = make_color_rgb(20, 16, 30);
            _bc1 = make_color_hsv((current_time / 12 + i * 40) mod 255, 180, 255);
            _bc2 = make_color_hsv((current_time / 12 + 128 + i * 40) mod 255, 200, 210);
            break;
    }

    // 彩卡外发光
    if (_d.tier == 2) {
        draw_set_alpha(0.10 * _ease);
        draw_set_color(_bc1);
        for (var g = 1; g <= 3; g++) {
            draw_roundrect(_r.x1 - 6 * g, _r.y1 - 6 * g, _r.x2 + 6 * g, _r.y2 + 6 * g, false);
        }
        draw_set_alpha(1);
    }

    // 卡面
    draw_set_alpha(_ease);
    draw_set_color(_bg);
    draw_roundrect(_r.x1, _r.y1 + _lift, _r.x2, _r.y2 + _lift, false);

    // 边框：银 1px / 金 2px / 彩 2px + 流光
    draw_set_color(_bc1);
    draw_roundrect(_r.x1, _r.y1 + _lift, _r.x2, _r.y2 + _lift, true);
    if (_d.tier >= 1) {
        draw_set_color(_bc2);
        draw_roundrect(_r.x1 + 2, _r.y1 + 2 + _lift, _r.x2 - 2, _r.y2 - 2 + _lift, true);
    }

    // 选中：双圈金边（提示"这张只是选中了，还没生效"）
    if (_sel) {
        draw_set_color(#FFD479);
        draw_roundrect(_r.x1 - 3, _r.y1 - 3 + _lift, _r.x2 + 3, _r.y2 + 3 + _lift, true);
        draw_roundrect(_r.x1 - 5, _r.y1 - 5 + _lift, _r.x2 + 5, _r.y2 + 5 + _lift, true);
    }

    // 形态竖色条：加码绿 / 减码红
    var _fc = (_d.form == "C") ? #FF6E6E : #7CE38B;
    draw_set_color(_fc);
    draw_rectangle(_r.x1 + 2, _r.y1 + 6 + _lift, _r.x1 + 6, _r.y2 - 6 + _lift, false);

    // 稀有度角标：只写银 / 金 / 彩
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    draw_set_color(_bc1);
    draw_text(_cx, _r.y1 + 30 + _lift, hex_tier_name(_d.tier));

    // 词条名
    draw_set_color(#F4F8FB);
    draw_text_ext(_cx, _r.y1 + 74 + _lift, _d.name, 34, card_w - 40);

    // 分隔线
    draw_set_color(make_color_rgb(70, 84, 100));
    draw_line(_r.x1 + 26, _r.y1 + 108 + _lift, _r.x2 - 26, _r.y1 + 108 + _lift);

    // 两段效果：卡片侧在上、老鼠侧在下，同向同色
    draw_set_color(_fc);
    draw_text_ext(_cx, _r.y1 + 132 + _lift, _d.card_desc, 26, card_w - 44);
    draw_set_alpha(_ease * 0.85);
    draw_text_ext(_cx, _r.y1 + 212 + _lift, _d.enemy_desc, 26, card_w - 44);

    // 叠层 / 已持有
    draw_set_alpha(_ease);
    var _own = hex_taken(_id);
    var _tail = "";
    if (_d.stack > 1) _tail = "叠 " + string(_own) + "/" + string(_d.stack);
    else if (_own > 0) _tail = "已持有";
    if (_tail != "") {
        draw_set_color(#9BB3C9);
        draw_text(_cx, _r.y2 - 58 + _lift, _tail);
    }
}

// ── 底部按钮：放弃 / 选择 / 重随 ──
// 「选择」是唯一确认入口，点牌只算选中
var _sel_name = "请先点选词条";
if (sel_idx >= 0 && sel_idx < array_length(offer)) {
    var _sd = hex_get(offer[sel_idx]);
    if (!is_undefined(_sd)) _sel_name = _sd.name;
}
draw_set_color(select_hover ? #8A6F33 : #5A4722);
draw_roundrect(select_x - btn_w / 2, btn_y - btn_h / 2, select_x + btn_w / 2, btn_y + btn_h / 2, false);
draw_set_color(select_hover ? #FFD479 : #C9A24E);
draw_roundrect(select_x - btn_w / 2, btn_y - btn_h / 2, select_x + btn_w / 2, btn_y + btn_h / 2, true);
draw_set_color(#FFF6E0);
draw_text(select_x, btn_y - 9, "选择");
draw_set_font(font_hei);
draw_set_color(#E0CFA4);
draw_text(select_x, btn_y + 14, _sel_name);
draw_set_font(font_yuan);

var _rr_text = "重随";
var _rr_sub;
if (_s.free_reroll > 0) {
    _rr_sub = "免费 x" + string(_s.free_reroll);
} else {
    _rr_sub = string(reroll_cost_now) + " 火苗";
}

draw_set_color(reroll_hover ? #D9F3FF : #3C5468);
draw_roundrect(reroll_x - btn_w / 2, btn_y - btn_h / 2, reroll_x + btn_w / 2, btn_y + btn_h / 2, false);
draw_set_color(#EAF4FB);
draw_text(reroll_x, btn_y - 9, _rr_text);
draw_set_font(font_hei);
draw_set_color(#9BB3C9);
draw_text(reroll_x, btn_y + 14, _rr_sub);
draw_set_font(font_yuan);

var _gu_gain = hex_cfg().giveup_flame + ((instance_exists(obj_battle)) ? obj_battle.current_wave : 0) * 40;
draw_set_color(giveup_hover ? #FFD9D9 : #5A3A3A);
draw_roundrect(giveup_x - btn_w / 2, btn_y - btn_h / 2, giveup_x + btn_w / 2, btn_y + btn_h / 2, false);
draw_set_color(#F6E7E7);
draw_text(giveup_x, btn_y - 9, "放弃");
draw_set_font(font_hei);
draw_set_color(#D8AFAF);
draw_text(giveup_x, btn_y + 14, "+" + string(_gu_gain) + " 火苗");
draw_set_font(font_yuan);

// ── 提示 ──
if (msg_timer > 0) {
    draw_set_alpha(min(1, msg_timer / 20));
    draw_set_color(#FF9E6B);
    draw_text(room_width / 2, btn_y + 62, msg_text);
    draw_set_alpha(1);
}

draw_set_halign(fa_left);
draw_set_valign(fa_top);
