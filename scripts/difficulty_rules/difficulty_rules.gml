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

/// @function play_mode_of_key(_key)
/// @desc 设置页开关的 config_key -> 玩法模式号。0 = 不是玩法开关
///       模式号：1 抽卡 / 2 欧皇 / 3 随机礼盒 / 4 海克斯
function play_mode_of_key(_key) {
    if (_key == "play_mode_gacha") return 1;
    if (_key == "play_mode_lucky") return 2;
    if (_key == "play_mode_gift")  return 3;
    if (_key == "play_mode_hex")   return 4;
    return 0;
}

/// @function play_mode_apply(_mode)
/// @desc 玩法模式唯一写入口：同时写 global.play_mode 与 config.ini（下次启动由
///       obj_game_init 读回），并处理「进出海克斯本局作废」与礼盒卡组同步。
///       四种玩法互斥是靠「play_mode 只有一个数」保证的，所以任何地方改玩法都必须走这里。
function play_mode_apply(_mode) {
    _mode = clamp(round(_mode), 0, 4);
    var _old = variable_global_exists("play_mode") ? global.play_mode : 0;
    global.play_mode = _mode;

    ini_open("config.ini");
    ini_write_real("settings", "play_mode", _mode);
    ini_close();

    if (_old == _mode) return _mode;

    // 进出海克斯模式：本局词条一律作废（docs 1.2.2）
    if (_old == 4 || _mode == 4) hex_reset_run();

    // 抽卡 / 欧皇 / 随机礼盒：同步礼盒卡的解锁状态与卡组
    if (_old == 1 || _old == 2 || _old == 3 || _mode == 1 || _mode == 2 || _mode == 3) {
        random_gift_sync_unlock();
        if (variable_global_exists("selected_deck") && ds_exists(global.selected_deck, ds_type_list)) {
            random_gift_prepare_selected_deck();
        }
    }
    return _mode;
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

/// @function difficulty_reward_item_fixed(_item_id)
/// @desc 不吃难度奖励倍率的专项养成材料（2026-10-30 用户口径：遗迹与营地的
///       食谱碎片 / 探险币按 JSON 基础值固定发放，不随难度放大）。
///       只登记「靠关卡独有产出、且会直接换养成进度」的物品，通用资源
///       （金币 / 香料 / 水晶 / 四叶草）仍然照常吃倍率。
function difficulty_reward_item_fixed(_item_id) {
    var _fixed = [
        "copper_cookbook_fragment",     // 铜食谱碎片（火山遗迹）
        "silver_cookbook_fragment",     // 银食谱碎片（火山遗迹）
        "gold_cookbook_fragment",       // 金食谱碎片（火山遗迹）
        "less_camp_coin",               // 补给币（探险营地关卡掉落）
        "camp_coin"                     // 营地金币（探险营地支线任务）
    ];
    return array_get_index(_fixed, _item_id) != -1;
}

/// @function difficulty_reward_item_amount(_item_id, _base_amount, _multiplier)
/// @desc 关卡结算发放口径的唯一出口：白名单物品保持基础值，其余乘难度奖励倍率。
///       任何发奖循环都必须走这里，不要在调用点各写一遍 `* reward_multiplier`。
function difficulty_reward_item_amount(_item_id, _base_amount, _multiplier) {
    if (difficulty_reward_item_fixed(_item_id)) return _base_amount;
    return _base_amount * _multiplier;
}

/// @function immortal_pick_card_list()
/// @desc 不朽开局「自选一张」的候选卡
///       2026-11-01 用户定：**生煎锅 / 披萨炉 / 焦油喷壶（tar_sprayer）**
///       换卡 / 加卡只改这一行，UI 按 array_length 自动排布，兜底取第 1 张
function immortal_pick_card_list() {
    return ["pan_fried_bun", "pizza_oven", "tar_sprayer"];
}

/// @function immortal_pick_info()
/// @desc 每张候选卡的「开局难度 + 开局星级」，键 = 卡片 id（与 immortal_pick_card_list() 一一对应）
///       2026-11-01 用户定：**三张一律 0 星、不显示开局难度**（`dif` 留空 = 不画标签）
///       改某张卡的难度或星级 = 改这里那一行；dif 只认「易 / 中 / 难」（颜色见 immortal_pick_difficulty_colour）
///       star 是 `unlock_card` 的 level（1 起算的星数，0 = 无星，取数值表第 star 档）
function immortal_pick_info() {
    return {
        pan_fried_bun: { dif: "", star: 0 },
        pizza_oven:    { dif: "", star: 2 },
        tar_sprayer:   { dif: "", star: 4 }
    };
}

/// @function immortal_pick_info_of(_card_id)
/// @desc 取某张候选卡的 {dif, star}；表里没有 → {dif:"", star:0}（不画难度、发无星）
function immortal_pick_info_of(_card_id) {
    var _t = immortal_pick_info();
    if (variable_struct_exists(_t, _card_id)) return _t[$ _card_id];
    return { dif: "", star: 0 };
}

/// @function immortal_pick_difficulty_colour(_label)
/// @desc 难度标签配色：易 = 绿 / 中 = 蓝 / 难 = 红
function immortal_pick_difficulty_colour(_label) {
    switch (_label) {
        case "易": return make_colour_rgb(88, 216, 118);
        case "中": return make_colour_rgb(92, 168, 255);
        case "难": return make_colour_rgb(246, 86, 86);
    }
    return c_white;
}

/// @function immortal_pick_face_h()
/// @desc 弹窗卡面「可见内容」的高度（精灵像素，量自该卡 register_card 登记的 sprite 第 0 帧 PNG，
///       alpha 包围盒阈值 16）。卡面画布下方普遍带一大截透明留白（如生煎锅 101x88 只有 y30~84 有内容），
///       按画布居中会让图案整体偏上，所以这里按内容高算中心。
///       这些精灵的原点惯例 = 内容底部中点（§2.2）→ 内容中心 = 原点 y - 内容高/2。
///       🔴 新增候选卡：量一下它的第 0 帧内容高补进来；表里没有 → 回落「按画布居中」
function immortal_pick_face_h() {
    return {
        pan_fried_bun: 54,   // spr_pan_fried_bun 101x88，内容 y 30~84
        pizza_oven:    66,   // spr_pizza_oven     90x69，内容 y  2~68
        tar_sprayer:   74,   // spr_tar_sprayer    86x76，内容 y  2~76
        spicy_pot:     50    // spr_spicy_pot      88x85，内容 y 19~69（备用，不在三选一名单里）
    };
}

/// @function immortal_pick_pending()
/// @desc 三选一还没结算（存档标记 immortal_pick_pending）
function immortal_pick_pending() {
    return variable_struct_exists(global.save_data, "immortal_pick_pending")
        && global.save_data.immortal_pick_pending;
}

/// @function immortal_pick_commit(_card_id)
/// @desc 结算自选：发卡（本体 + 该卡的**开局星级**）→ 清 pending → 存盘。卡片不在名单里返回 false
///       星级 = immortal_pick_info() 的 star（`unlock_card` 的 level 是 1 起算的星数，0 = 无星）；
///       2026-10-31 用户定：生煎锅 0 星 / 披萨炉 2 星 / 玉蜀黍 4 星（原来是全部 4 星）
function immortal_pick_commit(_card_id) {
    var _list = immortal_pick_card_list();
    if (array_get_index(_list, _card_id) == -1) return false;
    var _star = immortal_pick_info_of(_card_id).star;
    unlock_card(_card_id, _star, 0, 0);
    global.save_data.immortal_pick_pending = false;
    global.save_data.immortal_pick_taken = _card_id;
    save_file(global.save_slot);
    return true;
}

/// @function immortal_pick_claim_default()
/// @desc 异常兜底：选卡窗没点确定就被关掉（强关游戏 / ESC 关界面 / 切房间 / 弹窗被销毁）
///       → 默认发第一张，保证奖励不丢
function immortal_pick_claim_default() {
    if (!immortal_pick_pending()) return false;
    var _list = immortal_pick_card_list();
    if (array_length(_list) == 0) return false;
    return immortal_pick_commit(_list[0]);
}

/// @function difficulty_grant_immortal_start_cards()
/// @desc 【2026-11-01 起停用】由 difficulty_start_reward_grant() 取代（发奖前要先弹窗确认）。
///       现在没有任何地方调用它；留着只是为了老存档路径排查方便，别在新代码里用。
/// @desc 普通不朽难度的新存档：只发暖暖鸡本体，并置「三选一待选」标记。
///       2026-10-30 用户要求：原「炎焱兔 + 10 张池子随机 1 张」撤掉，改成点「不朽」时三选一。
/// @return true = 这一次刚发（启动兜底据此跳过，避免刚置的标记被当场结算掉）
function difficulty_grant_immortal_start_cards() {
    if (global.difficulty != 5 || global.play_mode != 0) return false;
    if (variable_struct_exists(global.save_data, "immortal_start_cards_given")) return false;
    if (array_length(global.save_data.completed_levels) != 0) return false;

    unlock_card("warm_birds", 0, 0, 0);
    global.save_data.immortal_pick_pending = true;
    global.save_data.immortal_pick_taken = "";
    global.save_data.immortal_start_cards_given = true;
    save_file(global.save_slot);
    return true;
}

// ── 开局奖励：永恒 / 不朽 互斥，发奖前必须先弹 obj_start_reward ──

/// @function difficulty_start_reward_table()
/// @desc 开局奖励表：键 = 难度号（4 永恒 / 5 不朽）
function difficulty_start_reward_table() {
    return {
        "4": { name: "永恒级", gold: 60000,  warm_bird: false, pick: false },
        "5": { name: "不朽级", gold: 200000, warm_bird: true,  pick: true  }
    };
}

/// @function difficulty_start_reward_of(_difficulty)
/// @desc 取某档的开局奖励配置；没有这一档返回 undefined
function difficulty_start_reward_of(_difficulty) {
    var _t = difficulty_start_reward_table();
    if (!variable_struct_exists(_t, string(_difficulty))) return undefined;
    return _t[$ string(_difficulty)];
}

/// @function difficulty_start_reward_claimed()
/// @desc 已经领过哪一档（0 = 没领 / 4 / 5）
///       老存档迁移（只做一次）：拿过不朽开局金币或暖暖鸡的，一律算「已领不朽」
function difficulty_start_reward_claimed() {
    if (!variable_struct_exists(global.save_data, "start_reward_claimed")) {
        var _old_immortal =
            (variable_struct_exists(global.save_data, "immortal_bonus_given")
                && global.save_data.immortal_bonus_given)
            || (variable_struct_exists(global.save_data, "immortal_start_cards_given")
                && global.save_data.immortal_start_cards_given);
        global.save_data.start_reward_claimed = _old_immortal ? 5 : 0;
    }
    return round(global.save_data.start_reward_claimed);
}

/// @function difficulty_start_reward_available(_difficulty)
/// @desc 这一档现在能不能领：必须是最上面那一档（新存档，通关数 0）+ 没领过任何一档
function difficulty_start_reward_available(_difficulty) {
    if (is_undefined(difficulty_start_reward_of(_difficulty))) return false;
    if (array_length(global.save_data.completed_levels) != 0) return false;
    return difficulty_start_reward_claimed() == 0;
}

/// @function difficulty_start_reward_gold_text(_gold)
/// @desc 金币文案加千分位（GM 的 string_format 不会插逗号）：60000 → "60,000"
function difficulty_start_reward_gold_text(_gold) {
    var _s = string(round(_gold));
    var _n = string_length(_s);
    var _out = "";
    for (var i = 1; i <= _n; i++) {
        if (i > 1 && ((_n - i + 1) mod 3) == 0) _out += ",";
        _out += string_char_at(_s, i);
    }
    return _out;
}

/// @function difficulty_start_reward_grant(_difficulty)
/// @desc 发奖 + 记 claimed + 存盘；调用前必须先过 difficulty_start_reward_available()
/// @return true = 发放成功
function difficulty_start_reward_grant(_difficulty) {
    if (!difficulty_start_reward_available(_difficulty)) return false;

    var _row = difficulty_start_reward_of(_difficulty);
    global.save_data.player.gold += _row.gold;
    show_notice("已领取" + _row.name + "开局奖励：+" + difficulty_start_reward_gold_text(_row.gold) + " 金币", 90);

    if (_row.warm_bird && global.play_mode == 0) {
        unlock_card("warm_birds", 0, 0, 0);
        global.save_data.immortal_start_cards_given = true;
        if (_row.pick) {
            global.save_data.immortal_pick_pending = true;
            global.save_data.immortal_pick_taken = "";
        }
    }

    // 旧字段一并写掉：其它地方（启动兜底 / 老存档判断）还在读它
    global.save_data.immortal_bonus_given = true;
    global.save_data.start_reward_claimed = _difficulty;
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
