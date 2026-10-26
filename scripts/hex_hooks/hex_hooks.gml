/// hex_hooks —— 与既有系统的接缝
/// 每个入口都必须先过 hex_enabled()，非海克斯模式一律原样返回

/// @function hex_mark_first_done()
/// @desc 把"开局首抽已处理"标记补上，解除放置锁定（hex_place_locked）。
///       本关没有抽取机会时（重复通关的关卡、序列续关）必须调用，
///       否则锁定永远解不开，整局一张卡都放不下去。
function hex_mark_first_done() {
    if (!hex_enabled()) return false;
    if (!hex_ensure_state()) return false;
    global.hex_state.first_done = true;
    return true;
}

/// @function hex_test_cleanup()
/// @desc 进入测试关卡时调用一次：把整套海克斯拆干净。
///       测试关卡测的是卡片本体数值，任何残留倍率 / HUD / 暂停面板都会污染伤害统计
function hex_test_cleanup() {
    if (!hex_enabled()) return false;

    hex_reset_run();                     // 清词条，倍率全部落回 1.0
    global.hex_pick_open     = false;
    global.hex_level_cleared = false;

    if (instance_exists(obj_hex_panel)) with (obj_hex_panel) instance_destroy();
    if (instance_exists(obj_hex_hud))   with (obj_hex_hud)   instance_destroy();

    if (instance_exists(obj_battle)) global.is_paused = false;

    hex_mark_first_done();               // 测试关卡没有首抽，别把放置锁住
    return true;
}

/// @function hex_battle_init()
/// @desc 进入战斗时调用一次：判断是否重置本局、建 HUD、结算开局火苗、触发首抽
function hex_battle_init() {
    if (!hex_enabled()) return false;
    // 测试关卡：整套关掉（不建 HUD、不抽卡、倍率回 1.0）
    if (hex_level_excluded()) {
        hex_test_cleanup();
        return false;
    }
    if (!variable_global_exists("hex_state")) hex_state_init();

    // 「一局」的边界：序列图（魔塔/龙渊/浮空/海底）跨关累积，其它单关即一局
    var _key = hex_map_of_level(global.level_id);
    var _is_seq = (_key != "" && hex_is_seq_map(_key));
    if (!variable_global_exists("hex_series_active")) global.hex_series_active = "";

    if (!_is_seq || global.hex_series_active != _key) {
        hex_reset_run();
        global.hex_series_active = _is_seq ? _key : "";
    }

    // 开局火苗 / 火苗上限（火苗上限走 flame_cap_base，避免被 longzhu 每帧重算覆盖）
    var _s = global.hex_state;
    if (variable_global_exists("flame")) global.flame += _s.flame_start;
    if (_s.flame_cap != 0) {
        if (!variable_global_exists("flame_cap_base")) global.flame_cap_base = 15000;
        global.flame_cap_base = max(2000, global.flame_cap_base + _s.flame_cap);
    }

    if (!instance_exists(obj_hex_hud)) instance_create_depth(0, 0, -2900, obj_hex_hud);

    // 重复通关的关卡没有开局抽取机会：先把"首抽已处理"补上，否则放不了卡
    if (hex_level_repeat()) hex_mark_first_done();

    hex_pi_recalc();
    return true;
}

/// @function hex_on_wave_start()
/// @desc 每波开始时结算火苗/回复类词条
function hex_on_wave_start() {
    if (!hex_enabled()) return;
    if (!variable_global_exists("hex_state")) return;
    var _s = global.hex_state;

    if (variable_global_exists("flame")) {
        global.flame += _s.flame_wave;
        if (_s.wave_flame_pct > 0) {
            global.flame += min(200, floor(global.flame * _s.wave_flame_pct));
        }
        if (variable_global_exists("flame_cap")) global.flame = min(global.flame, global.flame_cap);
    }

    if (_s.heal_wave > 0) {
        with (obj_card_parent) {
            if (self.plant_id != "player") {
                self.hp = min(self.max_hp, self.hp + self.max_hp * _s.heal_wave);
            }
        }
    }

    // 「时空炒锅」：每波开始卡槽冷却直接清零
    if (_s.wave_reset) {
        with (obj_card_slot) {
            cooldown_timer = cooldown;
        }
        if (variable_global_exists("buff_apply_id")) global.buff_apply_id += 1;
    }

    // 「双厨狂喜」：每波重置免费放置名额
    _s.free_place_used = false;
}

/// @function hex_enemy_scale(_inst)
/// @desc 把 PI 与词条的老鼠侧倍率乘到刚生成的敌人身上。必须在 instance_create 之后立刻调用
function hex_enemy_scale(_inst) {
    if (!hex_enabled()) return _inst;
    if (!instance_exists(_inst)) return _inst;

    var _hp  = hex_enemy_mult("hp");
    var _atk = hex_enemy_mult("atk");
    var _spd = hex_enemy_mult("spd");

    if (_hp != 1.0) {
        _inst.maxhp = max(1, round(_inst.maxhp * _hp));
        _inst.hp    = _inst.maxhp;
    }
    if (_atk != 1.0) _inst.atk = _inst.atk * _atk;
    if (_spd != 1.0) _inst.move_speed = _inst.move_speed * _spd;

    return _inst;
}

/// @function hex_spawn_flood(_enemy_list)
/// @desc 鼠潮：按 PI 阈值往本波尾部追加精英鼠（复用本波已有的敌人类型）
function hex_spawn_flood(_enemy_list) {
    if (!hex_enabled()) return 0;
    if (!variable_global_exists("pi_elite_extra")) return 0;
    var _n = global.pi_elite_extra;
    if (_n <= 0) return 0;
    if (!variable_global_exists("enemy_map")) return 0;

    var _types = [];
    for (var i = 0; i < array_length(_enemy_list); i++) {
        var _t = _enemy_list[i].type;
        if (_t != "" && ds_map_exists(global.enemy_map, _t)) array_push(_types, _t);
    }
    if (array_length(_types) == 0) return 0;

    var _spawned = 0;
    for (var k = 0; k < _n; k++) {
        var _type = _types[irandom(array_length(_types) - 1)];
        var _row  = irandom(global.grid_rows - 1) + 1;
        var _wx   = global.grid_offset_x + 9 * global.grid_cell_size_x;
        var _wy   = global.grid_offset_y + (_row - 1) * global.grid_cell_size_y;
        var _gp   = get_grid_position_from_world(_wx, _wy);

        var _e = instance_create_depth(_gp.x + 30, _gp.y + 38, 0, global.enemy_map[? _type]._obj);
        hex_enemy_scale(_e);
        if (global.pi_boss_escort) {
            _e.maxhp = round(_e.maxhp * 1.5);
            _e.hp    = _e.maxhp;
        }
        if (variable_instance_exists(_e, "grid_row")) _e.grid_row = _row;
        _spawned += 1;
    }
    return _spawned;
}

/// @function hex_on_win()
/// @desc 胜利结算瞬间记账：把本局词条写进存档并立即落盘。
///       与 complete_level() 的区别：那个函数只在「首次通关」时被调用，
///       重复通关已完成的关卡根本不会走到，所以解锁必须挂在这里。
/// @return bool 是否真的写入
function hex_on_win() {
    if (!hex_enabled()) return false;
    if (hex_level_excluded()) return false;      // 测试关卡不记账（数据不进存档）
    if (!variable_global_exists("hex_state") || !is_struct(global.hex_state)) return false;

    // 这是一次「通关离场」，不管记不记账，CleanUp 都不能把本局清空
    // （魔塔等序列的中途关是靠这个标记把本局续到下一关的）
    global.hex_level_cleared = true;

    if (global.hex_state.committed) return false;

    // 与 complete_level() 用同一个关卡 id 来源（level_data.id），找不到再退回 level_id
    var _lid = hex_current_level_id();
    if (!hex_commit_run(_lid)) return false;

    // 本局结束：序列标记作废，下次进同一张序列图从头开始
    global.hex_series_active = "";
    global.hex_level_cleared = true;

    if (variable_global_exists("save_slot")) save_file(global.save_slot);
    return true;
}

/// @function hex_try_drop(_x, _y)
/// @desc 敌人死亡时按掉率触发海克斯。触发即暂停并直接开三选一，不再落地拾取
function hex_try_drop(_x, _y) {
    if (!hex_enabled()) return false;
    if (hex_level_excluded()) return false;                 // 测试关卡不掉、不弹面板
    if (!variable_global_exists("hex_state")) return false;
    if (global.hex_pick_open) return false;                 // 已经在选，别叠面板
    if (instance_exists(obj_hex_panel)) return false;
    if (hex_taken_count() >= hex_cfg().max_hex) return false;
    if (random(1) >= hex_cfg().drop_rate) return false;

    instance_create_depth(0, 0, -9000, obj_hex_panel);
    return true;
}
