// Match the shop's outer UI colour before drawing the custom SWF background.
draw_set_color(make_color_rgb(37, 105, 170));
draw_rectangle(0, 0, room_width, room_height, true);
draw_sprite_ext(spr_mod_cs_shop_bg, 0, x, y, 1.8, 1.8, 0, c_white, 1);

// Clear the SWF's unused medal slots and floating panels.
draw_set_color(make_color_rgb(37, 105, 170));
draw_rectangle(x + 205, y - 470, x + 805, y - 405, true);
draw_set_color(make_color_rgb(0, 44, 81));
draw_rectangle(x + 190, y - 395, x + 850, y - 255, true);

// Silver tab on the left, gold tab on the right.
draw_sprite_ext(spr_mod_cs_shop_silver_tab, shop_type == 1 ? 0 : 1, x - 740, y - 438, 1.8, 1.8, 0, c_white, 1);
draw_sprite_ext(spr_mod_cs_shop_gold_tab, shop_type == 0 ? 0 : 1, x - 545, y - 438, 1.8, 1.8, 0, c_white, 1);

draw_set_font(font_number);
draw_set_halign(fa_left);
draw_set_valign(fa_middle);
draw_set_color(c_white);
draw_sprite_ext(spr_mod_cs_xunzhang, 0, x + 370, y - 438, 1.0, 1.0, 0, c_white, 1);
draw_text(x + 405, y - 438, string(get_material_amount("cross_server_gold_medal")));
draw_sprite_ext(spr_mod_cs_silver_medal, 0, x + 570, y - 438, 1.0, 1.0, 0, c_white, 1);
draw_text(x + 605, y - 438, string(get_material_amount("cross_server_silver_medal")));

var _cards = shop_type == 0 ? exchange_cards : silver_cards;
var _medal_sprite = shop_type == 0 ? spr_mod_cs_xunzhang : spr_mod_cs_silver_medal;
var _hover_desc = "";
// Match the gods shop exactly: four columns, four rows, sixteen products per page.
for (var _slot = 0; _slot < 16; _slot++) {
    var _index = (current_page - 1) * 16 + _slot;
    var _col = _slot mod 4;
    var _row = _slot div 4;
    var _gx = x - 618 + 411 * _col;
    var _gy = y - 248 + 165 * _row;
    draw_sprite_ext(spr_shop_goods_bg, 0, _gx, _gy, 1.8, 1.8, 0, c_white, 1);
    if (_index >= array_length(_cards)) continue;

    var _id = _cards[_index];
    var _goods = global.goods_map[? _id];
    var _card_id = variable_struct_exists(_goods, "card_id") ? _goods.card_id : _id;
    var _card_shape = variable_struct_exists(_goods, "card_shape") ? _goods.card_shape : 0;
    var _medals = real(_goods.cost);
    var _owned = false;
    var _goods_type = _goods.type;
    var _prerequisite_met = true;

    // 判断是否已拥有
    if (_goods_type == "card") {
        for (var _k = 0; _k < array_length(global.save_data.unlocked_cards); _k++) {
            var _owned_card = global.save_data.unlocked_cards[_k];
            var _owned_shape = variable_struct_exists(_owned_card, "max_shape") ? _owned_card.max_shape : _owned_card.shape;
            if (_owned_card.id == _card_id && _owned_shape >= _card_shape) { _owned = true; break; }
        }
        // 一 / 二转凭证不看前置（与 Mouse_4 同一口径，2026-10-28）
        if (_card_shape == 0 && variable_struct_exists(_goods, "required_card_shape")) {
            _prerequisite_met = false;
            for (var _k = 0; _k < array_length(global.save_data.unlocked_cards); _k++) {
                var _required_card = global.save_data.unlocked_cards[_k];
                var _required_shape = variable_struct_exists(_required_card, "max_shape") ? _required_card.max_shape : _required_card.shape;
                if (_required_card.id == _card_id
                    && _required_shape >= _goods.required_card_shape) {
                    _prerequisite_met = true;
                    break;
                }
            }
        }
    } else if (_goods_type == "weapon") {
        _owned = is_weapon_unlocked(_id);
    } else if (_goods_type == "gem") {
        _owned = is_gem_unlocked(_id);
        if (variable_struct_exists(_goods, "required_gem_id")) {
            _prerequisite_met = is_gem_unlocked(_goods.required_gem_id);
        }
    }

    // 绘制商品图标
    if (_goods_type == "card") {
        if (_card_shape > 0) {
            // 一转 / 二转 = 转职凭证：走 transfer_credit_draw（按档位选底板 + 该形态立绘现拼），
            // 与转职商店（obj_shop_bg 凭证页）/ 诸神商店 / 合成屋同一套口径（2026-10-27）。
            //   ① 不再画 spr_slot 卡槽：凭证自带底板，叠一起会露两层框
            //   ② 96 是金币商店凭证页的实测尺寸；中心对齐图标位（格子中心左移 122）
            //   ③ 档位由 transfer_credit_tier 算：普卡 1/2 → 一转/二转，金卡 1/2 → 三/四转
            var _credit_size = 96;
            transfer_credit_draw(_gx - 122 - _credit_size * 0.5, _gy - _credit_size * 0.5,
                _card_id, _card_shape, _credit_size, 0, 1);
        } else {
            var _card = deck_get_card_data(_card_id, _card_shape);
            if (_card != noone && ds_exists(_card, ds_type_map)) {
                draw_sprite_ext(spr_slot, 0, _gx - 122, _gy, 0.33, 0.33, 0, c_white, 1);
                draw_sprite_ext(_card[? "sprite"], 0, _gx - 122, _gy + 25, 1, 1, 0, c_white, 1);
            }
        }
    } else if (_goods_type == "weapon") {
        var _weapon_info = get_weapon_info(_id);
        if (_weapon_info != noone) {
            draw_sprite_ext(_weapon_info.icon, 0, _gx - 122, _gy - 20 + 25, 1.5, 1.5, 0, c_white, 1);
        }
    } else if (_goods_type == "gem") {
        var _gem_info = get_gem_info(_id);
        if (_gem_info != noone) {
            draw_sprite_ext(_gem_info.icon, 0, _gx - 122, _gy - 20 + 25, 0.9, 0.9, 0, c_white, 1);
        }
    }

    if (point_in_rectangle(mouse_x, mouse_y, _gx - 205, _gy - 82, _gx + 205, _gy + 82)) {
        _hover_desc = variable_struct_exists(_goods, "description") ? _goods.description : "";
    }

    // 抽卡 / 欧皇模式：只有**转职凭证（一转·二转，card_shape > 0）**能买，其余置灰；
    //   随机礼盒模式整店置灰（2026-10-28 用户口径，与 Mouse_4 的判定保持一致）
    var _is_credit = (_goods_type == "card" && _card_shape > 0);
    var _gacha_disabled = is_random_gift_mode() || (is_eternal_gacha_mode() && !_is_credit);

    draw_sprite_ext(spr_shop_buy_btn, 0, _gx + 77, _gy + 60, 1.8, 1.8, 0, (_gacha_disabled || !_prerequisite_met) ? c_gray : c_white, 1);
    draw_set_font(font_yuan);
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    draw_set_color(c_black);
    // 一转 / 二转卖的是凭证 → 名字写「卡名（一转凭证）」，跟背包 / 商店同一套叫法
    var _show_name = _goods.display_name;
    if (_goods_type == "card" && _card_shape > 0) _show_name = transfer_credit_name(_card_id, _card_shape);
    draw_text(_gx + 77, _gy - 46, _show_name);
    draw_set_font(font_number);
    draw_set_color(c_yellow);
    draw_text(_gx + 69, _gy + 2, string(_medals));
    draw_sprite_ext(_medal_sprite, 0, _gx + 167, _gy + 1, 0.8, 0.8, 0, c_white, 1);
    if (_owned) {
        draw_set_alpha(0.55);
        draw_set_color(c_black);
        draw_rectangle(_gx - 205, _gy - 82, _gx + 205, _gy + 82, false);
        draw_set_alpha(1);
        draw_set_font(font_yuan);
        draw_set_color(c_white);
        draw_text(_gx + 77, _gy + 60, "已兑换");
    } else if (_gacha_disabled) {
        draw_set_font(font_yuan);
        draw_set_color(c_white);
        draw_text(_gx + 77, _gy + 60, "不可购买");
    } else if (!_prerequisite_met) {
        draw_set_font(font_yuan);
        draw_set_color(c_white);
        var _required_text = _goods_type == "card"
            ? (_goods.required_card_shape == 0 ? "需先兑换本体" : "需先兑换一转")
            : "需先兑换前置宝石";
        draw_text(_gx + 77, _gy + 60, _required_text);
    }
}

// Centered pagination controls.
draw_sprite_ext(spr_shop_page_btn, 0, x - 100, y + 435, 1.8, 1.8, 0, c_white, 1);
draw_sprite_ext(spr_shop_page_btn, 0, x + 100, y + 435, -1.8, 1.8, 0, c_white, 1);
draw_set_font(font_number);
draw_set_halign(fa_center);
draw_set_valign(fa_middle);
draw_set_color(c_white);
draw_text(x, y + 435, string(current_page) + "/" + string(total_pages));

// Close button at bottom-right.
draw_sprite_ext(spr_closemenu_btn, 0, x + 740, y + 490, 1.8, 1.8, 0, c_white, 1);

// 悬停提示：显示商品简要介绍（与金币商店一致）
if (_hover_desc != "") {
    draw_set_font(font_yuan);
    // 说明现在直接取**情报岛**原文（技能描述较长，还会带换行）→ 按 420px 折行，
    //   否则长句会横穿整个屏幕（2026-10-28）
    var _wrap = 420;
    var _lh   = string_height("Ag");
    var _tw = string_width_ext(_hover_desc, _lh, _wrap);
    var _th = string_height_ext(_hover_desc, _lh, _wrap);
    var _tx = mouse_x + 15;
    var _ty = mouse_y + 15;
    if (_tx + _tw > room_width) {
        _tx = mouse_x - 15 - _tw;
    }
    _tx = clamp(_tx, 4, room_width - _tw - 4);          // 别顶出屏幕（长文案时左边会溢出）
    if (_ty + _th > room_height) {
        _ty = mouse_y - 15 - _th;
    }
    draw_set_color(c_black);
    draw_set_alpha(0.7);
    draw_rectangle(_tx - 6, _ty - 6, _tx + _tw + 6, _ty + _th + 6, false);
    draw_set_alpha(1);
    draw_set_color(c_white);
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
    draw_text_ext(_tx, _ty, _hover_desc, _lh, _wrap);
    draw_set_valign(fa_top);
}

// ── 购买确认窗（2026-10-28）：画在最上层，跟转职页/融合页的「系统提示」同一套观感 ──
if (confirm_id != ""){
    draw_set_alpha(0.55);
    draw_set_color(c_black);
    draw_rectangle(0, 0, room_width, room_height, false);
    draw_set_alpha(1);

    draw_sprite_ext(spr_battle_escape_menu, 0, x, y, 1.5, 1.5, 0, c_white, 1);
    draw_set_font(font_yuan);
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    draw_set_color(c_white);
    draw_text(x, y - 112, "兑换确认");
    draw_text(x, y - 44, "是否消耗 " + string(confirm_cost) + " " + confirm_medal_name);

    // 商品名可能长（卡名（二转凭证）），按宽度压一下
    var _nsc = 1;
    var _nw = string_width("兑换 " + confirm_name + "？");
    if (_nw > 300) _nsc = 300 / _nw;
    draw_text_transformed(x, y - 10, "兑换 " + confirm_name + "？", _nsc, _nsc, 0);

    var _lbl = ["确定", "取消"];
    for (var _b = 0; _b < 2; _b++){
        var _r  = cross_shop_confirm_rect(_b);
        var _bx = (_r[0] + _r[2]) * 0.5;
        var _by = (_r[1] + _r[3]) * 0.5;
        var _hit = point_in_rectangle(mouse_x, mouse_y, _r[0], _r[1], _r[2], _r[3]);
        var _fr = _hit ? (mouse_check_button(mb_left) ? 2 : 1) : 0;
        draw_sprite_ext(spr_common_button, _fr, _bx, _by, 0.75, 0.75, 0, c_white, 1);
        draw_set_color(c_white);
        draw_text(_bx, _by, _lbl[_b]);
    }
    draw_set_color(c_white);
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
}
