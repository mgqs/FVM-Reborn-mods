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
        drop_rate:        0.0005,  // 敌人掉率（0.05%）
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
        cat_hp:          {},      // 分类名 -> 生命倍率

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

        // ══════════ 机制层（v0.11 起，词条表重写后新增的通道）══════════
        // 卡片伤害
        crit_chance:     0,       // 暴击概率
        crit_mult:       1.5,     // 暴击倍率
        anti_air:        0,       // 对空中目标伤害增量
        slow_bonus:      0,       // 对被减速老鼠伤害增量
        atk_floor:       0,       // 攻击力下限比例（相对 base_atk）
        range_cut:       0,       // 卡片受到的范围伤害减免
        atk_per_speed:   0,       // 攻速加成转攻击（1.0 = 1:1）
        card_death_pct:  0,       // 卡片被摧毁时对全场老鼠造成攻击的倍数
        other_atk:       0,       // 非「天选之卡」卡片的攻击增量（负）
        top_card_id:     "",      // 「天选之卡」指向的卡片 id
        top_card_atk:    1.0,     // 该卡攻击倍率
        top_card_cycle:  0,       // 该卡攻速增量

        // 动态攻击（读场上结构）
        first_col_atk:   0,       // 每行最左侧卡片攻击增量
        field_need:      0,       // 场上卡数门槛
        field_need_atk:  0,       // 达标后的攻击增量
        borrow_per:      0,       // 每张增幅类给全队的攻击增量
        borrow_cap:      0,       // 上面封顶
        borrow_count:    0,       // 场上增幅类张数（hex_bond_recalc 维护）
        minor_stack_atk: 0,       // 同小分类每多一张彼此攻击增量
        deck_theme_size: 0,       // 「精简菜单」卡组张数条件
        deck_theme_atk:  0,       // 命中后的攻击增量
        deck_per_size:   0,       // 「满汉全席」卡组张数条件
        deck_per_atk:    0,       // 命中后每张卡的攻击增量
        ash_mix_atk:     0,       // 同时有灰烬与非灰烬时的攻击增量
        min_cat_atk:     0,       // 数量最少分类的攻击增量
        min_cat_name:    "",      // 数量最少的分类名（hex_bond_recalc 维护）
        pair_a:          "",      // 「一锅两吃」的两个分类
        pair_b:          "",
        pair_atk:        0,
        near_cycle_on:   false,   // 「逆火」：敌人贴近时该行卡片加速
        near_cycle_add:  0,       // 加速幅度（负值 = 间隔变短）
        near_cycle_range: 3,      // 判定的格数

        // 火苗 / 续航
        wave_flame_cap:  0,       // 「每波转火苗」的封顶
        heal_tick_pct:   0,       // 每 heal_tick_sec 秒回复最大生命的比例
        heal_tick_sec:   10,
        prod_bonus:      0,       // 产能类每次产出额外火苗
        cap_fixed:       0,       // 火苗上限固定值（>0 生效）
        cap_half:        false,   // 火苗上限减半
        cap_unbound:     false,   // 火苗无上限
        flame_gain_used: 0,       // 调试：已发放的定时火苗

        // 经济 / 放置
        refund_chance:   0,       // 放置时概率全额返还
        deck_cap:        0,       // 卡组上限增量
        zero_cd:         false,   // 卡片冷却归零
        zero_cd_cost:    1.0,     // 但费用倍率
        zero_cd_flame:   0,       // 每次使用后损失当前火苗的比例
        same_card_free:  false,   // 每波内第 2 次放置同名卡免费
        same_card_used:  false,
        same_card_last:  "",      // 本波最后放置的卡 id（同名判定用）
        terrain_free:    false,   // 任意地形可放置
        prep_bonus:      0,       // 每波额外布阵秒数

        // 周期效果
        nuke_sec:        0,       // 每 N 秒全屏火焰
        nuke_pct:        0,       // 伤害 = 全队攻击总和 × 该比例
        nuke_timer:      0,
        burn_sec:        0,       // 每 N 秒全场灼烧
        burn_pct:        0,       // 伤害 = 目标最大生命 × 该比例
        burn_timer:      0,

        // 波次
        wave_clear_flame: 0,      // 整波零损时给的额外火苗
        wave_clear_atk:   0,      // 整波零损时下波攻击增量
        wave_clear_cap:   0,      // 上面的叠加上限
        wave_clear_stacks: 0,
        wave_card_lost:   false,  // 本波是否有卡片被摧毁（hex_bond_recalc 之外的独立标记）

        // 击杀
        elite_atk:       0,       // 每击破一个精英给全队的攻击增量
        elite_cap:       0,       // 层数上限
        elite_stacks:    0,
        elite_seen_wave: -1,      // 已结算过的精英波，避免重复加层
        no_revive_chance: 0,      // 击杀后禁止复活/召唤的概率

        // 增幅
        buff_grant:      1.0,     // 增幅类卡片提供的倍率增量（乘在 buff 增益上）

        // 星级
        star_start:      0,       // 开局全体卡 +N 星
        star_random:     0,       // 开局随机 N 张卡 +1 星
        star_wave:       0,       // 每波随机 N 张卡 +1 星

        // 灰烬
        ash_explode:     false,   // 灰烬类死亡 3×3 爆炸
        ash_revive:      false,   // 灰烬类死亡 5 秒复活一次
        ash_blast:       0,       // 灰烬类死亡时对全场造成攻击的倍数

        // 老鼠侧
        e_bite:          1.0,     // 啃咬速度倍率（<1 更快）
        e_hp_air:        1.0,     // 空中老鼠生命
        e_hp_dive:       1.0,     // 潜水鼠生命
        e_hp_ground:     1.0,     // 地面老鼠生命
        e_hp_block:      1.0,     // 障碍类老鼠生命
        e_max_cards:     0,       // 场上美食数量上限（>0 生效）
        e_card_insta:    0,       // 卡片受伤时立即死亡的概率
        e_respawn:       0,       // 老鼠死亡时原地重生的概率
        e_card_blast:    false,   // 卡片被击杀时对 3×3 卡片造成等量伤害
        e_card_drain:    0,       // 卡片受伤后额外扣除的最大生命比例
        e_self_destruct: 0,       // 老鼠残血自爆概率
        e_no_revive:     false,   // 老鼠不能被复活/召唤
        e_mole_no_stun:  false,   // 地鼠出土立即行动
        e_slow_resist:   0,       // 减速抗性
        e_no_cat:        false,   // 禁用猫
        heal_tick_frame: 0,       // 定时回血计时（帧）

        // 羁绊
        bond_count:      {},      // 分类名 -> 不同 card_id 计数
        bond_tier:       {},      // 分类名 -> 已达成档位（0 表示未达成）
        bond_minor_extra: 0       // 每张卡额外计入的相邻小分类数（「一菜三吃」）
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
    if (variable_struct_exists(_d.ex, "cat_hp")) {
        var _ch = _d.ex.cat_hp;
        for (var ci = 0; ci < array_length(_ch); ci++) {
            var _cc = _ch[ci][0];
            var _cur3 = variable_struct_exists(_s.cat_hp, _cc) ? _s.cat_hp[$ _cc] : 1.0;
            _s.cat_hp[$ _cc] = _cur3 * (1 + _ch[ci][1]);
        }
    }

    // ══════════ v0.11 新增机制通道 ══════════
    // 卡片伤害
    if (variable_struct_exists(_d.ex, "crit")) {
        var _cr = _d.ex.crit;
        _s.crit_chance += _cr[0];
        _s.crit_mult    = max(_s.crit_mult, _cr[1]);
    }
    if (variable_struct_exists(_d.ex, "anti_air"))      _s.anti_air      += _d.ex.anti_air;
    if (variable_struct_exists(_d.ex, "slow_bonus"))    _s.slow_bonus    += _d.ex.slow_bonus;
    if (variable_struct_exists(_d.ex, "atk_floor"))     _s.atk_floor      = max(_s.atk_floor, _d.ex.atk_floor);
    if (variable_struct_exists(_d.ex, "range_cut"))     _s.range_cut     += _d.ex.range_cut;
    if (variable_struct_exists(_d.ex, "atk_per_speed")) _s.atk_per_speed += _d.ex.atk_per_speed;
    if (variable_struct_exists(_d.ex, "card_death_pct")) _s.card_death_pct += _d.ex.card_death_pct;
    if (variable_struct_exists(_d.ex, "other_atk"))     _s.other_atk     += _d.ex.other_atk;

    if (variable_struct_exists(_d.ex, "top_card_atk")) {
        var _tc = _d.ex.top_card_atk;
        // 同一张卡只能被「天选之卡」指一次；多张时取最高的那张（后面在 recalc 里按攻击排序挑）
        _s.top_card_atk   = _tc[0];
        _s.top_card_cycle += _tc[1];
        _s.top_card_id    = "@top";
    }

    // 动态攻击
    if (variable_struct_exists(_d.ex, "first_col_atk"))  _s.first_col_atk  += _d.ex.first_col_atk;
    if (variable_struct_exists(_d.ex, "minor_stack_atk")) _s.minor_stack_atk += _d.ex.minor_stack_atk;
    if (variable_struct_exists(_d.ex, "ash_mix_atk"))    _s.ash_mix_atk    += _d.ex.ash_mix_atk;
    if (variable_struct_exists(_d.ex, "min_cat_atk"))    _s.min_cat_atk    += _d.ex.min_cat_atk;
    if (variable_struct_exists(_d.ex, "field_need_atk")) {
        var _fn = _d.ex.field_need_atk;
        _s.field_need     = max(_s.field_need, _fn[0]);
        _s.field_need_atk += _fn[1];
    }
    if (variable_struct_exists(_d.ex, "borrow_atk")) {
        var _bw = _d.ex.borrow_atk;
        _s.borrow_per += _bw[0];
        _s.borrow_cap += _bw[1];
    }
    if (variable_struct_exists(_d.ex, "deck_theme_atk")) {
        var _dt = _d.ex.deck_theme_atk;
        _s.deck_theme_size = max(_s.deck_theme_size, _dt[0]);
        _s.deck_theme_atk += _dt[1];
    }
    if (variable_struct_exists(_d.ex, "deck_per_atk")) {
        var _dp = _d.ex.deck_per_atk;
        _s.deck_per_size = max(_s.deck_per_size, _dp[0]);
        _s.deck_per_atk += _dp[1];
    }
    if (variable_struct_exists(_d.ex, "pair_atk")) {
        var _pt = _d.ex.pair_atk;
        _s.pair_a = _pt[0][0];
        _s.pair_b = _pt[0][1];
        _s.pair_atk += _pt[1];
    }
    if (variable_struct_exists(_d.ex, "near_cycle")) {
        var _nc = _d.ex.near_cycle;
        _s.near_cycle_on    = true;
        _s.near_cycle_add  += _nc[0];
        _s.near_cycle_range = max(_s.near_cycle_range, _nc[1]);
    }

    // 火苗 / 续航
    if (variable_struct_exists(_d.ex, "wave_flame_cap")) _s.wave_flame_cap += _d.ex.wave_flame_cap;
    if (variable_struct_exists(_d.ex, "prod_bonus"))     _s.prod_bonus     += _d.ex.prod_bonus;
    if (variable_struct_exists(_d.ex, "heal_tick")) {
        var _ht = _d.ex.heal_tick;
        _s.heal_tick_pct += _ht[0];
        if (_s.heal_tick_pct > 0) _s.heal_tick_sec = min(_s.heal_tick_sec, _ht[1]);
    }
    if (variable_struct_exists(_d.ex, "cap_fixed"))  _s.cap_fixed  = max(_s.cap_fixed, _d.ex.cap_fixed);
    if (variable_struct_exists(_d.ex, "cap_half"))   _s.cap_half   = true;
    if (variable_struct_exists(_d.ex, "cap_unbound")) _s.cap_unbound = true;

    // 经济 / 放置
    if (variable_struct_exists(_d.ex, "refund_chance")) _s.refund_chance += _d.ex.refund_chance;
    if (variable_struct_exists(_d.ex, "deck_cap"))      _s.deck_cap      += _d.ex.deck_cap;
    if (variable_struct_exists(_d.ex, "terrain_free"))  _s.terrain_free   = true;
    if (variable_struct_exists(_d.ex, "same_card_free")) _s.same_card_free = true;
    if (variable_struct_exists(_d.ex, "prep_bonus"))    _s.prep_bonus    += _d.ex.prep_bonus;
    if (variable_struct_exists(_d.ex, "zero_cd")) {
        var _zc = _d.ex.zero_cd;
        _s.zero_cd      = true;
        _s.zero_cd_cost *= _zc[0];
        _s.zero_cd_flame = max(_s.zero_cd_flame, _zc[1]);
    }

    // 周期
    if (variable_struct_exists(_d.ex, "nuke")) { var _nk = _d.ex.nuke; _s.nuke_sec = max(_s.nuke_sec, _nk[0]); _s.nuke_pct += _nk[1]; }
    if (variable_struct_exists(_d.ex, "burn")) { var _bu = _d.ex.burn; _s.burn_sec = max(_s.burn_sec, _bu[0]); _s.burn_pct += _bu[1]; }

    // 波次零损
    if (variable_struct_exists(_d.ex, "wave_clear_flame")) {
        var _wc = _d.ex.wave_clear_flame;
        _s.wave_clear_flame += _wc[0];
        _s.wave_clear_atk   += _wc[1];
        _s.wave_clear_cap   += _wc[2];
    }

    // 击杀
    if (variable_struct_exists(_d.ex, "elite_atk")) {
        var _ea = _d.ex.elite_atk;
        _s.elite_atk  += _ea[0];
        _s.elite_cap  += _ea[1];
    }
    if (variable_struct_exists(_d.ex, "no_revive")) _s.no_revive_chance += _d.ex.no_revive;

    // 增幅 / 星级 / 灰烬
    if (variable_struct_exists(_d.ex, "buff_grant")) _s.buff_grant *= (1 + _d.ex.buff_grant);
    if (variable_struct_exists(_d.ex, "star_start"))  _s.star_start  += _d.ex.star_start;
    if (variable_struct_exists(_d.ex, "star_random")) _s.star_random += _d.ex.star_random;
    if (variable_struct_exists(_d.ex, "star_wave"))   _s.star_wave   += _d.ex.star_wave;
    if (variable_struct_exists(_d.ex, "ash_explode")) _s.ash_explode = true;
    if (variable_struct_exists(_d.ex, "ash_revive"))  _s.ash_revive  = true;
    if (variable_struct_exists(_d.ex, "ash_blast"))   _s.ash_blast  += _d.ex.ash_blast;
    if (variable_struct_exists(_d.ex, "bond_extra_minor")) _s.bond_minor_extra += _d.ex.bond_extra_minor;

    // ---- 老鼠侧 ----
    if (variable_struct_exists(_d.en, "e_hp"))    _s.e_hp    *= (1 + _d.en.e_hp);
    if (variable_struct_exists(_d.en, "e_spd"))   _s.e_spd   *= (1 + _d.en.e_spd);
    if (variable_struct_exists(_d.en, "e_atk"))   _s.e_atk   *= (1 + _d.en.e_atk);
    if (variable_struct_exists(_d.en, "e_count")) _s.e_count *= (1 + _d.en.e_count);
    if (variable_struct_exists(_d.en, "e_bite"))  _s.e_bite  *= (1 + _d.en.e_bite);
    if (variable_struct_exists(_d.en, "e_hp_air"))   _s.e_hp_air   *= (1 + _d.en.e_hp_air);
    if (variable_struct_exists(_d.en, "e_hp_dive"))  _s.e_hp_dive  *= (1 + _d.en.e_hp_dive);
    if (variable_struct_exists(_d.en, "e_hp_ground")) _s.e_hp_ground *= (1 + _d.en.e_hp_ground);
    if (variable_struct_exists(_d.en, "e_hp_block")) _s.e_hp_block *= (1 + _d.en.e_hp_block);
    if (variable_struct_exists(_d.en, "e_max_cards")) _s.e_max_cards = max(_s.e_max_cards, _d.en.e_max_cards);
    if (variable_struct_exists(_d.en, "e_card_insta")) _s.e_card_insta = max(_s.e_card_insta, _d.en.e_card_insta);
    if (variable_struct_exists(_d.en, "e_respawn"))    _s.e_respawn    = max(_s.e_respawn, _d.en.e_respawn);
    if (variable_struct_exists(_d.en, "e_card_blast")) _s.e_card_blast = true;
    if (variable_struct_exists(_d.en, "e_card_drain")) _s.e_card_drain = max(_s.e_card_drain, _d.en.e_card_drain);
    if (variable_struct_exists(_d.en, "e_self_destruct")) _s.e_self_destruct = max(_s.e_self_destruct, _d.en.e_self_destruct);
    if (variable_struct_exists(_d.en, "e_no_revive"))  _s.e_no_revive  = true;
    if (variable_struct_exists(_d.en, "e_mole_no_stun")) _s.e_mole_no_stun = true;
    if (variable_struct_exists(_d.en, "e_slow_resist")) _s.e_slow_resist += _d.en.e_slow_resist;
    if (variable_struct_exists(_d.en, "e_no_cat"))     _s.e_no_cat     = true;

    // 第二批（hex_112 ~ hex_184）的机制字段，实现在 scripts/hex_batch2
    hex_batch2_apply(_d);

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
    var _m = global.hex_mult.atk
           * hex_category_mult(_plant_id, "cat_atk")
           * hex_bond_atk_mult(_plant_id)
           * (1 + hex_dyn_atk_bonus(_plant_id))
           * hex_atk_per_speed_mult(_plant_id)
           * hex_top_card_atk_mult(_plant_id)
           * hex_batch2_id_atk(_plant_id)
           * hex_batch2_atk_factor(_plant_id);
    if (variable_global_exists("hex_state") && is_struct(global.hex_state)
        && global.hex_state.other_atk != 0 && !hex_is_top_card(_plant_id)) {
        _m *= (1 + global.hex_state.other_atk);
    }
    return _m;
}

/// @function hex_cycle_mult_for_card(_plant_id)
function hex_cycle_mult_for_card(_plant_id) {
    if (!hex_enabled()) return 1.0;
    if (!variable_global_exists("hex_mult")) return 1.0;
    var _m = global.hex_mult.cycle
           * hex_category_mult(_plant_id, "cat_cycle")
           * hex_bond_mult_for_card(_plant_id, "cycle")
           * hex_top_card_cycle_mult(_plant_id)
           * hex_batch2_id_cycle(_plant_id)
           * hex_batch2_cycle_factor(_plant_id);
    return clamp(_m, 0.05, 4.0);
}

/// @function hex_hp_mult_for_card(_plant_id)
function hex_hp_mult_for_card(_plant_id) {
    if (!hex_enabled()) return 1.0;
    if (!variable_global_exists("hex_mult")) return 1.0;
    var _m = global.hex_mult.hp * hex_bond_mult_for_card(_plant_id, "hp");
    if (variable_global_exists("hex_state") && is_struct(global.hex_state)
        && variable_struct_exists(global.hex_state, "cat_hp")) {
        var _cat = card_get_category(_plant_id);
        if (!is_undefined(_cat)) {
            var _ch = global.hex_state.cat_hp;
            if (variable_struct_exists(_ch, _cat.major)) _m *= _ch[$ _cat.major];
            if (variable_struct_exists(_ch, _cat.minor)) _m *= _ch[$ _cat.minor];
        }
    }
    return _m;
}

/// @function hex_is_top_card(_plant_id)
/// @desc 「天选之卡」指向的是场上攻击力最高的那张卡的 card_id（对局内没有选卡界面，
///       所以一律自动指向，规则与「招牌菜」的自动指向一致）
function hex_is_top_card(_plant_id) {
    if (!hex_enabled()) return false;
    if (!variable_global_exists("hex_state") || !is_struct(global.hex_state)) return false;
    if (!variable_struct_exists(global.hex_state, "top_card_id")) return false;
    var _t = global.hex_state.top_card_id;
    if (_t == "" || _t == "@top") return false;
    return (_plant_id == _t);
}

/// @function hex_top_card_atk_mult(_plant_id)
function hex_top_card_atk_mult(_plant_id) {
    if (!hex_is_top_card(_plant_id)) return 1.0;
    return global.hex_state.top_card_atk;
}

/// @function hex_top_card_cycle_mult(_plant_id)
function hex_top_card_cycle_mult(_plant_id) {
    if (!hex_is_top_card(_plant_id)) return 1.0;
    return max(0.2, 1 + global.hex_state.top_card_cycle);
}

/// @function hex_atk_per_speed_mult(_plant_id)
/// @desc 「复制食谱」：每 1% 攻速加成换 1% 攻击。
///       攻速只算海克斯给出的那一部分（hex 全局间隔 × 分类间隔），不掺本体数值，
///       否则会跟卡片自身攻速叠成指数。
function hex_atk_per_speed_mult(_plant_id) {
    if (!hex_enabled()) return 1.0;
    if (!variable_global_exists("hex_state") || !is_struct(global.hex_state)) return 1.0;
    var _k = global.hex_state.atk_per_speed;
    if (_k <= 0) return 1.0;
    if (!variable_global_exists("hex_mult")) return 1.0;
    var _cyc = global.hex_mult.cycle * hex_category_mult(_plant_id, "cat_cycle");
    if (_cyc <= 0) return 1.0;
    // 攻速加成 = 1/间隔倍率 - 1
    var _spd = (1 / _cyc) - 1;
    if (_spd <= 0) return 1.0;
    return (1 + _spd * _k);
}

/// @function hex_near_cycle_hit(_col, _row, _range)
/// @desc 「逆火」：该格前方 _range 格内是否有老鼠。
///       调用点必须在卡片实例上下文里（obj_mod_battle_manager 的 with (obj_card_parent)），
///       由它把结果乘进 cycle —— 这里刻意不放进 hex_cycle_mult_for_card，
///       因为那个函数只拿到 card_id，拿不到坐标，放进去会退化成"全局生效"。
function hex_near_cycle_hit(_col, _row, _range) {
    if (!hex_enabled()) return false;
    if (!variable_global_exists("hex_state") || !is_struct(global.hex_state)) return false;
    if (!variable_struct_exists(global.hex_state, "near_cycle_on")) return false;
    if (!global.hex_state.near_cycle_on) return false;
    var _hit = false;
    with (obj_enemy_parent) {
        if (hp > 0 && grid_row == _row && grid_col <= _col + _range && grid_col >= _col - 1) _hit = true;
    }
    return _hit;
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
        case "hp":  _v = clamp(_s.e_hp,  0.30, 4.0) * hex_batch2_enemy_hp_extra(); break;
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
/// @desc 把「火苗上限」类词条写进 flame_cap_base。
///       必须用「目标值整体重算」而不是差值累加：永久词条每局都会重新并入，
///       累加式写法会让上限每进一关涨一次。
///       优先级：固定值（破釜沉舟 500） > 无上限（无限续杯） > 基础 + 增量 > 减半（赌徒）
function hex_sync_flame_cap() {
    var _add     = 0;
    var _fixed   = 0;
    var _half    = false;
    var _unbound = false;

    if (hex_enabled() && variable_global_exists("hex_state") && is_struct(global.hex_state)) {
        var _s = global.hex_state;
        if (variable_struct_exists(_s, "flame_cap"))  _add     = _s.flame_cap;
        if (variable_struct_exists(_s, "cap_fixed"))  _fixed   = _s.cap_fixed;
        if (variable_struct_exists(_s, "cap_half"))   _half    = _s.cap_half;
        if (variable_struct_exists(_s, "cap_unbound")) _unbound = _s.cap_unbound;
    }

    var _target = 15000 + _add;
    if (_unbound) _target = 99999999;
    if (_fixed > 0) _target = _fixed;
    if (_half) _target = _target * 0.5;
    _target = max(2000, round(_target));

    if (variable_global_exists("flame_cap_base") && global.flame_cap_base == _target) return;
    global.flame_cap_base = _target;
    if (!variable_global_exists("hex_flame_cap_applied")) global.hex_flame_cap_applied = 0;
    global.hex_flame_cap_applied = _target - 15000;
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
    var _c = global.hex_state.cost;
    // 火候观察：冷却归零的代价是费用乘数（默认 x5）
    if (global.hex_state.zero_cd) _c *= global.hex_state.zero_cd_cost;
    return clamp(_c, 0.1, 12.0);
}

/// @function hex_gridless_for_card(_card_id)
/// @desc 该卡是否因为海克斯而不占格（增幅类 / 辅助类）
function hex_gridless_for_card(_card_id) {
    if (!hex_enabled()) return false;
    if (!variable_global_exists("hex_state")) return false;
    if (!is_struct(global.hex_state)) return false;
    if (!variable_struct_exists(global.hex_state, "gridless")) return false;
    if (!global.hex_state.gridless) return false;
    var _c = card_get_category(_card_id);
    if (is_undefined(_c)) return false;
    return (_c.major == "增幅类" || _c.major == "辅助类");
}

/// @function hex_effective_plant_type(_card_id, _base_type)
/// @desc 海克斯「悬浮厨房」：增幅类 / 辅助类按「不占格」处理。
///       做法与海洋女神四转（shape>=1）、战旗马一转完全一致 —— 直接把 plant_type
///       折算成 "gridless"，交给 can_place_at_position 里既有的 case "gridless" 统一放行，
///       不再另开一条并行分支（并行分支会漏掉底座、玩家占格、深度排序这些既有约定）。
function hex_effective_plant_type(_card_id, _base_type) {
    if (_base_type == "gridless") return _base_type;
    if (hex_gridless_for_card(_card_id)) return "gridless";
    return _base_type;
}

/// @function hex_fmt_pct(_v)
/// @desc 把倍率格式化成 +12% / -8%（v 是乘数，不是增量）
function hex_fmt_pct(_v) {
    var _n = round((_v - 1) * 100);
    if (_n > 0) return "+" + string(_n) + "%";
    if (_n == 0) return "0%";
    return string(_n) + "%";
}

/// @function hex_fmt_flat(_v)
function hex_fmt_flat(_v) {
    var _n = round(_v);
    if (_n > 0) return "+" + string(_n);
    return string(_n);
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

    // 第二批：每 N 击杀重置一张卡的冷却（跨接电缆）
    hex_batch2_on_kill();
}

/// @function hex_card_count()
/// @desc 场上卡片数（不含玩家本体）。hex_bond_recalc 每 15 帧维护
function hex_card_count() {
    if (!hex_enabled()) return 0;
    if (!variable_global_exists("hex_state")) return 0;
    return global.hex_state.card_on_field;
}

/// @function hex_dyn_atk_bonus(_plant_id)
/// @desc 动态攻击增量：场上卡数 / 顶级分类 / 击杀层数 / 精英层数 / 借味 / 蒸笼叠层 /
///       中央厨房 / 卡组结构 / 双味锅 / 主厨推荐 / 一锅两吃。返回「增量」，不是倍率。
///       注意：「每行最左侧 +X%」（双灶并行）需要坐标，放在 obj_mod_battle_manager 里乘，
///       这里不做，否则会退化成全队加成。
function hex_dyn_atk_bonus(_plant_id) {
    if (!hex_enabled()) return 0;
    if (!variable_global_exists("hex_state")) return 0;
    var _s = global.hex_state;
    var _add = 0;
    var _cat = card_get_category(_plant_id);

    if (_s.per_card_atk > 0) {
        _add += min(_s.per_card_atk * hex_card_count(), _s.per_card_cap);
    }
    if (_s.top_atk > 0 && _s.top_minor != "") {
        if (!is_undefined(_cat) && _cat.minor == _s.top_minor) _add += _s.top_atk;
    }
    if (_s.kill_stack && _s.kill_stacks > 0) {
        _add += _s.kill_stack_atk * _s.kill_stacks;
    }
    if (_s.elite_atk > 0 && _s.elite_stacks > 0) {
        _add += _s.elite_atk * _s.elite_stacks;
    }
    if (_s.borrow_per > 0 && _s.borrow_count > 0) {
        _add += min(_s.borrow_per * _s.borrow_count, _s.borrow_cap);
    }
    if (_s.minor_stack_atk > 0 && !is_undefined(_cat)) {
        var _n = hex_minor_inst_count(_cat.minor);
        if (_n > 1) _add += _s.minor_stack_atk * (_n - 1);
    }
    if (_s.field_need > 0 && hex_card_count() >= _s.field_need) {
        _add += _s.field_need_atk;
    }
    if (_s.wave_clear_atk > 0 && _s.wave_clear_stacks > 0) {
        _add += _s.wave_clear_atk * _s.wave_clear_stacks;
    }

    // ── 卡组结构类 ──
    var _deck = hex_deck_count();
    if (_s.deck_theme_size > 0 && _deck == _s.deck_theme_size) _add += _s.deck_theme_atk;
    if (_s.deck_per_size > 0 && _deck >= _s.deck_per_size) _add += _s.deck_per_atk;
    if (_s.ash_mix_atk > 0 && hex_has_ash_mix()) _add += _s.ash_mix_atk;
    if (_s.min_cat_atk > 0 && _s.min_cat_name != "" && !is_undefined(_cat)) {
        if (_cat.minor == _s.min_cat_name) _add += _s.min_cat_atk;
    }
    // 「一锅两吃」：直射类与投掷类同时在场时两者各 +X%
    if (_s.pair_atk > 0 && _s.pair_a != "" && !is_undefined(_cat)) {
        if ((_cat.major == _s.pair_a || _cat.major == _s.pair_b)
            && hex_has_major(_s.pair_a) && hex_has_major(_s.pair_b)) {
            _add += _s.pair_atk;
        }
    }
    return _add;
}

/// @function hex_minor_inst_count(_name)
/// @desc 场上某个小分类的「实例数」（含同名多张）。hex_bond_recalc 每 15 帧维护
function hex_minor_inst_count(_name) {
    if (!variable_global_exists("hex_minor_inst") || !is_struct(global.hex_minor_inst)) return 0;
    if (!variable_struct_exists(global.hex_minor_inst, _name)) return 0;
    return global.hex_minor_inst[$ _name];
}

/// @function hex_has_major(_name)
function hex_has_major(_name) {
    if (!hex_enabled()) return false;
    if (!variable_global_exists("hex_state") || !is_struct(global.hex_state)) return false;
    var _c = global.hex_state.bond_count;
    if (!is_struct(_c)) return false;
    if (!variable_struct_exists(_c, _name)) return false;
    return (_c[$ _name] > 0);
}

/// @function hex_has_ash_mix()
/// @desc 场上同时存在灰烬类与非灰烬类
function hex_has_ash_mix() {
    if (!hex_enabled()) return false;
    if (!variable_global_exists("hex_state") || !is_struct(global.hex_state)) return false;
    var _ash = hex_has_major("灰烬类");
    if (!_ash) return false;
    var _names = variable_struct_get_names(global.hex_state.bond_count);
    for (var i = 0; i < array_length(_names); i++) {
        if (_names[i] != "灰烬类" && global.hex_state.bond_count[$ _names[i]] > 0) return true;
    }
    return false;
}

/// @function hex_deck_count()
/// @desc 本局卡组的实际卡片张数（跳过空槽）。卡组结构类词条都用它
function hex_deck_count() {
    if (!variable_global_exists("selected_deck")) return 0;
    if (!ds_exists(global.selected_deck, ds_type_list)) return 0;
    var _n = 0;
    var _len = ds_list_size(global.selected_deck);
    for (var i = 0; i < _len; i++) {
        var _e = global.selected_deck[| i];
        if (!is_struct(_e)) continue;
        if (!variable_struct_exists(_e, "card_id")) continue;
        if (_e.card_id != "") _n++;
    }
    return _n;
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
    var _minor_inst = {}; // 小分类 -> 实例数（含同名多张）
    var _inst  = 0;       // 场上卡片实例数（含同名多张）
    var _borrow = 0;      // 场上增幅类实例数（「借味」）
    var _top_id = "";
    var _top_atk = -1;

    with (obj_card_parent) {
        if (self.plant_id == "player") continue;
        _inst += 1;

        var _cat0 = card_get_category(self.plant_id);
        if (!is_undefined(_cat0)) {
            if (_cat0.major == "增幅类") _borrow += 1;
            var _mn0 = _cat0.minor;
            if (_mn0 != "") _minor_inst[$ _mn0] = (variable_struct_exists(_minor_inst, _mn0) ? _minor_inst[$ _mn0] : 0) + 1;
        }
        // 「天选之卡」自动指向场上攻击力最高的那张（对局内没有选卡界面）
        if (!variable_instance_exists(self.id, "atk")) {
            // 没有 atk 的卡（玩家本体等）不参与
        } else if (self.atk > _top_atk) {
            _top_atk = self.atk;
            _top_id  = self.plant_id;
        }

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
    global.hex_state.borrow_count  = _borrow;
    global.hex_minor_inst          = _minor_inst;

    // 「天选之卡」：只在持有这个词条时才写入 id
    if (global.hex_state.top_card_atk != 1.0 || global.hex_state.other_atk != 0) {
        global.hex_state.top_card_id = _top_id;
    }

    // 数量最多的小分类（「招牌菜」用）。同数取先出现的，结果稳定
    var _top_n = "";
    var _top_c = 0;
    var _min_n = "";
    var _min_c = 9999;
    var _mn = variable_struct_get_names(_minor);
    for (var ti = 0; ti < array_length(_mn); ti++) {
        var _tc = _minor[$ _mn[ti]];
        if (_tc > _top_c) { _top_c = _tc; _top_n = _mn[ti]; }
        if (_tc < _min_c) { _min_c = _tc; _min_n = _mn[ti]; }
    }
    global.hex_state.top_minor = _top_n;
    global.hex_state.min_cat_name = _min_n;

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
        else if (array_length(global.hex_ids) != 174) {
            array_push(_err, "词条条数 " + string(array_length(global.hex_ids)) + " != 174");
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

        // 第二批机制状态：惰性补齐没跑过的话所有 b2_* 出口都会读不到字段
        if (!hex_batch2_ensure()) {
            array_push(_err, "hex_batch2 状态未建立（第二批词条全部失效）");
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

/// @function hex_effect_rows()
/// @desc 「效果」面板的数据源：把当前真正生效的加成整理成两栏（card / enemy）。
///       数值全部从 hex_state 与 global 出口现读，和战斗里实际用的那一份同源，
///       不另外维护一张说明表 —— 否则文案迟早和实现脱节。
function hex_effect_rows() {
    var _card  = [];
    var _enemy = [];
    if (!hex_enabled()) return { card: _card, enemy: _enemy };
    if (!variable_global_exists("hex_state") || !is_struct(global.hex_state)) {
        return { card: _card, enemy: _enemy };
    }
    var _s = global.hex_state;

    // ══════════ 卡片侧 ══════════
    // 倍率部分读 global.hex_mult（已经过夹逼，就是卡片实际吃到的值）
    if (variable_global_exists("hex_mult")) {
        array_push(_card, { label: "全队攻击",   value: hex_fmt_pct(global.hex_mult.atk),   tag: "攻击" });
        array_push(_card, { label: "全队生命",   value: hex_fmt_pct(global.hex_mult.hp),    tag: "生命" });
        array_push(_card, { label: "攻击间隔",   value: hex_fmt_pct(global.hex_mult.cycle), tag: "间隔" });
    }

    // 火苗
    if (_s.flame_start    != 0) array_push(_card, { label: "开局火苗",   value: hex_fmt_flat(_s.flame_start), tag: "火苗" });
    if (_s.flame_wave     != 0) array_push(_card, { label: "每波火苗",   value: hex_fmt_flat(_s.flame_wave),  tag: "火苗" });
    if (_s.flame_cap      != 0) array_push(_card, { label: "火苗上限",   value: hex_fmt_flat(_s.flame_cap),   tag: "火苗" });
    if (_s.flame_growth   != 1.0) array_push(_card, { label: "火苗获取", value: hex_fmt_pct(_s.flame_growth), tag: "火苗" });
    if (_s.wave_flame_pct != 0) array_push(_card, { label: "每波转火苗", value: string(round(_s.wave_flame_pct * 100)) + "%", tag: "火苗" });
    if (_s.flame_tick     != 0) array_push(_card, { label: "定时火苗",   value: "+" + string(round(_s.flame_tick)) + " / " + string(round(_s.flame_tick_sec)) + "秒", tag: "火苗" });
    if (_s.heal_wave      != 0) array_push(_card, { label: "每波回血",   value: string(round(_s.heal_wave * 100)) + "%", tag: "续航" });

    // 放置与经济
    if (_s.refund != 1.0) array_push(_card, { label: "铲除返还", value: string(round(_s.refund * 100)) + "%", tag: "经济" });
    if (_s.cost   != 1.0) array_push(_card, { label: "卡片费用", value: hex_fmt_pct(_s.cost), tag: "经济" });
    if (_s.gridless)      array_push(_card, { label: "增幅/辅助不占格", value: "生效", tag: "放置" });
    if (_s.free_place)    array_push(_card, { label: "每波首次放置免费", value: "生效", tag: "放置" });
    if (_s.wave_reset)    array_push(_card, { label: "每波卡槽冷却清零", value: "生效", tag: "放置" });

    // 击杀
    if (_s.kill_flame) {
        array_push(_card, { label: "击杀给火苗",
            value: string(round(_s.kill_flame_rate * 100)) + "% 给 " + string(round(_s.kill_flame_gain)),
            tag: "击杀" });
    }
    if (_s.kill_stack) {
        array_push(_card, { label: "击杀叠攻击",
            value: "每 " + string(round(_s.kill_stack_need)) + " 只 +" + string(round(_s.kill_stack_atk * 100)) + "%，"
                 + string(_s.kill_stacks) + "/" + string(round(_s.kill_stack_cap)) + " 层",
            tag: "击杀" });
    }

    // 分类 / 动态加成
    if (_s.top_atk > 0 && _s.top_minor != "") {
        array_push(_card, { label: "最多分类(" + _s.top_minor + ")", value: hex_fmt_pct(1 + _s.top_atk), tag: "分类" });
    }
    if (_s.per_card_atk > 0) {
        var _pc = min(_s.card_on_field * _s.per_card_atk, _s.per_card_cap);
        array_push(_card, { label: "场上每张卡加攻",
            value: hex_fmt_pct(1 + _pc) + "（" + string(round(_s.card_on_field)) + " 张）", tag: "分类" });
    }
    var _cats = variable_struct_get_names(_s.cat_atk);
    for (var i = 0; i < array_length(_cats); i++) {
        var _c = _cats[i];
        var _v = _s.cat_atk[$ _c];
        if (_v != 1.0) array_push(_card, { label: _c + " 攻击", value: hex_fmt_pct(_v), tag: "分类" });
    }
    var _catsc = variable_struct_get_names(_s.cat_cycle);
    for (var j = 0; j < array_length(_catsc); j++) {
        var _c2 = _catsc[j];
        var _v2 = _s.cat_cycle[$ _c2];
        if (_v2 != 1.0) array_push(_card, { label: _c2 + " 间隔", value: hex_fmt_pct(_v2), tag: "分类" });
    }

    // 共鸣：只列已达成档位的分类
    var _bond_names = variable_struct_get_names(_s.bond_tier);
    for (var k = 0; k < array_length(_bond_names); k++) {
        var _bn = _bond_names[k];
        var _tier = _s.bond_tier[$ _bn];
        if (_tier > 0) {
            array_push(_card, { label: _bn + " 共鸣",
                value: string(_tier) + " 档（场上 " + string(_s.bond_count[$ _bn]) + " 种）", tag: "共鸣" });
        }
    }
    if (_s.bond_power != 1.0) {
        array_push(_card, { label: "共鸣强度", value: hex_fmt_pct(_s.bond_power), tag: "共鸣" });
    }

    // ── 伤害 / 周期 / 结构类（v0.11 新增通道）──
    if (_s.crit_chance > 0) {
        array_push(_card, { label: "暴击", value: string(round(_s.crit_chance * 100)) + "% 造成 "
            + string(_s.crit_mult) + " 倍", tag: "伤害" });
    }
    if (_s.anti_air > 0)    array_push(_card, { label: "对空伤害",   value: hex_pct(_s.anti_air),  tag: "伤害" });
    if (_s.slow_bonus > 0)  array_push(_card, { label: "对减速目标", value: hex_pct(_s.slow_bonus), tag: "伤害" });
    if (_s.atk_floor > 0)   array_push(_card, { label: "攻击力下限", value: string(round(_s.atk_floor * 100)) + "%", tag: "伤害" });
    if (_s.range_cut > 0)   array_push(_card, { label: "卡片受伤减免", value: string(round(_s.range_cut * 100)) + "%", tag: "伤害" });
    if (_s.card_death_pct > 0) array_push(_card, { label: "卡片阵亡反击", value: string(round(_s.card_death_pct * 100)) + "% 攻击", tag: "伤害" });
    if (_s.atk_per_speed > 0)  array_push(_card, { label: "攻速转攻击", value: "1:1", tag: "伤害" });

    if (_s.heal_tick_pct > 0) {
        array_push(_card, { label: "定时回血",
            value: string(round(_s.heal_tick_pct * 1000) / 10) + "% / " + string(round(_s.heal_tick_sec)) + "秒", tag: "续航" });
    }
    if (_s.prod_bonus > 0) array_push(_card, { label: "产能额外产出", value: "+" + string(round(_s.prod_bonus)) + " 火苗", tag: "火苗" });
    if (_s.burn_sec > 0) {
        array_push(_card, { label: "火海",
            value: string(round(_s.burn_pct * 100)) + "% 最大生命 / " + string(round(_s.burn_sec)) + "秒", tag: "伤害" });
    }
    if (_s.nuke_sec > 0) {
        array_push(_card, { label: "灶神附体",
            value: string(round(_s.nuke_pct * 100)) + "% 全队攻击 / " + string(round(_s.nuke_sec)) + "秒", tag: "伤害" });
    }
    if (_s.wave_clear_flame > 0) {
        array_push(_card, { label: "整波零损",
            value: "+" + string(round(_s.wave_clear_flame)) + " 火苗，攻击 +"
                 + string(round(_s.wave_clear_atk * 100)) + "%（" + string(_s.wave_clear_stacks) + "/"
                 + string(round(_s.wave_clear_cap)) + "）", tag: "波次" });
    }
    if (_s.elite_atk > 0) {
        array_push(_card, { label: "击破精英叠攻击",
            value: "每层 +" + string(round(_s.elite_atk * 100)) + "%（" + string(_s.elite_stacks)
                 + "/" + string(round(_s.elite_cap)) + "）", tag: "波次" });
    }

    if (_s.deck_cap != 0)  array_push(_card, { label: "卡组上限", value: hex_fmt_flat(_s.deck_cap), tag: "构筑" });
    if (_s.zero_cd) {
        array_push(_card, { label: "卡片冷却",
            value: "归零，费用 x" + string(round(_s.zero_cd_cost)) + "，每次损失 "
                 + string(round(_s.zero_cd_flame * 100)) + "% 火苗", tag: "构筑" });
    }
    if (_s.same_card_free) array_push(_card, { label: "同名卡第 2 张", value: "免费", tag: "构筑" });
    if (_s.terrain_free)   array_push(_card, { label: "地形限制", value: "任意地形可放", tag: "构筑" });
    if (_s.cap_fixed > 0)  array_push(_card, { label: "火苗上限", value: "固定 " + string(round(_s.cap_fixed)), tag: "火苗" });
    if (_s.cap_half)       array_push(_card, { label: "火苗上限", value: "减半", tag: "火苗" });
    if (_s.cap_unbound)    array_push(_card, { label: "火苗上限", value: "无上限", tag: "火苗" });
    if (_s.refund_chance > 0) {
        array_push(_card, { label: "放置返还", value: string(round(_s.refund_chance * 100)) + "% 全额", tag: "经济" });
    }
    if (_s.buff_grant != 1.0) {
        array_push(_card, { label: "增幅类倍率", value: hex_fmt_pct(_s.buff_grant), tag: "增幅" });
    }
    if (_s.ash_explode) array_push(_card, { label: "灰烬阵亡", value: "3x3 爆炸", tag: "伤害" });
    if (_s.ash_blast > 0) array_push(_card, { label: "灰烬阵亡", value: "全场爆炸", tag: "伤害" });

    // ══════════ 老鼠侧 ══════════
    // 同样读实际出口：hex_enemy_mult 已经把 PI 与夹逼都算进去了
    array_push(_enemy, { label: "老鼠生命", value: hex_fmt_pct(hex_enemy_mult("hp")),  tag: "属性" });
    array_push(_enemy, { label: "老鼠攻击", value: hex_fmt_pct(hex_enemy_mult("atk")), tag: "属性" });
    array_push(_enemy, { label: "老鼠移速", value: hex_fmt_pct(hex_enemy_mult("spd")), tag: "属性" });
    if (_s.e_count != 1.0) {
        array_push(_enemy, { label: "老鼠数量", value: hex_fmt_pct(_s.e_count), tag: "属性" });
    }
    array_push(_enemy, { label: "压迫 PI", value: string(_s.pi_value), tag: "压迫" });
    if (variable_global_exists("pi_enemy_mult")) {
        array_push(_enemy, { label: "PI 全属性", value: hex_fmt_pct(global.pi_enemy_mult), tag: "压迫" });
    }
    if (_s.e_bite != 1.0) {
        array_push(_enemy, { label: "啃咬速度", value: hex_fmt_pct(1 / max(0.1, _s.e_bite)), tag: "属性" });
    }
    if (_s.e_hp_air != 1.0)    array_push(_enemy, { label: "空中老鼠生命", value: hex_fmt_pct(_s.e_hp_air),    tag: "分型" });
    if (_s.e_hp_dive != 1.0)   array_push(_enemy, { label: "潜水鼠生命",   value: hex_fmt_pct(_s.e_hp_dive),   tag: "分型" });
    if (_s.e_hp_ground != 1.0) array_push(_enemy, { label: "地面老鼠生命", value: hex_fmt_pct(_s.e_hp_ground), tag: "分型" });
    if (_s.e_hp_block != 1.0)  array_push(_enemy, { label: "障碍鼠生命",   value: hex_fmt_pct(_s.e_hp_block),  tag: "分型" });
    if (_s.e_max_cards > 0) {
        array_push(_enemy, { label: "场上美食上限", value: string(round(_s.e_max_cards)), tag: "压制" });
    }
    if (_s.e_card_insta > 0) {
        array_push(_enemy, { label: "美食受伤即死", value: string(round(_s.e_card_insta * 100)) + "%", tag: "压制" });
    }
    if (_s.e_card_drain > 0) {
        array_push(_enemy, { label: "美食受伤流失", value: string(round(_s.e_card_drain * 100)) + "% 最大生命", tag: "压制" });
    }
    if (_s.e_card_blast) array_push(_enemy, { label: "美食阵亡反噬", value: "3x3 等量伤害", tag: "压制" });
    if (_s.e_no_cat)     array_push(_enemy, { label: "猫", value: "已禁用", tag: "压制" });
    if (variable_global_exists("pi_elite_extra") && global.pi_elite_extra > 0) {
        array_push(_enemy, { label: "每波精英鼠", value: "+" + string(global.pi_elite_extra), tag: "压迫" });
    }
    if (variable_global_exists("pi_boss_escort") && global.pi_boss_escort) {
        array_push(_enemy, { label: "BOSS 波护卫", value: "已启用", tag: "压迫" });
    }

    return { card: _card, enemy: _enemy };
}

// ══════════════════════ v0.11 机制层读取口 ══════════════════════
// 每个函数都必须能在「非海克斯模式」下安全返回中性值，
// 调用方一律不加 if 包住 —— 与 hex_mult 的约定一致。

/// @function hex_enemy_bite_mult()
/// @desc 老鼠啃咬速度倍率（<1 = 咬得更快）。乘在 atk_cycle 上
function hex_enemy_bite_mult() {
    if (!hex_enabled()) return 1.0;
    if (!variable_global_exists("hex_state") || !is_struct(global.hex_state)) return 1.0;
    return clamp(global.hex_state.e_bite, 0.35, 2.5);
}

/// @function hex_classify_enemy(_inst)
/// @desc 老鼠分型：air / dive / block / ground。
///       引擎只有 target_type == "air" 这一个显式标记，其余靠 mouse_id 与越障能力推断
function hex_classify_enemy(_inst) {
    if (!instance_exists(_inst)) return "ground";
    if (variable_instance_exists(_inst, "target_type") && _inst.target_type == "air") return "air";
    if (variable_instance_exists(_inst, "mouse_id")) {
        var _id = string(_inst.mouse_id);
        if (string_pos("submarine", _id) > 0 || string_pos("dive", _id) > 0) return "dive";
        if (string_pos("eel", _id) > 0 || string_pos("fish", _id) > 0) return "dive";
    }
    // 障碍类：不能越障的（车辆 / 鼹鼠 / 固定障碍物）在 Create 里把 can_use_ladder 置 false
    if (variable_instance_exists(_inst, "can_use_ladder") && !_inst.can_use_ladder) return "block";
    return "ground";
}

/// @function hex_enemy_hp_mult_for(_inst)
/// @desc 老鼠生命倍率，含分型加成（空中 / 潜水 / 地面 / 障碍）
function hex_enemy_hp_mult_for(_inst) {
    var _m = hex_enemy_mult("hp");
    if (!hex_enabled()) return _m;
    if (!variable_global_exists("hex_state") || !is_struct(global.hex_state)) return _m;
    var _s = global.hex_state;
    var _kind = hex_classify_enemy(_inst);
    var _sub = 1.0;
    switch (_kind) {
        case "air":   _sub = _s.e_hp_air;    break;
        case "dive":  _sub = _s.e_hp_dive;   break;
        case "block": _sub = _s.e_hp_block;  break;
        default:      _sub = _s.e_hp_ground; break;
    }
    return _m * clamp(_sub, 0.3, 3.0);
}

/// @function hex_damage_taken_mult()
/// @desc 老鼠受到伤害的额外倍率：暴击 / 对空 / 对减速目标。
///       必须在 obj_enemy_parent 的实例上下文里调用（要读 target_type / is_slowdown）
function hex_damage_taken_mult() {
    if (!hex_enabled()) return 1.0;
    if (!variable_global_exists("hex_state") || !is_struct(global.hex_state)) return 1.0;
    var _s = global.hex_state;
    var _m = 1.0;

    if (_s.crit_chance > 0 && random(1) < _s.crit_chance) _m *= _s.crit_mult;
    if (_s.anti_air > 0 && variable_instance_exists(id, "target_type") && target_type == "air") {
        _m *= (1 + _s.anti_air);
    }
    if (_s.slow_bonus > 0 && variable_instance_exists(id, "is_slowdown") && is_slowdown) {
        _m *= (1 + _s.slow_bonus);
    }
    return _m;
}

/// @function hex_card_incoming_damage(_dmg)
/// @desc 卡片受到伤害时的减免（范围伤害 −X%）。所有对卡的 AOE 伤害都该过这里
function hex_card_incoming_damage(_dmg) {
    if (!hex_enabled()) return _dmg;
    if (!variable_global_exists("hex_state") || !is_struct(global.hex_state)) return _dmg;
    var _cut = clamp(global.hex_state.range_cut, 0, 0.9);
    if (hex_card_insta_kill_chance() > 0 && random(1) < hex_card_insta_kill_chance()) return _dmg + 999999;
    return _dmg * (1 - _cut);
}

/// @function hex_card_insta_kill_chance()
function hex_card_insta_kill_chance() {
    if (!hex_enabled()) return 0;
    if (!variable_global_exists("hex_state") || !is_struct(global.hex_state)) return 0;
    return clamp(global.hex_state.e_card_insta, 0, 1);
}

/// @function hex_card_drain_pct()
/// @desc 卡片受伤后额外扣除的最大生命比例（现炒现卖）
function hex_card_drain_pct() {
    if (!hex_enabled()) return 0;
    if (!variable_global_exists("hex_state") || !is_struct(global.hex_state)) return 0;
    return clamp(global.hex_state.e_card_drain, 0, 1);
}

/// @function hex_enemy_respawn_chance()
function hex_enemy_respawn_chance() {
    if (!hex_enabled()) return 0;
    if (!variable_global_exists("hex_state") || !is_struct(global.hex_state)) return 0;
    return clamp(global.hex_state.e_respawn, 0, 1);
}

/// @function hex_enemy_self_destruct_chance()
function hex_enemy_self_destruct_chance() {
    if (!hex_enabled()) return 0;
    if (!variable_global_exists("hex_state") || !is_struct(global.hex_state)) return 0;
    return clamp(global.hex_state.e_self_destruct, 0, 1);
}

/// @function hex_enemy_max_cards()
/// @desc 场上美食数量上限（大火爆炒：不能超过 50）。0 = 不限制
function hex_enemy_max_cards() {
    if (!hex_enabled()) return 0;
    if (!variable_global_exists("hex_state") || !is_struct(global.hex_state)) return 0;
    return global.hex_state.e_max_cards;
}

/// @function hex_mole_no_stun()
function hex_mole_no_stun() {
    if (!hex_enabled()) return false;
    if (!variable_global_exists("hex_state") || !is_struct(global.hex_state)) return false;
    return global.hex_state.e_mole_no_stun;
}

/// @function hex_enemy_slow_resist()
function hex_enemy_slow_resist() {
    if (!hex_enabled()) return 0;
    if (!variable_global_exists("hex_state") || !is_struct(global.hex_state)) return 0;
    return clamp(global.hex_state.e_slow_resist, 0, 0.9);
}

/// @function hex_card_prod_bonus()
/// @desc 产能类每次产出的额外火苗
function hex_card_prod_bonus(_plant_id) {
    if (!hex_enabled()) return 0;
    if (!variable_global_exists("hex_state") || !is_struct(global.hex_state)) return 0;
    if (global.hex_state.prod_bonus <= 0) return 0;
    var _cat = card_get_category(_plant_id);
    if (is_undefined(_cat)) return 0;
    if (_cat.major != "产能类") return 0;
    return global.hex_state.prod_bonus;
}

/// @function hex_deck_cap_bonus()
function hex_deck_cap_bonus() {
    if (!hex_enabled()) return 0;
    if (!variable_global_exists("hex_state") || !is_struct(global.hex_state)) return 0;
    return round(global.hex_state.deck_cap);
}

/// @function hex_card_atk_floor(_base_atk)
/// @desc 攻击力下限（稳住锅气：被啃咬时不低于基础 80%）
function hex_card_atk_floor(_base_atk) {
    if (!hex_enabled()) return 0;
    if (!variable_global_exists("hex_state") || !is_struct(global.hex_state)) return 0;
    var _f = global.hex_state.atk_floor;
    if (_f <= 0) return 0;
    return _base_atk * _f;
}

/// @function hex_buff_grant_mult()
/// @desc 增幅类卡片提供的倍率增量（香料提味 / 秘制酱料）。
///       用法：增幅增益 = 1 + (原始增益 - 1) × 该倍率
function hex_buff_grant_mult() {
    if (!hex_enabled()) return 1.0;
    if (!variable_global_exists("hex_state") || !is_struct(global.hex_state)) return 1.0;
    return max(1.0, global.hex_state.buff_grant);
}

/// @function hex_card_cooldown(_base)
/// @desc 卡片冷却（火候观察：0 冷却）
function hex_card_cooldown(_base) {
    if (!hex_enabled()) return _base;
    if (!variable_global_exists("hex_state") || !is_struct(global.hex_state)) return _base;
    if (global.hex_state.zero_cd) return 0;
    return _base;
}

/// @function hex_zero_cd_flame_loss()
/// @desc 0 冷却卡每次使用后损失当前火苗的比例
function hex_zero_cd_flame_loss() {
    if (!hex_enabled()) return 0;
    if (!variable_global_exists("hex_state") || !is_struct(global.hex_state)) return 0;
    return clamp(global.hex_state.zero_cd_flame, 0, 1);
}

/// @function hex_terrain_free()
function hex_terrain_free() {
    if (!hex_enabled()) return false;
    if (!variable_global_exists("hex_state") || !is_struct(global.hex_state)) return false;
    return global.hex_state.terrain_free;
}

/// @function hex_placement_refund_chance()
function hex_placement_refund_chance() {
    if (!hex_enabled()) return 0;
    if (!variable_global_exists("hex_state") || !is_struct(global.hex_state)) return 0;
    return clamp(global.hex_state.refund_chance, 0, 1);
}

/// @function hex_same_card_free_ready()
/// @desc 双厨狂喜：每波内第 2 次放置同名卡免费
function hex_same_card_free_ready() {
    if (!hex_enabled()) return false;
    if (!variable_global_exists("hex_state") || !is_struct(global.hex_state)) return false;
    return (global.hex_state.same_card_free && !global.hex_state.same_card_used);
}

/// @function hex_same_card_free_try(_card_id)
/// @desc 双厨狂喜：本波内第 2 次放置「同一张卡」时免费，每波只免一次。
///       必须在真正扣费的那一刻调用（不是选中时），否则点一下不放手牌也会被消耗掉
function hex_same_card_free_try(_card_id) {
    if (!hex_enabled()) return false;
    if (!variable_global_exists("hex_state") || !is_struct(global.hex_state)) return false;
    var _s = global.hex_state;
    if (!variable_struct_exists(_s, "same_card_free") || !_s.same_card_free) return false;
    if (_s.same_card_used) return false;
    if (!variable_struct_exists(_s, "same_card_last")) _s.same_card_last = "";
    if (_s.same_card_last == _card_id) {
        _s.same_card_used = true;
        return true;
    }
    _s.same_card_last = _card_id;
    return false;
}

/// @function hex_card_death_pct()
/// @desc 以牙还牙：卡片被摧毁时对全场老鼠造成该卡攻击的 N 倍
function hex_card_death_pct() {
    if (!hex_enabled()) return 0;
    if (!variable_global_exists("hex_state") || !is_struct(global.hex_state)) return 0;
    return global.hex_state.card_death_pct;
}

/// @function hex_ash_explode_on()
function hex_ash_explode_on() {
    if (!hex_enabled()) return false;
    if (!variable_global_exists("hex_state") || !is_struct(global.hex_state)) return false;
    return global.hex_state.ash_explode;
}

/// @function hex_ash_revive_on()
function hex_ash_revive_on() {
    if (!hex_enabled()) return false;
    if (!variable_global_exists("hex_state") || !is_struct(global.hex_state)) return false;
    return global.hex_state.ash_revive;
}

/// @function hex_card_blast_on()
function hex_card_blast_on() {
    if (!hex_enabled()) return false;
    if (!variable_global_exists("hex_state") || !is_struct(global.hex_state)) return false;
    return global.hex_state.e_card_blast;
}

/// @function hex_star_on_card(_inst)
/// @desc 星级类词条：开局全体 +N 星（食材升级）。在卡片创建后调用
function hex_star_on_card(_inst) {
    if (!hex_enabled()) return;
    if (!instance_exists(_inst)) return;
    if (!variable_global_exists("hex_state") || !is_struct(global.hex_state)) return;
    var _n = round(global.hex_state.star_start);
    if (_n <= 0) return;
    if (!variable_instance_exists(_inst, "shape")) return;
    var _max = 2;
    if (variable_instance_exists(_inst, "max_shape")) _max = _inst.max_shape;
    _inst.shape = min(_inst.shape + _n, _max);
}

/// @function hex_periodic_run()
/// @desc 周期效果总入口，由 obj_battle/Step_0 每帧调用：
///       灶神附体（全屏火焰）/ 火海（百分比灼烧）/ 小火慢炖（定时回血）
function hex_periodic_run() {
    if (!hex_enabled()) return;
    if (!variable_global_exists("hex_state") || !is_struct(global.hex_state)) return;
    var _s = global.hex_state;

    // ── 小火慢炖：每 N 秒回复最大生命 ──
    if (_s.heal_tick_pct > 0) {
        _s.heal_tick_frame = (variable_struct_exists(_s, "heal_tick_frame") ? _s.heal_tick_frame : 0) + 1;
        var _need = max(1, round(_s.heal_tick_sec * 60));
        if (_s.heal_tick_frame >= _need) {
            _s.heal_tick_frame = 0;
            with (obj_card_parent) {
                if (self.plant_id != "player") {
                    self.hp = min(self.max_hp, self.hp + self.max_hp * _s.heal_tick_pct);
                }
            }
        }
    }

    // ── 火海：每 N 秒按最大生命百分比灼烧全场 ──
    if (_s.burn_sec > 0 && _s.burn_pct > 0) {
        _s.burn_timer += 1;
        if (_s.burn_timer >= round(_s.burn_sec * 60)) {
            _s.burn_timer = 0;
            with (obj_enemy_parent) {
                if (hp > 0) {
                    damage_amount = max(1, round(maxhp * _s.burn_pct));
                    damage_type   = "normal";
                    event_user(0);   // 用户事件 0 = Other_10 的受伤结算（Other_20 不存在，写 10 会静默失效）
                }
            }
        }
    }

    // ── 灶神附体：每 N 秒按全队攻击总和的比例打一发全屏 ──
    if (_s.nuke_sec > 0 && _s.nuke_pct > 0) {
        _s.nuke_timer += 1;
        if (_s.nuke_timer >= round(_s.nuke_sec * 60)) {
            _s.nuke_timer = 0;
            var _sum = 0;
            with (obj_card_parent) {
                if (self.plant_id != "player" && variable_instance_exists(self.id, "atk")) _sum += self.atk;
            }
            if (_sum > 0) {
                var _dmg = max(1, round(_sum * _s.nuke_pct));
                with (obj_enemy_parent) {
                    if (hp > 0) {
                        damage_amount = _dmg;
                        damage_type   = "normal";
                        event_user(0);   // 用户事件 0 = Other_10 的受伤结算（Other_20 不存在，写 10 会静默失效）
                    }
                }
            }
        }
    }

    // 第二批（hex_112 ~ hex_184）的周期效果：落地沉睡/无敌、山脉龙魂、达摩克里斯、
    // 大战召唤、鼠洞、认知偏差。全部在 hex_batch2 内部按毫秒切块，不吃帧率。
    hex_batch2_tick();
}

/// @function hex_enemy_no_cat()
/// @desc 「食材升级」的老鼠侧代价：禁用猫（猫会把老鼠吓退）
function hex_enemy_no_cat() {
    if (!hex_enabled()) return false;
    if (!variable_global_exists("hex_state") || !is_struct(global.hex_state)) return false;
    return global.hex_state.e_no_cat;
}
