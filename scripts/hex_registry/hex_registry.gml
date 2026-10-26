/// hex_registry —— 海克斯词条库（111 条）
///
/// 铁律：**描述即实现**。每一条的 card_desc / enemy_desc 必须和 ex / en 里的数值一一对应，
/// 不允许出现「文案写着穿透 +1，实际只加了 12% 攻击」这种折算条目——
/// 上一版有 77 条是折算的，玩家点了看不到效果，本版全部改成真实生效的数值与机制。
///
/// 数值约定：ex / en 里的值都是「增量」——0.08 = +8%，-0.18 = -18%。
/// en 的 e_hp 同时承接「老鼠护甲」（本作敌人没有独立护甲字段，护甲并入生命）。
///
/// ex 可用通道（hex_apply 逐项消费）：
///   数值类：atk / cycle / hp / cat_atk / cat_cycle
///          flame_start / flame_wave / flame_cap / flame_growth / wave_flame_pct
///          flame_tick（配 flame_tick_sec）/ heal_wave / free_reroll
///   机制类：
///     refund         铲除返还倍率增量（hex_refund_mult）
///     cost           卡片费用倍率增量（hex_cost_mult）
///     gridless       增幅类 / 辅助类不占格（hex_gridless_for_card）
///     free_place     每波首次放置免费（hex_free_place_ready）
///     wave_reset     每波开始卡槽冷却清零（hex_on_wave_start）
///     bond_power     共鸣效果强度增量（hex_bond_mult_for_card）
///     bond_req_major 主分类共鸣要求降低量（hex_bond_thresholds）
///     bond_req_minor 小分类共鸣要求降低量（hex_bond_thresholds）
///     bond_extra     场上最大分类的共鸣计数加成（hex_bond_recalc）
///     top_atk        场上数量最多的小分类攻击增量（hex_dyn_atk_bonus）
///     per_card_atk   [每张卡的攻击增量, 封顶]（hex_dyn_atk_bonus）
///     kill_flame     [触发概率, 火苗数量]（hex_on_kill）
///     kill_stack     [每层攻击增量, 层数上限] + kill_stack_need（hex_on_kill）

/// @function hex_registry_init()
/// @desc 建立词条库。必须在 card_category_init() 之后调用
function hex_registry_init() {
    global.hex_db  = {};
    global.hex_ids = [];
    hex_register_builtin();
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

    // ══════════════════════════════ 银 ══════════════════════════════
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
        ex: { flame_growth: 0.2 }, en: { e_spd: 0.06 }
    });
    hex_register("hex_003", {
        tier: 0, form: "A", name: "剩菜打包",
        card_desc: "每波开始获得当前火苗 8%", enemy_desc: "老鼠数量 +5%",
        stack: 1, impl: true,
        ex: { wave_flame_pct: 0.08 }, en: { e_count: 0.05 }
    });
    hex_register("hex_004", {
        tier: 0, form: "A", name: "老汤底",
        card_desc: "每波开始火苗 +100", enemy_desc: "老鼠生命 +6%",
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
        ex: { cost: -0.08 }, en: { e_hp: 0.1 }
    });
    hex_register("hex_008", {
        tier: 0, form: "A", name: "一锅两吃",
        card_desc: "直射类与投掷类攻击各 +5%", enemy_desc: "老鼠生命 +7%",
        stack: 1, impl: true,
        ex: { cat_atk: [ ["直射类", 0.05], ["投掷类", 0.05] ] }, en: { e_hp: 0.07 }
    });
    hex_register("hex_009", {
        tier: 0, form: "A", name: "盐少许",
        card_desc: "全队攻击 +8%", enemy_desc: "老鼠生命 +9%",
        stack: 2, impl: true,
        ex: { atk: 0.08 }, en: { e_hp: 0.09 }
    });
    hex_register("hex_010", {
        tier: 0, form: "A", name: "快手翻炒",
        card_desc: "全队攻击间隔 -8%", enemy_desc: "老鼠攻击 +8%",
        stack: 2, impl: true,
        ex: { cycle: -0.08 }, en: { e_atk: 0.08 }
    });
    hex_register("hex_011", {
        tier: 0, form: "A", name: "一勺到底",
        card_desc: "全队生命 +25%", enemy_desc: "老鼠攻击 +10%",
        stack: 2, impl: true,
        ex: { hp: 0.25 }, en: { e_atk: 0.1 }
    });
    hex_register("hex_012", {
        tier: 0, form: "A", name: "小火慢煮",
        card_desc: "全队生命 +8%", enemy_desc: "老鼠移速 +6%",
        stack: 2, impl: true,
        ex: { hp: 0.08 }, en: { e_spd: 0.06 }
    });
    hex_register("hex_013", {
        tier: 0, form: "A", name: "稳住锅气",
        card_desc: "全队攻击 +5%", enemy_desc: "老鼠攻击 +6%",
        stack: 1, impl: true,
        ex: { atk: 0.05 }, en: { e_atk: 0.06 }
    });
    hex_register("hex_014", {
        tier: 0, form: "A", name: "灶台擦净",
        card_desc: "全队生命 +8%", enemy_desc: "老鼠生命 +8%",
        stack: 1, impl: true,
        ex: { hp: 0.08 }, en: { e_hp: 0.08 }
    });
    hex_register("hex_015", {
        tier: 0, form: "A", name: "一勺糖",
        card_desc: "全队攻击 +5%", enemy_desc: "老鼠生命 +9%",
        stack: 1, impl: true,
        ex: { atk: 0.05 }, en: { e_hp: 0.09 }
    });
    hex_register("hex_016", {
        tier: 0, form: "A", name: "文火慢煮",
        card_desc: "每波开始全体回复 8% 生命", enemy_desc: "老鼠攻击 +5%",
        stack: 2, impl: true,
        ex: { heal_wave: 0.08 }, en: { e_atk: 0.05 }
    });
    hex_register("hex_017", {
        tier: 0, form: "A", name: "刀工精细",
        card_desc: "直射类攻击间隔 -12%", enemy_desc: "老鼠生命 +10%",
        stack: 2, impl: true,
        ex: { cat_cycle: [ ["直射类", -0.12] ] }, en: { e_hp: 0.1 }
    });
    hex_register("hex_018", {
        tier: 0, form: "A", name: "面糊裹身",
        card_desc: "投掷类攻击 +14%", enemy_desc: "老鼠生命 +10%",
        stack: 2, impl: true,
        ex: { cat_atk: [ ["投掷类", 0.14] ] }, en: { e_hp: 0.1 }
    });
    hex_register("hex_019", {
        tier: 0, form: "A", name: "文火慢烤",
        card_desc: "灰烬类攻击 +18%", enemy_desc: "老鼠移速 +7%",
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
        card_desc: "增幅类攻击 +6%", enemy_desc: "老鼠数量 +4%",
        stack: 2, impl: true,
        ex: { cat_atk: [ ["增幅类", 0.06] ] }, en: { e_count: 0.04 }
    });
    hex_register("hex_022", {
        tier: 0, form: "A", name: "隔水加热",
        card_desc: "每波开始火苗 +60", enemy_desc: "老鼠生命 +8%",
        stack: 1, impl: true,
        ex: { flame_wave: 60 }, en: { e_hp: 0.08 }
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
        card_desc: "多向类攻击 +8%", enemy_desc: "老鼠生命 +5%",
        stack: 1, impl: true,
        ex: { cat_atk: [ ["多向类", 0.08] ] }, en: { e_hp: 0.05 }
    });
    hex_register("hex_027", {
        tier: 0, form: "A", name: "甜咸平衡",
        card_desc: "全队攻击 +5%", enemy_desc: "老鼠数量 +5%",
        stack: 1, impl: true,
        ex: { atk: 0.05 }, en: { e_count: 0.05 }
    });
    hex_register("hex_028", {
        tier: 0, form: "A", name: "防空警报",
        card_desc: "全队攻击 +12%", enemy_desc: "老鼠生命 +8%",
        stack: 2, impl: true,
        ex: { atk: 0.12 }, en: { e_hp: 0.08 }
    });
    hex_register("hex_029", {
        tier: 0, form: "A", name: "冰镇",
        card_desc: "全队攻击间隔 -8%", enemy_desc: "老鼠移速 +6%",
        stack: 1, impl: true,
        ex: { cycle: -0.08 }, en: { e_spd: 0.06 }
    });
    hex_register("hex_030", {
        tier: 0, form: "A", name: "熄火",
        card_desc: "火苗获取量 +14%", enemy_desc: "老鼠生命 +8%",
        stack: 1, impl: true,
        ex: { flame_growth: 0.14 }, en: { e_hp: 0.08 }
    });
    hex_register("hex_031", {
        tier: 0, form: "A", name: "去腥",
        card_desc: "直射类攻击 +12%", enemy_desc: "老鼠生命 +10%",
        stack: 1, impl: true,
        ex: { cat_atk: [ ["直射类", 0.12] ] }, en: { e_hp: 0.1 }
    });
    hex_register("hex_032", {
        tier: 0, form: "A", name: "去骨",
        card_desc: "投掷类攻击 +12%", enemy_desc: "老鼠生命 +10%",
        stack: 1, impl: true,
        ex: { cat_atk: [ ["投掷类", 0.12] ] }, en: { e_hp: 0.1 }
    });
    hex_register("hex_033", {
        tier: 0, form: "A", name: "除霜",
        card_desc: "灰烬类攻击 +14%", enemy_desc: "老鼠生命 +12%",
        stack: 1, impl: true,
        ex: { cat_atk: [ ["灰烬类", 0.14] ] }, en: { e_hp: 0.12 }
    });
    hex_register("hex_034", {
        tier: 0, form: "A", name: "净锅",
        card_desc: "全队生命 +18%", enemy_desc: "老鼠生命 +8%",
        stack: 1, impl: true,
        ex: { hp: 0.18 }, en: { e_hp: 0.08 }
    });
    hex_register("hex_035", {
        tier: 0, form: "A", name: "顺手一抹",
        card_desc: "铲除返还 +40%", enemy_desc: "老鼠生命 +6%",
        stack: 1, impl: true,
        ex: { refund: 0.4 }, en: { e_hp: 0.06 }
    });
    hex_register("hex_036", {
        tier: 0, form: "A", name: "双份备料",
        card_desc: "全队攻击 +6%", enemy_desc: "老鼠数量 +6%",
        stack: 1, impl: true,
        ex: { atk: 0.06 }, en: { e_count: 0.06 }
    });
    hex_register("hex_037", {
        tier: 0, form: "A", name: "半成品",
        card_desc: "本局获得 2 次免费重随", enemy_desc: "老鼠生命 +8%",
        stack: 1, impl: true,
        ex: { free_reroll: 2 }, en: { e_hp: 0.08 }
    });
    hex_register("hex_038", {
        tier: 0, form: "A", name: "火候观察",
        card_desc: "每波开始火苗 +40", enemy_desc: "老鼠生命 +4%",
        stack: 1, impl: true,
        ex: { flame_wave: 40 }, en: { e_hp: 0.04 }
    });

    // ── 银 · 减码 ──
    hex_register("hex_039", {
        tier: 0, form: "C", name: "少油",
        card_desc: "全队攻击间隔 +6%", enemy_desc: "老鼠移速 -15%",
        stack: 1, impl: true,
        ex: { cycle: 0.06 }, en: { e_spd: -0.15 }
    });
    hex_register("hex_040", {
        tier: 0, form: "C", name: "收汁",
        card_desc: "火苗上限 -800", enemy_desc: "老鼠生命 -12%",
        stack: 1, impl: true,
        ex: { flame_cap: -800 }, en: { e_hp: -0.12 }
    });
    hex_register("hex_041", {
        tier: 0, form: "C", name: "冷冻保鲜",
        card_desc: "全队攻击间隔 +8%", enemy_desc: "老鼠攻击 -28%",
        stack: 1, impl: true,
        ex: { cycle: 0.08 }, en: { e_atk: -0.28 }
    });
    hex_register("hex_042", {
        tier: 0, form: "C", name: "清汤寡水",
        card_desc: "全队生命 -15%", enemy_desc: "老鼠生命 -18%",
        stack: 1, impl: true,
        ex: { hp: -0.15 }, en: { e_hp: -0.18 }
    });
    hex_register("hex_043", {
        tier: 0, form: "C", name: "老灶台",
        card_desc: "每波开始火苗 -50", enemy_desc: "老鼠数量 -11%",
        stack: 1, impl: true,
        ex: { flame_wave: -50 }, en: { e_count: -0.11 }
    });

    // ══════════════════════════════ 金 ══════════════════════════════
    hex_register("hex_044", {
        tier: 1, form: "A", name: "大火爆炒",
        card_desc: "直射类攻击间隔 -22%，投掷类 +10%", enemy_desc: "老鼠生命 +8%",
        stack: 1, impl: true,
        ex: { cat_cycle: [ ["直射类", -0.22], ["投掷类", 0.1] ] }, en: { e_hp: 0.08 }
    });
    hex_register("hex_045", {
        tier: 1, form: "A", name: "面点师",
        card_desc: "投掷类攻击 +30%，直射类 -10%", enemy_desc: "老鼠生命 +10%",
        stack: 1, impl: true,
        ex: { cat_atk: [ ["投掷类", 0.3], ["直射类", -0.1] ] }, en: { e_hp: 0.1 }
    });
    hex_register("hex_046", {
        tier: 1, form: "A", name: "火锅底料",
        card_desc: "灰烬类攻击 +35%", enemy_desc: "老鼠生命 +14%",
        stack: 1, impl: true,
        ex: { cat_atk: [ ["灰烬类", 0.35] ] }, en: { e_hp: 0.14 }
    });
    hex_register("hex_047", {
        tier: 1, form: "A", name: "清汤锅",
        card_desc: "灰烬类攻击 +30%", enemy_desc: "老鼠移速 +12%",
        stack: 1, impl: true,
        ex: { cat_atk: [ ["灰烬类", 0.30] ] }, en: { e_spd: 0.12 }
    });
    hex_register("hex_048", {
        tier: 1, form: "A", name: "蒸汽加压",
        card_desc: "喷壶类攻击 +18%", enemy_desc: "老鼠生命 +14%",
        stack: 1, impl: true,
        ex: { cat_atk: [ ["喷壶类", 0.18] ] }, en: { e_hp: 0.14 }
    });
    hex_register("hex_049", {
        tier: 1, form: "A", name: "双灶并行",
        card_desc: "全队攻击 +14%", enemy_desc: "老鼠生命 +10%",
        stack: 1, impl: true,
        ex: { atk: 0.14 }, en: { e_hp: 0.1 }
    });
    hex_register("hex_050", {
        tier: 1, form: "A", name: "现炒现卖",
        card_desc: "全队攻击间隔 -8%", enemy_desc: "老鼠数量 +8%",
        stack: 1, impl: true,
        ex: { cycle: -0.08 }, en: { e_count: 0.08 }
    });
    hex_register("hex_051", {
        tier: 1, form: "A", name: "招牌菜",
        card_desc: "场上数量最多的小分类，攻击 +45%", enemy_desc: "老鼠生命 +10%",
        stack: 1, impl: true,
        ex: { top_atk: 0.45 }, en: { e_hp: 0.1 }
    });
    hex_register("hex_052", {
        tier: 1, form: "A", name: "秘制酱料",
        card_desc: "增幅类攻击 +22%", enemy_desc: "老鼠生命 +10%",
        stack: 1, impl: true,
        ex: { cat_atk: [ ["增幅类", 0.22] ] }, en: { e_hp: 0.1 }
    });
    hex_register("hex_053", {
        tier: 1, form: "A", name: "逆火",
        card_desc: "全队攻击间隔 -7%", enemy_desc: "老鼠移速 +8%",
        stack: 1, impl: true,
        ex: { cycle: -0.07 }, en: { e_spd: 0.08 }
    });

    // ── 金 · 减码 ──
    hex_register("hex_054", {
        tier: 1, form: "C", name: "爆炒锅",
        card_desc: "全队攻击 -15%", enemy_desc: "老鼠移速 -35%",
        stack: 1, impl: true,
        ex: { atk: -0.15 }, en: { e_spd: -0.35 }
    });
    hex_register("hex_055", {
        tier: 1, form: "C", name: "慢煮锅",
        card_desc: "全队攻击间隔 +25%", enemy_desc: "老鼠生命 -50%",
        stack: 1, impl: true,
        ex: { cycle: 0.25 }, en: { e_hp: -0.5 }
    });

    hex_register("hex_056", {
        tier: 1, form: "A", name: "食材升级",
        card_desc: "全队攻击 +20%", enemy_desc: "老鼠生命 +18%",
        stack: 1, impl: true,
        ex: { atk: 0.20 }, en: { e_hp: 0.18 }
    });
    hex_register("hex_057", {
        tier: 1, form: "A", name: "复刻招牌",
        card_desc: "全队攻击 +15%", enemy_desc: "老鼠数量 +10%",
        stack: 1, impl: true,
        ex: { atk: 0.15 }, en: { e_count: 0.1 }
    });
    hex_register("hex_058", {
        tier: 1, form: "A", name: "火候掌控",
        card_desc: "火苗上限 +2000，开局火苗 +150", enemy_desc: "老鼠生命 +12%",
        stack: 1, impl: true,
        ex: { flame_cap: 2000, flame_start: 150 }, en: { e_hp: 0.12 }
    });
    hex_register("hex_059", {
        tier: 1, form: "A", name: "老汤续锅",
        card_desc: "每波开始回复 30% 生命，火苗 +100", enemy_desc: "老鼠攻击 +10%",
        stack: 1, impl: true,
        ex: { heal_wave: 0.30, flame_wave: 100 }, en: { e_atk: 0.1 }
    });
    hex_register("hex_060", {
        tier: 1, form: "A", name: "精选食材",
        card_desc: "全队攻击 +18%", enemy_desc: "老鼠生命 +10%",
        stack: 1, impl: true,
        ex: { atk: 0.18 }, en: { e_hp: 0.1 }
    });
    hex_register("hex_061", {
        tier: 1, form: "A", name: "灶王保佑",
        card_desc: "全队攻击 +10%", enemy_desc: "老鼠生命 +12%",
        stack: 1, impl: true,
        ex: { atk: 0.10 }, en: { e_hp: 0.12 }
    });
    hex_register("hex_062", {
        tier: 1, form: "A", name: "备菜台",
        card_desc: "全队攻击 +12%", enemy_desc: "老鼠数量 +10%",
        stack: 1, impl: true,
        ex: { atk: 0.12 }, en: { e_count: 0.1 }
    });
    hex_register("hex_063", {
        tier: 1, form: "A", name: "大锅饭",
        card_desc: "场上每张卡给全队攻击 +1.2%（上限 +12%）", enemy_desc: "老鼠数量 +10%",
        stack: 1, impl: true,
        ex: { per_card_atk: [0.012, 0.12] }, en: { e_count: 0.1 }
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
        card_desc: "全队攻击 +10%", enemy_desc: "老鼠生命 +10%",
        stack: 1, impl: true,
        ex: { atk: 0.10 }, en: { e_hp: 0.1 }
    });
    hex_register("hex_068", {
        tier: 1, form: "A", name: "借味",
        card_desc: "全队攻击 +12%", enemy_desc: "老鼠生命 +10%",
        stack: 1, impl: true,
        ex: { atk: 0.12 }, en: { e_hp: 0.1 }
    });
    hex_register("hex_069", {
        tier: 1, form: "A", name: "中央厨房",
        card_desc: "全队攻击 +18%", enemy_desc: "老鼠移速 +10%",
        stack: 1, impl: true,
        ex: { atk: 0.18 }, en: { e_spd: 0.1 }
    });
    hex_register("hex_070", {
        tier: 1, form: "A", name: "精简菜单",
        card_desc: "全队攻击 +30%", enemy_desc: "老鼠生命 +15%",
        stack: 1, impl: true,
        ex: { atk: 0.30 }, en: { e_hp: 0.15 }
    });
    hex_register("hex_071", {
        tier: 1, form: "A", name: "满汉全席",
        card_desc: "全队攻击 +27%", enemy_desc: "老鼠数量 +10%",
        stack: 1, impl: true,
        ex: { atk: 0.27 }, en: { e_count: 0.1 }
    });
    hex_register("hex_072", {
        tier: 1, form: "A", name: "双味锅",
        card_desc: "全队攻击 +12%", enemy_desc: "老鼠生命 +10%",
        stack: 1, impl: true,
        ex: { atk: 0.12 }, en: { e_hp: 0.1 }
    });
    hex_register("hex_073", {
        tier: 1, form: "A", name: "主厨推荐",
        card_desc: "全队攻击 +14%", enemy_desc: "老鼠移速 +8%",
        stack: 1, impl: true,
        ex: { atk: 0.14 }, en: { e_spd: 0.08 }
    });
    hex_register("hex_074", {
        tier: 1, form: "A", name: "高汤提鲜",
        card_desc: "全队攻击 +15%，火苗获取量 -20%", enemy_desc: "老鼠生命 +8%",
        stack: 1, impl: true,
        ex: { atk: 0.15, flame_growth: -0.2 }, en: { e_hp: 0.08 }
    });

    // ── 金 · 减码 ──
    hex_register("hex_075", {
        tier: 1, form: "C", name: "快刀",
        card_desc: "全队攻击 -10%", enemy_desc: "老鼠移速 -30%",
        stack: 1, impl: true,
        ex: { atk: -0.1 }, en: { e_spd: -0.3 }
    });
    hex_register("hex_076", {
        tier: 1, form: "A", name: "椒盐",
        card_desc: "全队攻击 +30%", enemy_desc: "老鼠生命 +10%",
        stack: 1, impl: true,
        ex: { atk: 0.30 }, en: { e_hp: 0.10 }
    });
    hex_register("hex_077", {
        tier: 1, form: "A", name: "醋溜",
        card_desc: "全队攻击 +20%", enemy_desc: "老鼠生命 +10%",
        stack: 1, impl: true,
        ex: { atk: 0.20 }, en: { e_hp: 0.10 }
    });
    hex_register("hex_078", {
        tier: 1, form: "A", name: "一勺封喉",
        card_desc: "全队攻击 +12%", enemy_desc: "老鼠生命 +10%",
        stack: 1, impl: true,
        ex: { atk: 0.12 }, en: { e_hp: 0.1 }
    });
    hex_register("hex_079", {
        tier: 1, form: "C", name: "糖衣",
        card_desc: "全队攻击 -10%", enemy_desc: "老鼠攻击 -55%",
        stack: 1, impl: true,
        ex: { atk: -0.1 }, en: { e_atk: -0.55 }
    });
    hex_register("hex_080", {
        tier: 1, form: "C", name: "窄油锅",
        card_desc: "全队攻击 -12%", enemy_desc: "老鼠移速 -35%",
        stack: 1, impl: true,
        ex: { atk: -0.12 }, en: { e_spd: -0.35 }
    });
    hex_register("hex_081", {
        tier: 1, form: "C", name: "慢工出细活",
        card_desc: "全队攻击间隔 +12%", enemy_desc: "老鼠数量 -35%",
        stack: 1, impl: true,
        ex: { cycle: 0.12 }, en: { e_count: -0.35 }
    });
    hex_register("hex_082", {
        tier: 1, form: "C", name: "断粮",
        card_desc: "火苗获取量 -35%", enemy_desc: "老鼠生命 -45%",
        stack: 1, impl: true,
        ex: { flame_growth: -0.35 }, en: { e_hp: -0.45 }
    });

    // ══════════════════════════════ 彩 ══════════════════════════════
    hex_register("hex_083", {
        tier: 2, form: "A", name: "万物皆可炸",
        card_desc: "全队攻击 +15%，全队生命 +15%", enemy_desc: "老鼠生命 +25%",
        stack: 1, impl: true,
        ex: { atk: 0.15, hp: 0.15 }, en: { e_hp: 0.25 }
    });
    hex_register("hex_084", {
        tier: 2, form: "A", name: "无限续杯",
        card_desc: "火苗获取量 +100%，火苗上限 +8000", enemy_desc: "老鼠数量 +20%",
        stack: 1, impl: true,
        ex: { flame_growth: 1.00, flame_cap: 8000 }, en: { e_count: 0.2 }
    });
    hex_register("hex_085", {
        tier: 2, form: "A", name: "满汉全席宴",
        card_desc: "全队攻击 +20%，卡片费用 -25%，开局火苗 +300", enemy_desc: "老鼠生命 +30%",
        stack: 1, impl: true,
        ex: { atk: 0.20, cost: -0.25, flame_start: 300 }, en: { e_hp: 0.3 }
    });
    hex_register("hex_086", {
        tier: 2, form: "A", name: "双厨狂喜",
        card_desc: "每波第一次放置不消耗火苗", enemy_desc: "老鼠移速 +20%",
        stack: 1, impl: true,
        ex: { free_place: true }, en: { e_spd: 0.2 }
    });
    hex_register("hex_087", {
        tier: 2, form: "A", name: "时空炒锅",
        card_desc: "每波开始所有卡槽冷却立即清零", enemy_desc: "老鼠攻击 +20%",
        stack: 1, impl: true,
        ex: { wave_reset: true }, en: { e_atk: 0.2 }
    });
    hex_register("hex_088", {
        tier: 2, form: "A", name: "复制食谱",
        card_desc: "全队攻击 +25%", enemy_desc: "老鼠生命 +22%",
        stack: 1, impl: true,
        ex: { atk: 0.25 }, en: { e_hp: 0.22 }
    });
    hex_register("hex_089", {
        tier: 2, form: "A", name: "灶神附体",
        card_desc: "全队攻击 +28%", enemy_desc: "老鼠生命 +25%",
        stack: 1, impl: true,
        ex: { atk: 0.28 }, en: { e_hp: 0.25 }
    });
    hex_register("hex_090", {
        tier: 2, form: "A", name: "一锅端",
        card_desc: "全队攻击 +15%，每波开始火苗 +120", enemy_desc: "老鼠数量 +15%",
        stack: 1, impl: true,
        ex: { atk: 0.15, flame_wave: 120 }, en: { e_count: 0.15 }
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
        ex: { atk: 0.6, flame_growth: -0.5 }, en: { e_hp: 0.3 }
    });
    hex_register("hex_093", {
        tier: 2, form: "A", name: "百味调和",
        card_desc: "直射 / 投掷 / 多向 三类攻击各 +40%", enemy_desc: "老鼠生命 +25%",
        stack: 1, impl: true,
        ex: { cat_atk: [ ["直射类", 0.40], ["投掷类", 0.40], ["多向类", 0.40] ] }, en: { e_hp: 0.25 }
    });
    hex_register("hex_094", {
        tier: 2, form: "A", name: "火海",
        card_desc: "全队攻击 +22%", enemy_desc: "老鼠生命 +30%",
        stack: 1, impl: true,
        ex: { atk: 0.22 }, en: { e_hp: 0.3 }
    });
    hex_register("hex_095", {
        tier: 2, form: "C", name: "冰窖",
        card_desc: "全队攻击间隔 +20%", enemy_desc: "老鼠移速 -55%",
        stack: 1, impl: true,
        ex: { cycle: 0.2 }, en: { e_spd: -0.55 }
    });
    hex_register("hex_096", {
        tier: 2, form: "A", name: "盛宴",
        card_desc: "全队攻击 +22%", enemy_desc: "老鼠数量 +25%",
        stack: 1, impl: true,
        ex: { atk: 0.22 }, en: { e_count: 0.25 }
    });
    hex_register("hex_097", {
        tier: 2, form: "A", name: "以牙还牙",
        card_desc: "全队攻击 +20%", enemy_desc: "老鼠生命 +25%",
        stack: 1, impl: true,
        ex: { atk: 0.20 }, en: { e_hp: 0.25 }
    });
    hex_register("hex_098", {
        tier: 2, form: "A", name: "时间暂停",
        card_desc: "全队攻击 +12%", enemy_desc: "老鼠生命 +30%",
        stack: 1, impl: true,
        ex: { atk: 0.12 }, en: { e_hp: 0.3 }
    });
    hex_register("hex_099", {
        tier: 2, form: "A", name: "一菜三吃",
        card_desc: "全队攻击 +18%", enemy_desc: "老鼠生命 +25%",
        stack: 1, impl: true,
        ex: { atk: 0.18 }, en: { e_hp: 0.25 }
    });
    hex_register("hex_100", {
        tier: 2, form: "C", name: "明火",
        card_desc: "灰烬类攻击间隔 +80%", enemy_desc: "老鼠生命 -65%",
        stack: 1, impl: true,
        ex: { cat_cycle: [ ["灰烬类", 0.80] ] }, en: { e_hp: -0.65 }
    });
    hex_register("hex_101", {
        tier: 2, form: "A", name: "火焰喷射",
        card_desc: "喷壶类攻击 +20%", enemy_desc: "老鼠生命 +30%",
        stack: 1, impl: true,
        ex: { cat_atk: [ ["喷壶类", 0.20] ] }, en: { e_hp: 0.3 }
    });
    hex_register("hex_102", {
        tier: 2, form: "A", name: "无中生有",
        card_desc: "全队攻击 +15%，本局获得 1 次免费重随", enemy_desc: "老鼠数量 +20%",
        stack: 1, impl: true,
        ex: { atk: 0.15, free_reroll: 1 }, en: { e_count: 0.2 }
    });
    hex_register("hex_103", {
        tier: 2, form: "C", name: "破釜沉舟",
        card_desc: "火苗上限 -6000", enemy_desc: "老鼠生命 -60%",
        stack: 1, impl: true,
        ex: { flame_cap: -6000 }, en: { e_hp: -0.6 }
    });
    hex_register("hex_104", {
        tier: 2, form: "C", name: "断火",
        card_desc: "全队攻击 -25%", enemy_desc: "老鼠移速 -65%",
        stack: 1, impl: true,
        ex: { atk: -0.25 }, en: { e_spd: -0.65 }
    });
    hex_register("hex_105", {
        tier: 2, form: "C", name: "空锅",
        card_desc: "全队攻击间隔 +25%", enemy_desc: "老鼠生命 -80%",
        stack: 1, impl: true,
        ex: { cycle: 0.25 }, en: { e_hp: -0.8 }
    });
    hex_register("hex_106", {
        tier: 2, form: "C", name: "冰封千里",
        card_desc: "全队攻击间隔 +40%", enemy_desc: "老鼠数量 -70%",
        stack: 1, impl: true,
        ex: { cycle: 0.4 }, en: { e_count: -0.7 }
    });
    hex_register("hex_107", {
        tier: 2, form: "A", name: "天选之卡",
        card_desc: "全队攻击 +12%，全队生命 +30%", enemy_desc: "老鼠生命 +30%",
        stack: 1, impl: true,
        ex: { atk: 0.12, hp: 0.30 }, en: { e_hp: 0.3 }
    });
    hex_register("hex_108", {
        tier: 2, form: "A", name: "赌徒的锅铲",
        card_desc: "火苗上限 -4000，铲除返还 +20%", enemy_desc: "老鼠移速 +15%",
        stack: 1, impl: true,
        ex: { flame_cap: -4000, refund: 0.2 }, en: { e_spd: 0.15 }
    });
    hex_register("hex_109", {
        tier: 2, form: "A", name: "龙柱共鸣",
        card_desc: "全队攻击 +10%，每波开始火苗 +200", enemy_desc: "老鼠生命 +20%",
        stack: 1, impl: true,
        ex: { atk: 0.10, flame_wave: 200 }, en: { e_hp: 0.2 }
    });
    hex_register("hex_110", {
        tier: 2, form: "A", name: "悬浮厨房",
        card_desc: "增幅类与辅助类卡片不占格，可直接叠放", enemy_desc: "老鼠生命 +25%",
        stack: 1, impl: true,
        ex: { gridless: true }, en: { e_hp: 0.25 }
    });
    hex_register("hex_111", {
        tier: 2, form: "A", name: "灶台主宰",
        card_desc: "每击杀 25 只老鼠，全队攻击 +4%（上限 10 层）", enemy_desc: "老鼠数量 +20%",
        stack: 1, impl: true,
        ex: { kill_stack: [0.04, 10], kill_stack_need: 25 }, en: { e_count: 0.2 }
    });
}
