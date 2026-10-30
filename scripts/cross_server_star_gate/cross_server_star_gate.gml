// ══════════════════════════════════════════════════════════════════════
// 跨服远征 · 关卡星级门槛
//   castle-0 → 8 星，castle-1 → 9 星，……，castle-7 → 15 星
//   判定依据：背包（unlocked_cards）中已有卡片的最高星级。
//   注意星级是 unlocked_cards[].level，不是 shape（shape 是转职形态）。
// ══════════════════════════════════════════════════════════════════════

/// @function cross_server_star_require(_level_index)
/// @desc 跨服第 _level_index 关（castle-0 起）要求的卡片最高星级：8 星起每关 +1。
function cross_server_star_require(_level_index) {
    return 8 + max(0, _level_index);
}

/// @function save_data_max_card_star()
/// @desc 背包中已有卡片的最高星级。老存档可能缺 level / max_level 字段，逐个兜底。
function save_data_max_card_star() {
    if (!variable_global_exists("save_data")) return 0;
    if (!variable_struct_exists(global.save_data, "unlocked_cards")) return 0;

    var _cards = global.save_data.unlocked_cards;
    if (!is_array(_cards)) return 0;

    var _max = 0;
    for (var _i = 0; _i < array_length(_cards); _i++) {
        var _c = _cards[_i];
        if (!is_struct(_c)) continue;
        var _lv = 0;
        if (variable_struct_exists(_c, "level")) _lv = real(_c.level);
        // max_level 是历史最高，卡片被消耗/重铸过也不会把门槛拉回去
        if (variable_struct_exists(_c, "max_level")) _lv = max(_lv, real(_c.max_level));
        if (_lv > _max) _max = _lv;
    }
    return _max;
}

/// @function cross_server_star_gate(_level_index)
/// @desc true = 星级达标，可以进入。不达标时由调用方 show_notice 提示。
function cross_server_star_gate(_level_index) {
    return save_data_max_card_star() >= cross_server_star_require(_level_index);
}

/// @function cross_server_star_gate_text(_level_index)
/// @desc 星级不足时的提示文案（show_notice 用 font_yuan，文案已比对字形表）。
function cross_server_star_gate_text(_level_index) {
    return "背包中没有" + string(cross_server_star_require(_level_index)) + "星卡片，无法进入";
}
