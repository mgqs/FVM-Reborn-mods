/// @function is_gacha_mode()
/// @desc 当前是否为抽卡版或欧皇版
function is_gacha_mode() {
    return global.play_mode == 1 || global.play_mode == 2;
}

/// @function is_random_gift_mode()
/// @desc 当前是否为随机礼盒玩法
function is_random_gift_mode() {
    return global.play_mode == 3;
}

/// @function random_gift_sync_unlock()
/// @desc 根据当前玩法同步随机礼盒的存档解锁状态。
function random_gift_sync_unlock() {
    if (!variable_global_exists("save_data") || !is_array(global.save_data.unlocked_cards)) return;
    var _lihe_index = -1;
    for (var i = 0; i < array_length(global.save_data.unlocked_cards); i++) {
        if (global.save_data.unlocked_cards[i].id == "lihe") {
            _lihe_index = i;
            break;
        }
    }
    if (is_random_gift_mode()) {
        if (_lihe_index == -1) {
            array_push(global.save_data.unlocked_cards,
                {id: "lihe", level: 0, shape: 0, skill: 0, max_level: 0, max_shape: 0});
        } else if (global.save_data.unlocked_cards[_lihe_index].level == 0
            && global.save_data.unlocked_cards[_lihe_index].max_level == 16) {
            global.save_data.unlocked_cards[_lihe_index].max_level = 0;
        }
    } else if (_lihe_index != -1) {
        array_delete(global.save_data.unlocked_cards, _lihe_index, 1);
    }
}

/// @function random_gift_is_direct_card_allowed(card_id)
/// @desc 随机礼盒模式下允许玩家直接带入卡组的卡片
function random_gift_is_direct_card_allowed(card_id) {
    if (card_id == "lihe") return true;
    return array_get_index([
        "wooden_plate", "wooden_cork", "cotton_candy", "sausage",
        "oil_lamp", "soda_bubble", "tang_hu_lu", "double_water_pipe", "wanpilong"
    ], card_id) != -1;
}

/// @function random_gift_prepare_selected_deck()
/// @desc 清理随机礼盒模式下不允许直接使用的卡，并确保至少有一张礼盒
function random_gift_prepare_selected_deck() {
    if (!is_random_gift_mode()) return;
    random_gift_sync_unlock();
    // The gift mode grants Wanpilong's third shape at battle start.
    var _wanpilong_unlocked = false;
    for (var _ui = 0; _ui < array_length(global.save_data.unlocked_cards); _ui++) {
        if (global.save_data.unlocked_cards[_ui].id == "wanpilong") {
            global.save_data.unlocked_cards[_ui].shape = 2;
            global.save_data.unlocked_cards[_ui].max_shape = max(global.save_data.unlocked_cards[_ui].max_shape, 2);
            _wanpilong_unlocked = true;
            break;
        }
    }
    if (!_wanpilong_unlocked) array_push(global.save_data.unlocked_cards,
        {id: "wanpilong", level: 0, shape: 2, skill: 0, max_level: 0, max_shape: 2});
    deck_ensure_size();
    var has_gift = false;
    var has_wanpilong = false;
    for (var i = 0; i < ds_list_size(global.selected_deck); i++) {
        if (deck_slot_is_empty(i)) continue;
        var entry = global.selected_deck[| i];
        var card_id = entry[? "card_id"];
        if (!random_gift_is_direct_card_allowed(card_id)) {
            remove_from_deck(i);
        } else if (card_id == "lihe") {
            has_gift = true;
        } else if (card_id == "wanpilong") {
            entry[? "shape"] = 2;
            entry[? "data"] = deck_get_card_data("wanpilong", 2);
            has_wanpilong = true;
        }
    }
    if (!has_gift) add_to_deck("lihe", 0);
    if (!has_wanpilong) add_to_deck("wanpilong", 2);
}

/// @function difficulty_get_reward_multiplier_for(_difficulty)
/// @desc 给定难度号的奖励倍率。与玩法模式无关：抽卡版 / 欧皇版 / 随机礼盒 / 海克斯
///       一律按"实际基础难度"结算，不按模式给固定值。
///       美味 1 / 火山 1 / 浮空 2 / 星际 3 / 永恒 4 / 不朽 7
function difficulty_get_reward_multiplier_for(_difficulty) {
    var _table = [1, 1, 2, 3, 4, 7];
    return _table[clamp(floor(_difficulty), 0, array_length(_table) - 1)];
}

/// @function difficulty_get_reward_multiplier()
/// @desc 当前难度的奖励倍率（只读 global.difficulty，不看 global.play_mode）
///       海克斯的「达摩克里斯之剑（×10）」「搏一搏（翻倍/减半）」也在这里并入，
///       这样结算界面显示的数字与实际入账完全同源
function difficulty_get_reward_multiplier() {
    return difficulty_get_reward_multiplier_for(global.difficulty) * hex_batch2_reward_mult();
}

/// @function difficulty_grant_immortal_start_cards()
/// @desc 普通不朽难度的新存档解锁炎焱兔和一张随机白板卡
function difficulty_grant_immortal_start_cards() {
    if (global.difficulty != 5 || global.play_mode != 0) return false;
    if (variable_struct_exists(global.save_data, "immortal_start_cards_given")) return false;
    if (array_length(global.save_data.completed_levels) != 0) return false;

    // 烤串机本体改为百味关首通奖励，不再计入不朽开局随机白板；按玩家要求换成邪恶牛油果。
    var _card_pool = [
        "spoon_rabbit", "yanhuangma", "guiyuanma", "double_blade_snake", "niuyouguo",
        "yufengma", "fenjima", "xiandima", "laipishe", "starrabbit"
    ];
    unlock_card("yanyantu", 0, 0, 0);
    unlock_card(_card_pool[irandom(array_length(_card_pool) - 1)], 0, 0, 0);
    global.save_data.immortal_start_cards_given = true;
    save_file(global.save_slot);
    return true;
}

/// @function difficulty_get_name()
/// @desc 返回基础难度名称
function difficulty_get_name(_difficulty) {
    var names = ["美味级", "火山级", "浮空级", "星际级", "永恒级", "不朽级"];
    _difficulty = clamp(_difficulty, 0, array_length(names) - 1);
    return names[_difficulty];
}

/// @function difficulty_get_display_name()
/// @desc 返回基础难度和玩法模式组合名称
function difficulty_get_display_name() {
    var result = difficulty_get_name(global.difficulty);
    if (global.play_mode == 1) result += "·抽卡版";
    else if (global.play_mode == 2) result += "·欧皇版";
    else if (global.play_mode == 3) result += "·随机礼盒";
    else if (global.play_mode == 4) result += "·海克斯模式";
    return result;
}
