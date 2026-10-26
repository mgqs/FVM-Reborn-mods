/// hex_persist —— 持久化：只有通关才入档
///
/// 三条铁律（docs 6.1）：
///   1. 本局词条只存在内存（global.hex_state.picked），绝不逐次落盘；
///   2. 唯一落盘点 = complete_level()；
///   3. 写入的是「累计获得次数」，不是覆盖，也不是解锁后才能用。

/// @function hex_seq_maps()
/// @desc 这些地图是"一条序列 = 一局"，只有打完最后一关才入档
function hex_seq_maps() {
    return ["tower_cake", "longyuan", "floating_island", "undersea_vortex"];
}

/// @function hex_is_seq_map(_key)
/// @desc 该地图是否是"整条序列 = 一局"
function hex_is_seq_map(_key) {
    return (array_index_of(hex_seq_maps(), _key) != -1);
}

/// @function hex_map_of_level(_level_id)
/// @desc 关卡属于哪个地图；找不到返回 ""
function hex_map_of_level(_level_id) {
    if (!variable_global_exists("maps_map")) return "";
    if (!ds_exists(global.maps_map, ds_type_map)) return "";
    var _k = ds_map_find_first(global.maps_map);
    while (!is_undefined(_k)) {
        var _md = ds_map_find_value(global.maps_map, _k);
        if (is_struct(_md) && variable_struct_exists(_md, "levels_data")) {
            var _levels = _md.levels_data;
            for (var j = 0; j < array_length(_levels); j++) {
                if (_levels[j].id == _level_id) return _k;
            }
        }
        _k = ds_map_find_next(global.maps_map, _k);
    }
    return "";
}

/// @function hex_run_scope_end(_level_id)
/// @desc 本局是否已走到结算点。岛屿单关恒 true
function hex_run_scope_end(_level_id) {
    if (!variable_global_exists("maps_map")) return true;
    if (!ds_exists(global.maps_map, ds_type_map)) return true;

    var _seq = hex_seq_maps();
    var _k = ds_map_find_first(global.maps_map);
    while (!is_undefined(_k)) {
        var _md = ds_map_find_value(global.maps_map, _k);
        if (is_struct(_md) && variable_struct_exists(_md, "levels_data")) {
            var _levels = _md.levels_data;
            for (var j = 0; j < array_length(_levels); j++) {
                if (_levels[j].id == _level_id) {
                    if (array_index_of(_seq, _k) == -1) return true;      // 岛屿：单关即结算
                    return (_level_id == _levels[array_length(_levels) - 1].id);
                }
            }
        }
        _k = ds_map_find_next(global.maps_map, _k);
    }
    return true;
}

/// @function hex_ensure_save_fields()
/// @desc 老存档补字段（写法与 completed_elite_levels 一致）
function hex_ensure_save_fields() {
    if (!variable_global_exists("save_data")) return;
    if (!variable_struct_exists(global.save_data, "hex_unlocked")
        || !is_array(global.save_data.hex_unlocked)) {
        global.save_data.hex_unlocked = [];
    }
    if (!variable_struct_exists(global.save_data, "hex_stats")
        || !is_struct(global.save_data.hex_stats)) {
        global.save_data.hex_stats = { runs_cleared: 0, runs_abandoned: 0, best_pi: 0 };
    }
}

/// @function hex_current_level_id()
/// @desc 当前关卡的 id（与 complete_level / 存档比对用的是同一个来源）
function hex_current_level_id() {
    if (variable_global_exists("level_data") && is_struct(global.level_data)
        && variable_struct_exists(global.level_data, "id")) {
        return global.level_data.id;
    }
    if (variable_global_exists("level_id")) return global.level_id;
    return "";
}

/// @function hex_level_repeat()
/// @desc 该关卡此前已经通关（重复挑战）。参考抽卡模式：重复通过不再给抽取机会
function hex_level_repeat() {
    if (!hex_enabled()) return false;
    var _lid = hex_current_level_id();
    if (_lid == "") return false;
    return is_level_completed(_lid);
}

/// @function hex_date_stamp()
/// @desc 存档用的日期戳 "YYYY-MM-DD"。
///       注意 GML 没有 date_string_of()，别抄别的语言；这里自己拼，两位补零
function hex_date_stamp() {
    var _now = date_current_datetime();
    var _y = string(date_get_year(_now));
    var _m = string(date_get_month(_now));
    var _d = string(date_get_day(_now));
    if (string_length(_m) < 2) _m = "0" + _m;
    if (string_length(_d) < 2) _d = "0" + _d;
    return _y + "-" + _m + "-" + _d;
}

/// @function hex_commit_run(_level_id)
/// @desc 把本局词条写进存档。非海克斯模式 / 序列未到末关 / 空手通关都不写
/// @return bool 是否真的写入
function hex_commit_run(_level_id) {
    if (!hex_enabled()) return false;                                  // 非海克斯模式：一条都不写
    if (hex_level_excluded()) return false;                            // 测试关卡不入档
    if (_level_id == "test_level") return false;                       // 双保险：显式传测试关卡 id 也不写
    if (!variable_global_exists("hex_state")) return false;
    if (!is_struct(global.hex_state)) return false;
    if (global.hex_state.committed) return false;                      // 本局已记过账，不重复加
    if (array_length(global.hex_state.picked) == 0) return false;      // 空手通关不写
    if (!hex_run_scope_end(_level_id)) return false;                   // 魔塔等序列未到末关

    hex_ensure_save_fields();
    // 注意：直接操作 global.save_data.hex_unlocked，不要先取到局部变量。
    // GML 数组是写时复制，array_push 到局部副本不回写到原数组（解锁"写了但看不到"就是这么来的）
    var _today = hex_date_stamp();

    for (var i = 0; i < array_length(global.hex_state.picked); i++) {
        var _id  = global.hex_state.picked[i].id;
        var _hit = -1;
        for (var j = 0; j < array_length(global.save_data.hex_unlocked); j++) {
            if (global.save_data.hex_unlocked[j].id == _id) { _hit = j; break; }
        }
        if (_hit == -1) {
            array_push(global.save_data.hex_unlocked,
                { id: _id, count: 1, first_date: _today, last_date: _today });
        } else {
            global.save_data.hex_unlocked[_hit].count    += 1;
            global.save_data.hex_unlocked[_hit].last_date = _today;
        }
    }

    global.hex_state.committed = true;
    global.save_data.hex_stats.runs_cleared += 1;
    global.save_data.hex_stats.best_pi =
        max(global.save_data.hex_stats.best_pi, global.hex_state.pi_value);

    return true;   // 真正的 save_file 由调用方统一做
}

/// @function hex_note_abandoned()
/// @desc 失败时记一笔放弃统计（不写词条）
function hex_note_abandoned() {
    if (!hex_enabled()) return;
    hex_ensure_save_fields();
    global.save_data.hex_stats.runs_abandoned += 1;
}

/// @function hex_unlocked_times(_id)
/// @desc 该词条累计通关获得次数（0 = 未解锁）
function hex_unlocked_times(_id) {
    if (!variable_global_exists("save_data")) return 0;
    if (!variable_struct_exists(global.save_data, "hex_unlocked")) return 0;
    var _list = global.save_data.hex_unlocked;
    for (var i = 0; i < array_length(_list); i++) {
        if (_list[i].id == _id) return _list[i].count;
    }
    return 0;
}

/// @function hex_unlocked_total()
/// @desc 已解锁词条种数（「已有词条 N」按钮上的数字）
function hex_unlocked_total() {
    if (!variable_global_exists("save_data")) return 0;
    if (!variable_struct_exists(global.save_data, "hex_unlocked")) return 0;
    return array_length(global.save_data.hex_unlocked);
}

/// @function hex_load_collection()
/// @desc 把存档里「已解锁」的词条并进本局状态，让它们**永久生效**。
///       每条按 min(取得次数, 词条自带的叠层上限) 叠层，与单局内的叠层规则一致。
///       不写进 picked：永久条目不占本局 16 条名额、不参与本局记账，单独放 persist。
///       由 hex_state_init() 在建局时调用，所以每次开局都会重新并入一遍（幂等）。
/// @return int 实际并入的层数
function hex_load_collection() {
    if (!hex_active()) return 0;              // 非海克斯模式 / 测试关卡：一条都不并入
    if (!variable_global_exists("hex_state")) return 0;
    if (!is_struct(global.hex_state)) return 0;
    if (!variable_global_exists("save_data")) return 0;

    hex_ensure_save_fields();
    var _s = global.hex_state;
    _s.persist = [];                          // 重建，避免重复并入

    var _n = 0;
    for (var i = 0; i < array_length(global.save_data.hex_unlocked); i++) {
        var _e = global.save_data.hex_unlocked[i];
        if (!is_struct(_e)) continue;
        if (!variable_struct_exists(_e, "id")) continue;
        if (!is_string(_e.id)) continue;        // 存档被改坏时不炸

        var _d = hex_get(_e.id);
        if (is_undefined(_d)) continue;        // 词条已被删掉，老存档里可能还留着
        if (!_d.impl) continue;

        var _cap = variable_struct_exists(_d, "stack") ? max(1, _d.stack) : 1;
        var _times = variable_struct_exists(_e, "count") ? _e.count : 1;
        if (!is_real(_times)) _times = 1;
        var _stack = min(max(0, floor(_times)), _cap);
        if (_stack <= 0) continue;

        for (var k = 0; k < _stack; k++) hex_apply_core(_e.id);
        array_push(_s.persist, { id: _e.id, stack: _stack, tier: _d.tier, form: _d.form });
        _n += _stack;
    }

    // 永久层同样施加压迫，否则收藏越多越白嫖
    hex_pi_recalc();
    if (_n > 0 && variable_global_exists("buff_apply_id")) global.buff_apply_id += 1;
    return _n;
}
