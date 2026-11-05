/// hex_test_picker —— 测试关卡（test_level）专用的「自选海克斯」数据层
///
/// 为什么要有这一层：
///   正式关只能三选一随机抽，想测某条词条得反复刷。测试关里改成「全库自选 + 点一下就生效」。
///
/// 三条铁律：
///   1. 只在 hex_enabled() && hex_level_excluded()（即测试关）下工作，正式关一行都不碰
///   2. 不写存档、不占 hex_cfg().max_hex 的 16 条名额、不进 runs_cleared 统计
///   3. 每次增删都「整局重建」（hex_reset_run + 按列表重放），
///      所以「移除一条」能真正把数值撤掉 —— hex_apply 是累乘的，没法单条撤销

/// @function hex_test_enabled()
/// @desc 当前是不是「测试关卡 + 海克斯模式」
function hex_test_enabled() {
    return (hex_enabled() && hex_level_excluded());
}

/// @function hex_picker_is_open()
/// @desc 自选面板是不是正展开着。展开时整局被冻结，别的系统据此让出鼠标
///       （obj_card_slot 等会直接 exit，避免同一帧里 Step 执行顺序造成的穿透）
function hex_picker_is_open() {
    if (!variable_global_exists("hex_picker_open")) return false;
    return global.hex_picker_open;
}

/// @function hex_test_add(_id)
/// @desc 加一层。允许重复（重复 = 叠层，rebuild 时就会 apply 多次），上限由调用方按 stack 控制
function hex_test_add(_id) {
    if (!variable_global_exists("hex_test_picks") || !is_array(global.hex_test_picks)) {
        global.hex_test_picks = [];
    }
    array_push(global.hex_test_picks, _id);
    return true;
}

/// @function hex_test_stack(_id)
/// @desc 这条在自选列表里叠了几层
function hex_test_stack(_id) {
    if (!variable_global_exists("hex_test_picks") || !is_array(global.hex_test_picks)) return 0;
    var _n = 0;
    var _len = array_length(global.hex_test_picks);
    for (var i = 0; i < _len; i++) {
        if (global.hex_test_picks[i] == _id) _n += 1;
    }
    return _n;
}

/// @function hex_test_remove(_id)
function hex_test_remove(_id) {
    if (!variable_global_exists("hex_test_picks") || !is_array(global.hex_test_picks)) return false;
    var _i = array_get_index(global.hex_test_picks, _id);
    if (_i == -1) return false;
    array_delete(global.hex_test_picks, _i, 1);
    return true;
}

/// @function hex_test_remove_all(_id)
/// @desc 把某条的全部层一次删掉（右键 / 侧栏 ✕ 用）
function hex_test_remove_all(_id) {
    if (!variable_global_exists("hex_test_picks") || !is_array(global.hex_test_picks)) return 0;
    var _removed = 0;
    for (var k = 0; k < 64; k++) {
        if (!hex_test_remove(_id)) break;
        _removed += 1;
    }
    return _removed;
}

/// @function hex_test_clear()
function hex_test_clear() {
    global.hex_test_picks = [];
}

/// @function hex_test_has(_id)
function hex_test_has(_id) {
    if (!variable_global_exists("hex_test_picks") || !is_array(global.hex_test_picks)) return false;
    return (array_get_index(global.hex_test_picks, _id) != -1);
}

/// @function hex_test_count()
function hex_test_count() {
    if (!variable_global_exists("hex_test_picks") || !is_array(global.hex_test_picks)) return 0;
    return array_length(global.hex_test_picks);
}

/// @function hex_test_batch_of(_id)
/// @desc 词条属于哪一批：1 本体 / 2 第二批 / 3 第三批 / 4 特殊（卦·契约，没有序号）
function hex_test_batch_of(_id) {
    if (string_length(_id) < 7) return 4;
    var _b = string_byte_at(_id, 5);
    if (_b < 48 || _b > 57) return 4;              // hex_hana_ / hex_contract_
    var _n = real(string_copy(_id, 5, 3));
    if (_n <= 111) return 1;
    if (_n <= 184) return 2;
    return 3;
}

/// @function hex_test_rebuild()
/// @desc 把当前自选列表整体重放进本局数值。增 / 删 / 清空之后都要调一次。
///       内部先 hex_reset_run()，所以调用它等于「这一局的海克斯从头来过」
function hex_test_rebuild() {
    if (!hex_enabled()) return false;

    // 先把列表抄一份：hex_reset_run 不会动它，但抄一份避免 rebuild 中途被面板改动影响
    var _list = [];
    if (variable_global_exists("hex_test_picks") && is_array(global.hex_test_picks)) {
        for (var i = 0; i < array_length(global.hex_test_picks); i++) {
            array_push(_list, global.hex_test_picks[i]);
        }
    }

    hex_reset_run();                       // 本局数值全部落回 1.0（含火苗上限差值同步）

    for (var j = 0; j < array_length(_list); j++) {
        var _id = _list[j];
        var _d  = hex_get(_id);
        if (is_undefined(_d)) continue;
        if (!_d.impl) continue;
        hex_apply(_id);                    // 记账 + 重算 PI + 打 buff_apply_id 脏标记
    }

    // 开局的一次性结算（卡组统计 / 类别打乱 / 拇指的阶级 / 契约 / 食指标记）也要重跑：
    // 「按卡组种数」「按最高档位」这类词条全靠它，不跑就永远是 0
    hex_b3_on_battle_init();

    if (variable_global_exists("hex_state") && is_struct(global.hex_state)) {
        var _s = global.hex_state;
        _s.first_done = true;              // 测试关没有首抽，别让 hex_place_locked 把放置锁死
        _s.pi_value   = 0;                 // 压迫指数不计入：鼠军保持原始强度，方便对数值

        // 卦 / 契约在 apply 时会挂「下一关开局面板」的 pending；
        // 测试关不弹那个面板，留着会带到正式局的下一关，这里清掉。
        // （测试契约请直接选 hex_contract_1..5，它们自带 b3_contract_pick）
        if (variable_struct_exists(_s, "b3_hana_pending"))     _s.b3_hana_pending     = false;
        if (variable_struct_exists(_s, "b3_contract_pending")) _s.b3_contract_pending = false;

        hex_sync_globals();                // PI 归零后把 global.pi_enemy_mult 同步回去
    }

    if (variable_global_exists("buff_apply_id")) global.buff_apply_id += 1;
    return true;
}
