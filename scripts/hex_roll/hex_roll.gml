/// hex_roll —— 三选一抽取：稀有度权重、减码占比、保底

/// @function hex_pickable(_id)
/// @desc 该词条当前是否可出现在牌面上
function hex_pickable(_id) {
    var _d = hex_get(_id);
    if (is_undefined(_d)) return false;
    if (!_d.impl) return false;                     // 未实装的不进池
    if (hex_taken(_id) >= _d.stack) return false;   // 叠满
    // 减码型单局上限
    if (_d.form == "C" && hex_taken_c() >= hex_cfg().max_c) return false;
    // 总上限
    if (hex_taken_count() >= hex_cfg().max_hex) return false;
    return true;
}

/// @function hex_tier_weights()
/// @desc 六档难度对应的银/金/彩权重（docs 3.4）
function hex_tier_weights() {
    var _d = clamp(variable_global_exists("difficulty") ? global.difficulty : 2, 0, 5);
    var _w = [
        [68, 27,  5],
        [63, 30,  7],
        [58, 32, 10],
        [53, 33, 14],
        [48, 34, 18],
        [42, 35, 23]
    ];
    return _w[_d];
}

/// @function hex_c_ratio()
/// @desc 本次选择里减码型的目标占比（docs 3.4：难度 + 选择次数修正）
function hex_c_ratio() {
    var _d = clamp(variable_global_exists("difficulty") ? global.difficulty : 2, 0, 5);
    var _base = [0.08, 0.11, 0.14, 0.17, 0.20, 0.24][_d];
    var _picks = variable_global_exists("hex_state") ? global.hex_state.picks : 0;
    var _extra = min(0.015 * max(0, _picks - 1), 0.09);
    return clamp(_base + _extra, 0, 0.45);
}

/// @function hex_roll_tier()
/// @desc 按权重摇一档稀有度
function hex_roll_tier() {
    var _w = hex_tier_weights();
    var _total = _w[0] + _w[1] + _w[2];
    var _r = random(_total);
    if (_r < _w[0]) return 0;
    if (_r < _w[0] + _w[1]) return 1;
    return 2;
}

/// @function hex_candidates(_tier, _form)
/// @desc 取出该档、该形态的可选 id 列表。_form = "" 表示不限
function hex_candidates(_tier, _form) {
    var _list = [];
    for (var i = 0; i < array_length(global.hex_ids); i++) {
        var _id = global.hex_ids[i];
        if (!hex_pickable(_id)) continue;
        var _d = global.hex_db[$ _id];
        if (_d.tier != _tier) continue;
        if (_form != "" && _d.form != _form) continue;
        array_push(_list, _id);
    }
    return _list;
}

/// @function hex_roll_offer()
/// @desc 生成三选一。返回 id 数组；池被抽干时可能少于 3 条
function hex_roll_offer() {
    if (!hex_ensure_state()) return [];

    var _cfg   = hex_cfg();
    var _first = (global.hex_state.picks == 0);
    var _out   = [];
    var _c_r   = hex_c_ratio();

    // 保底：连续 2 次全 C 后，本次至少 1 张 A（docs 3.4）
    var _force_a = (global.hex_state.c_streak >= 2);

    for (var slot = 0; slot < 3; slot++) {
        var _tier;
        if (_first && slot == 0 && _cfg.first_pick_color) {
            _tier = 2;                                   // 开局首抽必出彩
        } else {
            _tier = hex_roll_tier();
        }

        var _want_c = (!_force_a || slot < 2) && (random(1) < _c_r);
        var _form   = _want_c ? "C" : "A";

        // 该档该形态的候选；没有就跨形态、跨档兜底
        var _cands = hex_candidates(_tier, _form);
        if (array_length(_cands) == 0) _cands = hex_candidates(_tier, "");
        if (array_length(_cands) == 0) _cands = hex_candidates(1, "");
        if (array_length(_cands) == 0) _cands = hex_candidates(0, "");
        if (array_length(_cands) == 0) _cands = hex_candidates(2, "");
        if (array_length(_cands) == 0) break;            // 池抽干

        // 同一次牌面不重复
        var _pick = "";
        for (var try_i = 0; try_i < 12; try_i++) {
            var _cand = _cands[irandom(array_length(_cands) - 1)];
            if (array_index_of(_out, _cand) == -1) { _pick = _cand; break; }
        }
        if (_pick == "") _pick = _cands[0];

        array_push(_out, _pick);
        _force_a = false;                                // 已经给过一张 A，解除保底
    }

    return _out;
}

/// @function hex_offer_has_a(_offer)
function hex_offer_has_a(_offer) {
    for (var i = 0; i < array_length(_offer); i++) {
        var _d = hex_get(_offer[i]);
        if (!is_undefined(_d) && _d.form == "A") return true;
    }
    return false;
}

/// @function hex_note_pick_form(_form)
/// @desc 记录本次选择是否为全 C，用于保底判定
function hex_note_pick_form(_form) {
    if (!hex_ensure_state()) return;
    if (_form == "C") global.hex_state.c_streak += 1;
    else              global.hex_state.c_streak  = 0;
}

/// @function hex_offer_preview_pi(_id)
/// @desc 面板用：这张牌会让 PI 变成多少
function hex_offer_preview_pi(_id) {
    var _d = hex_get(_id);
    if (is_undefined(_d)) return global.hex_state.pi_value;
    return global.hex_state.pi_value + _d.tier + 1;
}
