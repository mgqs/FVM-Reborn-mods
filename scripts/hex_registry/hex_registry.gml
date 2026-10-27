/// hex_registry —— 海克斯词条库（111 条，v0.11 全表重写）
///
/// 铁律：**描述即实现**。每一条的 card_desc / enemy_desc 必须和 ex / en 里的数值一一对应。
/// 表里凡是引擎当前无法表达的机制（穿透数、溅射范围、灼烧持续、星级随机、选卡时间……），
/// 一律改写成等效且真实生效的描述，不允许出现"文案写着穿透 +1，实际只加攻击"却不说的情况。
/// 已改写条目在 docs/海克斯玩法设计.md 的 v0.11 变更记录里有清单。
///
/// 数值约定：ex / en 里的值都是「增量」——0.08 = +8%，-0.18 = -18%。
/// en 的 e_hp 同时承接「老鼠护甲」（本作敌人没有独立护甲字段，护甲并入生命）。
///
/// ══════════ ex 通道（hex_apply_core 逐项消费）══════════
///  数值类：atk / cycle / hp / cat_atk / cat_cycle / cat_hp
///          flame_start / flame_wave / flame_cap / flame_growth / wave_flame_pct
///          flame_tick（配 flame_tick_sec）/ heal_wave / free_reroll
///  机制类：
///     refund        铲除返还倍率增量        hex_refund_mult
///     cost          卡片费用倍率增量        hex_cost_mult
///     gridless      增幅/辅助不占格         hex_gridless_for_card
///     free_place    每波首次放置免费        hex_free_place_ready
///     wave_reset    每波开始卡槽冷却清零    hex_on_wave_start
///     bond_power    共鸣强度增量            hex_bond_mult_for_card
///     bond_req_major / bond_req_minor       hex_bond_thresholds
///     bond_extra    最多大分类共鸣计数 +N   hex_bond_recalc
///     bond_extra_minor 最多小分类计数 +N    hex_bond_recalc
///     top_atk       最多小分类攻击增量      hex_dyn_atk_bonus
///     per_card_atk  [每张卡攻击, 封顶]      hex_dyn_atk_bonus
///     kill_flame    [概率, 火苗]            hex_on_kill
///     kill_stack    [每层攻击, 层数上限]    hex_on_kill
///     elite_atk     [每精英攻击, 层数上限]  hex_on_wave_start
///     wave_clear_flame [火苗, 攻击, 上限]   hex_on_wave_start
///     crit          [概率, 倍率]            hex_damage_taken_mult
///     anti_air      对空伤害增量            hex_damage_taken_mult
///     slow_bonus    对被减速目标伤害增量    hex_damage_taken_mult
///     atk_floor     攻击力下限比例          hex_card_atk_floor
///     range_cut     卡片受到伤害减免        hex_card_incoming_damage
///     atk_per_speed 攻速换攻击的系数        hex_atk_per_speed_mult
///     card_death_pct 卡片被摧毁时反击倍数   hex_card_death_pct
///     top_card_atk  [攻击倍率, 攻速增量]    hex_top_card_atk_mult
///     other_atk     其余卡片攻击增量        hex_atk_mult_for_card
///     first_col_atk 每行最左卡片攻击增量    obj_mod_battle_manager
///     near_cycle    [攻速增量, 判定格数]    hex_near_cycle_hit
///     field_need_atk [卡数门槛, 攻击]       hex_dyn_atk_bonus
///     borrow_atk    [每张增幅类, 封顶]      hex_dyn_atk_bonus
///     minor_stack_atk 同小分类每多一张       hex_dyn_atk_bonus
///     deck_theme_atk [卡组张数, 攻击]       hex_dyn_atk_bonus
///     deck_per_atk  [卡组张数, 每张攻击]    hex_dyn_atk_bonus
///     ash_mix_atk   灰烬+非灰烬共存攻击     hex_dyn_atk_bonus
///     min_cat_atk   最少分类攻击增量        hex_dyn_atk_bonus
///     pair_atk      [[分类A,分类B], 攻击]   hex_dyn_atk_bonus
///     wave_flame_cap 「每波转火苗」封顶      hex_on_wave_start
///     heal_tick     [比例, 秒]              hex_periodic_run
///     prod_bonus    产能类每次产出 +N       hex_card_prod_bonus
///     deck_cap      卡组上限增量            deck_slot_max
///     zero_cd       [费用倍率, 火苗损失]    hex_card_cooldown
///     same_card_free 每波第 2 张同名卡免费  hex_same_card_free_ready
///     terrain_free  任意地形可放置          can_place_at_position
///     refund_chance 放置概率全额返还        hex_placement_refund_chance
///     cap_fixed / cap_half / cap_unbound    hex_sync_flame_cap
///     nuke          [秒, 全队攻击比例]      hex_periodic_run
///     burn          [秒, 最大生命比例]      hex_periodic_run
///     buff_grant    增幅类倍率增量          hex_buff_grant_mult
///     star_start    开局全体 +N 星          hex_star_on_card
///     ash_explode   灰烬死亡 3x3 爆炸       hex_on_card_destroyed
///     ash_revive    灰烬死亡后复活          hex_on_card_destroyed
///
/// ══════════ en 通道 ══════════
///   e_hp / e_spd / e_atk / e_count    hex_enemy_mult
///   e_bite      啃咬速度倍率          hex_enemy_bite_mult
///   e_hp_air / e_hp_dive / e_hp_ground / e_hp_block   hex_enemy_hp_mult_for
///   e_max_cards 场上美食上限          hex_enemy_max_cards
///   e_card_insta 卡片受伤即死概率     hex_card_incoming_damage
///   e_card_drain 卡片受伤后最大生命流失 hex_card_drain_pct
///   e_card_blast 卡片阵亡时 3x3 反噬  hex_on_card_destroyed
///   e_no_cat    禁用猫                hex_enemy_no_cat

/// @function hex_registry_init()
/// @desc 建立词条库。必须在 card_category_init() 之后调用
function hex_registry_init() {
    global.hex_db  = {};
    global.hex_ids = [];
    hex_register_builtin();
    // 第二批（hex_112 ~ hex_184）：机制实现集中在 scripts/hex_batch2
    hex_register_batch2();
    var _n = 0;
    for (var i = 0; i < array_length(global.hex_ids); i++) {
        if (global.hex_db[$ global.hex_ids[i]].impl) _n++;
    }
    show_debug_message("海克斯词条库：" + string(array_length(global.hex_ids)) + " 条，可抽取 " + string(_n) + " 条");
}

/// @function hex_register(_id, _data)
function hex_register(_id, _data) {
    if (!variable_global_exists("hex_db")) return;
    if (variable_struct_exists(global.hex_db, _id)) return;
    array_push(global.hex_ids, _id);
    global.hex_db[$ _id] = _data;
}

/// @function hex_get(_id)
/// @desc 取词条定义，未注册返回 undefined
function hex_get(_id) {
    if (!variable_global_exists("hex_db")) return undefined;
    if (!variable_struct_exists(global.hex_db, _id)) return undefined;
    return global.hex_db[$ _id];
}

/// @function hex_tier_name(_tier)
function hex_tier_name(_tier) {
    switch (_tier) { case 0: return "银"; case 1: return "金"; default: return "彩"; }
}

function hex_register_builtin() {

    // ══════════════════════════════ 银 · 43 ══════════════════════════════
    hex_register("hex_001", {
        tier: 0, form: "A", name: "开胃小菜",
        card_desc: "开局火苗 +350", enemy_desc: "老鼠生命 +8%",
        stack: 1, impl: true,
        ex: { flame_start: 350 }, en: { e_hp: 0.08 }
    });
    hex_register("hex_002", {
        tier: 0, form: "A", name: "慢火细煮",
        card_desc: "火苗获取量 +20%", enemy_desc: "老鼠移速 +6%",
        stack: 2, impl: true,
        ex: { flame_growth: 0.20 }, en: { e_spd: 0.06 }
    });
    hex_register("hex_003", {
        tier: 0, form: "A", name: "剩菜打包",
        card_desc: "每波结束获得当前火苗 8%（上限 200）", enemy_desc: "老鼠数量 +5%",
        stack: 1, impl: true,
        ex: { wave_flame_pct: 0.08, wave_flame_cap: 200 }, en: { e_count: 0.05 }
    });
    hex_register("hex_004", {
        tier: 0, form: "A", name: "老汤底",
        card_desc: "每波开始火苗 +100", enemy_desc: "老鼠护甲 +6%",
        stack: 2, impl: true,
        ex: { flame_wave: 100 }, en: { e_hp: 0.06 }
    });
    hex_register("hex_005", {
        tier: 0, form: "A", name: "稳火",
        card_desc: "每 15 秒火苗 +25", enemy_desc: "老鼠数量 +4%",
        stack: 2, impl: true,
        ex: { flame_tick: 25, flame_tick_sec: 15 }, en: { e_count: 0.04 }
    });
    hex_register("hex_006", {
        tier: 0, form: "A", name: "边角料",
        card_desc: "击杀老鼠 3% 概率火苗 +10", enemy_desc: "老鼠生命 +7%",
        stack: 1, impl: true,
        ex: { kill_flame: [0.03, 10] }, en: { e_hp: 0.07 }
    });
    hex_register("hex_007", {
        tier: 0, form: "A", name: "轻油少盐",
        card_desc: "卡片费用 -8%", enemy_desc: "老鼠生命 +10%",
        stack: 1, impl: true,
        ex: { cost: -0.08 }, en: { e_hp: 0.10 }
    });
    hex_register("hex_008", {
        tier: 0, form: "A", name: "一锅两吃",
        card_desc: "直射类与投掷类同时在场时，两者攻击各 +5%", enemy_desc: "老鼠生命 +7%",
        stack: 1, impl: true,
        ex: { pair_atk: [["直射类", "投掷类"], 0.05] }, en: { e_hp: 0.07 }
    });
    hex_register("hex_009", {
        tier: 0, form: "A", name: "盐少许",
        card_desc: "全队攻击 +10%", enemy_desc: "老鼠生命 +8%",
        stack: 2, impl: true,
        ex: { atk: 0.10 }, en: { e_hp: 0.08 }
    });
    hex_register("hex_010", {
        tier: 0, form: "A", name: "快手翻炒",
        card_desc: "全部卡片冷却 -8%", enemy_desc: "老鼠啃咬速度 +8%",
        stack: 2, impl: true,
        ex: { cycle: -0.08 }, en: { e_bite: 0.08 }
    });
    hex_register("hex_011", {
        tier: 0, form: "A", name: "一勺到底",
        card_desc: "卡片生命 +25%", enemy_desc: "老鼠攻击 +10%",
        stack: 2, impl: true,
        ex: { hp: 0.25 }, en: { e_atk: 0.10 }
    });
    hex_register("hex_012", {
        tier: 0, form: "A", name: "小火慢煮",
        card_desc: "每 10 秒回复 1.2% 最大生命", enemy_desc: "老鼠移速 +6%",
        stack: 2, impl: true,
        ex: { heal_tick: [0.012, 10] }, en: { e_spd: 0.06 }
    });
    hex_register("hex_013", {
        tier: 0, form: "A", name: "稳住锅气",
        card_desc: "卡片攻击力不低于基础值的 80%", enemy_desc: "老鼠啃咬速度 +6%",
        stack: 1, impl: true,
        ex: { atk_floor: 0.80 }, en: { e_bite: 0.06 }
    });
    hex_register("hex_014", {
        tier: 0, form: "A", name: "灶台擦净",
        card_desc: "卡片受到的伤害 -10%", enemy_desc: "老鼠生命 +8%",
        stack: 1, impl: true,
        ex: { range_cut: 0.10 }, en: { e_hp: 0.08 }
    });
    hex_register("hex_015", {
        tier: 0, form: "A", name: "一撮糖",
        card_desc: "攻击 10% 概率造成 1.5 倍伤害", enemy_desc: "老鼠生命 +9%",
        stack: 1, impl: true,
        ex: { crit: [0.10, 1.5] }, en: { e_hp: 0.09 }
    });
    hex_register("hex_016", {
        tier: 0, form: "A", name: "小火温养",
        card_desc: "每波开始全体回复 8% 生命", enemy_desc: "老鼠啃咬速度 +5%",
        stack: 2, impl: true,
        ex: { heal_wave: 0.08 }, en: { e_bite: 0.05 }
    });
    hex_register("hex_017", {
        tier: 0, form: "A", name: "刀工精细",
        card_desc: "直射类攻速 +12%", enemy_desc: "老鼠生命 +10%",
        stack: 2, impl: true,
        ex: { cat_cycle: [ ["直射类", -0.12] ] }, en: { e_hp: 0.10 }
    });
    hex_register("hex_018", {
        tier: 0, form: "A", name: "面糊裹身",
        card_desc: "投掷类攻击 +14%", enemy_desc: "空中老鼠生命 +12%",
        stack: 2, impl: true,
        ex: { cat_atk: [ ["投掷类", 0.14] ] }, en: { e_hp_air: 0.12 }
    });
    hex_register("hex_019", {
        tier: 0, form: "A", name: "文火慢烤",
        card_desc: "灰烬类伤害 +18%", enemy_desc: "老鼠移速 +7%",
        stack: 2, impl: true,
        ex: { cat_atk: [ ["灰烬类", 0.18] ] }, en: { e_spd: 0.07 }
    });
    hex_register("hex_020", {
        tier: 0, form: "A", name: "精油润锅",
        card_desc: "喷壶类攻击 +10%", enemy_desc: "老鼠生命 +9%",
        stack: 1, impl: true,
        ex: { cat_atk: [ ["喷壶类", 0.10] ] }, en: { e_hp: 0.09 }
    });
    hex_register("hex_021", {
        tier: 0, form: "A", name: "香料提味",
        card_desc: "增幅类卡片提供的倍率 +6%", enemy_desc: "老鼠数量 +4%",
        stack: 2, impl: true,
        ex: { buff_grant: 0.06 }, en: { e_count: 0.04 }
    });
    hex_register("hex_022", {
        tier: 0, form: "A", name: "隔水加热",
        card_desc: "产能类每次产出 +1 火苗", enemy_desc: "老鼠生命 +8%",
        stack: 1, impl: true,
        ex: { prod_bonus: 1 }, en: { e_hp: 0.08 }
    });
    hex_register("hex_023", {
        tier: 0, form: "A", name: "薄切",
        card_desc: "直线穿透类攻击 +12%", enemy_desc: "老鼠生命 +8%",
        stack: 1, impl: true,
        ex: { cat_atk: [ ["直线穿透类", 0.12] ] }, en: { e_hp: 0.08 }
    });
    hex_register("hex_024", {
        tier: 0, form: "A", name: "油温够高",
        card_desc: "灼烧投手攻击 +10%", enemy_desc: "老鼠移速 +6%",
        stack: 2, impl: true,
        ex: { cat_atk: [ ["灼烧投手", 0.10] ] }, en: { e_spd: 0.06 }
    });
    hex_register("hex_025", {
        tier: 0, form: "A", name: "夹生",
        card_desc: "投掷类攻击 +10%", enemy_desc: "老鼠生命 +6%",
        stack: 1, impl: true,
        ex: { cat_atk: [ ["投掷类", 0.10] ] }, en: { e_hp: 0.06 }
    });
    hex_register("hex_026", {
        tier: 0, form: "A", name: "三线全开",
        card_desc: "多向类每方向伤害 +8%", enemy_desc: "老鼠护甲 +5%",
        stack: 1, impl: true,
        ex: { cat_atk: [ ["多向类", 0.08] ] }, en: { e_hp: 0.05 }
    });
    hex_register("hex_027", {
        tier: 0, form: "A", name: "甜咸平衡",
        card_desc: "辅助类生命 +20%", enemy_desc: "老鼠数量 +5%",
        stack: 1, impl: true,
        ex: { cat_hp: [ ["辅助类", 0.20] ] }, en: { e_count: 0.05 }
    });
    hex_register("hex_028", {
        tier: 0, form: "A", name: "防空警报",
        card_desc: "对空中目标伤害 +12%", enemy_desc: "地面老鼠生命 +8%",
        stack: 2, impl: true,
        ex: { anti_air: 0.12 }, en: { e_hp_ground: 0.08 }
    });
    hex_register("hex_029", {
        tier: 0, form: "A", name: "冰镇",
        card_desc: "全队攻速 +8%", enemy_desc: "老鼠移速 +6%",
        stack: 1, impl: true,
        ex: { cycle: -0.08 }, en: { e_spd: 0.06 }
    });
    hex_register("hex_030", {
        tier: 0, form: "A", name: "抽薪",
        card_desc: "火苗获取量 +14%", enemy_desc: "老鼠生命 +8%",
        stack: 1, impl: true,
        ex: { flame_growth: 0.14 }, en: { e_hp: 0.08 }
    });
    hex_register("hex_031", {
        tier: 0, form: "A", name: "去腥",
        card_desc: "直射类攻击 +12%", enemy_desc: "潜水鼠生命 +10%",
        stack: 1, impl: true,
        ex: { cat_atk: [ ["直射类", 0.12] ] }, en: { e_hp_dive: 0.10 }
    });
    hex_register("hex_032", {
        tier: 0, form: "A", name: "去骨",
        card_desc: "投掷类攻击 +12%", enemy_desc: "空中老鼠生命 +10%",
        stack: 1, impl: true,
        ex: { cat_atk: [ ["投掷类", 0.12] ] }, en: { e_hp_air: 0.10 }
    });
    hex_register("hex_033", {
        tier: 0, form: "A", name: "除霜",
        card_desc: "灰烬类伤害 +14%", enemy_desc: "障碍类老鼠生命 +12%",
        stack: 1, impl: true,
        ex: { cat_atk: [ ["灰烬类", 0.14] ] }, en: { e_hp_block: 0.12 }
    });
    hex_register("hex_034", {
        tier: 0, form: "A", name: "净锅",
        card_desc: "卡片生命 +18%", enemy_desc: "老鼠移速 +10%",
        stack: 1, impl: true,
        ex: { hp: 0.18 }, en: { e_spd: 0.10 }
    });
    hex_register("hex_035", {
        tier: 0, form: "A", name: "顺手一抹",
        card_desc: "铲除返还 +40%", enemy_desc: "老鼠生命 +6%",
        stack: 1, impl: true,
        ex: { refund: 0.40 }, en: { e_hp: 0.06 }
    });
    hex_register("hex_036", {
        tier: 0, form: "A", name: "双份备料",
        card_desc: "卡组上限 +1", enemy_desc: "老鼠数量 +6%",
        stack: 1, impl: true,
        ex: { deck_cap: 1 }, en: { e_count: 0.06 }
    });
    hex_register("hex_037", {
        tier: 0, form: "A", name: "半成品",
        card_desc: "本局获得 2 次免费重随", enemy_desc: "老鼠生命 +8%",
        stack: 1, impl: true,
        ex: { free_reroll: 2 }, en: { e_hp: 0.08 }
    });
    hex_register("hex_038", {
        tier: 0, form: "A", name: "火候观察",
        card_desc: "卡片冷却归零，但费用 x5，每次使用后损失当前火苗的 1/4", enemy_desc: "老鼠生命 +4%",
        stack: 1, impl: true,
        ex: { zero_cd: [5.0, 0.25] }, en: { e_hp: 0.04 }
    });

    // ── 银 · 减码 5 ──
    hex_register("hex_039", {
        tier: 0, form: "C", name: "少油",
        card_desc: "全队攻速 -6%", enemy_desc: "老鼠移速 -5%",
        stack: 1, impl: true,
        ex: { cycle: 0.06 }, en: { e_spd: -0.05 }
    });
    hex_register("hex_040", {
        tier: 0, form: "C", name: "收汁",
        card_desc: "火苗上限 -800", enemy_desc: "老鼠生命 -6%",
        stack: 1, impl: true,
        ex: { flame_cap: -800 }, en: { e_hp: -0.06 }
    });
    hex_register("hex_041", {
        tier: 0, form: "C", name: "冷冻保鲜",
        card_desc: "全部卡片冷却 +8%", enemy_desc: "老鼠攻击 -28%",
        stack: 1, impl: true,
        ex: { cycle: 0.08 }, en: { e_atk: -0.28 }
    });
    hex_register("hex_042", {
        tier: 0, form: "C", name: "清汤寡水",
        card_desc: "卡片生命 -15%", enemy_desc: "老鼠护甲 -18%",
        stack: 1, impl: true,
        ex: { hp: -0.15 }, en: { e_hp: -0.18 }
    });
    hex_register("hex_043", {
        tier: 0, form: "C", name: "老灶台",
        card_desc: "每波开始火苗 -50", enemy_desc: "老鼠数量 -5%",
        stack: 1, impl: true,
        ex: { flame_wave: -50 }, en: { e_count: -0.05 }
    });

    // ══════════════════════════════ 金 · 39 ══════════════════════════════
    hex_register("hex_044", {
        tier: 1, form: "A", name: "大火爆炒",
        card_desc: "直射类攻击间隔 -22%，投掷类 +10%", enemy_desc: "场上美食数量不能超过 50",
        stack: 1, impl: true,
        ex: { cat_cycle: [ ["直射类", -0.22], ["投掷类", 0.10] ] }, en: { e_max_cards: 50 }
    });
    hex_register("hex_045", {
        tier: 1, form: "A", name: "面点师",
        card_desc: "投掷类攻击 +30%，直射类 -10%", enemy_desc: "美食受伤时 1/3 概率立即死亡",
        stack: 1, impl: true,
        ex: { cat_atk: [ ["投掷类", 0.30], ["直射类", -0.10] ] }, en: { e_card_insta: 0.3333 }
    });
    hex_register("hex_046", {
        tier: 1, form: "A", name: "火锅底料",
        card_desc: "灰烬类伤害 +35%，阵亡时触发 3x3 爆炸", enemy_desc: "老鼠移速 +14%",
        stack: 1, impl: true,
        ex: { cat_atk: [ ["灰烬类", 0.35] ], ash_explode: true }, en: { e_spd: 0.14 }
    });
    hex_register("hex_047", {
        tier: 1, form: "A", name: "清汤锅",
        card_desc: "灰烬类伤害 +30%，阵亡时对全场老鼠造成攻击 100% 的爆炸", enemy_desc: "老鼠移速 +12%",
        stack: 1, impl: true,
        ex: { cat_atk: [ ["灰烬类", 0.30] ], ash_blast: 1.0 }, en: { e_spd: 0.12 }
    });
    hex_register("hex_048", {
        tier: 1, form: "A", name: "蒸汽加压",
        card_desc: "喷壶类攻击 +30%", enemy_desc: "空中老鼠移速 +14%",
        stack: 1, impl: true,
        ex: { cat_atk: [ ["喷壶类", 0.30] ] }, en: { e_hp_air: 0.14 }
    });
    hex_register("hex_049", {
        tier: 1, form: "A", name: "双灶并行",
        card_desc: "每行最左侧卡片攻击 +28%", enemy_desc: "老鼠护甲 +10%",
        stack: 1, impl: true,
        ex: { first_col_atk: 0.28 }, en: { e_hp: 0.10 }
    });
    hex_register("hex_050", {
        tier: 1, form: "A", name: "现炒现卖",
        card_desc: "全队攻击间隔 -10%", enemy_desc: "美食受伤后额外流失 10% 最大生命",
        stack: 1, impl: true,
        ex: { cycle: -0.10 }, en: { e_card_drain: 0.10 }
    });
    hex_register("hex_051", {
        tier: 1, form: "A", name: "招牌菜",
        card_desc: "场上数量最多的小分类，攻击 +45%", enemy_desc: "老鼠生命 +10%",
        stack: 1, impl: true,
        ex: { top_atk: 0.45 }, en: { e_hp: 0.10 }
    });
    hex_register("hex_052", {
        tier: 1, form: "A", name: "秘制酱料",
        card_desc: "增幅类卡片提供的倍率 +22%", enemy_desc: "卡片火苗消耗 x3",
        stack: 1, impl: true,
        ex: { buff_grant: 0.22, cost: 2.0 }, en: { e_count: 0.0 }
    });
    hex_register("hex_053", {
        tier: 1, form: "A", name: "逆火",
        card_desc: "敌人进入卡片前方 3 格时，该行卡片攻速 +25%", enemy_desc: "老鼠移速 +8%",
        stack: 1, impl: true,
        ex: { near_cycle: [-0.25, 3] }, en: { e_spd: 0.08 }
    });

    // ── 金 · 减码 2 ──
    hex_register("hex_054", {
        tier: 1, form: "C", name: "爆炒锅",
        card_desc: "全队攻击 -15%", enemy_desc: "老鼠移速 -5%",
        stack: 1, impl: true,
        ex: { atk: -0.15 }, en: { e_spd: -0.05 }
    });
    hex_register("hex_055", {
        tier: 1, form: "C", name: "慢煮锅",
        card_desc: "全队攻击间隔 -25%", enemy_desc: "老鼠生命 -40%",
        stack: 1, impl: true,
        ex: { cycle: -0.25 }, en: { e_hp: -0.40 }
    });

    hex_register("hex_056", {
        tier: 1, form: "A", name: "食材升级",
        card_desc: "全队攻击 +20%，生命 +20%", enemy_desc: "禁用猫",
        stack: 1, impl: true,
        ex: { atk: 0.20, hp: 0.20 }, en: { e_no_cat: true }
    });
    hex_register("hex_057", {
        tier: 1, form: "A", name: "复刻招牌",
        card_desc: "全队攻击 +15%，每波首次放置免费", enemy_desc: "老鼠数量 +10%",
        stack: 1, impl: true,
        ex: { atk: 0.15, free_place: true }, en: { e_count: 0.10 }
    });
    hex_register("hex_058", {
        tier: 1, form: "A", name: "火候掌控",
        card_desc: "火苗上限 +2000，开局火苗 +400", enemy_desc: "老鼠生命 +12%",
        stack: 1, impl: true,
        ex: { flame_cap: 2000, flame_start: 400 }, en: { e_hp: 0.12 }
    });
    hex_register("hex_059", {
        tier: 1, form: "A", name: "老汤续锅",
        card_desc: "每波开始回复所有卡 30% 生命，火苗 +100", enemy_desc: "老鼠啃咬速度 +10%",
        stack: 1, impl: true,
        ex: { heal_wave: 0.30, flame_wave: 100 }, en: { e_bite: 0.10 }
    });
    hex_register("hex_060", {
        tier: 1, form: "A", name: "精选食材",
        card_desc: "本局获得 2 次免费重随，全队攻击 +10%", enemy_desc: "老鼠生命 +10%",
        stack: 1, impl: true,
        ex: { free_reroll: 2, atk: 0.10 }, en: { e_hp: 0.10 }
    });
    hex_register("hex_061", {
        tier: 1, form: "A", name: "灶王保佑",
        card_desc: "全队攻击 +12%", enemy_desc: "老鼠生命 +12%",
        stack: 1, impl: true,
        ex: { atk: 0.12 }, en: { e_hp: 0.12 }
    });
    hex_register("hex_062", {
        tier: 1, form: "A", name: "备菜台",
        card_desc: "卡组上限 +2", enemy_desc: "老鼠数量 +10%",
        stack: 1, impl: true,
        ex: { deck_cap: 2 }, en: { e_count: 0.10 }
    });
    hex_register("hex_063", {
        tier: 1, form: "A", name: "大锅饭",
        card_desc: "场上每有 1 张卡，全队攻击 +1.2%（上限 12 张）", enemy_desc: "美食阵亡时对 3x3 内美食造成等量伤害",
        stack: 1, impl: true,
        ex: { per_card_atk: [0.012, 0.12] }, en: { e_card_blast: true }
    });
    hex_register("hex_064", {
        tier: 1, form: "A", name: "编外厨师",
        card_desc: "场上数量最多的大分类，共鸣计数 +2", enemy_desc: "老鼠生命 +12%",
        stack: 1, impl: true,
        ex: { bond_extra: 2 }, en: { e_hp: 0.12 }
    });
    hex_register("hex_065", {
        tier: 1, form: "A", name: "调味大师",
        card_desc: "所有共鸣效果 +20%", enemy_desc: "老鼠生命 +15%",
        stack: 1, impl: true,
        ex: { bond_power: 0.20 }, en: { e_hp: 0.15 }
    });
    hex_register("hex_066", {
        tier: 1, form: "A", name: "双料锅",
        card_desc: "所有小分类共鸣要求 -1", enemy_desc: "老鼠数量 +8%",
        stack: 1, impl: true,
        ex: { bond_req_minor: 1 }, en: { e_count: 0.08 }
    });
    hex_register("hex_067", {
        tier: 1, form: "A", name: "蒸笼叠层",
        card_desc: "同一个小分类内，每多 1 张卡彼此攻击 +4%", enemy_desc: "老鼠生命 +10%",
        stack: 1, impl: true,
        ex: { minor_stack_atk: 0.04 }, en: { e_hp: 0.10 }
    });
    hex_register("hex_068", {
        tier: 1, form: "A", name: "借味",
        card_desc: "场上每有 1 张增幅类卡，全队攻击 +5%（上限 5 层）", enemy_desc: "老鼠生命 +10%",
        stack: 1, impl: true,
        ex: { borrow_atk: [0.05, 0.25] }, en: { e_hp: 0.10 }
    });
    hex_register("hex_069", {
        tier: 1, form: "A", name: "中央厨房",
        card_desc: "场上卡片数达到 12 时，全队攻击 +18%", enemy_desc: "老鼠移速 +10%",
        stack: 1, impl: true,
        ex: { field_need_atk: [12, 0.18] }, en: { e_spd: 0.10 }
    });
    hex_register("hex_070", {
        tier: 1, form: "A", name: "精简菜单",
        card_desc: "本局卡组仅 6 张卡时，全队攻击 +30%", enemy_desc: "老鼠生命 +15%",
        stack: 1, impl: true,
        ex: { deck_theme_atk: [6, 0.30] }, en: { e_hp: 0.15 }
    });
    hex_register("hex_071", {
        tier: 1, form: "A", name: "满汉全席",
        card_desc: "本局卡组满 12 张时，每张卡攻击 +9%", enemy_desc: "老鼠数量 +10%",
        stack: 1, impl: true,
        ex: { deck_per_atk: [12, 0.09] }, en: { e_count: 0.10 }
    });
    hex_register("hex_072", {
        tier: 1, form: "A", name: "双味锅",
        card_desc: "同时存在灰烬类与非灰烬类时，全队攻击 +12%", enemy_desc: "老鼠生命 +10%",
        stack: 1, impl: true,
        ex: { ash_mix_atk: 0.12 }, en: { e_hp: 0.10 }
    });
    hex_register("hex_073", {
        tier: 1, form: "A", name: "主厨推荐",
        card_desc: "场上数量最少的分类，其卡片攻击 +35%", enemy_desc: "老鼠移速 +8%",
        stack: 1, impl: true,
        ex: { min_cat_atk: 0.35 }, en: { e_spd: 0.08 }
    });
    hex_register("hex_074", {
        tier: 1, form: "A", name: "高汤提鲜",
        card_desc: "全队攻击 +15%，火苗获取量 -20%", enemy_desc: "老鼠护甲 +8%",
        stack: 1, impl: true,
        ex: { atk: 0.15, flame_growth: -0.20 }, en: { e_hp: 0.08 }
    });

    // ── 金 · 减码 / 特殊 8 ──
    hex_register("hex_075", {
        tier: 1, form: "C", name: "快刀",
        card_desc: "全队伤害 -10%", enemy_desc: "老鼠移速 -5%",
        stack: 1, impl: true,
        ex: { atk: -0.10 }, en: { e_spd: -0.05 }
    });
    hex_register("hex_076", {
        tier: 1, form: "A", name: "椒盐",
        card_desc: "对空中目标伤害 +30%", enemy_desc: "地面老鼠生命 +10%",
        stack: 1, impl: true,
        ex: { anti_air: 0.30 }, en: { e_hp_ground: 0.10 }
    });
    hex_register("hex_077", {
        tier: 1, form: "A", name: "醋溜",
        card_desc: "被减速的老鼠受到伤害 +20%", enemy_desc: "老鼠移速 +8%",
        stack: 1, impl: true,
        ex: { slow_bonus: 0.20 }, en: { e_spd: 0.08 }
    });
    hex_register("hex_078", {
        tier: 1, form: "A", name: "一勺封喉",
        card_desc: "全队攻击 +14%", enemy_desc: "老鼠生命 +10%",
        stack: 1, impl: true,
        ex: { atk: 0.14 }, en: { e_hp: 0.10 }
    });
    hex_register("hex_079", {
        tier: 1, form: "C", name: "糖衣",
        card_desc: "卡片攻击 -10%", enemy_desc: "老鼠攻击 -15%",
        stack: 1, impl: true,
        ex: { atk: -0.10 }, en: { e_atk: -0.15 }
    });
    hex_register("hex_080", {
        tier: 1, form: "C", name: "窄油锅",
        card_desc: "全队攻击 -12%", enemy_desc: "老鼠移速 -5%",
        stack: 1, impl: true,
        ex: { atk: -0.12 }, en: { e_spd: -0.05 }
    });
    hex_register("hex_081", {
        tier: 1, form: "C", name: "慢工出细活",
        card_desc: "全队攻速 -12%", enemy_desc: "老鼠数量 -10%",
        stack: 1, impl: true,
        ex: { cycle: 0.12 }, en: { e_count: -0.10 }
    });
    hex_register("hex_082", {
        tier: 1, form: "C", name: "断粮",
        card_desc: "火苗获取量 -35%", enemy_desc: "老鼠生命 -5%",
        stack: 1, impl: true,
        ex: { flame_growth: -0.35 }, en: { e_hp: -0.05 }
    });

    // ══════════════════════════════ 彩 · 29 ══════════════════════════════
    hex_register("hex_083", {
        tier: 2, form: "A", name: "万物皆可炸",
        card_desc: "所有卡片可放置在任何地形，并享受该地形加成", enemy_desc: "老鼠生命 +25%",
        stack: 1, impl: true,
        ex: { terrain_free: true }, en: { e_hp: 0.25 }
    });
    hex_register("hex_084", {
        tier: 2, form: "A", name: "无限续杯",
        card_desc: "火苗获取量 +100%，火苗无上限", enemy_desc: "老鼠数量 +20%",
        stack: 1, impl: true,
        ex: { flame_growth: 1.00, cap_unbound: true }, en: { e_count: 0.20 }
    });
    hex_register("hex_085", {
        tier: 2, form: "A", name: "满汉全席宴",
        card_desc: "所有卡片费用 -25%", enemy_desc: "老鼠生命 +30%",
        stack: 1, impl: true,
        ex: { cost: -0.25 }, en: { e_hp: 0.30 }
    });
    hex_register("hex_086", {
        tier: 2, form: "A", name: "双厨狂喜",
        card_desc: "每波内第 2 次放置同名卡费用为 0", enemy_desc: "老鼠移速 +20%",
        stack: 1, impl: true,
        ex: { same_card_free: true }, en: { e_spd: 0.20 }
    });
    hex_register("hex_087", {
        tier: 2, form: "A", name: "时空炒锅",
        card_desc: "每波开始全体卡片冷却立即清零", enemy_desc: "老鼠啃咬速度 +20%",
        stack: 1, impl: true,
        ex: { wave_reset: true }, en: { e_bite: 0.20 }
    });
    hex_register("hex_088", {
        tier: 2, form: "A", name: "复制食谱",
        card_desc: "美食每拥有 1% 攻速加成，就获得 1% 攻击加成", enemy_desc: "老鼠生命 +22%",
        stack: 1, impl: true,
        ex: { atk_per_speed: 1.0 }, en: { e_hp: 0.22 }
    });
    hex_register("hex_089", {
        tier: 2, form: "A", name: "灶神附体",
        card_desc: "每 30 秒全屏火焰，伤害为全队攻击总和的 200%", enemy_desc: "老鼠生命 +25%",
        stack: 1, impl: true,
        ex: { nuke: [30, 2.0] }, en: { e_hp: 0.25 }
    });
    hex_register("hex_090", {
        tier: 2, form: "A", name: "一锅端",
        card_desc: "每波结束若无卡片阵亡，火苗 +500 且下波全队 +15% 攻击（可叠 3 层）", enemy_desc: "老鼠数量 +15%",
        stack: 1, impl: true,
        ex: { wave_clear_flame: [500, 0.15, 3] }, en: { e_count: 0.15 }
    });
    hex_register("hex_091", {
        tier: 2, form: "A", name: "满席共鸣",
        card_desc: "所有主分类共鸣要求 -2（最低 2 张）", enemy_desc: "老鼠生命 +35%",
        stack: 1, impl: true,
        ex: { bond_req_major: 2 }, en: { e_hp: 0.35 }
    });
    hex_register("hex_092", {
        tier: 2, form: "A", name: "厨神降临",
        card_desc: "全队攻击 +60%，火苗获取量 -50%", enemy_desc: "老鼠生命 +30%",
        stack: 1, impl: true,
        ex: { atk: 0.60, flame_growth: -0.50 }, en: { e_hp: 0.30 }
    });
    hex_register("hex_093", {
        tier: 2, form: "A", name: "百味调和",
        card_desc: "直射 / 投掷 / 多向 三类攻击各 +40%", enemy_desc: "老鼠护甲 +25%",
        stack: 1, impl: true,
        ex: { cat_atk: [ ["直射类", 0.40], ["投掷类", 0.40], ["多向类", 0.40] ] }, en: { e_hp: 0.25 }
    });
    hex_register("hex_094", {
        tier: 2, form: "A", name: "火海",
        card_desc: "每 10 秒对全场老鼠造成其 3% 最大生命的灼烧", enemy_desc: "老鼠生命 +30%",
        stack: 1, impl: true,
        ex: { burn: [10, 0.03] }, en: { e_hp: 0.30 }
    });
    hex_register("hex_095", {
        tier: 2, form: "C", name: "冰窖",
        card_desc: "全队攻速 -20%", enemy_desc: "老鼠移速 -8%",
        stack: 1, impl: true,
        ex: { cycle: 0.20 }, en: { e_spd: -0.08 }
    });
    hex_register("hex_096", {
        tier: 2, form: "A", name: "盛宴",
        card_desc: "卡组上限 +4", enemy_desc: "老鼠数量 +25%",
        stack: 1, impl: true,
        ex: { deck_cap: 4 }, en: { e_count: 0.25 }
    });
    hex_register("hex_097", {
        tier: 2, form: "A", name: "以牙还牙",
        card_desc: "卡片被摧毁时对全场老鼠造成该卡攻击 300% 的伤害", enemy_desc: "老鼠生命 +25%",
        stack: 1, impl: true,
        ex: { card_death_pct: 3.0 }, en: { e_hp: 0.25 }
    });
    hex_register("hex_098", {
        tier: 2, form: "A", name: "时间暂停",
        card_desc: "每波开始全体回复 12% 生命", enemy_desc: "老鼠生命 +30%",
        stack: 1, impl: true,
        ex: { heal_wave: 0.12 }, en: { e_hp: 0.30 }
    });
    hex_register("hex_099", {
        tier: 2, form: "A", name: "一菜三吃",
        card_desc: "场上数量最多的小分类，共鸣计数 +1", enemy_desc: "老鼠生命 +25%",
        stack: 1, impl: true,
        ex: { bond_extra_minor: 1 }, en: { e_hp: 0.25 }
    });
    hex_register("hex_100", {
        tier: 2, form: "C", name: "明火",
        card_desc: "所有灰烬卡冷却 +80%", enemy_desc: "老鼠生命 -10%",
        stack: 1, impl: true,
        ex: { cat_cycle: [ ["灰烬类", 0.80] ] }, en: { e_hp: -0.10 }
    });
    hex_register("hex_101", {
        tier: 2, form: "A", name: "火焰喷射",
        card_desc: "喷壶类攻击 +40%", enemy_desc: "老鼠生命 +30%",
        stack: 1, impl: true,
        ex: { cat_atk: [ ["喷壶类", 0.40] ] }, en: { e_hp: 0.30 }
    });
    hex_register("hex_102", {
        tier: 2, form: "A", name: "无中生有",
        card_desc: "每波开始火苗 +250", enemy_desc: "老鼠数量 +20%",
        stack: 1, impl: true,
        ex: { flame_wave: 250 }, en: { e_count: 0.20 }
    });
    hex_register("hex_103", {
        tier: 2, form: "C", name: "破釜沉舟",
        card_desc: "火苗上限固定为 500", enemy_desc: "老鼠生命 -20%",
        stack: 1, impl: true,
        ex: { cap_fixed: 500 }, en: { e_hp: -0.20 }
    });
    hex_register("hex_104", {
        tier: 2, form: "C", name: "断火",
        card_desc: "全队攻击 -25%", enemy_desc: "老鼠移速 -10%",
        stack: 1, impl: true,
        ex: { atk: -0.25 }, en: { e_spd: -0.10 }
    });
    hex_register("hex_105", {
        tier: 2, form: "C", name: "空锅",
        card_desc: "全队攻速 -25%", enemy_desc: "老鼠生命 -25%",
        stack: 1, impl: true,
        ex: { cycle: 0.25 }, en: { e_hp: -0.25 }
    });
    hex_register("hex_106", {
        tier: 2, form: "C", name: "冰封千里",
        card_desc: "全部卡片冷却 +40%", enemy_desc: "老鼠数量 -20%",
        stack: 1, impl: true,
        ex: { cycle: 0.40 }, en: { e_count: -0.20 }
    });
    hex_register("hex_107", {
        tier: 2, form: "A", name: "天选之卡",
        card_desc: "场上攻击最高的卡攻击 x2、攻速 +30%，其余卡攻击 -15%", enemy_desc: "老鼠生命 +30%",
        stack: 1, impl: true,
        ex: { top_card_atk: [2.0, -0.30], other_atk: -0.15 }, en: { e_hp: 0.30 }
    });
    hex_register("hex_108", {
        tier: 2, form: "A", name: "赌徒的锅铲",
        card_desc: "火苗上限减半，每次放置 30% 概率全额返还费用", enemy_desc: "老鼠移速 +15%",
        stack: 1, impl: true,
        ex: { cap_half: true, refund_chance: 0.30 }, en: { e_spd: 0.15 }
    });
    hex_register("hex_109", {
        tier: 2, form: "A", name: "龙柱共鸣",
        card_desc: "全队攻击 +10%，每波开始火苗 +200", enemy_desc: "老鼠生命 +20%",
        stack: 1, impl: true,
        ex: { atk: 0.10, flame_wave: 200 }, en: { e_hp: 0.20 }
    });
    hex_register("hex_110", {
        tier: 2, form: "A", name: "悬浮厨房",
        card_desc: "所有增幅类与辅助类卡片不占用格子", enemy_desc: "老鼠生命 +25%",
        stack: 1, impl: true,
        ex: { gridless: true }, en: { e_hp: 0.25 }
    });
    hex_register("hex_111", {
        tier: 2, form: "A", name: "灶台主宰",
        card_desc: "关卡内每击破 1 个精英，全队攻击 +4%（上限 10 层）", enemy_desc: "老鼠数量 +20%",
        stack: 1, impl: true,
        ex: { elite_atk: [0.04, 10] }, en: { e_count: 0.20 }
    });
}
