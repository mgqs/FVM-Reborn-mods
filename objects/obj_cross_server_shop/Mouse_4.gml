// Close button at bottom-right.
if (is_closing) exit;

// 购买确认窗开着 → 只处理它的两个按钮，其它交互全锁（2026-10-28）
if (confirm_id != ""){
    if (mouse_check_button_pressed(mb_left)){
        var _r0 = cross_shop_confirm_rect(0);
        var _r1 = cross_shop_confirm_rect(1);
        if (point_in_rectangle(mouse_x, mouse_y, _r0[0], _r0[1], _r0[2], _r0[3])){
            cross_shop_buy_do();                      // 确定：扣勋章 + 发货
        }
        else if (point_in_rectangle(mouse_x, mouse_y, _r1[0], _r1[1], _r1[2], _r1[3])){
            confirm_id = "";                          // 取消
            audio_play_sound(snd_button, 0, 0);
        }
    }
    exit;
}

if (point_in_rectangle(mouse_x, mouse_y, x + 680, y + 430, x + 800, y + 550)) {
    audio_play_sound(snd_button, 0, 0);
    // Defer teardown until this mouse event has finished dispatching. This
    // prevents the same click from reaching the underlying expedition button.
    is_closing = true;
    visible = false;
    alarm[0] = 1;
    exit;
}

// Silver tab on the left, gold tab on the right.
if (point_in_rectangle(mouse_x, mouse_y, x - 835, y - 470, x - 645, y - 405)) {
    if (shop_type != 1) { shop_type = 1; current_page = 1; total_pages = max(1, ceil(array_length(silver_cards) / 16)); audio_play_sound(snd_button, 0, 0); }
    exit;
}
if (point_in_rectangle(mouse_x, mouse_y, x - 640, y - 470, x - 450, y - 405)) {
    if (shop_type != 0) { shop_type = 0; current_page = 1; total_pages = max(1, ceil(array_length(exchange_cards) / 16)); audio_play_sound(snd_button, 0, 0); }
    exit;
}

// 扩大翻页按钮点击区域，匹配按钮精灵的实际显示大小（缩放1.8倍后约100x100）
if (point_in_rectangle(mouse_x, mouse_y, x - 160, y + 385, x - 40, y + 485)) {
    current_page = max(1, current_page - 1);
    audio_play_sound(snd_button, 0, 0);
    exit;
}
if (point_in_rectangle(mouse_x, mouse_y, x + 40, y + 385, x + 160, y + 485)) {
    current_page = min(total_pages, current_page + 1);
    audio_play_sound(snd_button, 0, 0);
    exit;
}

    var _cards = shop_type == 0 ? exchange_cards : silver_cards;
for (var _slot = 0; _slot < 16; _slot++) {
    var _index = (current_page - 1) * 16 + _slot;
    if (_index >= array_length(_cards)) continue;
    var _col = _slot mod 4;
    var _row = _slot div 4;
    var _gx = x - 618 + 411 * _col;
    var _gy = y - 248 + 165 * _row;
    if (!point_in_rectangle(mouse_x, mouse_y, _gx - 5, _gy + 35, _gx + 175, _gy + 92)) continue;

    var _id = _cards[_index];
    var _goods = global.goods_map[? _id];
    var _card_id = variable_struct_exists(_goods, "card_id") ? _goods.card_id : _id;
    var _card_shape = variable_struct_exists(_goods, "card_shape") ? _goods.card_shape : 0;
    var _medals = real(_goods.cost);
    var _goods_type = _goods.type;
    var _owned = false;
    var _prerequisite_met = true;
    var _required_gem_id = "";

    // 抽卡 / 欧皇模式：**一转·二转凭证照常可买**，其余（卡本体 / 武器 / 宝石）仍禁买；
    //   随机礼盒模式整店禁买（2026-10-28 用户口径）
    //   跨服黄金页的一/二转卖的就是转职凭证（card_shape > 0），跟威望商店、诸神的凭证一致
    var _is_credit = (_goods_type == "card" && _card_shape > 0);
    if (is_random_gift_mode()) {
        show_notice("随机礼盒模式无法使用跨服商店", 60);
        exit;
    }
    if (is_eternal_gacha_mode() && !_is_credit) {
        show_notice("抽卡模式只能购买转职凭证", 60);
        exit;
    }

    // 判断是否已拥有
    if (_goods_type == "card") {
        for (var _k = 0; _k < array_length(global.save_data.unlocked_cards); _k++) {
            var _owned_card = global.save_data.unlocked_cards[_k];
            var _owned_shape = variable_struct_exists(_owned_card, "max_shape") ? _owned_card.max_shape : _owned_card.shape;
            if (_owned_card.id == _card_id && _owned_shape >= _card_shape) { _owned = true; break; }
        }
        // 一 / 二转凭证（card_shape > 0）：**不看前置**（不要求本体、不要求前一档），
        //   与威望商店一致；只保留「已有对应形态 → 已兑换」这一条（上面的 _owned）
        //   2026-10-28 用户口径
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
            _required_gem_id = _goods.required_gem_id;
            _prerequisite_met = is_gem_unlocked(_required_gem_id);
        }
    }

    var _medal_id = shop_type == 0 ? "cross_server_gold_medal" : "cross_server_silver_medal";
    var _balance = get_material_amount(_medal_id);
    if (_owned) show_notice("该商品已兑换", 60);
    else if (!_prerequisite_met) {
        if (_required_gem_id != "") {
            var _required_goods = global.goods_map[? _required_gem_id];
            show_notice("请先兑换" + _required_goods.display_name, 60);
        } else {
            var _required_shape = _goods.required_card_shape;
            show_notice(_required_shape == 0 ? "请先兑换本体卡牌" : "请先兑换一转转职凭证", 60);
        }
    }
    else if (_balance < _medals && !global.debug) show_notice(shop_type == 0 ? "金色勋章不足" : "白银勋章不足", 60);
    else {
        // 2026-10-28：不再一点就买 —— 弹确认窗，确定后才扣勋章发货（见 cross_shop_buy_do）
        cross_shop_confirm_open(_id);
    }
    exit;
}
