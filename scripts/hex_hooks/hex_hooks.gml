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
    // 火苗上限用「差值同步」：永久词条每局都会并进来，直接累加会越进关卡越涨
    hex_sync_flame_cap();

    // 一关只掉一次：本关已经掉过就不再掷骰（「两个旗子里只给一次」）
    global.hex_drop_used = false;

    if (!instance_exists(obj_hex_hud)) instance_create_depth(0, 0, -2900, obj_hex_hud);

    // 「食材升级」：禁用猫（含开局已经生成的那一排）
    if (hex_enemy_no_cat()) {
        with (obj_cat) instance_destroy();
    }

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

    // ── 上一波收尾（本次是新一波开始，说明上一波刚结束）──
    var _prev_wave = -1;
    if (instance_exists(obj_battle)) _prev_wave = obj_battle.current_wave - 1;
    hex_wave_settle(_prev_wave);

    if (variable_global_exists("flame")) {
        global.flame += _s.flame_wave;
        if (_s.wave_flame_pct > 0) {
            var _cap = (_s.wave_flame_cap > 0) ? _s.wave_flame_cap : 200;
            global.flame += min(_cap, floor(global.flame * _s.wave_flame_pct));
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
    _s.same_card_used  = false;
    _s.same_card_last  = "";
    // 本波卡片损失标记清零（「一锅端」按波结算）
    _s.wave_card_lost  = false;
}

/// @function hex_wave_settle(_prev_wave)
/// @desc 上一波结算：「一锅端」（整波零损）与「灶台主宰」（击破精英加层）。
///       在 hex_on_wave_start 里、火苗加成之前调用，保证加成算进本波开局火苗
function hex_wave_settle(_prev_wave) {
    if (!hex_enabled()) return;
    if (!variable_global_exists("hex_state") || !is_struct(global.hex_state)) return;
    var _s = global.hex_state;
    if (_prev_wave < 0) return;

    // ── 一锅端：整波没有卡片阵亡 ──
    if (_s.wave_clear_flame > 0 || _s.wave_clear_atk > 0) {
        if (!_s.wave_card_lost) {
            if (variable_global_exists("flame")) {
                global.flame += _s.wave_clear_flame;
                if (variable_global_exists("flame_cap")) global.flame = min(global.flame, global.flame_cap);
            }
            if (_s.wave_clear_cap > 0 && _s.wave_clear_stacks < _s.wave_clear_cap) {
                _s.wave_clear_stacks += 1;
                if (variable_global_exists("buff_apply_id")) global.buff_apply_id += 1;
            }
        }
        _s.wave_card_lost = false;
    }

    // ── 灶台主宰：每击破一个精英阶段 +1 层 ──
    if (_s.elite_atk > 0 && _s.elite_cap > 0) {
        var _ew = -1;
        if (variable_global_exists("level_file") && is_struct(global.level_file)
            && variable_struct_exists(global.level_file, "elite_wave")) {
            _ew = global.level_file.elite_wave;
        }
        if (_ew >= 0 && _prev_wave >= _ew && _s.elite_seen_wave != _prev_wave) {
            _s.elite_seen_wave = _prev_wave;
            if (_s.elite_stacks < _s.elite_cap) {
                _s.elite_stacks += 1;
                if (variable_global_exists("buff_apply_id")) global.buff_apply_id += 1;
            }
        }
    }
}

/// @function hex_enemy_scale(_inst)
/// @desc 把 PI 与词条的老鼠侧倍率乘到刚生成的普通敌人身上。必须在 instance_create 之后、
///       关卡难度系数之后立刻调用。自动按 is_boss 判断口径（漏传也不会变强得离谱）。
function hex_enemy_scale(_inst) {
    var _is_boss = false;
    if (instance_exists(_inst) && variable_instance_exists(_inst, "is_boss")) {
        _is_boss = _inst.is_boss;
    }
    return hex_enemy_scale_apply(_inst, _is_boss);
}

/// @function hex_enemy_scale_boss(_inst)
/// @desc BOSS 专用入口（BOSS 由 obj_battle/Step_2 单独生成，必须显式调用）。
///       BOSS 只吃血量与攻击，不吃移速：位移全是状态机按坐标硬推的
///       （遁地、瞬移、跳跃、绕场），改 move_speed 会与技能落点错位。
function hex_enemy_scale_boss(_inst) {
    return hex_enemy_scale_apply(_inst, true);
}

/// @function hex_enemy_scale_apply(_inst, _boss)
/// @desc 实际的倍率落点。两个入口共用，保证口径只有一份。
function hex_enemy_scale_apply(_inst, _boss) {
    if (!hex_enabled()) return _inst;
    if (!instance_exists(_inst)) return _inst;

    var _hp  = hex_enemy_hp_mult_for(_inst);
    var _atk = hex_enemy_mult("atk");
    var _spd = _boss ? 1.0 : hex_enemy_mult("spd");

    // 血量按比例缩放：BOSS 有的会带护盾/分身，hp 不一定等于 maxhp，直接拉满会白送血
    if (_hp != 1.0 && variable_instance_exists(_inst, "maxhp") && _inst.maxhp > 0) {
        var _ratio = clamp(_inst.hp / _inst.maxhp, 0, 1);
        _inst.maxhp = max(1, round(_inst.maxhp * _hp));
        _inst.hp    = max(1, round(_inst.maxhp * _ratio));
    }
    if (_atk != 1.0 && variable_instance_exists(_inst, "atk")) {
        _inst.atk = _inst.atk * _atk;
    }
    if (_spd != 1.0 && variable_instance_exists(_inst, "move_speed")) {
        _inst.move_speed = _inst.move_speed * _spd;
    }

    // ── 第二批：出生瞬间的机制标记（只在对应词条生效时挂）──
    if (hex_batch2_ensure()) {
        var _bs = global.hex_state;

        // 「均值」：出生时生命额外加上当前火苗数值
        if (_bs.b2_e_hp_flame && variable_instance_exists(_inst, "maxhp")
            && variable_global_exists("flame")) {
            var _fb = floor(max(0, global.flame));
            if (_fb > 0) {
                _inst.maxhp += _fb;
                _inst.hp    += _fb;
            }
        }

        // 「轻装伏击」：没啃咬过之前不可被攻击
        if (_bs.b2_e_hit_after) _inst.b2_can_be_hit = false;

        // 「3秒真美鼠」：出场无敌（表里按帧写，转成毫秒再比较）
        if (_bs.b2_e_invuln > 0) {
            _inst.b2_guard_until = current_time + hex_batch2_frames_to_ms(_bs.b2_e_invuln);
        }
    }

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
    // 一关最多掉一次：开局首抽已经把这一关的那一次用掉了，掉落只是小概率的额外惊喜，
    // 但同一关里不该连着弹出第二个面板把强度顶飞
    if (!variable_global_exists("hex_drop_used")) global.hex_drop_used = false;
    if (global.hex_drop_used) return false;
    if (random(1) >= hex_cfg().drop_rate) return false;

    global.hex_drop_used = true;
    instance_create_depth(0, 0, -9000, obj_hex_panel);
    return true;
}

/// @function hex_on_card_destroyed(_card)
/// @desc 卡片阵亡结算（在 obj_card_parent/Destroy_0 里、实例仍存在时调用）：
///       以牙还牙（全场反击）/ 火锅底料（灰烬 3x3 爆炸）/ 清汤锅（灰烬全场爆炸）/
///       大锅饭（3x3 内美食被反噬）/ 一锅端的"本波是否损失卡片"标记
function hex_on_card_destroyed(_card) {
    if (!hex_enabled()) return;
    if (!instance_exists(_card)) return;
    if (!variable_global_exists("hex_state") || !is_struct(global.hex_state)) return;
    var _s = global.hex_state;

    var _pid = "";
    if (variable_instance_exists(_card, "plant_id")) _pid = _card.plant_id;
    if (_pid == "player" || _pid == "") return;      // 玩家本体不参与卡片结算

    // 一锅端：本波已经损失过卡片，本波不再给奖励
    _s.wave_card_lost = true;

    var _atk  = variable_instance_exists(_card, "atk") ? _card.atk : 0;
    var _mhp  = variable_instance_exists(_card, "max_hp") ? _card.max_hp : 0;
    var _col  = variable_instance_exists(_card, "grid_col") ? _card.grid_col : -99;
    var _row  = variable_instance_exists(_card, "grid_row") ? _card.grid_row : -99;
    var _is_ash = false;
    var _cat = card_get_category(_pid);
    if (!is_undefined(_cat) && _cat.major == "灰烬类") _is_ash = true;

    // ── 以牙还牙：卡片被摧毁时对全场老鼠反击 ──
    if (_s.card_death_pct > 0 && _atk > 0) {
        var _d = max(1, round(_atk * _s.card_death_pct));
        with (obj_enemy_parent) {
            if (hp > 0) {
                damage_amount = _d;
                damage_type   = "normal";
                event_user(10);
            }
        }
    }

    // ── 火锅底料：灰烬阵亡时 3x3 爆炸 ──
    if (_is_ash && _s.ash_explode && _atk > 0) {
        var _d2 = max(1, round(_atk * 1.5));
        with (obj_enemy_parent) {
            if (hp > 0 && abs(other.grid_col - _col) <= 1 && abs(other.grid_row - _row) <= 1) {
                damage_amount = _d2;
                damage_type   = "normal";
                event_user(10);
            }
        }
    }

    // ── 清汤锅：灰烬阵亡时对全场老鼠爆炸 ──
    if (_is_ash && _s.ash_blast > 0 && _atk > 0) {
        var _d3 = max(1, round(_atk * _s.ash_blast));
        with (obj_enemy_parent) {
            if (hp > 0) {
                damage_amount = _d3;
                damage_type   = "normal";
                event_user(10);
            }
        }
    }

    // ── 大锅饭：阵亡时把自身血量倾泻到 3x3 内的其他美食身上 ──
    if (_s.e_card_blast && _mhp > 0) {
        with (obj_card_parent) {
            if (self.id != _card && self.plant_id != "player"
                && abs(other.grid_col - _col) <= 1 && abs(other.grid_row - _row) <= 1) {
                self.hp -= hex_card_incoming_damage(_mhp);
                event_user(2);
            }
        }
    }
}
