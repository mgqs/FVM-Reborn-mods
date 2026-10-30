/// hex_batch2 —— 第二批词条（hex_112 ~ hex_184）的机制层
///
/// 与 hex_core 的约定完全一致：
///   · 非海克斯模式一律返回中性值（1.0 / 0 / false），调用方不加 if 包住；
///   · 所有状态挂在 global.hex_state 上，用 hex_batch2_ensure() 惰性补齐，
///     这样旧存档 / 旧状态结构不需要改 hex_state_init 也能用；
///   · 数值入口只读，不改写别的系统的状态；需要改状态的一律走 *_hook() 函数，
///     由对象层在明确的时机调用。

// ══════════════════════ 状态 ══════════════════════

/// @function hex_batch2_ensure()
/// @desc 惰性补齐第二批用到的字段。返回 false 表示当前没有可用的局内状态
function hex_batch2_ensure() {
    if (!variable_global_exists("hex_state")) return false;
    if (!is_struct(global.hex_state)) return false;
    var _s = global.hex_state;
    if (variable_struct_exists(_s, "b2_ready")) return true;

    // 卡片侧
    _s.b2_id_atk        = {};      // card_id -> 攻击倍率
    _s.b2_id_cycle      = {};      // card_id -> 间隔倍率
    _s.b2_id_cost       = {};      // card_id -> 费用倍率
    _s.b2_id_hp_fix     = {};      // card_id -> 固定生命
    _s.b2_id_count      = {};      // card_id -> 场上张数（炸丸子用）
    _s.b2_fusion_atk    = 1.0;     // 融合卡攻击倍率
    _s.b2_count_atk     = "";      // 【炸丸子】统计的小分类名
    _s.b2_count_step    = 0;       // 每组加成
    _s.b2_count_size    = 6;       // 每组张数
    _s.b2_flame_atk     = 0;       // 每 1000 火苗的攻击增量
    _s.b2_flame_flat    = 0;       // 拾取单个火苗的固定附加值
    _s.b2_time_add      = 0;       // 限时增加（秒）
    _s.b2_spawn         = 1.0;     // 出怪间隔倍率
    _s.b2_reward        = 1.0;     // 关卡奖励倍率
    _s.b2_gamble        = 1.0;     // 【搏一搏】本关掷出的倍率
    _s.b2_resist        = 0;       // 每损失 20% 生命的抗性增量
    _s.b2_equalize      = false;   // 攻击与生命取大值
    _s.b2_reflect       = 0;       // 反伤比例
    _s.b2_knock_cell    = 0;       // 防御类击退格数
    _s.b2_knock_cost    = 0;       // 击退消耗生命
    _s.b2_flame_shield  = false;   // 受击改为扣火苗
    _s.b2_invuln        = 0;       // 落地无敌帧
    _s.b2_sleep         = 0;       // 落地沉睡帧
    _s.b2_sleep_atk     = 0;       // 沉睡类攻击增量
    _s.b2_avg_cost      = false;   // 费用取卡槽平均
    _s.b2_coffee_only   = false;   // 只允许咖啡杯系攻击卡
    _s.b2_bull_row      = false;   // 多行子弹收敛到本行
    _s.b2_puffer_p      = 0;       // 河豚爆炸段纯随机概率
    _s.b2_puffer_dmg    = 1.0;     // 河豚灰烬伤害倍率
    _s.b2_kill_cd       = 0;       // 每多少击杀重置一张卡的冷却
    _s.b2_kill_cd_n     = 0;
    _s.b2_per_card_cycle = 0;      // 场上每张卡给全队的间隔增量
    _s.b2_hp_stack      = 0;       // 每秒叠加的生命上限比例
    _s.b2_hp_stack_cap  = 0;       // 叠加上限
    _s.b2_hole_refund   = false;   // 清除鼠洞返还
    _s.b2_blast_p       = 0;       // 老鼠死亡爆炸概率
    _s.b2_blast_mult    = 1.2;     // 爆炸伤害 = 生命上限 × 该倍率
    _s.b2_cognition     = false;   // 认知偏差
    _s.b2_cognition_pending = false;

    // 老鼠侧
    _s.b2_e_hit_after   = false;   // 必须先啃咬过才能被打
    _s.b2_e_invuln      = 0;       // 出场无敌帧
    _s.b2_e_hp_per_card = 0;       // 每张在场卡给老鼠的生命增量
    _s.b2_e_hp_per_cap  = 0;       // 上面的封顶
    _s.b2_e_hp_flame    = false;   // 出生生命 + 当前火苗
    _s.b2_e_summon      = 0;       // 每 N 秒召唤同类
    _s.b2_e_hole        = 0;       // 每 N 秒刷一个鼠洞
    _s.b2_e_super       = 0;       // 每秒随机强化一只老鼠的概率
    _s.b2_e_super_hp    = 0;       // 强化加的血量
    _s.b2_e_super_spd   = 0;       // 强化加的移速
    _s.b2_boss_shield   = 0;       // BOSS 护盾需要的灰烬命中数
    _s.b2_boss_flame    = 0;       // BOSS 入场火苗
    _s.b2_boss_atk      = 0;       // 首个 BOSS 入场给全队的攻击增量
    _s.b2_boss_atk_done = false;

    // 计时（毫秒，逐个效果独立，避免互相踩）
    _s.b2_tick_ms       = current_time;
    _s.b2_summon_ms     = current_time;
    _s.b2_hole_ms       = current_time;

    _s.b2_ready = true;
    return true;
}

/// @function hex_batch2_apply(_d)
/// @desc 把一条第二批词条的机制字段并入本局状态。由 hex_apply_core 统一调用
function hex_batch2_apply(_d) {
    if (!hex_batch2_ensure()) return false;
    var _s  = global.hex_state;
    var _ex = _d.ex;
    var _en = _d.en;

    // ── 指定卡牌 ──
    if (variable_struct_exists(_ex, "b2_id_atk")) {
        var _a = _ex.b2_id_atk;
        for (var i = 0; i < array_length(_a); i++) {
            var _id = _a[i][0];
            var _cur = 1.0;
            if (variable_struct_exists(_s.b2_id_atk, _id)) _cur = _s.b2_id_atk[$ _id];
            _s.b2_id_atk[$ _id] = _cur * (1 + _a[i][1]);
        }
    }
    if (variable_struct_exists(_ex, "b2_id_cycle")) {
        var _b = _ex.b2_id_cycle;
        for (var j = 0; j < array_length(_b); j++) {
            var _id2 = _b[j][0];
            var _cur2 = 1.0;
            if (variable_struct_exists(_s.b2_id_cycle, _id2)) _cur2 = _s.b2_id_cycle[$ _id2];
            _s.b2_id_cycle[$ _id2] = _cur2 * (1 + _b[j][1]);
        }
    }
    if (variable_struct_exists(_ex, "b2_id_cost")) {
        var _c = _ex.b2_id_cost;
        for (var k = 0; k < array_length(_c); k++) {
            var _id3 = _c[k][0];
            var _cur3 = 1.0;
            if (variable_struct_exists(_s.b2_id_cost, _id3)) _cur3 = _s.b2_id_cost[$ _id3];
            _s.b2_id_cost[$ _id3] = _cur3 * (1 + _c[k][1]);
        }
    }
    if (variable_struct_exists(_ex, "b2_id_hp_fix")) {
        var _h = _ex.b2_id_hp_fix;
        for (var m = 0; m < array_length(_h); m++) {
            _s.b2_id_hp_fix[$ _h[m][0]] = _h[m][1];
        }
    }

    // ── 卡牌数值 ──
    if (variable_struct_exists(_ex, "b2_fusion_atk"))    _s.b2_fusion_atk *= (1 + _ex.b2_fusion_atk);
    if (variable_struct_exists(_ex, "b2_flame_atk"))     _s.b2_flame_atk += _ex.b2_flame_atk;
    if (variable_struct_exists(_ex, "b2_flame_flat"))    _s.b2_flame_flat += _ex.b2_flame_flat;
    if (variable_struct_exists(_ex, "b2_time_add"))      _s.b2_time_add += _ex.b2_time_add;
    if (variable_struct_exists(_ex, "b2_spawn"))         _s.b2_spawn *= (1 + _ex.b2_spawn);
    if (variable_struct_exists(_ex, "b2_reward"))        _s.b2_reward *= (1 + _ex.b2_reward);
    if (variable_struct_exists(_ex, "b2_resist"))        _s.b2_resist += _ex.b2_resist;
    if (variable_struct_exists(_ex, "b2_reflect"))       _s.b2_reflect += _ex.b2_reflect;
    if (variable_struct_exists(_ex, "b2_per_card_cycle")) _s.b2_per_card_cycle += _ex.b2_per_card_cycle;
    if (variable_struct_exists(_ex, "b2_kill_cd"))       _s.b2_kill_cd = max(_s.b2_kill_cd, _ex.b2_kill_cd);

    if (variable_struct_exists(_ex, "b2_equalize"))  _s.b2_equalize  = true;
    if (variable_struct_exists(_ex, "b2_flame_shield")) _s.b2_flame_shield = true;
    if (variable_struct_exists(_ex, "b2_avg_cost"))  _s.b2_avg_cost  = true;
    if (variable_struct_exists(_ex, "b2_coffee_only")) _s.b2_coffee_only = true;
    if (variable_struct_exists(_ex, "b2_bull_row"))  _s.b2_bull_row  = true;
    if (variable_struct_exists(_ex, "b2_hole_refund")) _s.b2_hole_refund = true;
    if (variable_struct_exists(_ex, "b2_cognition")) {
        _s.b2_cognition = true;
        // 立刻改判成另一条：由 hex_batch2_tick() 结算（抽到的那一帧可能正在暂停，
        // 所以那段结算放在 tick 的暂停保护之前）。每次并入只触发一次，
        // 永久解锁的词条因此每关开局触发一次。
        _s.b2_cognition_pending = true;
    }

    if (variable_struct_exists(_ex, "b2_knock")) {
        var _kn = _ex.b2_knock;
        _s.b2_knock_cell = max(_s.b2_knock_cell, _kn[0]);
        _s.b2_knock_cost = max(_s.b2_knock_cost, _kn[1]);
    }
    if (variable_struct_exists(_ex, "b2_sleep")) {
        var _sl = _ex.b2_sleep;
        _s.b2_sleep     = max(_s.b2_sleep, _sl[0]);
        _s.b2_sleep_atk += _sl[1];
    }
    if (variable_struct_exists(_ex, "b2_count_atk")) {
        var _ca = _ex.b2_count_atk;
        _s.b2_count_atk  = _ca[0];
        _s.b2_count_step += _ca[1];
        _s.b2_count_size  = max(1, round(_ca[2]));
    }
    if (variable_struct_exists(_ex, "b2_puffer")) {
        var _pf = _ex.b2_puffer;
        _s.b2_puffer_p   = max(_s.b2_puffer_p, _pf[0]);
        _s.b2_puffer_dmg = max(_s.b2_puffer_dmg, _pf[1]);
    }
    if (variable_struct_exists(_ex, "b2_hp_stack")) {
        var _hs = _ex.b2_hp_stack;
        _s.b2_hp_stack     = max(_s.b2_hp_stack, _hs[0]);
        _s.b2_hp_stack_cap = max(_s.b2_hp_stack_cap, _hs[1]);
    }
    if (variable_struct_exists(_ex, "b2_blast")) {
        var _bl = _ex.b2_blast;
        _s.b2_blast_p    = max(_s.b2_blast_p, _bl[0]);
        _s.b2_blast_mult = max(_s.b2_blast_mult, _bl[1]);
    }
    if (variable_struct_exists(_ex, "b2_invuln")) _s.b2_invuln = max(_s.b2_invuln, _ex.b2_invuln);

    // 落地类效果（沉睡 / 无敌）只该作用于【拿到词条之后种下】的卡片：
    // 这里把当前已经在场的卡全部标记成已处理，避免抽到词条瞬间全场一起睡 10 秒
    if (variable_struct_exists(_ex, "b2_sleep") || variable_struct_exists(_ex, "b2_invuln")) {
        with (obj_card_parent) {
            self.b2_placed = true;
        }
    }

    // ── 老鼠侧 ──
    if (variable_struct_exists(_en, "b2_e_hit_after")) _s.b2_e_hit_after = true;
    if (variable_struct_exists(_en, "b2_e_hp_flame"))  _s.b2_e_hp_flame  = true;
    if (variable_struct_exists(_en, "b2_e_invuln"))    _s.b2_e_invuln    = max(_s.b2_e_invuln, _en.b2_e_invuln);
    if (variable_struct_exists(_en, "b2_e_summon"))    _s.b2_e_summon    = max(_s.b2_e_summon, _en.b2_e_summon);
    if (variable_struct_exists(_en, "b2_e_hole"))      _s.b2_e_hole      = max(_s.b2_e_hole, _en.b2_e_hole);
    if (variable_struct_exists(_en, "b2_boss_shield")) _s.b2_boss_shield = max(_s.b2_boss_shield, _en.b2_boss_shield[1]);
    if (variable_struct_exists(_en, "b2_e_hp_per_card")) {
        var _ec = _en.b2_e_hp_per_card;
        _s.b2_e_hp_per_card += _ec[0];
        _s.b2_e_hp_per_cap  += _ec[1];
    }
    if (variable_struct_exists(_en, "b2_e_super")) {
        var _es = _en.b2_e_super;
        _s.b2_e_super     = max(_s.b2_e_super, _es[0]);
        _s.b2_e_super_hp  = max(_s.b2_e_super_hp, _es[1]);
        _s.b2_e_super_spd = max(_s.b2_e_super_spd, _es[2]);
    }
    if (variable_struct_exists(_ex, "b2_boss_entry")) {
        var _be = _ex.b2_boss_entry;
        _s.b2_boss_flame = max(_s.b2_boss_flame, _be[0]);
        _s.b2_boss_atk   = max(_s.b2_boss_atk, _be[1]);
    }
    if (variable_struct_exists(_ex, "b2_reward_gamble")) {
        if (!variable_struct_exists(_s, "b2_gamble_ready")) _s.b2_gamble_ready = true;
    }

    return true;
}

// ══════════════════════ 卡片侧读取口 ══════════════════════

/// @function hex_batch2_is_attack_card(_id)
function hex_batch2_is_attack_card(_id) {
    var _c = card_get_category(_id);
    if (is_undefined(_c)) return false;
    var _majors = ["直射类", "投掷类", "多向类", "专业防空类", "喷壶类",
                   "追踪类", "非远程类", "灰烬类"];
    return (array_index_of(_majors, _c.major) != -1);
}

/// @function hex_batch2_id_atk(_card_id)
function hex_batch2_id_atk(_card_id) {
    if (!hex_enabled()) return 1.0;
    if (!hex_batch2_ensure()) return 1.0;
    var _m = 1.0;
    var _s = global.hex_state;
    if (variable_struct_exists(_s.b2_id_atk, _card_id)) _m *= _s.b2_id_atk[$ _card_id];
    // 【食之灵】：所有融合卡（card_id 以 ronghe 开头）
    if (_s.b2_fusion_atk != 1.0 && string_pos("ronghe", _card_id) == 1) _m *= _s.b2_fusion_atk;
    return _m;
}

/// @function hex_batch2_id_cycle(_card_id)
function hex_batch2_id_cycle(_card_id) {
    if (!hex_enabled()) return 1.0;
    if (!hex_batch2_ensure()) return 1.0;
    var _s = global.hex_state;
    if (!variable_struct_exists(_s.b2_id_cycle, _card_id)) return 1.0;
    return _s.b2_id_cycle[$ _card_id];
}

/// @function hex_batch2_id_hp_fix(_card_id)
/// @desc 该卡的固定生命值；0 表示不生效
function hex_batch2_id_hp_fix(_card_id) {
    if (!hex_enabled()) return 0;
    if (!hex_batch2_ensure()) return 0;
    var _s = global.hex_state;
    if (!variable_struct_exists(_s.b2_id_hp_fix, _card_id)) return 0;
    return _s.b2_id_hp_fix[$ _card_id];
}

/// @function hex_batch2_atk_factor(_plant_id)
/// @desc 追加在 hex_atk_mult_for_card 末端的额外攻击系数（增量式）
function hex_batch2_atk_factor(_plant_id) {
    if (!hex_enabled()) return 1.0;
    if (!hex_batch2_ensure()) return 1.0;
    var _s = global.hex_state;
    var _add = 0;

    // 【炽热火苗】：每 1000 火苗 +1% 攻击
    if (_s.b2_flame_atk > 0 && variable_global_exists("flame")) {
        _add += _s.b2_flame_atk * floor(max(0, global.flame) / 1000);
    }
    // 【瞌睡虫】：睡醒后的攻击加成
    if (_s.b2_sleep_atk > 0 && hex_batch2_is_attack_card(_plant_id)) {
        _add += _s.b2_sleep_atk;
    }
    // 【炸丸子】：同种追踪卡每满 N 张 +1 档
    if (_s.b2_count_atk != "" && _s.b2_count_step > 0) {
        var _cat = card_get_category(_plant_id);
        if (!is_undefined(_cat) && _cat.minor == _s.b2_count_atk) {
            var _n = 0;
            if (variable_struct_exists(_s, "b2_id_count")
                && variable_struct_exists(_s.b2_id_count, _plant_id)) {
                _n = _s.b2_id_count[$ _plant_id];
            }
            var _lvl = floor(_n / _s.b2_count_size);
            if (_lvl > 0) _add += _s.b2_count_step * min(_lvl, 9);
        }
    }
    // 【渎神】：首个 BOSS 入场后的全队攻击
    if (_s.b2_boss_atk > 0 && _s.b2_boss_atk_done && hex_batch2_is_attack_card(_plant_id)) {
        _add += _s.b2_boss_atk;
    }
    return 1 + _add;
}

/// @function hex_batch2_cycle_factor(_plant_id)
function hex_batch2_cycle_factor(_plant_id) {
    if (!hex_enabled()) return 1.0;
    if (!hex_batch2_ensure()) return 1.0;
    var _s = global.hex_state;
    var _add = 0;
    // 【大战】：场上每张卡 −2.5% 间隔（最多 −75%）
    if (_s.b2_per_card_cycle < 0) {
        var _n = 0;
        if (variable_struct_exists(_s, "card_on_field")) _n = _s.card_on_field;
        _add = max(-0.75, _s.b2_per_card_cycle * _n);
    }
    return 1 + _add;
}

/// @function hex_batch2_enemy_hp_extra()
/// @desc 【爆破组就位】：每张在场卡给老鼠 +1% 生命
function hex_batch2_enemy_hp_extra() {
    if (!hex_enabled()) return 1.0;
    if (!hex_batch2_ensure()) return 1.0;
    var _s = global.hex_state;
    if (_s.b2_e_hp_per_card <= 0) return 1.0;
    var _n = 0;
    if (variable_struct_exists(_s, "card_on_field")) _n = _s.card_on_field;
    return 1 + min(_n * _s.b2_e_hp_per_card, _s.b2_e_hp_per_cap);
}

// ══════════════════════ 费用 / 放置 ══════════════════════

/// @function hex_batch2_cost(_card_id, _base)
/// @desc 卡片费用的统一出口：费用倍率 + 【均值】+ 指定卡折扣
function hex_batch2_cost(_card_id, _base) {
    if (!hex_enabled()) return _base;
    if (!hex_batch2_ensure()) return _base;
    var _s = global.hex_state;
    var _c = _base;

    // 【均值】：全卡槽费用的平均值
    if (_s.b2_avg_cost) {
        var _sum = 0;
        var _n = 0;
        with (obj_card_slot) {
            _sum += cost;
            _n += 1;
        }
        if (_n > 0) _c = _sum / _n;
    }

    _c = _c * hex_cost_mult();
    if (variable_struct_exists(_s.b2_id_cost, _card_id)) _c *= _s.b2_id_cost[$ _card_id];
    return max(0, _c);
}

/// @function hex_batch2_coffee_block(_card_id)
/// @desc 【牢大的祝福】：除咖啡杯系以外的攻击类卡片无法落位
function hex_batch2_coffee_block(_card_id) {
    if (!hex_enabled()) return false;
    if (!hex_batch2_ensure()) return false;
    if (!global.hex_state.b2_coffee_only) return false;
    if (_card_id == "coffee_cup" || _card_id == "ronghekafei") return false;
    return hex_batch2_is_attack_card(_card_id);
}

/// @function hex_batch2_time_add()
function hex_batch2_time_add() {
    if (!hex_enabled()) return 0;
    if (!hex_batch2_ensure()) return 0;
    return global.hex_state.b2_time_add;
}

/// @function hex_batch2_spawn_interval()
/// @desc 出怪间隔倍率（<1 = 更快）
function hex_batch2_spawn_interval() {
    if (!hex_enabled()) return 1.0;
    if (!hex_batch2_ensure()) return 1.0;
    return clamp(global.hex_state.b2_spawn, 0.2, 3.0);
}

/// @function hex_batch2_reward_mult()
/// @desc 关卡奖励倍率（×10 / 搏一搏），由 difficulty_get_reward_multiplier 读取
function hex_batch2_reward_mult() {
    if (!hex_enabled()) return 1.0;
    if (!hex_batch2_ensure()) return 1.0;
    var _s = global.hex_state;
    return max(0.05, _s.b2_reward * _s.b2_gamble);
}

/// @function hex_batch2_flame_flat()
/// @desc 拾取单个火苗时的固定附加值（【熠熠生辉】）
function hex_batch2_flame_flat() {
    if (!hex_enabled()) return 0;
    if (!hex_batch2_ensure()) return 0;
    return global.hex_state.b2_flame_flat;
}

/// @function hex_batch2_bull_row()
function hex_batch2_bull_row() {
    if (!hex_enabled()) return false;
    if (!hex_batch2_ensure()) return false;
    return global.hex_state.b2_bull_row;
}

/// @function hex_batch2_equalize_on()
/// @desc 【取长补短】：攻击与生命取大值
function hex_batch2_equalize_on() {
    if (!hex_enabled()) return false;
    if (!hex_batch2_ensure()) return false;
    return global.hex_state.b2_equalize;
}

/// @function hex_batch2_puffer()
/// @desc 河豚词条：[爆炸概率, 伤害倍率]；未启用返回 [0, 1]
function hex_batch2_puffer() {
    if (!hex_enabled()) return [0, 1.0];
    if (!hex_batch2_ensure()) return [0, 1.0];
    return [ global.hex_state.b2_puffer_p, global.hex_state.b2_puffer_dmg ];
}

// ══════════════════════ 受击 / 死亡 / BOSS ══════════════════════

/// @function hex_batch2_enemy_damage_take(_inst, _dmg, _type)
/// @desc 老鼠受伤前置过滤：出场无敌 / 轻装伏击 / BOSS 石护盾。
///       返回实际应扣的伤害，0 表示这一下完全无效
function hex_batch2_enemy_damage_take(_inst, _dmg, _type) {
    if (!hex_enabled()) return _dmg;
    if (!instance_exists(_inst)) return _dmg;
    if (!hex_batch2_ensure()) return _dmg;
    var _s = global.hex_state;

    // 出场无敌
    if (variable_instance_exists(_inst, "b2_guard_until")) {
        if (_inst.b2_guard_until > 0 && current_time < _inst.b2_guard_until) return 0;
    }

    // 【轻装伏击】：没啃咬过之前不可被攻击
    if (_s.b2_e_hit_after && variable_instance_exists(_inst, "b2_can_be_hit")) {
        if (!_inst.b2_can_be_hit) return 0;
    }

    // 【石护盾】：BOSS 血量到 75/50/25% 生成护盾
    if (_s.b2_boss_shield > 0 && variable_instance_exists(_inst, "is_boss") && _inst.is_boss) {
        _dmg = hex_batch2_boss_shield(_inst, _dmg, _type);
    }
    return _dmg;
}

/// @function hex_batch2_boss_shield(_inst, _dmg, _type)
/// @desc 石护盾结算。护盾存在时只吃 20% 伤害，灰烬伤害才计数
function hex_batch2_boss_shield(_inst, _dmg, _type) {
    var _s = global.hex_state;
    if (!variable_instance_exists(_inst, "b2_shield_left")) {
        _inst.b2_shield_left  = 0;      // 剩余需击破次数（0 = 无护盾）
        _inst.b2_shield_next  = 0.75;   // 下一个触发阈值
        _inst.b2_shield_until = 0;      // 破盾后双倍伤害的到期时间
    }

    // 破盾后的 10 秒内伤害翻倍
    if (_inst.b2_shield_until > 0 && current_time < _inst.b2_shield_until) {
        return _dmg * 2;
    }

    // 到阈值就开盾（一次只开一层）
    if (_inst.b2_shield_left <= 0 && _inst.b2_shield_next > 0
        && variable_instance_exists(_inst, "maxhp") && _inst.maxhp > 0) {
        if (_inst.hp / _inst.maxhp <= _inst.b2_shield_next) {
            _inst.b2_shield_left = _s.b2_boss_shield;
            if (_inst.b2_shield_next > 0.5)      _inst.b2_shield_next = 0.5;
            else if (_inst.b2_shield_next > 0.25) _inst.b2_shield_next = 0.25;
            else                                  _inst.b2_shield_next = 0;
        }
    }

    if (_inst.b2_shield_left > 0) {
        if (_type == "ash") _inst.b2_shield_left -= 1;
        if (_inst.b2_shield_left <= 0) {
            // 击破的这一下正常结算，之后 10 秒双倍
            _inst.b2_shield_until = current_time + 10000;
            return _dmg;
        }
        return max(1, _dmg * 0.2);
    }
    return _dmg;
}

/// @function hex_batch2_card_take_hit(_card, _enemy, _atk)
/// @desc 卡片被啃咬的统一结算：反伤 / 防御类击退 / 火苗护盾 / 抗性。
///       由 obj_enemy_parent/Step_0 在攻击命中时调用（替代原来的 hp -= atk）
function hex_batch2_card_take_hit(_card, _enemy, _atk) {
    if (!instance_exists(_card)) return;
    if (!hex_enabled()) {
        if (!_card.invincible) _card.hp -= _atk;
        return;
    }
    if (!hex_batch2_ensure()) {
        if (!_card.invincible) _card.hp -= _atk;
        return;
    }
    var _s = global.hex_state;

    // 【QQ弹弹】：防御类卡片不受伤，改为消耗生命把老鼠推回去
    if (_s.b2_knock_cell > 0) {
        var _cat = card_get_category(_card.plant_id);
        if (!is_undefined(_cat) && _cat.major == "防御类") {
            if (instance_exists(_enemy)) {
                _enemy.x += _s.b2_knock_cell * global.grid_cell_size_x;
            }
            _card.hp -= _s.b2_knock_cost;
            return;
        }
    }

    var _dmg = _atk;

    // 【炼金龙魂】：每损失 20% 生命 +抗性（最高 50%）
    if (_s.b2_resist > 0 && _card.max_hp > 0) {
        var _lost = 1 - clamp(_card.hp / _card.max_hp, 0, 1);
        var _stack = floor(_lost / 0.2);
        if (_stack > 0) _dmg = _dmg * (1 - min(0.5, _stack * _s.b2_resist));
    }

    // 【火苗生命体】：伤害改为扣火苗，火苗不够时正常扣血
    if (_s.b2_flame_shield && variable_global_exists("flame")) {
        if (global.flame >= _dmg) {
            global.flame -= _dmg;
            _dmg = 0;
        }
    }

    if (_card.invincible) _dmg = 0;
    if (_dmg > 0) _card.hp -= _dmg;

    // 【各种刺身】：反伤
    if (_s.b2_reflect > 0 && instance_exists(_enemy)) {
        _enemy.hp -= _atk * _s.b2_reflect;
    }
}

/// @function hex_batch2_on_bite(_inst)
/// @desc 老鼠啃咬过一次：解除【轻装伏击】的不可攻击状态
function hex_batch2_on_bite(_inst) {
    if (!hex_enabled()) return;
    if (!instance_exists(_inst)) return;
    _inst.b2_can_be_hit = true;
}

/// @function hex_batch2_on_enemy_death(_inst)
/// @desc 老鼠死亡：3×3 不分敌我的爆炸（塔之诅咒）
function hex_batch2_on_enemy_death(_inst) {
    if (!hex_enabled()) return;
    if (!instance_exists(_inst)) return;
    if (!hex_batch2_ensure()) return;
    var _s = global.hex_state;
    if (_s.b2_blast_p <= 0) return;
    if (random(1) >= _s.b2_blast_p) return;

    var _dmg = 100;
    if (variable_instance_exists(_inst, "maxhp") && _inst.maxhp > 0) {
        _dmg = _inst.maxhp * _s.b2_blast_mult;
    }
    hex_batch2_blast(_inst.x, _inst.y, _dmg);
}

/// @function hex_batch2_blast(_x, _y, _dmg)
/// @desc 3×3 范围伤害，敌我通吃
function hex_batch2_blast(_x, _y, _dmg) {
    var _gp = get_grid_position_from_world(_x, _y);
    if (is_undefined(_gp)) return;
    var _row = _gp.row;
    var _col = _gp.col;

    with (obj_enemy_parent) {
        if (self.hp > 0 && abs(self.grid_row - _row) <= 1 && abs(self.grid_col - _col) <= 1) {
            self.hp -= _dmg;
        }
    }
    with (obj_card_parent) {
        if (self.plant_id != "player" && abs(self.grid_row - _row) <= 1 && abs(self.grid_col - _col) <= 1) {
            self.hp -= _dmg;
        }
    }
}

/// @function hex_batch2_on_kill()
/// @desc 击杀计数类词条（跨接电缆）
function hex_batch2_on_kill() {
    if (!hex_enabled()) return;
    if (!hex_batch2_ensure()) return;
    var _s = global.hex_state;
    if (_s.b2_kill_cd <= 0) return;

    _s.b2_kill_cd_n += 1;
    if (_s.b2_kill_cd_n < _s.b2_kill_cd) return;
    _s.b2_kill_cd_n = 0;

    if (!instance_exists(obj_card_slot)) return;
    var _n = instance_number(obj_card_slot);
    if (_n <= 0) return;
    var _slot = instance_find(obj_card_slot, irandom(_n - 1));
    if (instance_exists(_slot)) _slot.cooldown_timer = _slot.cooldown;
}

/// @function hex_batch2_on_boss_enter(_boss)
/// @desc BOSS 入场：加火苗；本局第一个 BOSS 额外给全队攻击
function hex_batch2_on_boss_enter(_boss) {
    if (!hex_enabled()) return;
    if (!hex_batch2_ensure()) return;
    var _s = global.hex_state;

    if (_s.b2_boss_flame > 0 && variable_global_exists("flame")) {
        var _cap = 999999;
        if (variable_global_exists("flame_cap")) _cap = global.flame_cap;
        global.flame = min(global.flame + _s.b2_boss_flame, _cap);
    }
    if (!_s.b2_boss_atk_done && _s.b2_boss_atk > 0) {
        _s.b2_boss_atk_done = true;
        if (variable_global_exists("buff_apply_id")) global.buff_apply_id += 1;
    }
}

/// @function hex_batch2_hole_refund()
/// @desc 鼠洞被清除时的返还
function hex_batch2_hole_refund() {
    if (!hex_enabled()) return;
    if (!hex_batch2_ensure()) return;
    if (!global.hex_state.b2_hole_refund) return;

    var _flame = 25;
    var _gold  = 100;
    if (random(1) < 0.01) {
        _flame = 100;
        _gold  = 5000;
    }
    if (variable_global_exists("flame")) {
        var _cap = 999999;
        if (variable_global_exists("flame_cap")) _cap = global.flame_cap;
        global.flame = min(global.flame + _flame, _cap);
    }
    if (variable_global_exists("save_data") && is_struct(global.save_data)
        && variable_struct_exists(global.save_data, "player")) {
        global.save_data.player.gold += _gold;
    }
}

// ══════════════════════ 每帧 / 每秒 ══════════════════════

/// @function hex_batch2_tick()
/// @desc 第二批的周期总入口，由 hex_periodic_run() 每帧调用。
///       内部按毫秒切【每秒】块，避免受帧率/加速影响
function hex_batch2_tick() {
    if (!hex_enabled()) return;
    if (!hex_batch2_ensure()) return;
    var _s = global.hex_state;

    // 【搏一搏】：每关只在开局掷一次，之后本关奖励倍率固定
    if (variable_struct_exists(_s, "b2_gamble_ready")) {
        var _lid = "";
        if (variable_global_exists("level_id")) _lid = string(global.level_id);
        if (!variable_struct_exists(_s, "b2_gamble_level") || _s.b2_gamble_level != _lid) {
            _s.b2_gamble_level = _lid;
            if (random(1) < 0.5) _s.b2_gamble = 2.0;
            else                _s.b2_gamble = 0.5;
        }
    }

    // 【认知偏差】抽到后立刻变成另一条：哪怕处于暂停（面板里刚确认）也要结算
    if (_s.b2_cognition_pending) {
        _s.b2_cognition_pending = false;
        hex_batch2_cognition_roll();
    }

    // 暂停时不推进任何周期效果（召唤 / 刷洞 / 叠血），否则选卡面板开着也会刷怪
    if (variable_global_exists("is_paused") && global.is_paused) return;

    // 计数：同种卡在场上多少张（【炸丸子】用）
    if (_s.b2_count_atk != "") hex_batch2_count_cards();

    // ── 落地效果：沉睡 / 无敌 ──
    if (_s.b2_sleep > 0 || _s.b2_invuln > 0) hex_batch2_placement_effects();

    // ── 每秒块 ──
    if (current_time - _s.b2_tick_ms >= 1000) {
        _s.b2_tick_ms = current_time;

        // 山脉龙魂：生命上限随时间叠加
        if (_s.b2_hp_stack > 0) {
            var _step = _s.b2_hp_stack;
            var _cap  = _s.b2_hp_stack_cap;
            with (obj_card_parent) {
                if (self.plant_id != "player") {
                    if (!variable_instance_exists(self.id, "b2_hp_stack")) self.b2_hp_stack = 0;
                    if (self.b2_hp_stack < _cap) {
                        self.b2_hp_stack = min(_cap, self.b2_hp_stack + _step);
                        var _base = self.max_hp;
                        if (variable_instance_exists(self.id, "base_max_hp")) _base = self.base_max_hp;
                        // 公式必须与 obj_mod_battle_manager 的「纯上限」完全一致，
                        // 否则这边每秒把 max_hp 设回不含取长补短 / 固定生命的旧值，血条会抖一下
                        var _nm = _base * hex_hp_mult_for_card(self.plant_id) * (1 + self.b2_hp_stack);
                        var _fx = hex_batch2_id_hp_fix(self.plant_id);
                        if (_fx > 0) _nm = _fx;
                        if (hex_batch2_equalize_on()) _nm = max(self.atk, _nm);
                        var _old_max = self.max_hp;
                        self.max_hp = _nm;
                        if (_old_max > 0 && self.max_hp != _old_max && self.hp > 0)
                            self.hp = min(self.max_hp, self.hp * (self.max_hp / _old_max));
                        if (self.hp > self.max_hp) self.hp = self.max_hp;
                    }
                }
            }
        }

        // 达摩克里斯之剑：每秒概率强化一只老鼠
        if (_s.b2_e_super > 0 && random(1) < _s.b2_e_super) {
            var _n = instance_number(obj_enemy_parent);
            if (_n > 0) {
                var _e = instance_find(obj_enemy_parent, irandom(_n - 1));
                if (instance_exists(_e) && variable_instance_exists(_e, "maxhp")) {
                    _e.maxhp += round(_s.b2_e_super_hp);
                    _e.hp = _e.maxhp;
                    if (variable_instance_exists(_e, "move_speed")) {
                        _e.move_speed *= (1 + _s.b2_e_super_spd);
                    }
                }
            }
        }
    }

    // ── 大战：每 N 秒让一只在场老鼠召唤同类 ──
    if (_s.b2_e_summon > 0) {
        if (current_time - _s.b2_summon_ms >= _s.b2_e_summon * 1000) {
            _s.b2_summon_ms = current_time;
            var _cnt = instance_number(obj_enemy_parent);
            if (_cnt > 0 && _cnt < 55 && variable_global_exists("enemy_map")) {
                var _pick = instance_find(obj_enemy_parent, irandom(_cnt - 1));
                if (instance_exists(_pick)) {
                    var _is_boss = false;
                    if (variable_instance_exists(_pick, "is_boss")) _is_boss = _pick.is_boss;
                    if (!_is_boss) {
                        var _new = instance_create_depth(_pick.x, _pick.y, _pick.depth, _pick.object_index);
                        hex_enemy_scale(_new);
                    }
                }
            }
        }
    }

    // ── 爱打洞的老鼠：每 N 秒在右侧五列刷一个鼠洞 ──
    if (_s.b2_e_hole > 0) {
        if (current_time - _s.b2_hole_ms >= _s.b2_e_hole * 1000) {
            _s.b2_hole_ms = current_time;
            hex_batch2_spawn_hole();
        }
    }
}

/// @function hex_batch2_count_cards()
/// @desc 维护 card_id -> 场上张数
function hex_batch2_count_cards() {
    var _s = global.hex_state;
    _s.b2_id_count = {};
    with (obj_card_parent) {
        if (self.plant_id != "player") {
            var _pid = self.plant_id;
            var _n = 1;
            if (variable_struct_exists(global.hex_state.b2_id_count, _pid)) {
                _n = global.hex_state.b2_id_count[$ _pid] + 1;
            }
            global.hex_state.b2_id_count[$ _pid] = _n;
        }
    }
}

/// @function hex_batch2_frames_to_ms(_frames)
/// @desc 词条表里的时长一律按「帧」写（60 帧/秒）。凡是拿 current_time（毫秒）
///       做比较的地方，必须先过这个换算，否则 180 帧会被当成 180 毫秒。
function hex_batch2_frames_to_ms(_frames) {
    return _frames * (1000 / 60);
}

/// @function hex_batch2_placement_effects()
/// @desc 新卡落地：沉睡 10 秒 / 无敌 3 秒
function hex_batch2_placement_effects() {
    var _s = global.hex_state;
    var _sleep = _s.b2_sleep;
    var _inv   = _s.b2_invuln;

    with (obj_card_parent) {
        if (self.plant_id != "player") {
            if (!variable_instance_exists(self.id, "b2_placed")) {
                self.b2_placed = true;
                self.b2_inv_was = self.invincible;
                if (_sleep > 0 && hex_batch2_is_attack_card(self.plant_id)) {
                    self.state = CARD_STATE.SLEEP;
                    self.awake_buff_timer = max(self.awake_buff_timer, _sleep);
                }
                if (_inv > 0) {
                    self.invincible = true;
                    self.b2_inv_until = current_time + hex_batch2_frames_to_ms(_inv);
                }
            }
            if (variable_instance_exists(self.id, "b2_inv_until") && self.b2_inv_until > 0) {
                if (current_time >= self.b2_inv_until) {
                    self.b2_inv_until = 0;
                    self.invincible = self.b2_inv_was;
                }
            }
        }
    }
}

/// @function hex_batch2_spawn_hole()
/// @desc 在最右侧五列找一个可放置格刷鼠洞
function hex_batch2_spawn_hole() {
    if (!variable_global_exists("grid_terrains")) return;
    if (!variable_global_exists("grid_cols") || !variable_global_exists("grid_rows")) return;
    var _cols = global.grid_cols;
    var _rows = global.grid_rows;
    if (_cols <= 0 || _rows <= 0) return;

    var _start = max(0, _cols - 5);
    for (var try_i = 0; try_i < 8; try_i++) {
        var _c = irandom_range(_start, _cols - 1);
        var _r = irandom(_rows - 1);
        var _cell = global.grid_terrains[_r][_c];
        if (is_struct(_cell) && _cell.type == "obstacle") continue;
        var _wp = get_world_position_from_grid(_c, _r);
        var _hole = instance_create_depth(_wp.x, _wp.y, -5, obj_mouse_hole);
        if (instance_exists(_hole)) {
            _hole.grid_row = _r;
            _hole.grid_col = _c;
        }
        return;
    }
}

/// @function hex_batch2_cognition_roll()
/// @desc 认知偏差：银 50% / 金 30% / 彩 20%，随机挑一条未满层的实装词条并入
function hex_batch2_cognition_roll() {
    if (!variable_global_exists("hex_ids")) return;
    var _r = random(1);
    var _tier = 0;
    if (_r >= 0.5 && _r < 0.8) _tier = 1;
    if (_r >= 0.8) _tier = 2;

    // 该档抽不到就跨档兜底
    var _order = [_tier, 0, 1, 2];
    for (var t = 0; t < array_length(_order); t++) {
        var _cands = [];
        for (var i = 0; i < array_length(global.hex_ids); i++) {
            var _id = global.hex_ids[i];
            if (_id == "hex_179") continue;
            var _d = hex_get(_id);
            if (is_undefined(_d)) continue;
            if (_d.tier != _order[t]) continue;
            if (!hex_pickable(_id)) continue;
            array_push(_cands, _id);
        }
        if (array_length(_cands) > 0) {
            hex_apply(_cands[irandom(array_length(_cands) - 1)]);
            return;
        }
    }
}

// ══════════════════════ 词条表 ══════════════════════

/// @function hex_register_batch2()
/// @desc 注册第二批词条。由 hex_registry_init() 调用
function hex_register_batch2() {

    // ══════════ 已实装 ══════════
    hex_register("hex_113", {
        tier: 1, form: "A", name: "剧毒美食I",
        card_desc: "该卡爆炸段完全随机（50% 概率炸鼠），灰烬伤害 ×11",
        enemy_desc: "无",
        stack: 1, impl: true,
        ex: { b2_puffer: [0.5, 11.0] }, en: {}
    });
    hex_register("hex_118", {
        tier: 2, form: "A", name: "火苗生命体",
        card_desc: "美食受到的伤害改为扣火苗，火苗不足时正常扣血",
        enemy_desc: "无",
        stack: 1, impl: true,
        ex: { b2_flame_shield: true }, en: {}
    });
    hex_register("hex_119", {
        tier: 0, form: "A", name: "均值",
        card_desc: "所有卡槽的卡片费用变为全卡槽的平均值",
        enemy_desc: "老鼠出生时生命额外加上当前火苗数值",
        stack: 1, impl: true,
        ex: { b2_avg_cost: true }, en: { b2_e_hp_flame: true }
    });
    hex_register("hex_120", {
        tier: 2, form: "A", name: "全息制冷",
        card_desc: "全体美食攻击间隔减半",
        enemy_desc: "出怪间隔减半",
        stack: 1, impl: true,
        ex: { cycle: -0.5, b2_spawn: -0.5 }, en: {}
    });
    hex_register("hex_121", {
        tier: 2, form: "A", name: "闪闪发亮",
        card_desc: "拾取每个火苗额外 +25 火苗",
        enemy_desc: "老鼠生命 +25%",
        stack: 1, impl: true,
        ex: { b2_flame_flat: 25 }, en: { e_hp: 0.25 }
    });
    hex_register("hex_124", {
        tier: 1, form: "A", name: "牢大的祝福",
        card_desc: "咖啡杯与融合咖啡杯伤害 ×5；其它攻击类卡片无法放置",
        enemy_desc: "无",
        stack: 1, impl: true,
        ex: { b2_id_atk: [ ["coffee_cup", 4.0], ["ronghekafei", 4.0] ], b2_coffee_only: true }, en: {}
    });
    hex_register("hex_125", {
        tier: 1, form: "A", name: "爆破组就位",
        card_desc: "爆炸类（瞬发类）卡片攻击 +100%，攻击间隔 -50%",
        enemy_desc: "出怪数 +100%；每张在场卡片给老鼠 +1% 生命（上限 +100%）",
        stack: 1, impl: true,
        ex: { cat_atk: [ ["瞬发类", 1.0] ], cat_cycle: [ ["瞬发类", -0.5] ] },
        en: { e_count: 1.0, b2_e_hp_per_card: [0.01, 1.0] }
    });
    hex_register("hex_126", {
        tier: 2, form: "A", name: "炽热火苗",
        card_desc: "火苗上限 +50000；每 1000 火苗给全队 +1% 攻击",
        enemy_desc: "老鼠生命 +50%，移速 +20%",
        stack: 1, impl: true,
        ex: { flame_cap: 50000, b2_flame_atk: 0.01 }, en: { e_hp: 0.5, e_spd: 0.2 }
    });
    hex_register("hex_127", {
        tier: 2, form: "A", name: "达摩克里斯之剑",
        card_desc: "关卡获得的金币与素材奖励 ×10",
        enemy_desc: "每秒 0.75% 概率让一只老鼠生命 +1000000、移速 +200%",
        stack: 1, impl: true,
        ex: { b2_reward: 9.0 }, en: { b2_e_super: [0.0075, 1000000, 2.0] }
    });
    hex_register("hex_129", {
        tier: 1, form: "A", name: "加速",
        card_desc: "全体美食攻击间隔减半",
        enemy_desc: "老鼠移速 ×2、啃咬伤害 ×2",
        stack: 1, impl: true,
        ex: { cycle: -0.5 }, en: { e_spd: 1.0, e_atk: 1.0 }
    });
    hex_register("hex_133", {
        tier: 0, form: "A", name: "暂缓时光",
        card_desc: "关卡限时 +1 分钟",
        enemy_desc: "无",
        stack: 1, impl: true,
        ex: { b2_time_add: 60 }, en: {}
    });
    hex_register("hex_134", {
        tier: 0, form: "A", name: "我真没胖",
        card_desc: "全体卡片生命 +10%",
        enemy_desc: "老鼠攻击 +5%",
        stack: 1, impl: true,
        ex: { hp: 0.10 }, en: { e_atk: 0.05 }
    });
    hex_register("hex_135", {
        tier: 0, form: "C", name: "轻装伏击",
        card_desc: "无",
        enemy_desc: "所有鼠军啃咬过一次后才可被攻击，但生命 -70%",
        stack: 1, impl: true,
        ex: {}, en: { e_hp: -0.7, b2_e_hit_after: true }
    });
    hex_register("hex_136", {
        tier: 0, form: "A", name: "塔之怨念",
        card_desc: "老鼠死亡时 5% 概率 3×3 爆炸，伤害为其生命上限 ×1.2（不分敌我）",
        enemy_desc: "老鼠移速 +20%",
        stack: 1, impl: true,
        ex: { b2_blast: [0.05, 1.2] }, en: { e_spd: 0.2 }
    });
    hex_register("hex_141", {
        tier: 1, form: "A", name: "各种刺身",
        card_desc: "所有美食被啃咬时 100% 反伤",
        enemy_desc: "无",
        stack: 1, impl: true,
        ex: { b2_reflect: 1.0 }, en: {}
    });
    hex_register("hex_142", {
        tier: 2, form: "A", name: "跨接电缆",
        card_desc: "每击杀 75 只老鼠，随机一张卡片冷却立即完毕",
        enemy_desc: "老鼠生命 +25%",
        stack: 1, impl: true,
        ex: { b2_kill_cd: 75 }, en: { e_hp: 0.25 }
    });
    hex_register("hex_143", {
        tier: 1, form: "A", name: "大战",
        card_desc: "每有一张在场美食，全场攻击间隔 -2.5%、攻击 +1%",
        enemy_desc: "在场的鼠军每 7 秒召唤一只同类（BOSS 除外）",
        stack: 1, impl: true,
        ex: { per_card_atk: [0.01, 1.0], b2_per_card_cycle: -0.025 }, en: { b2_e_summon: 7 }
    });
    hex_register("hex_144", {
        tier: 1, form: "A", name: "有规矩，不烧心",
        card_desc: "卡片伤害 ×2.5",
        enemy_desc: "卡片耗火 ×2.5",
        stack: 1, impl: true,
        ex: { atk: 1.5, cost: 1.5 }, en: {}
    });
    hex_register("hex_147", {
        tier: 1, form: "A", name: "熊熊烈火",
        card_desc: "火盆类卡片攻击 ×2，生命值固定为 10",
        enemy_desc: "无",
        stack: 1, impl: true,
        ex: { b2_id_atk: [ ["brazier", 1.0], ["ronghehuopen", 1.0] ],
              b2_id_hp_fix: [ ["brazier", 10], ["ronghehuopen", 10] ] }, en: {}
    });
    hex_register("hex_150", {
        tier: 0, form: "A", name: "3秒真美鼠",
        card_desc: "所有美食放下时无敌 3 秒",
        enemy_desc: "所有鼠军出场时无敌 3 秒",
        stack: 1, impl: true,
        ex: { b2_invuln: 180 }, en: { b2_e_invuln: 180 }
    });
    hex_register("hex_152", {
        tier: 0, form: "A", name: "爱打洞的老鼠",
        card_desc: "爆爆鸡、旋风牛冷却 -75%、耗火 -50%；清除鼠洞返还 25 火苗与 100 金币（1% 概率 100 火苗与 5000 金币）",
        enemy_desc: "每 10 秒在右侧五列随机出现一个鼠洞",
        stack: 1, impl: true,
        ex: { b2_id_cycle: [ ["baobaoji", -0.75], ["xuanfengniu", -0.75] ],
              b2_id_cost:  [ ["baobaoji", -0.5],  ["xuanfengniu", -0.5] ],
              b2_hole_refund: true },
        en: { b2_e_hole: 10 }
    });
    hex_register("hex_154", {
        tier: 1, form: "A", name: "炼金龙魂",
        card_desc: "每损失 20% 生命，受到伤害 -10%（最高 -50%）",
        enemy_desc: "无",
        stack: 1, impl: true,
        ex: { b2_resist: 0.10 }, en: {}
    });
    hex_register("hex_155", {
        tier: 1, form: "A", name: "疾风龙魂",
        card_desc: "灰烬类（一次性）卡片冷却 -50%",
        enemy_desc: "无",
        stack: 1, impl: true,
        ex: { cat_cycle: [ ["灰烬类", -0.5] ] }, en: {}
    });
    hex_register("hex_158", {
        tier: 1, form: "A", name: "海洋龙魂",
        card_desc: "卡片每秒回复 5% 最大生命",
        enemy_desc: "无",
        stack: 1, impl: true,
        ex: { heal_tick: [0.05, 1] }, en: {}
    });
    hex_register("hex_159", {
        tier: 1, form: "A", name: "山脉龙魂",
        card_desc: "卡片每秒叠加 3% 生命上限，最多叠到 +30%",
        enemy_desc: "无",
        stack: 1, impl: true,
        ex: { b2_hp_stack: [0.03, 0.30] }, en: {}
    });
    hex_register("hex_164", {
        tier: 0, form: "A", name: "QQ弹弹",
        card_desc: "防御类卡片受击时改为把老鼠击退 2.5 格（无伤害），自身消耗 50 生命",
        enemy_desc: "无",
        stack: 1, impl: true,
        ex: { b2_knock: [2.5, 50] }, en: {}
    });
    hex_register("hex_165", {
        tier: 0, form: "A", name: "炸丸子",
        card_desc: "追踪类卡片冷却 -50%；同种追踪卡每满 6 张攻击 +20%（最多 +180%）",
        enemy_desc: "无",
        stack: 1, impl: true,
        ex: { cat_cycle: [ ["追踪类", -0.5] ], b2_count_atk: ["追踪类", 0.2, 6] }, en: {}
    });
    hex_register("hex_166", {
        tier: 0, form: "A", name: "荷包蛋",
        card_desc: "投掷类卡片攻击 +50%",
        enemy_desc: "无",
        stack: 1, impl: true,
        ex: { cat_atk: [ ["投掷类", 0.5] ] }, en: {}
    });
    hex_register("hex_167", {
        tier: 0, form: "A", name: "困困虫",
        card_desc: "攻击类卡片种下即沉睡 10 秒，醒来后攻击 +30%",
        enemy_desc: "无",
        stack: 1, impl: true,
        ex: { b2_sleep: [600, 0.30] }, en: {}
    });
    hex_register("hex_168", {
        tier: 0, form: "A", name: "食之灵",
        card_desc: "全体融合卡攻击 +30%",
        enemy_desc: "无",
        stack: 1, impl: true,
        ex: { b2_fusion_atk: 0.30 }, en: {}
    });
    hex_register("hex_169", {
        tier: 0, form: "A", name: "石护盾",
        card_desc: "无",
        enemy_desc: "BOSS 血量降到 75%/50%/25% 时生成需 3 次灰烬伤害打破的护盾；未破前减伤 80%，破后 10 秒内受伤翻倍",
        stack: 1, impl: true,
        ex: {}, en: { b2_boss_shield: ["ash", 3] }
    });
    hex_register("hex_173", {
        tier: 2, form: "A", name: "取长补短",
        card_desc: "美食的攻击与生命，取两者中较高的那个",
        enemy_desc: "无",
        stack: 1, impl: true,
        ex: { b2_equalize: true }, en: {}
    });
    hex_register("hex_179", {
        tier: 1, form: "A", name: "认知偏差",
        card_desc: "选到后立即随机变成另一条词条（银 50% / 金 30% / 彩 20%）",
        enemy_desc: "无",
        stack: 1, impl: true,
        ex: { b2_cognition: true }, en: {}
    });
    hex_register("hex_180", {
        tier: 0, form: "A", name: "碎片整理",
        card_desc: "多行攻击卡片的子弹全部集中到本行（仅对向右飞行的子弹生效）",
        enemy_desc: "无",
        stack: 1, impl: true,
        ex: { b2_bull_row: true }, en: {}
    });
    hex_register("hex_181", {
        tier: 2, form: "A", name: "逆神",
        card_desc: "BOSS 入场立刻获得 3000 火苗；本局第一个 BOSS 入场时全队攻击 +200%",
        enemy_desc: "无",
        stack: 1, impl: true,
        ex: { b2_boss_entry: [3000, 2.0] }, en: {}
    });
    hex_register("hex_182", {
        tier: 1, form: "A", name: "搏一搏摩托变单车",
        card_desc: "关卡奖励 50% 概率翻倍、50% 概率减半",
        enemy_desc: "无",
        stack: 1, impl: true,
        ex: { b2_reward_gamble: true }, en: {}
    });
    hex_register("hex_184", {
        tier: 0, form: "A", name: "低语耳环",
        card_desc: "开局火苗 +1000，每波开始再 +1000",
        enemy_desc: "无",
        stack: 1, impl: true,
        ex: { flame_start: 1000, flame_wave: 1000 }, en: {}
    });

    // ══════════ 未实装（不进抽取池）══════════
    hex_register("hex_112", {
        tier: 1, form: "A", name: "保罗的触手",
        card_desc: "未实装：子弹是各自对象里写死的 x += move_speed，没有统一的速度矢量层，无法改成八向随机",
        enemy_desc: "未实装",
        stack: 1, impl: false, ex: {}, en: {}
    });
    hex_register("hex_114", {
        tier: 2, form: "A", name: "剧毒美食II",
        card_desc: "未实装：需要【选到后替换 I】的回滚机制（现有机制只有叠加，没有撤销）",
        enemy_desc: "未实装",
        stack: 1, impl: false, ex: {}, en: {}
    });
    hex_register("hex_115", {
        tier: 2, form: "A", name: "回归基本功",
        card_desc: "未实装：强制 shape=0 会与转职贴图/技能状态机冲突，需要改角色形态解算",
        enemy_desc: "未实装",
        stack: 1, impl: false, ex: {}, en: {}
    });
    hex_register("hex_116", {
        tier: 0, form: "A", name: "爆燃1",
        card_desc: "未实装：需要火苗落地倒计时爆炸 + 双方 3×3 伤害的新物件逻辑",
        enemy_desc: "未实装",
        stack: 1, impl: false, ex: {}, en: {}
    });
    hex_register("hex_117", {
        tier: 1, form: "A", name: "爆燃2",
        card_desc: "未实装：同爆燃1，且需要连锁爆炸传播",
        enemy_desc: "未实装",
        stack: 1, impl: false, ex: {}, en: {}
    });
    hex_register("hex_122", {
        tier: 2, form: "A", name: "管线王朝",
        card_desc: "未实装：子弹没有【平射/投掷】统一口径与过火标记，无法按类型拆分伤害与减伤",
        enemy_desc: "未实装",
        stack: 1, impl: false, ex: {}, en: {}
    });
    hex_register("hex_123", {
        tier: 2, form: "A", name: "投手王朝",
        card_desc: "未实装：同上，缺少子弹类型统一口径",
        enemy_desc: "未实装",
        stack: 1, impl: false, ex: {}, en: {}
    });
    hex_register("hex_128", {
        tier: 2, form: "A", name: "弯勺魔术",
        card_desc: "未实装：需要把全部攻击卡子弹改造成追踪弹，并禁用喷壶类，属于子弹层重构",
        enemy_desc: "未实装",
        stack: 1, impl: false, ex: {}, en: {}
    });
    hex_register("hex_130", {
        tier: 0, form: "A", name: "鱼塘",
        card_desc: "未实装：局内没有【发一张卡进卡槽】的统一入口，需要改卡槽生成流程",
        enemy_desc: "未实装",
        stack: 1, impl: false, ex: {}, en: {}
    });
    hex_register("hex_131", {
        tier: 1, form: "A", name: "养鱼手册",
        card_desc: "未实装：同鱼塘，且需要按已有转职决定发 1 转还是 2 转",
        enemy_desc: "未实装",
        stack: 1, impl: false, ex: {}, en: {}
    });
    hex_register("hex_132", {
        tier: 0, form: "A", name: "速冻",
        card_desc: "未实装：减速→冻结要改全部减速卡的结算口径，需要一个统一减速入口",
        enemy_desc: "未实装",
        stack: 1, impl: false, ex: {}, en: {}
    });
    hex_register("hex_137", {
        tier: 0, form: "A", name: "化为灰烬",
        card_desc: "未实装：【不可复活】涉及复生饭 / 治愈苗两套独立复活逻辑",
        enemy_desc: "未实装",
        stack: 1, impl: false, ex: {}, en: {}
    });
    hex_register("hex_138", {
        tier: 0, form: "A", name: "谁家锯骨血刺",
        card_desc: "未实装：局内无法直接补一张已放置形态的鱼刺，需要走卡槽发卡流程",
        enemy_desc: "未实装",
        stack: 1, impl: false, ex: {}, en: {}
    });
    hex_register("hex_140", {
        tier: 2, form: "A", name: "财运锻造器",
        card_desc: "未实装：金币消费发生在局外熔炼界面，海克斯是局内状态，跨不到那边",
        enemy_desc: "未实装",
        stack: 1, impl: false, ex: {}, en: {}
    });
    hex_register("hex_145", {
        tier: 1, form: "A", name: "给你糖完了",
        card_desc: "未实装：布丁与水神的反弹在各自对象里实现，复制子弹需要逐个改",
        enemy_desc: "未实装",
        stack: 1, impl: false, ex: {}, en: {}
    });
    hex_register("hex_146", {
        tier: 2, form: "A", name: "大哥来了",
        card_desc: "未实装：150 发散射在机枪小笼包对象内实现，且同屏子弹数会拖垮性能",
        enemy_desc: "未实装",
        stack: 1, impl: false, ex: {}, en: {}
    });
    hex_register("hex_148", {
        tier: 2, form: "A", name: "致命节奏",
        card_desc: "未实装：没有一个统一的【卡片开火】事件，无法统计连续攻击层数",
        enemy_desc: "未实装",
        stack: 1, impl: false, ex: {}, en: {}
    });
    hex_register("hex_149", {
        tier: 2, form: "A", name: "幸运蒸包",
        card_desc: "未实装：局内没有金币结算出口，金币只在通关奖励里发",
        enemy_desc: "未实装",
        stack: 1, impl: false, ex: {}, en: {}
    });
    hex_register("hex_151", {
        tier: 0, form: "A", name: "死灵复苏",
        card_desc: "未实装：魂鼠是龙渊专属敌人，普通关卡没有可复用的魂鼠对象",
        enemy_desc: "未实装",
        stack: 1, impl: false, ex: {}, en: {}
    });
    hex_register("hex_156", {
        tier: 1, form: "A", name: "雷电龙魂",
        card_desc: "未实装：需要在受伤事件里做二次溅射，递归伤害容易打穿钩子，需先做伤害来源标记",
        enemy_desc: "未实装",
        stack: 1, impl: false, ex: {}, en: {}
    });
    hex_register("hex_157", {
        tier: 1, form: "A", name: "烈火龙魂",
        card_desc: "未实装：同雷电龙魂",
        enemy_desc: "未实装",
        stack: 1, impl: false, ex: {}, en: {}
    });
    hex_register("hex_160", {
        tier: 0, form: "A", name: "压榨I",
        card_desc: "未实装：需要在铲子对象里加【范围作用于产能卡】的分支，属铲子逻辑改造",
        enemy_desc: "未实装",
        stack: 1, impl: false, ex: {}, en: {}
    });
    hex_register("hex_161", {
        tier: 1, form: "A", name: "压榨II",
        card_desc: "未实装：同压榨I，且要记录【已翻倍】的卡片状态",
        enemy_desc: "未实装",
        stack: 1, impl: false, ex: {}, en: {}
    });
    hex_register("hex_170", {
        tier: 0, form: "A", name: "火焰杯",
        card_desc: "未实装：需要新素材（火焰杯未点燃/点燃两态）与新放置物件",
        enemy_desc: "未实装",
        stack: 1, impl: false, ex: {}, en: {}
    });
    hex_register("hex_171", {
        tier: 0, form: "A", name: "火护盾",
        card_desc: "未实装：需要【减速伤害】的统一标记，现有 damage_type 里没有这一类",
        enemy_desc: "未实装",
        stack: 1, impl: false, ex: {}, en: {}
    });
    hex_register("hex_172", {
        tier: 0, form: "A", name: "丰收季",
        card_desc: "未实装：需要新建红/绿苹果物件与贴图，以及一套独立的吸引火力逻辑",
        enemy_desc: "未实装",
        stack: 1, impl: false, ex: {}, en: {}
    });

    return true;
}
