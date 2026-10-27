/// hex_core —— 海克斯核心：开关、局内状态、数值出口
///
/// 铁律（见 docs/海克斯玩法设计.md 1.1）：
///   只要 hex_enabled() 为假，本模块所有出口必须返回 1.0 / 0 / false，
///   不允许"不写值"，也不允许在调用方用 if 跳过——用默认安全值兜底。
///
/// 出口只有四个，其它系统一律通过它们读海克斯：
///   hex_atk_mult_for_card()  卡片攻击倍率（含分类专精 + 羁绊）
///   hex_cycle_mult_for_card() 卡片攻击间隔倍率（越小越快）
///   hex_hp_mult_for_card()    卡片生命倍率
///   hex_enemy_mult()          老鼠属性倍率（PI）

/// @function hex_enabled()
/// @desc 海克斯系统总开关。全工程唯一判定点
function hex_enabled() {
    if (!variable_global_exists("play_mode")) return false;
    return (global.play_mode == 4);
}

/// @function hex_level_excluded()
/// @desc 测试关卡（test_level）不参与海克斯：不弹面板、不建 HUD、不刷鼠潮、不记档。
///       关卡 id 与通关判定同源（global.level_data.id），取不到时退回 global.level_id
function hex_level_excluded() {
    if (variable_global_exists("level_data") && is_struct(global.level_data)
        && variable_struct_exists(global.level_data, "id")) {
        if (global.level_data.id == "test_level") return true;
    }
    if (variable_global_exists("level_id") && global.level_id == "test_level") return true;
    return false;
}

/// @function hex_active()
/// @desc 真正处于「海克斯对局」中：模式开着，且当前不是测试关卡。
///       所有会建实例 / 写档 / 锁操作的入口都该用它，纯数值出口继续用 hex_enabled()
function hex_active() {
    return (hex_enabled() && !hex_level_excluded());
}

/// @function hex_place_locked()
/// @desc 开局首抽还没处理完时，禁止放置任何卡片/角色。
///       注意是"首抽处理完"而不是"手里有词条"——玩家可以在首抽里直接放弃，
///       放弃之后必须允许正常放卡，否则整局就废了。
///       重复通关的关卡本关不开首抽面板，永远不锁（双保险，防止标记漏设把整局锁死）。
function hex_place_locked() {
    if (!hex_enabled()) return false;
    if (hex_level_excluded()) return false;      // 测试关卡压根没有首抽，永远不锁
    if (!variable_global_exists("hex_state")) return false;
    if (!is_struct(global.hex_state)) return false;
    if (!variable_struct_exists(global.hex_state, "first_done")) return false;
    if (global.hex_state.first_done) return false;
    if (hex_level_repeat()) return false;
    // 只有「首抽面板确实还开着、玩家还没做出选择」时才该锁。
    // 面板已经不在了（关掉了 / 被销毁 / 压根没弹出来），就没有理由再锁整局：
    // 任何一条把面板提前关掉、却漏设 first_done 的路径，都会让玩家整局一张卡都放不下去。
    if (!instance_exists(obj_hex_panel)) return false;
    return true;
}

/// @function hex_cfg()
/// @desc 参数唯一来源。只有一套值，调数值只改这里
function hex_cfg() {
    return {
        max_hex:          16,      // 单局词条上限
        first_pick_color: true,    // 开局首抽必出一张彩
        drop_rate:        0.010,   // 敌人掉率
        pi_rate:          0.008,   // PI 斜率（每点 +0.8%）
        pi_cap:           0.30,    // PI 加成上限
        max_c:            4,       // 单局减码型上限
        reroll_cost:      [200, 400, 800],
        giveup_flame:     120,     // 弃权火苗
        giveup_pi:        2        // 弃权 PI
    };
}

/// @function hex_state_init()
/// @desc 建局内状态。只在海克斯模式进入关卡时调用
function hex_state_init() {
    global.hex_state = {
        picked:          [],      // 本局抽到的词条 [{ id, stack, tier, form }]
        persist:         [],      // 存档里已解锁、永久生效的词条（每次建局重新并入）
        picks:           0,
        rerolls:         0,
        giveups:         0,
        pi_value:        0,       // 压迫指数（不能叫 pi：与 GML 内置常量 pi 冲突，赋值会报 GM1031）
        free_reroll:     0,
        c_streak:        0,       // 连续全 C 的次数（保底用）
        first_done:      false,   // 开局首抽是否已经处理过（选过或放弃过）
        committed:       false,   // 本局是否已经写入存档（防止重复记账）

        // 卡片侧汇总倍率
        atk:             1.0,
        cycle:           1.0,
        hp:              1.0,
        cat_atk:         {},      // 分类名 -> 倍率
        cat_cycle:       {},

        // 火苗相关
        flame_start:     0,       // 开局火苗增量
        flame_wave:      0,       // 每波开始增量
        flame_cap:       0,       // 火苗上限增量
        flame_growth:    1.0,     // 自然增长倍率
        wave_flame_pct:  0,       // 每波开始按当前火苗百分比追加
        heal_wave:       0,       // 每波开始按最大生命百分比回复
        flame_tick:      0,       // 每 N 秒固定加火苗
        flame_tick_sec:  15,

        // 老鼠侧汇总倍率
        e_hp:            1.0,
        e_spd:           1.0,
        e_atk:           1.0,
        e_count:         1.0,     // <1 表示按概率少刷

        // ── 机制通道（不是纯数值，需要外部系统配合读取）──
        refund:          1.0,     // 铲除返还倍率
        cost:            1.0,     // 卡片费用倍率
        gridless:        false,   // 增幅类 / 辅助类不占格
        free_place:      false,   // 每波首次放置免费
        free_place_used: false,
        wave_reset:      false,   // 每波开始卡槽冷却清零
        bond_power:      1.0,     // 共鸣效果强度倍率
        bond_req_major:  0,       // 主共鸣要求降低量
        bond_req_minor:  0,       // 小共鸣要求降低量
        bond_extra:      0,       // 场上最大分类的共鸣计数加成

        per_card_atk:    0,       // 场上每张卡给全队的攻击增量
        per_card_cap:    0,       // 上面的封顶
        top_atk:         0,       // 场上数量最多的小分类攻击增量
        card_on_field:   0,       // 场上卡片实例数（hex_bond_recalc 维护）
        top_minor:       "",      // 数量最多的小分类

        kill_flame:      false,   // 击杀概率给火苗
        kill_flame_rate: 0,
        kill_flame_gain: 0,
        kill_stack:      false,   // 击杀累积攻击
        kill_stack_need: 25,      // 每多少只老鼠升 1 层
        kill_stack_atk:  0,
        kill_stack_cap:  0,
        kill_stacks:     0,
        kill_counter:    0,

        // 羁绊
        bond_count:      {},      // 分类名 -> 不同 card_id 计数
        bond_tier:       {}       // 分类名 -> 已达成档位（0 表示未达成）
    };
    // 换局必须清羁绊，否则上一局的档位会短暂残留到下一次重算（15 帧）
    global.bond_count = {};
    global.bond_tier  = {};
    hex_sync_globals();

    // 已解锁的词条永久生效：每次建局都按存档重新并入（测试关卡 hex_active 为假，不会带进去）
    hex_load_collection();
}

/// @function hex_reset_run()
/// @desc 清空本局（退出、失败、切模式、换关序列起点）
function hex_reset_run() {
    global.hex_state = undefined;
    hex_state_init();            // 内部会 hex_sync_globals()，非海克斯模式下自动落回 1.0
    global.hex_last_wave     = -1;
    global.hex_pending_pick  = 0;
    global.hex_pick_open     = false;
    // 退出战斗后重进必须重新抽取（docs 1.2：只有通关才留档，中途退出不留）
    global.hex_series_active = "";

    // 本局作废后把「火苗上限 +X」的加成同步回永久词条的水平（永久词条的火苗上限仍然保留）
    hex_sync_flame_cap();
}

/// @function hex_ensure_state()
/// @desc 容错：任何出口被调用前保证状态存在
function hex_ensure_state() {
    if (!hex_enabled()) return false;
    if (!variable_global_exists("hex_state")) hex_state_init();
    if (!is_struct(global.hex_state)) hex_state_init();
    return true;
}

/// @function hex_sync_globals()
/// @desc 把状态里的倍率同步到全局出口；非海克斯模式一律强制 1.0
function hex_sync_globals() {
    if (!hex_enabled()) {
        global.hex_mult      = { atk: 1.0, cycle: 1.0, hp: 1.0 };
        global.pi_enemy_mult = 1.0;
        global.pi_elite_extra = 0;
        global.pi_boss_escort = false;
        global.bond_mult     = 1.0;
        return;
    }
    var _s = global.hex_state;
    global.hex_mult = {
        atk:   clamp(_s.atk,   0.25, 8.0),
        cycle: clamp(_s.cycle, 0.30, 3.0),
        hp:    clamp(_s.hp,    0.25, 5.0)
    };
    global.pi_enemy_mult  = min(1 + _s.pi_value * hex_cfg().pi_rate, 1 + hex_cfg().pi_cap);

    // 鼠潮阶梯：10 / 18 / 26 点各加 1/2/3 只精英。写成顺序覆盖，避免链式三元
    var _elite = 0;
    if (_s.pi_value >= 10) _elite = 1;
    if (_s.pi_value >= 18) _elite = 2;
    if (_s.pi_value >= 26) _elite = 3;
    global.pi_elite_extra = _elite;

    global.pi_boss_escort = (_s.pi_value >= 32);
}

/// @function hex_pi_recalc()
/// @desc 重算压迫指数。只在拿牌 / 弃权 / 开局调用
function hex_pi_recalc() {
    if (!hex_ensure_state()) return;
    var _s = global.hex_state;
    var _p = _s.giveups * hex_cfg().giveup_pi;
    // 银 1 / 金 2 / 彩 3，按叠层次数累计（拿两遍双叠的金牌就是 4 点）
    for (var i = 0; i < array_length(_s.picked); i++) {
        _p += (_s.picked[i].tier + 1) * _s.picked[i].stack;
    }
    // 永久词条同样施加压迫：否则收藏越多越白嫖，老鼠完全追不上
    for (var j = 0; j < array_length(_s.persist); j++) {
        _p += (_s.persist[j].tier + 1) * _s.persist[j].stack;
    }
    _s.pi_value = _p;
    hex_sync_globals();
}

/// @function hex_apply_core(_id)
/// @desc 把一条词条按「1 层」并入本局数值。只做数值，不记账、不重算 PI：
///       单局抽取（hex_apply）和永久收藏（hex_load_collection）都调它
function hex_apply_core(_id) {
    var _d = hex_get(_id);
    if (is_undefined(_d)) return false;
    if (!_d.impl) return false;

    var _s = global.hex_state;

    // ---- 卡片侧 ----
    if (variable_struct_exists(_d.ex, "atk"))          _s.atk   *= (1 + _d.ex.atk);
    if (variable_struct_exists(_d.ex, "cycle"))        _s.cycle *= (1 + _d.ex.cycle);
    if (variable_struct_exists(_d.ex, "hp"))           _s.hp    *= (1 + _d.ex.hp);
    if (variable_struct_exists(_d.ex, "flame_start"))  _s.flame_start += _d.ex.flame_start;
    if (variable_struct_exists(_d.ex, "flame_wave"))   _s.flame_wave  += _d.ex.flame_wave;
    if (variable_struct_exists(_d.ex, "flame_cap"))    _s.flame_cap   += _d.ex.flame_cap;
    if (variable_struct_exists(_d.ex, "flame_growth")) _s.flame_growth *= (1 + _d.ex.flame_growth);
    if (variable_struct_exists(_d.ex, "wave_flame_pct")) _s.wave_flame_pct += _d.ex.wave_flame_pct;
    if (variable_struct_exists(_d.ex, "heal_wave"))    _s.heal_wave += _d.ex.heal_wave;
    if (variable_struct_exists(_d.ex, "flame_tick")) {
        _s.flame_tick += _d.ex.flame_tick;
        if (variable_struct_exists(_d.ex, "flame_tick_sec")) {
            _s.flame_tick_sec = min(_s.flame_tick_sec, _d.ex.flame_tick_sec);
        }
    }
    if (variable_struct_exists(_d.ex, "free_reroll"))  _s.free_reroll += _d.ex.free_reroll;

    // ── 机制通道：这些值不是倍率，由各自的读取函数消费 ──
    if (variable_struct_exists(_d.ex, "refund"))         _s.refund += _d.ex.refund;
    if (variable_struct_exists(_d.ex, "cost"))           _s.cost *= (1 + _d.ex.cost);
    if (variable_struct_exists(_d.ex, "gridless"))       _s.gridless = true;
    if (variable_struct_exists(_d.ex, "free_place"))     _s.free_place = true;
    if (variable_struct_exists(_d.ex, "wave_reset"))     _s.wave_reset = true;
    if (variable_struct_exists(_d.ex, "bond_power"))     _s.bond_power *= (1 + _d.ex.bond_power);
    if (variable_struct_exists(_d.ex, "bond_req_major")) _s.bond_req_major += _d.ex.bond_req_major;
    if (variable_struct_exists(_d.ex, "bond_req_minor")) _s.bond_req_minor += _d.ex.bond_req_minor;
    if (variable_struct_exists(_d.ex, "bond_extra"))     _s.bond_extra += _d.ex.bond_extra;
    if (variable_struct_exists(_d.ex, "top_atk"))        _s.top_atk += _d.ex.top_atk;

    if (variable_struct_exists(_d.ex, "per_card_atk")) {
        var _pc = _d.ex.per_card_atk;
        _s.per_card_atk += _pc[0];
        _s.per_card_cap += _pc[1];
    }
    if (variable_struct_exists(_d.ex, "kill_flame")) {
        var _kf = _d.ex.kill_flame;
        _s.kill_flame      = true;
        _s.kill_flame_rate += _kf[0];
        _s.kill_flame_gain += _kf[1];
    }
    if (variable_struct_exists(_d.ex, "kill_stack")) {
        var _ks = _d.ex.kill_stack;
        _s.kill_stack     = true;
        _s.kill_stack_atk += _ks[0];
        _s.kill_stack_cap += _ks[1];
        if (variable_struct_exists(_d.ex, "kill_stack_need")) {
            _s.kill_stack_need = min(_s.kill_stack_need, _d.ex.kill_stack_need);
        }
    }

    if (variable_struct_exists(_d.ex, "cat_atk")) {
        var _a = _d.ex.cat_atk;
        for (var i = 0; i < array_length(_a); i++) {
            var _c = _a[i][0];
            var _cur = variable_struct_exists(_s.cat_atk, _c) ? _s.cat_atk[$ _c] : 1.0;
            _s.cat_atk[$ _c] = _cur * (1 + _a[i][1]);
        }
    }
    if (variable_struct_exists(_d.ex, "cat_cycle")) {
        var _b = _d.ex.cat_cycle;
        for (var j = 0; j < array_length(_b); j++) {
            var _c2 = _b[j][0];
            var _cur2 = variable_struct_exists(_s.cat_cycle, _c2) ? _s.cat_cycle[$ _c2] : 1.0;
            _s.cat_cycle[$ _c2] = _cur2 * (1 + _b[j][1]);
        }
    }

    // ---- 老鼠侧 ----
    if (variable_struct_exists(_d.en, "e_hp"))    _s.e_hp    *= (1 + _d.en.e_hp);
    if (variable_struct_exists(_d.en, "e_spd"))   _s.e_spd   *= (1 + _d.en.e_spd);
    if (variable_struct_exists(_d.en, "e_atk"))   _s.e_atk   *= (1 + _d.en.e_atk);
    if (variable_struct_exists(_d.en, "e_count")) _s.e_count *= (1 + _d.en.e_count);

    return true;
}

/// @function hex_apply(_id)
/// @desc 本局抽到一条：并入数值 + 记进 picked + 重算 PI。
///       重复拿同一条按叠层上限判断由调用方负责
function hex_apply(_id) {
    if (!hex_ensure_state()) return false;
    var _d = hex_get(_id);
    if (is_undefined(_d)) return false;
    if (!hex_apply_core(_id)) return false;

    var _s = global.hex_state;

    // ---- 记账 ----
    var _found = false;
    for (var k = 0; k < array_length(_s.picked); k++) {
        if (_s.picked[k].id == _id) {
            _s.picked[k].stack += 1;
            _found = true;
            break;
        }
    }
    if (!_found) {
        array_push(_s.picked, { id: _id, stack: 1, tier: _d.tier, form: _d.form });
    }
    _s.picks += 1;

    hex_pi_recalc();
    hex_sync_flame_cap();     // 「火苗上限 +X」当场生效，不必等下一关
    // 让所有卡片下一帧重算 atk/cycle：buff_apply_id 是既有系统唯一的重算脏标记
    if (variable_global_exists("buff_apply_id")) global.buff_apply_id += 1;
    return true;
}

/// @function hex_taken(_id)
/// @desc 当前总层数（永久收藏 + 本局抽取），用于叠层上限判断
function hex_taken(_id) {
    if (!hex_ensure_state()) return 0;
    var _s = global.hex_state;
    var _n = 0;
    for (var i = 0; i < array_length(_s.persist); i++) {
        if (_s.persist[i].id == _id) _n += _s.persist[i].stack;
    }
    for (var k = 0; k < array_length(_s.picked); k++) {
        if (_s.picked[k].id == _id) _n += _s.picked[k].stack;
    }
    return _n;
}

/// @function hex_taken_count()
/// @desc 本局抽到的条数（不含永久收藏，永久的不占 16 条名额）
function hex_taken_count() {
    if (!hex_enabled()) return 0;
    if (!variable_global_exists("hex_state")) return 0;
    if (!is_struct(global.hex_state)) return 0;
    return array_length(global.hex_state.picked);
}

/// @function hex_persist_count()
/// @desc 永久生效的词条种数（已解锁且本次建局已并入的）
function hex_persist_count() {
    if (!hex_active()) return 0;
    if (!variable_global_exists("hex_state")) return 0;
    if (!is_struct(global.hex_state)) return 0;
    if (!variable_struct_exists(global.hex_state, "persist")) return 0;
    return array_length(global.hex_state.persist);
}

/// @function hex_persist_total_stack()
/// @desc 永久生效的总层数（含叠层），HUD 用
function hex_persist_total_stack() {
    if (hex_persist_count() == 0) return 0;
    var _n = 0;
    for (var i = 0; i < array_length(global.hex_state.persist); i++) {
        _n += global.hex_state.persist[i].stack;
    }
    return _n;
}

/// @function hex_taken_c()
/// @desc 已持有的减码型条数（用于 4 条上限）
function hex_taken_c() {
    if (!hex_ensure_state()) return 0;
    var _n = 0;
    for (var i = 0; i < array_length(global.hex_state.picked); i++) {
        if (global.hex_state.picked[i].form == "C") _n++;
    }
    return _n;
}

// ══════════════════════ 数值出口 ══════════════════════

/// @function hex_category_mult(_plant_id, _map_name)
/// @desc 分类专精倍率。_map_name = "cat_atk" / "cat_cycle"
function hex_category_mult(_plant_id, _map_name) {
    if (!hex_enabled()) return 1.0;
    if (!variable_global_exists("hex_state")) return 1.0;
    var _m = (_map_name == "cat_atk") ? global.hex_state.cat_atk : global.hex_state.cat_cycle;
    var _mult = 1.0;
    var _cat = card_get_category(_plant_id);
    if (is_undefined(_cat)) return 1.0;
    if (variable_struct_exists(_m, _cat.major)) _mult *= _m[$ _cat.major];
    if (variable_struct_exists(_m, _cat.minor)) _mult *= _m[$ _cat.minor];
    return _mult;
}

/// @function hex_bond_table()
/// @desc 羁绊效果表（docs 2.3 / 2.4）。每个分类一条，按档位从低到高给增量。
///       能落到数值引擎上的效果走 atk / cycle / hp 三个通道；
///       纯机制类效果（穿透、溅射、不占格等）在本表里折算成等效数值，见每条注释。
function hex_bond_table() {
    if (variable_global_exists("hex_bond_tbl")) return global.hex_bond_tbl;
    global.hex_bond_tbl = {

        // ══════ 主羁绊（12）══════
        // 直射：2 档攻击；3 档穿透折算成攻击间隔；4 档 −14% 间隔
        "直射类":     [ { atk: 0.08 }, { atk: 0.08, cycle: -0.06 }, { atk: 0.08, cycle: -0.14 } ],
        // 投掷：溅射范围 / 易伤 / 越障，都折成伤害
        "投掷类":     [ { atk: 0.10 }, { atk: 0.20 }, { atk: 0.26, cycle: -0.06 } ],
        // 多向：方向伤害 / 补射 / 叠层
        "多向类":     [ { atk: 0.10 }, { atk: 0.18 }, { atk: 0.26, cycle: -0.08 } ],
        // 增幅：增幅倍率 +10% 落成增幅类自身伤害
        "增幅类":     [ { atk: 0.10 }, { atk: 0.16 }, { atk: 0.24 } ],
        // 产能：产出 +10%（走火苗侧，这里给卡本体一点补偿）
        "产能类":     [ { atk: 0.08 }, { atk: 0.12 }, { atk: 0.16 } ],
        // 辅助：生命 +20% / 增益延长 / 每张辅助给全队 +3%
        "辅助类":     [ { hp: 0.20 }, { hp: 0.28 }, { hp: 0.28, atk: 0.09 } ],
        // 专业防空：对空伤害
        "专业防空类": [ { atk: 0.20 }, { atk: 0.26 }, { atk: 0.34 } ],
        // 喷壶：伤害 / 减速 / 间隔 −20%
        "喷壶类":     [ { atk: 0.12 }, { atk: 0.18 }, { atk: 0.18, cycle: -0.20 } ],
        // 追踪：子弹速度折成伤害，锁定/转移折成更多伤害
        "追踪类":     [ { atk: 0.14 }, { atk: 0.22 }, { atk: 0.30 } ],
        // 非远程：生命 +30% / 反伤 / 死亡爆炸
        "非远程类":   [ { hp: 0.30 }, { hp: 0.38 }, { hp: 0.38, atk: 0.20 } ],
        // 灰烬：灰烬伤害 / 死亡爆炸 / 不占上限
        "灰烬类":     [ { atk: 0.15 }, { atk: 0.22 }, { atk: 0.30 } ],
        // 防御：生命 / 站场加攻 / 反伤
        "防御类":     [ { hp: 0.25 }, { hp: 0.25, atk: 0.10 }, { hp: 0.35, atk: 0.10 } ],

        // ══════ 子羁绊（8）══════
        "传统直线类": [ { cycle: -0.10 }, { cycle: -0.12 }, { cycle: -0.14 } ],
        // 固定轨迹：轨迹伤害 / 数量 / 受增幅倍率
        "固定轨迹类": [ { atk: 0.15 }, { atk: 0.22 }, { atk: 0.30 } ],
        "单线投手":   [ { atk: 0.12 }, { atk: 0.20 }, { atk: 0.30 } ],
        "灼烧投手":   [ { atk: 0.10 }, { atk: 0.18 } ],
        "海星类":     [ { atk: 0.10 }, { atk: 0.18 } ],
        "子弹增幅":   [ { atk: 0.12 }, { atk: 0.20 } ],
        "水管类":     [ { cycle: -0.12 }, { cycle: -0.24 } ],
        "三线类":     [ { atk: 0.10 }, { atk: 0.20 } ]
    };
    return global.hex_bond_tbl;
}

/// @function hex_pct(_v)
/// @desc 增量转百分比文本：0.18 -> "+18%"，-0.12 -> "-12%"
function hex_pct(_v) {
    var _n = round(_v * 100);
    if (_n > 0) return "+" + string(_n) + "%";
    return string(_n) + "%";
}

/// @function hex_bond_effect_text(_name, _idx)
/// @desc 某个分类第 _idx 档（0 基）的效果描述，给悬停提示用。
///       表里可能只有 2 档（子羁绊），越界返回空串。
function hex_bond_effect_text(_name, _idx) {
    var _tbl = hex_bond_table();
    if (!variable_struct_exists(_tbl, _name)) return "";
    var _arr = _tbl[$ _name];
    if (array_length(_arr) == 0) return "";
    // 表里可能只有 2 档，档位算到 3 时按最后一档显示
    if (_idx >= array_length(_arr)) _idx = array_length(_arr) - 1;
    if (_idx < 0) return "";
    var _e = _arr[_idx];
    var _s = "";
    if (variable_struct_exists(_e, "atk"))   _s += "攻击 " + hex_pct(_e.atk);
    if (variable_struct_exists(_e, "hp"))    _s += (_s == "" ? "" : "  ") + "生命 " + hex_pct(_e.hp);
    if (variable_struct_exists(_e, "cycle")) _s += (_s == "" ? "" : "  ") + "间隔 " + hex_pct(_e.cycle);
    return _s;
}

/// @function hex_bond_bonus(_name, _kind)
/// @desc 某个分类在某通道上的增量。_kind = "atk" / "cycle" / "hp"
function hex_bond_bonus(_name, _kind) {
    if (!hex_enabled()) return 0;
    if (_name == "") return 0;
    var _t = hex_bond_tier(_name);
    if (_t <= 0) return 0;

    var _tbl = hex_bond_table();
    if (!variable_struct_exists(_tbl, _name)) return 0;

    var _arr = _tbl[$ _name];
    var _e   = _arr[min(_t, array_length(_arr)) - 1];
    if (!variable_struct_exists(_e, _kind)) return 0;
    return _e[$ _kind];
}

/// @function hex_bond_mult_for_card(_plant_id, _kind)
/// @desc 大类 + 小类同时生效（docs 2.4：刻意叠加），返回倍率
function hex_bond_mult_for_card(_plant_id, _kind) {
    if (!hex_enabled()) return 1.0;
    var _cat = card_get_category(_plant_id);
    if (is_undefined(_cat)) return 1.0;
    var _add = hex_bond_bonus(_cat.major, _kind) + hex_bond_bonus(_cat.minor, _kind);
    // 「调味大师」：所有共鸣效果按比例增强
    if (variable_global_exists("hex_state") && is_struct(global.hex_state)) {
        _add *= global.hex_state.bond_power;
    }
    return max(0.2, 1 + _add);
}

/// @function hex_bond_atk_mult(_plant_id)
/// @desc 羁绊攻击倍率（大类 + 小类累加后一次性成倍）
function hex_bond_atk_mult(_plant_id) {
    return hex_bond_mult_for_card(_plant_id, "atk");
}

/// @function hex_atk_mult_for_card(_plant_id)
function hex_atk_mult_for_card(_plant_id) {
    if (!hex_enabled()) return 1.0;
    if (!variable_global_exists("hex_mult")) return 1.0;
    return global.hex_mult.atk
         * hex_category_mult(_plant_id, "cat_atk")
         * hex_bond_atk_mult(_plant_id)
         * (1 + hex_dyn_atk_bonus(_plant_id));
}

/// @function hex_cycle_mult_for_card(_plant_id)
function hex_cycle_mult_for_card(_plant_id) {
    if (!hex_enabled()) return 1.0;
    if (!variable_global_exists("hex_mult")) return 1.0;
    return global.hex_mult.cycle
         * hex_category_mult(_plant_id, "cat_cycle")
         * hex_bond_mult_for_card(_plant_id, "cycle");
}

/// @function hex_hp_mult_for_card(_plant_id)
function hex_hp_mult_for_card(_plant_id) {
    if (!hex_enabled()) return 1.0;
    if (!variable_global_exists("hex_mult")) return 1.0;
    return global.hex_mult.hp * hex_bond_mult_for_card(_plant_id, "hp");
}

/// @function hex_enemy_mult(_kind)
/// @desc 老鼠属性倍率。_kind = "hp" / "spd" / "atk"
///       永久词条会一层层累加，这里必须夹逼：老鼠侧没有别的兜底，
///       一旦叠到几十倍，卡片侧 8 倍攻击的夹逼就完全追不上
function hex_enemy_mult(_kind) {
    if (!hex_enabled()) return 1.0;
    if (!variable_global_exists("hex_state")) return 1.0;
    var _s = global.hex_state;
    var _v = 1.0;
    switch (_kind) {
        case "hp":  _v = clamp(_s.e_hp,  0.30, 4.0); break;
        case "spd": _v = clamp(_s.e_spd, 0.40, 2.5); break;
        case "atk": _v = clamp(_s.e_atk, 0.30, 3.0); break;
        default:    _v = 1.0;                        break;
    }
    return _v * global.pi_enemy_mult;
}

/// @function hex_flame_growth()
/// @desc 拾取火苗时的增量倍率（「火苗自然增长 +X%」）
function hex_flame_growth() {
    if (!hex_enabled()) return 1.0;
    if (!variable_global_exists("hex_state")) return 1.0;
    return global.hex_state.flame_growth;
}

/// @function hex_sync_flame_cap()
/// @desc 把「火苗上限 +X」写进 flame_cap_base。
///       必须用差值：永久词条每局都会重新并入，直接累加会让上限每进一关涨一次
function hex_sync_flame_cap() {
    if (!variable_global_exists("hex_flame_cap_applied")) global.hex_flame_cap_applied = 0;

    // 目标值：海克斯模式取状态里的 flame_cap，其它模式一律 0（= 把加成退回原样）
    var _want = 0;
    if (hex_enabled() && variable_global_exists("hex_state") && is_struct(global.hex_state)
        && variable_struct_exists(global.hex_state, "flame_cap")) {
        _want = global.hex_state.flame_cap;
    }

    var _d = _want - global.hex_flame_cap_applied;
    if (abs(_d) < 0.001) return;
    if (!variable_global_exists("flame_cap_base")) global.flame_cap_base = 15000;
    global.flame_cap_base = max(2000, global.flame_cap_base + _d);
    global.hex_flame_cap_applied = _want;
}

/// @function hex_enemy_skip_chance()
/// @desc 生成时跳过这只老鼠的概率（「老鼠数量 −X%」）
function hex_enemy_skip_chance() {
    if (!hex_enabled()) return 0;
    if (!variable_global_exists("hex_state")) return 0;
    return clamp(1 - global.hex_state.e_count, 0, 0.9);
}

/// @function hex_enemy_extra_chance()
/// @desc 生成时额外再多刷一只老鼠的概率（「老鼠数量 +X%」），与上面的跳过对称
function hex_enemy_extra_chance() {
    if (!hex_enabled()) return 0;
    if (!variable_global_exists("hex_state")) return 0;
    return clamp(global.hex_state.e_count - 1, 0, 2.0);
}

// ══════════════════════ 机制通道 ══════════════════════

/// @function hex_refund_mult()
/// @desc 铲除返还倍率。铲子本身已有返还率，这里再乘一层
function hex_refund_mult() {
    if (!hex_enabled()) return 1.0;
    if (!variable_global_exists("hex_state")) return 1.0;
    return max(0, global.hex_state.refund);
}

/// @function hex_cost_mult()
/// @desc 卡片费用倍率
function hex_cost_mult() {
    if (!hex_enabled()) return 1.0;
    if (!variable_global_exists("hex_state")) return 1.0;
    return clamp(global.hex_state.cost, 0.1, 3.0);
}

/// @function hex_gridless_for_card(_card_id)
/// @desc 该卡是否因为海克斯而不占格（增幅类 / 辅助类）
function hex_gridless_for_card(_card_id) {
    if (!hex_enabled()) return false;
    if (!variable_global_exists("hex_state")) return false;
    if (!global.hex_state.gridless) return false;
    var _c = card_get_category(_card_id);
    if (is_undefined(_c)) return false;
    return (_c.major == "增幅类" || _c.major == "辅助类");
}

/// @function hex_free_place_ready()
function hex_free_place_ready() {
    if (!hex_enabled()) return false;
    if (!variable_global_exists("hex_state")) return false;
    return (global.hex_state.free_place && !global.hex_state.free_place_used);
}

/// @function hex_consume_free_place()
/// @desc 用掉本波的免费放置名额
function hex_consume_free_place() {
    if (!hex_enabled()) return false;
    if (!variable_global_exists("hex_state")) return false;
    if (!global.hex_state.free_place || global.hex_state.free_place_used) return false;
    global.hex_state.free_place_used = true;
    return true;
}

/// @function hex_on_kill(_x, _y)
/// @desc 老鼠死亡结算：概率给火苗 + 击杀累积攻击
function hex_on_kill(_x, _y) {
    if (!hex_enabled()) return;
    if (!variable_global_exists("hex_state")) return;
    var _s = global.hex_state;

    if (_s.kill_flame && _s.kill_flame_rate > 0 && random(1) < _s.kill_flame_rate) {
        if (variable_global_exists("flame")) {
            var _cap = variable_global_exists("flame_cap") ? global.flame_cap : 999999;
            global.flame = min(global.flame + _s.kill_flame_gain, _cap);
        }
    }

    if (_s.kill_stack && _s.kill_stack_cap > 0 && _s.kill_stacks < _s.kill_stack_cap) {
        _s.kill_counter += 1;
        var _need = max(1, _s.kill_stack_need);
        while (_s.kill_counter >= _need && _s.kill_stacks < _s.kill_stack_cap) {
            _s.kill_counter -= _need;
            _s.kill_stacks  += 1;
            // 层数变了要让卡片重算攻击
            if (variable_global_exists("buff_apply_id")) global.buff_apply_id += 1;
        }
    }
}

/// @function hex_card_count()
/// @desc 场上卡片数（不含玩家本体）。hex_bond_recalc 每 15 帧维护
function hex_card_count() {
    if (!hex_enabled()) return 0;
    if (!variable_global_exists("hex_state")) return 0;
    return global.hex_state.card_on_field;
}

/// @function hex_dyn_atk_bonus(_plant_id)
/// @desc 动态攻击增量：场上卡数 / 顶级分类 / 击杀层数。返回「增量」，不是倍率
function hex_dyn_atk_bonus(_plant_id) {
    if (!hex_enabled()) return 0;
    if (!variable_global_exists("hex_state")) return 0;
    var _s = global.hex_state;
    var _add = 0;

    if (_s.per_card_atk > 0) {
        _add += min(_s.per_card_atk * hex_card_count(), _s.per_card_cap);
    }
    if (_s.top_atk > 0 && _s.top_minor != "") {
        var _c = card_get_category(_plant_id);
        if (!is_undefined(_c) && _c.minor == _s.top_minor) _add += _s.top_atk;
    }
    if (_s.kill_stack && _s.kill_stacks > 0) {
        _add += _s.kill_stack_atk * _s.kill_stacks;
    }
    return _add;
}

// ══════════════════════ 羁绊 ══════════════════════

/// @function hex_bond_recalc()
/// @desc 统计场上不同 card_id 的分类计数。同名卡多张只算 1 个
function hex_bond_recalc() {
    if (!hex_enabled()) {
        global.bond_count = {};
        global.bond_tier  = {};
        global.bond_mult  = 1.0;
        return;
    }
    if (!variable_global_exists("hex_state")) hex_state_init();
    if (!variable_global_exists("bond_tier") || !is_struct(global.bond_tier)) global.bond_tier = {};

    var _seen  = {};      // card_id -> true
    var _major = {};      // 分类名 -> 计数
    var _minor = {};
    var _inst  = 0;       // 场上卡片实例数（含同名多张）

    with (obj_card_parent) {
        if (self.plant_id == "player") continue;
        _inst += 1;
        if (variable_struct_exists(_seen, self.plant_id)) continue;
        _seen[$ self.plant_id] = true;

        var _cat = card_get_category(self.plant_id);
        if (!is_undefined(_cat)) {
            var _m = _cat.major;
            var _n = _cat.minor;
            if (_m != "") _major[$ _m] = (variable_struct_exists(_major, _m) ? _major[$ _m] : 0) + 1;
            if (_n != "") _minor[$ _n] = (variable_struct_exists(_minor, _n) ? _minor[$ _n] : 0) + 1;
        }
    }

    global.hex_state.card_on_field = _inst;

    // 数量最多的小分类（「招牌菜」用）。同数取先出现的，结果稳定
    var _top_n = "";
    var _top_c = 0;
    var _mn = variable_struct_get_names(_minor);
    for (var ti = 0; ti < array_length(_mn); ti++) {
        var _tc = _minor[$ _mn[ti]];
        if (_tc > _top_c) { _top_c = _tc; _top_n = _mn[ti]; }
    }
    global.hex_state.top_minor = _top_n;

    // 「编外厨师」：场上数量最多的大分类，共鸣计数额外 +N
    if (global.hex_state.bond_extra > 0 && array_length(variable_struct_get_names(_major)) > 0) {
        var _bx_n = "";
        var _bx_c = -1;
        var _mnames = variable_struct_get_names(_major);
        for (var bi = 0; bi < array_length(_mnames); bi++) {
            var _bc = _major[$ _mnames[bi]];
            if (_bc > _bx_c) { _bx_c = _bc; _bx_n = _mnames[bi]; }
        }
        if (_bx_n != "") _major[$ _bx_n] = _bx_c + global.hex_state.bond_extra;
    }

    global.hex_state.bond_count = _major;
    global.bond_count = _major;

    // 先在临时表里算完，再和上一帧比对：档位一变就让所有卡片重算攻击
    var _prev_tier = global.bond_tier;
    var _new_tier  = {};

    // 阈值：大池 2/4/6，中池 2/3/5，小池 2/3/4（docs 2.3 / 2.4）
    var _names = variable_struct_get_names(_major);
    for (var i = 0; i < array_length(_names); i++) {
        var _name = _names[i];
        var _cnt  = _major[$ _name];
        var _th   = hex_bond_thresholds(_name);
        var _t    = hex_tier_by_count(_cnt, _th);
        _new_tier[$ _name] = _t;
    }

    var _minor_names = variable_struct_get_names(_minor);
    for (var j = 0; j < array_length(_minor_names); j++) {
        var _n2 = _minor_names[j];
        var _c2 = _minor[$ _n2];
        var _th2 = hex_bond_thresholds(_n2);
        _new_tier[$ _n2] = hex_tier_by_count(_c2, _th2);
    }

    // 档位是否发生变动（含新增/消失的分类）
    var _changed = false;
    var _all = variable_struct_get_names(_new_tier);
    for (var k = 0; k < array_length(_all); k++) {
        var _nm = _all[k];
        if (!variable_struct_exists(_prev_tier, _nm)) {
            if (_new_tier[$ _nm] != 0) { _changed = true; break; }
        } else if (_prev_tier[$ _nm] != _new_tier[$ _nm]) {
            _changed = true; break;
        }
    }

    global.bond_tier  = _new_tier;
    global.hex_state.bond_tier = _new_tier;
    global.bond_mult = 1.0;

    // 羁绊是全局加成，卡片的攻击必须重算——buff_apply_id 是既有系统唯一的重算脏标记
    if (_changed && variable_global_exists("buff_apply_id")) global.buff_apply_id += 1;
}

/// @function hex_is_major_name(_name)
/// @desc 是否是大分类名（12 个主共鸣）
function hex_is_major_name(_name) {
    var _majors = ["直射类", "投掷类", "多向类", "增幅类", "产能类", "辅助类",
                   "专业防空类", "喷壶类", "追踪类", "非远程类", "灰烬类", "防御类"];
    return (array_index_of(_majors, _name) != -1);
}

/// @function hex_bond_thresholds(_name)
/// @desc 该分类的三档阈值。按卡片池大小分级，池子小的更容易凑成。
///       「双料锅 / 满席共鸣」会按主/小分类分别降低要求，最低 2 张
function hex_bond_thresholds(_name) {
    var _pool = 0;
    if (variable_global_exists("card_category_index")
        && ds_map_exists(global.card_category_index, _name)) {
        _pool = ds_list_size(ds_map_find_value(global.card_category_index, _name));
    }
    var _th = [2, 3, 4];
    if (_pool >= 25)      _th = [2, 4, 6];
    else if (_pool >= 8)  _th = [2, 3, 5];

    if (hex_enabled() && variable_global_exists("hex_state") && is_struct(global.hex_state)) {
        var _off = hex_is_major_name(_name) ? global.hex_state.bond_req_major
                                            : global.hex_state.bond_req_minor;
        if (_off > 0) {
            _th = [ max(2, _th[0] - _off), max(2, _th[1] - _off), max(2, _th[2] - _off) ];
        }
    }
    return _th;
}

/// @function hex_tier_by_count(_cnt, _th)
/// @desc 按三档阈值判定档位 0/1/2/3。单独成函数，避免链式三元（GML 解析器不支持）
function hex_tier_by_count(_cnt, _th) {
    if (_cnt >= _th[2]) return 3;
    if (_cnt >= _th[1]) return 2;
    if (_cnt >= _th[0]) return 1;
    return 0;
}

/// @function hex_bond_next_threshold(_name)
/// @desc 距离下一档还差多少个不同 card_id（HUD 用「直射 4 / 6」）
function hex_bond_next_threshold(_name) {
    var _th = hex_bond_thresholds(_name);
    var _t  = hex_bond_tier(_name);
    if (_t >= 3) return _th[2];
    return _th[_t];
}

/// @function hex_bond_tier(_name)
function hex_bond_tier(_name) {
    if (!hex_enabled()) return 0;
    if (!variable_global_exists("bond_tier")) return 0;
    if (!variable_struct_exists(global.bond_tier, _name)) return 0;
    return global.bond_tier[$ _name];
}

/// @function hex_bond_count(_name)
function hex_bond_count(_name) {
    if (!hex_enabled()) return 0;
    if (!variable_global_exists("bond_count")) return 0;
    if (!variable_struct_exists(global.bond_count, _name)) return 0;
    return global.bond_count[$ _name];
}

// ══════════════════════ 隔离自检 ══════════════════════

/// @function hex_selfcheck()
/// @desc 隔离回归自检（docs 8 验收标准）。返回违规描述数组，空数组 = 全部通过。
///       用途：切到任一旧模式进关，按 F9 打印，确认海克斯在那四个模式里"完全不存在"。
function hex_selfcheck() {
    var _err = [];

    if (hex_enabled() && hex_level_excluded()) {
        // 测试关卡：整套海克斯必须为零，否则伤害统计不可信
        if (variable_global_exists("hex_mult")) {
            if (abs(global.hex_mult.atk   - 1.0) > 0.0001
             || abs(global.hex_mult.cycle - 1.0) > 0.0001
             || abs(global.hex_mult.hp    - 1.0) > 0.0001) {
                array_push(_err, "测试关卡 hex_mult != 1.0");
            }
        }
        if (variable_global_exists("pi_enemy_mult")
            && abs(global.pi_enemy_mult - 1.0) > 0.0001) {
            array_push(_err, "测试关卡 pi_enemy_mult != 1.0");
        }
        if (hex_taken_count() > 0)          array_push(_err, "测试关卡仍持有词条");
        if (instance_exists(obj_hex_hud))   array_push(_err, "测试关卡存在 HUD 实例");
        if (instance_exists(obj_hex_panel)) array_push(_err, "测试关卡存在选择面板");
        if (hex_place_locked())             array_push(_err, "测试关卡放置被锁");
    } else if (!hex_enabled()) {
        // 四个旧模式：三乘区必须恒 1.0 且存在（undefined 参与乘法会静默变 0）
        if (!variable_global_exists("hex_mult")) {
            array_push(_err, "hex_mult 不存在");
        } else {
            if (abs(global.hex_mult.atk   - 1.0) > 0.0001) array_push(_err, "hex_mult.atk != 1.0");
            if (abs(global.hex_mult.cycle - 1.0) > 0.0001) array_push(_err, "hex_mult.cycle != 1.0");
            if (abs(global.hex_mult.hp    - 1.0) > 0.0001) array_push(_err, "hex_mult.hp != 1.0");
        }
        if (!variable_global_exists("pi_enemy_mult")) array_push(_err, "pi_enemy_mult 不存在");
        else if (abs(global.pi_enemy_mult - 1.0) > 0.0001) array_push(_err, "pi_enemy_mult != 1.0");

        if (!variable_global_exists("bond_mult")) array_push(_err, "bond_mult 不存在");
        else if (abs(global.bond_mult - 1.0) > 0.0001) array_push(_err, "bond_mult != 1.0");

        // 实例侧：HUD / 面板 / 词条列表一律不该存在
        if (instance_exists(obj_hex_hud))    array_push(_err, "非海克斯模式存在 HUD 实例");
        if (instance_exists(obj_hex_panel))  array_push(_err, "非海克斯模式存在选择面板");
        if (instance_exists(obj_hex_list))   array_push(_err, "非海克斯模式存在词条列表");

        // 存档侧：一条都不该写
        if (variable_global_exists("save_data")
            && variable_struct_exists(global.save_data, "hex_unlocked")) {
            if (array_length(global.save_data.hex_unlocked) != 0) {
                array_push(_err, "非海克斯模式写入了 hex_unlocked（"
                               + string(array_length(global.save_data.hex_unlocked)) + " 条）");
            }
        }
    } else {
        // 海克斯模式：库、状态、倍率出口都不能是 undefined
        if (!variable_global_exists("hex_db")) array_push(_err, "hex_db 未初始化");
        else if (array_length(global.hex_ids) != 111) {
            array_push(_err, "词条条数 " + string(array_length(global.hex_ids)) + " != 111");
        }
        if (!variable_global_exists("hex_state") || !is_struct(global.hex_state)) {
            array_push(_err, "hex_state 未建立");
        } else if (!variable_struct_exists(global.hex_state, "persist")) {
            array_push(_err, "hex_state 缺少 persist 字段（已解锁词条不会永久生效）");
        } else if (hex_unlocked_total() > 0 && array_length(global.hex_state.persist) == 0) {
            array_push(_err, "存档有 " + string(hex_unlocked_total()) + " 条已解锁，本局却一条永久词条都没并入");
        }
        if (hex_taken_count() > hex_cfg().max_hex) {
            array_push(_err, "本局词条数超过上限 " + string(hex_cfg().max_hex));
        }

        // 每张卡读倍率都必须拿到正数
        with (obj_card_parent) {
            if (self.plant_id != "") {
                var _a = hex_atk_mult_for_card(self.plant_id);
                var _c = hex_cycle_mult_for_card(self.plant_id);
                var _h = hex_hp_mult_for_card(self.plant_id);
                if (!(_a > 0) || !(_c > 0) || !(_h > 0)) {
                    array_push(_err, "卡片倍率非正: " + self.plant_id
                                   + " atk=" + string(_a) + " cycle=" + string(_c) + " hp=" + string(_h));
                }
            }
        }
    }

    return _err;
}

/// @function hex_selfcheck_report()
/// @desc 把自检结果打到调试控制台，返回是否全部通过
function hex_selfcheck_report() {
    var _r = hex_selfcheck();
    var _tag = "旧模式";
    if (hex_enabled()) _tag = hex_level_excluded() ? "海克斯模式·测试关卡" : "海克斯模式";
    show_debug_message("════ 海克斯隔离自检 · " + _tag + " ════");
    if (array_length(_r) == 0) {
        show_debug_message("通过：0 项违规");
        return true;
    }
    for (var i = 0; i < array_length(_r); i++) {
        show_debug_message("✗ " + string(_r[i]));
    }
    return false;
}
