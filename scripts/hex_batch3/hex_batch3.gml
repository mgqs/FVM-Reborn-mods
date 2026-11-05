/// hex_batch3 —— 二期词条（hex_185 ~ hex_259）的机制层
///
/// 与 hex_core / hex_batch2 的约定完全一致：
///   · 非海克斯模式一律返回中性值（1.0 / 0 / false），调用方不加 if 包住；
///   · 状态挂在 global.hex_state 上，用 hex_b3_ensure() 惰性补齐，
///     这样旧存档 / 旧结构不需要改 hex_state_init 也能用；
///   · 数值入口只读；需要改别的系统状态的一律走 *_hook()，由对象层在明确时机调用。
///
/// 条目来源：桌面/二期海克斯.md（68 条），其中 196 动帧格了 / 251 无量空处 判定为不可实现，
/// 实装 66 条（A 组 47 + B 组 19）。编号 184 已被「低语耳环」占用，新表首条改用 hex_185。

// ══════════════════════ 状态 ══════════════════════

/// @function hex_b3_ensure()
/// @desc 惰性补齐二期用到的字段。返回 false 表示当前没有可用的局内状态
function hex_b3_ensure() {
    if (!variable_global_exists("hex_state")) return false;
    if (!is_struct(global.hex_state)) return false;
    var _s = global.hex_state;
    if (variable_struct_exists(_s, "b3_ready")) return true;

    // ── 卡片侧静态加成 ──
    _s.b3_direct_atk      = 0;      // 平射类（直射类）攻击增量
    _s.b3_other_atk       = 0;      // 其它攻击卡攻击增量（负）
    _s.b3_pierce_atk      = 0;      // 穿透卡攻击增量
    _s.b3_id_atk          = {};     // 指定卡攻击倍率（章鱼烧 / 雷神）
    _s.b3_all_stat        = 0;      // 全属性增量（唯我独尊）
    _s.b3_thumb_atk       = 0;      // 拇指的阶级：按卡组最高档位给的全属性增量
    _s.b3_run_stat        = 0;      // 演出的高潮：本局随机全属性增量
    _s.b3_hp_on_hit       = false;  // 生存下去的勇气：受伤扣上限
    _s.b3_first_free      = false;  // 直面恐惧：每张卡首次放置免费
    _s.b3_slot_cd         = 1.0;    // 地广人稀：卡槽冷却倍率
    _s.b3_prod_mult       = 1.0;    // 江人皇：产能火苗产量倍率
    _s.b3_gem_cd          = 1.0;    // 宝石三件套：技能冷却倍率

    // ── 卡片生存 ──
    _s.b3_card_dr         = 0;      // 鲨鱼的厚皮：卡片减伤比例
    _s.b3_card_flat_dr    = 0;      // 您的盾牌：卡片固定减伤
    _s.b3_ash_proof       = false;  // 免疫灰烬秒杀
    _s.b3_control_immune  = false;  // 不受冻结 / 沉睡影响
    _s.b3_card_taken_add  = 0;      // 齿轮的烟气：卡片每受击 +X 受伤
    _s.b3_card_taken_cap  = 0.30;
    _s.b3_last_stand      = false;  // 孤狼的高傲：卡片致死免一次
    _s.b3_lifesteal       = false;  // 血魔的渴血
    _s.b3_lifesteal_cap   = 3.0;

    // ── 老鼠侧 ──
    _s.b3_enemy_taken_add = 0;      // 齿轮的烟气：老鼠每受击 +X 受伤
    _s.b3_enemy_taken_cap = 0.50;
    _s.b3_e_flat_dr       = 0;      // 您的盾牌：老鼠固定减伤
    _s.b3_e_atk_add       = 0;      // 老鼠攻击额外倍率（在 e_atk 的夹逼之外再乘一层）
    _s.b3_e_dr_roll       = 0;      // 演出的高潮：每只老鼠的 -10~+10 随机减伤（出生时 roll）
    _s.b3_dmg_jitter      = 0;      // 生死界限：每发子弹 ±X
    _s.b3_lethal_guard_ms = 0;      // 守护他人的决意：老鼠致死免死时长（毫秒）
    _s.b3_first_hit_mult  = 0;      // 当头棒喝：第一次伤害倍率
    _s.b3_duel_step       = 0;      // 决斗：对同一目标每次命中递增，封顶 25%
    _s.b3_boss_transfer   = 0;      // 悬丝的傀儡：BOSS 伤害转移上限
    _s.b3_boss_dmg        = 0;      // 对 BOSS 伤害增量
    _s.b3_boss_extra      = false;  // 呼朋唤友：BOSS 出现时再叫一只
    _s.b3_boss_extra_done = false;

    // ── 击杀 / 死亡 ──
    _s.b3_death_fire      = 0;      // 以我残躯化烈火：美食阵亡火焰攻击力
    _s.b3_e_death_lava    = 0;      // 以我残躯化烈火：鼠军阵亡熔岩时长（秒）
    _s.b3_finger_atk      = 0;      // 中指的义理：每层给全队的攻击增量
    _s.b3_finger_cycle    = 0;      // 同上，攻速增量
    _s.b3_finger_stacks   = 0;
    _s.b3_finger_cap      = 20;
    _s.b3_clone_p         = 0;      // 重燃的火光：鼠军死亡复制概率
    _s.b3_coin            = 0;      // 鼠鼠爱财宝：死亡掉落金币
    _s.b3_coin_rare       = 0;
    _s.b3_coin_p          = 0;
    _s.b3_death_cause_atk = 0;      // 起源：每达成一种死亡方式给全队的攻击增量
    _s.b3_death_cause_cap = 4;
    _s.b3_cause_mask      = 0;      // 位掩码：1 撞飞 / 2 灰烬 / 4 压扁 / 8 子弹

    // ── 周期效果（秒）──
    _s.b3_decay_sec       = 0;      // 派送箱：存活 N 秒后每秒扣血
    _s.b3_decay_hp        = 5;
    _s.b3_reaper_sec      = 0;      // 死神临近
    _s.b3_bomb_sec        = 0;      // 爆破区
    _s.b3_ghost_sec       = 0;      // 疑神疑鬼
    _s.b3_freeze_sec      = 0;      // 冰冰冰
    _s.b3_eat_sec         = 0;      // deepseek：随机吃掉一张卡
    _s.b3_couple_sec      = 0;      // 婚介所
    _s.b3_lava_sec        = 0;      // 喷涌的地脉：场地熔岩间隔
    _s.b3_lava_bonus      = 0;      // 喷涌的地脉：站在岩浆上时的攻击/攻速增量
    _s.b3_enemy_drain_sec = 0;      // 海洋的婚礼：鼠军每秒流失最大生命比例

    // ── 时间 / 节奏 ──
    _s.b3_time_slow       = false;  // 时间：拖卡时减速
    _s.b3_speed_lock      = false;  // 拥抱过去：锁 2 倍速
    _s.b3_pause_kills     = false;  // 拥抱过去：暂停后随机死卡
    _s.b3_chill           = false;  // 拥抱过去：非 BOSS 50% 寒冷

    // ── 选择界面 ──
    _s.b3_pick_all        = false;  // 领主阳伞
    _s.b3_extra_pick      = false;  // 宾邦
    _s.b3_hana           = false;   // Hana 的四卦：开局四选一
    _s.b3_hana_done      = false;
    _s.b3_hana_used      = false;   // 四卦本局已抽过

    // ── 病毒 / 组 / 契约 ──
    _s.b3_infected_dmg    = 0;      // 对跨服鼠军伤害增量
    _s.b3_infected_p      = 0;      // 生成时替换成跨服鼠军的概率
    _s.b3_group           = [];     // 本局持有的组标记（"五指" / "残响"）
    _s.b3_finger_rule     = false;  // 后巷的统治者
    _s.b3_resonance       = false;  // 残响乐团
    _s.b3_contract        = "";     // 本局签订的契约
    _s.b3_contract_off    = false;  // 残响乐团：契约负面失效

    // ── 进度计数 ──
    _s.b3_seen_type       = {};     // 本关见过的鼠军类型
    _s.b3_seen_type_n     = 0;
    _s.b3_major_kinds     = 0;      // 场上美食的大分类种数
    _s.b3_pick_cat        = "";     // 值得托付的信任：本波翻倍的分类
    _s.b3_mark_card       = "";     // 食指的指令：被标记的美食 card_id
    _s.b3_mark_card_bonus = 0;      // 命中后的全属性增量
    _s.b3_mark_enemy      = noone;  // 食指的指令：被标记的鼠军
    _s.b3_mark_enemy_ms   = 0;      // 上一条标记的时间
    _s.b3_mark_penalty_ms = 0;      // 标记鼠军死亡后的 -50% 到期时间
    _s.b3_placed_once     = {};     // 直面恐惧：本局已经放置过的 card_id
    _s.b3_couple_hot      = {};     // 婚介所：被选中的 card_id

    // ── 补充：词条表里出现过、但上面没有默认值的字段 ──
    _s.b3_finger_hp       = 0;      // 中指的义理：鼠军侧每层 +2% 生命
    _s.b3_thumb           = false;  // 拇指的阶级开关
    _s.b3_seen_atk        = 0;      // 环指的艺术：每种鼠军给全队的攻击增量
    _s.b3_deck_hp         = 0;      // 环指的艺术：卡组每种分类给鼠军生命的增量
    _s.b3_deck_kinds      = 0;      // 卡组里的大分类种数
    _s.b3_mark_on         = false;  // 食指的指令开关
    _s.b3_adj_on          = false;  // 小指的聚散开关
    _s.b3_same_hp         = 0;      // 小指的聚散：同种鼠军每只 +X 生命
    _s.b3_kind_hp_add     = 0;      // 顶点的合奏 / 小指：每种鼠军给鼠军生命的增量
    _s.b3_pick_on         = false;  // 值得托付的信任开关
    _s.b3_unique          = false;  // 唯我独尊：每种卡限一张
    _s.b3_ninja           = false;  // 释放忍术
    _s.b3_major_atk       = 0;      // 顶点的合奏：每种大分类给全队的攻击增量
    _s.b3_player_invuln   = false;  // 悬丝的傀儡：人物致死免疫
    _s.b3_slow_bullet     = 0;      // 冻实的冰块：减速子弹伤害增量
    _s.b3_first_shot      = false;  // 当头棒喝：美食第一发 ×10
    _s.b3_bullet_fire     = 0;      // 重燃的火光开关
    _s.b3_shuffle         = false;  // 昂首阔步的信念
    _s.b3_info            = false;  // 情报收集
    _s.b3_sea             = false;  // 海洋的婚礼
    _s.b3_no_stop         = false;  // 疑神疑鬼：无目标也不停火
    _s.b3_sea_ok          = false;  // 海神 + 海洋女神同时在卡组
    _s.b3_levelup         = false;  // 低声耳环
    _s.b3_e_hp_pow        = 0;      // 我是老曙：鼠军血量倍率增量（3^X - 1）
    _s.b3_contract_on     = false;  // 不公的契约开关
    _s.b3_hana_pending    = false;  // Hana 的四卦：本关开局要弹四选一
    _s.b3_hana_enemy      = -1;     // Hana 的鼠军侧选项
    _s.b3_clone_left      = 0;      // Hana：还剩几只老鼠出场时复制自身
    _s.b3_free3           = 0;      // Hana 的卦·免：还剩几次免费放置
    _s.b3_charge_on       = false;  // 知识收集开关
    _s.b3_pause_n         = 0;      // 拥抱过去：累计暂停次数
    _s.b3_cost_override   = {};     // 自由契约：被改价的卡
    _s.b3_resonance_done  = false;  // 残响乐团：已经补算过一次

    // ── 实时联动（这几个漏初始化会直接报「变量未定义」）──
    _s.b3_adj_sig         = "";     // 小指的聚散：上一次的邻接指纹，变了才重算
    _s.b3_finger_hp_add   = 0;      // 中指的义理：鼠军侧累计的生命增量（新出场的鼠也要吃）
    _s.b3_mark_card_ms    = 0;      // 食指的指令：上一次挑卡标记的时间
    _s.b3_speed_prev      = 0;      // 时间：进减速前的游戏帧率，放卡后按它还原

    // 计时（毫秒，逐个效果独立，避免互相踩）
    _s.b3_sec_ms          = current_time;
    _s.b3_decay_ms        = current_time;
    _s.b3_reaper_ms       = current_time;
    _s.b3_bomb_ms         = current_time;
    _s.b3_ghost_ms        = current_time;
    _s.b3_freeze_ms       = current_time;
    _s.b3_eat_ms          = current_time;
    _s.b3_couple_ms       = current_time;
    _s.b3_lava_ms         = current_time;
    _s.b3_contract_ms     = current_time;

    // 不公的契约：开局五选一（面板在这之后才创建）
    _s.b3_contract_on     = false;
    _s.b3_contract_pending = false;
    _s.b3_contract_pending_ms = 0;
    _s.b3_contract_show   = false;
    _s.b3_contract_free_mult = 1.0;
    _s.b3_contract_free_ms = 0;

    _s.b3_ready = true;
    return true;
}

/// @function hex_b3_apply(_d)
/// @desc 把一条二期词条的机制字段并入本局状态。由 hex_apply_core 统一调用
function hex_b3_apply(_d) {
    if (!hex_b3_ensure()) return false;
    var _s  = global.hex_state;
    var _ex = _d.ex;
    var _en = _d.en;

    // ── 卡片侧 ──
    if (variable_struct_exists(_ex, "b3_direct_atk"))  _s.b3_direct_atk  += _ex.b3_direct_atk;
    if (variable_struct_exists(_ex, "b3_other_atk"))   _s.b3_other_atk   += _ex.b3_other_atk;
    if (variable_struct_exists(_ex, "b3_pierce_atk"))  _s.b3_pierce_atk  += _ex.b3_pierce_atk;
    if (variable_struct_exists(_ex, "b3_all_stat"))    _s.b3_all_stat    += _ex.b3_all_stat;
    if (variable_struct_exists(_ex, "b3_prod_mult"))   _s.b3_prod_mult   *= (1 + _ex.b3_prod_mult);
    if (variable_struct_exists(_ex, "b3_gem_cd"))      _s.b3_gem_cd      *= (1 + _ex.b3_gem_cd);
    if (variable_struct_exists(_ex, "b3_slot_cd"))     _s.b3_slot_cd     *= _ex.b3_slot_cd;

    if (variable_struct_exists(_ex, "b3_id_atk")) {
        var _ia = _ex.b3_id_atk;
        for (var i = 0; i < array_length(_ia); i++) {
            var _cid = _ia[i][0];
            var _cur = 1.0;
            if (variable_struct_exists(_s.b3_id_atk, _cid)) _cur = _s.b3_id_atk[$ _cid];
            _s.b3_id_atk[$ _cid] = _cur * (1 + _ia[i][1]);
        }
    }

    if (variable_struct_exists(_ex, "b3_run_stat")) {
        // 演出的高潮：本局随机 1%~100% 全属性
        _s.b3_run_stat += random_range(0.01, 1.0);
    }
    if (variable_struct_exists(_ex, "b3_hp_on_hit"))     _s.b3_hp_on_hit      = true;
    if (variable_struct_exists(_ex, "b3_first_free"))    _s.b3_first_free     = true;
    if (variable_struct_exists(_ex, "b3_control_immune")) _s.b3_control_immune = true;
    if (variable_struct_exists(_ex, "b3_ash_proof"))     _s.b3_ash_proof      = true;
    if (variable_struct_exists(_ex, "b3_last_stand"))    _s.b3_last_stand     = true;
    if (variable_struct_exists(_ex, "b3_lifesteal")) {
        _s.b3_lifesteal = true;
        if (variable_struct_exists(_ex, "b3_lifesteal_cap")) _s.b3_lifesteal_cap = _ex.b3_lifesteal_cap;
    }
    if (variable_struct_exists(_ex, "b3_card_dr"))     _s.b3_card_dr     += _ex.b3_card_dr;
    if (variable_struct_exists(_ex, "b3_card_flat_dr")) _s.b3_card_flat_dr += _ex.b3_card_flat_dr;
    if (variable_struct_exists(_ex, "b3_card_taken")) {
        var _ct = _ex.b3_card_taken;
        _s.b3_card_taken_add += _ct[0];
        _s.b3_card_taken_cap  = max(_s.b3_card_taken_cap, _ct[1]);
    }
    if (variable_struct_exists(_ex, "b3_finger")) {
        // 中指的义理：美食阵亡给全队叠层
        var _fg = _ex.b3_finger;
        _s.b3_finger_atk   += _fg[0];
        _s.b3_finger_cycle += _fg[1];
        _s.b3_finger_cap    = max(_s.b3_finger_cap, _fg[2]);
    }
    if (variable_struct_exists(_ex, "b3_death_fire"))  _s.b3_death_fire  = max(_s.b3_death_fire, _ex.b3_death_fire);
    if (variable_struct_exists(_ex, "b3_bullet_fire")) _s.b3_bullet_fire = max(_s.b3_bullet_fire, _ex.b3_bullet_fire);
    if (variable_struct_exists(_ex, "b3_death_cause_atk")) _s.b3_death_cause_atk += _ex.b3_death_cause_atk;
    if (variable_struct_exists(_ex, "b3_decay")) {
        var _dc = _ex.b3_decay;
        _s.b3_decay_sec = max(_s.b3_decay_sec, _dc[0]);
        _s.b3_decay_hp  = max(_s.b3_decay_hp, _dc[1]);
    }
    if (variable_struct_exists(_ex, "b3_reaper_sec"))  _s.b3_reaper_sec  = max(_s.b3_reaper_sec, _ex.b3_reaper_sec);
    if (variable_struct_exists(_ex, "b3_bomb_sec"))    _s.b3_bomb_sec    = max(_s.b3_bomb_sec, _ex.b3_bomb_sec);
    if (variable_struct_exists(_ex, "b3_freeze_sec"))  _s.b3_freeze_sec  = max(_s.b3_freeze_sec, _ex.b3_freeze_sec);
    if (variable_struct_exists(_ex, "b3_eat_sec"))     _s.b3_eat_sec     = max(_s.b3_eat_sec, _ex.b3_eat_sec);
    if (variable_struct_exists(_ex, "b3_couple_sec"))  _s.b3_couple_sec  = max(_s.b3_couple_sec, _ex.b3_couple_sec);
    if (variable_struct_exists(_ex, "b3_lava")) {
        var _lv = _ex.b3_lava;
        _s.b3_lava_sec   = max(_s.b3_lava_sec, _lv[0]);
        _s.b3_lava_bonus += _lv[1];
    }
    if (variable_struct_exists(_ex, "b3_time_slow"))   _s.b3_time_slow   = true;
    if (variable_struct_exists(_ex, "b3_speed_lock"))  _s.b3_speed_lock  = true;
    if (variable_struct_exists(_ex, "b3_pause_kills")) _s.b3_pause_kills = true;
    if (variable_struct_exists(_ex, "b3_pick_all"))    _s.b3_pick_all    = true;
    if (variable_struct_exists(_ex, "b3_extra_pick"))  _s.b3_extra_pick  = true;
    if (variable_struct_exists(_ex, "b3_hana"))        _s.b3_hana        = true;

    // ── 老鼠侧 ──
    // 残响乐团会把残响组的卡片侧效果再跑一遍（hex_apply_core 用 hex_card_only_apply 标记），
    // 那一轮必须整体跳过老鼠侧，否则「削弱鼠军」的部分会被反向翻倍，等于白送加强
    var _b3_card_only = variable_global_exists("hex_card_only_apply") && global.hex_card_only_apply;
    if (!_b3_card_only) {
    if (variable_struct_exists(_en, "b3_e_flat_dr"))   _s.b3_e_flat_dr   += _en.b3_e_flat_dr;
    if (variable_struct_exists(_en, "b3_e_atk_add"))   _s.b3_e_atk_add   += _en.b3_e_atk_add;
    if (variable_struct_exists(_en, "b3_e_dr_roll"))   _s.b3_e_dr_roll    = _en.b3_e_dr_roll;
    if (variable_struct_exists(_en, "b3_dmg_jitter"))  _s.b3_dmg_jitter  += _en.b3_dmg_jitter;
    if (variable_struct_exists(_en, "b3_lethal_guard")) _s.b3_lethal_guard_ms = max(_s.b3_lethal_guard_ms, _en.b3_lethal_guard * 1000);
    if (variable_struct_exists(_en, "b3_first_hit"))   _s.b3_first_hit_mult = max(_s.b3_first_hit_mult, _en.b3_first_hit);
    if (variable_struct_exists(_en, "b3_duel_step"))   _s.b3_duel_step   += _en.b3_duel_step;
    if (variable_struct_exists(_en, "b3_boss_transfer")) _s.b3_boss_transfer += _en.b3_boss_transfer;
    if (variable_struct_exists(_en, "b3_boss_dmg"))    _s.b3_boss_dmg    += _en.b3_boss_dmg;
    if (variable_struct_exists(_en, "b3_boss_extra"))  _s.b3_boss_extra   = true;
    if (variable_struct_exists(_en, "b3_e_death_lava")) _s.b3_e_death_lava = max(_s.b3_e_death_lava, _en.b3_e_death_lava);
    if (variable_struct_exists(_en, "b3_coin")) {
        var _cn = _en.b3_coin;
        _s.b3_coin      = max(_s.b3_coin, _cn[0]);
        _s.b3_coin_rare = max(_s.b3_coin_rare, _cn[1]);
        _s.b3_coin_p    = max(_s.b3_coin_p, _cn[2]);
    }
    if (variable_struct_exists(_en, "b3_enemy_taken")) {
        var _et = _en.b3_enemy_taken;
        _s.b3_enemy_taken_add += _et[0];
        _s.b3_enemy_taken_cap  = max(_s.b3_enemy_taken_cap, _et[1]);
    }
    if (variable_struct_exists(_en, "b3_enemy_drain_sec")) _s.b3_enemy_drain_sec = max(_s.b3_enemy_drain_sec, _en.b3_enemy_drain_sec);
    if (variable_struct_exists(_en, "b3_infected")) {
        var _if = _en.b3_infected;
        _s.b3_infected_dmg += _if[0];
        _s.b3_infected_p    = max(_s.b3_infected_p, _if[1]);
    }
    if (variable_struct_exists(_en, "b3_chill")) _s.b3_chill = true;
    if (variable_struct_exists(_en, "b3_ghost_sec"))   _s.b3_ghost_sec   = max(_s.b3_ghost_sec, _en.b3_ghost_sec);
    if (variable_struct_exists(_en, "b3_deck_hp"))      _s.b3_deck_hp     += _en.b3_deck_hp;
    if (variable_struct_exists(_en, "b3_clone")) {
        var _cl = _en.b3_clone;
        _s.b3_clone_p = max(_s.b3_clone_p, _cl[0]);
    }
    if (variable_struct_exists(_en, "b3_finger_hp")) {
        // 中指的义理·鼠军侧：其余鼠军每只 +2% 生命（在 on_enemy_death 里结算）
        _s.b3_finger_hp += _en.b3_finger_hp;
    }
    }

    // ── 补充：卡片侧开关 / 增量（二期表里出现过的全部键）──
    if (variable_struct_exists(_ex, "b3_thumb"))        _s.b3_thumb        = true;
    if (variable_struct_exists(_ex, "b3_seen_atk"))     _s.b3_seen_atk    += _ex.b3_seen_atk;
    if (variable_struct_exists(_ex, "b3_mark"))         _s.b3_mark_on      = true;
    if (variable_struct_exists(_ex, "b3_adj"))          _s.b3_adj_on       = true;
    if (variable_struct_exists(_ex, "b3_pick"))         _s.b3_pick_on      = true;
    if (variable_struct_exists(_ex, "b3_unique"))       _s.b3_unique       = true;
    if (variable_struct_exists(_ex, "b3_charge"))       _s.b3_charge_on    = true;
    if (variable_struct_exists(_ex, "b3_shuffle"))      _s.b3_shuffle      = true;
    if (variable_struct_exists(_ex, "b3_info")) {
        // 情报收集：首次启用时把老存档里已知的鼠军全部标记为「已读」，
        // 否则老档一进关就是全场 -20%（文档 4.7 明确要求做这个迁移）
        if (!variable_global_exists("save_data") || !is_struct(global.save_data)) {
            // 没有存档结构就直接跳过
        } else if (!variable_struct_exists(global.save_data, "b3_info_seen")) {
            global.save_data.b3_info_seen = [];
            if (variable_global_exists("enemy_map") && ds_exists(global.enemy_map, ds_type_map)) {
                var _all = ds_map_keys_to_array(global.enemy_map);
                for (var _i = 0; _i < array_length(_all); _i++) {
                    array_push(global.save_data.b3_info_seen, string(_all[_i]));
                }
            }
        }
        _s.b3_info = true;
    }
    if (variable_struct_exists(_ex, "b3_sea"))          _s.b3_sea          = true;
    if (variable_struct_exists(_ex, "b3_no_stop"))      _s.b3_no_stop      = true;
    if (variable_struct_exists(_ex, "b3_levelup"))      _s.b3_levelup      = true;
    if (variable_struct_exists(_ex, "b3_first_shot"))   _s.b3_first_shot   = true;
    if (variable_struct_exists(_ex, "b3_player_guard")) _s.b3_player_invuln = true;
    if (variable_struct_exists(_ex, "b3_contract_on"))  _s.b3_contract_on  = true;
    if (variable_struct_exists(_ex, "b3_contract_pick")) {
        // 不公的契约：玩家在五选一面板里挑的那一种
        _s.b3_contract         = _ex.b3_contract_pick;
        _s.b3_contract_ms      = current_time;
        _s.b3_contract_pending = false;
        _s.b3_contract_show    = false;
        if (variable_global_exists("buff_apply_id")) global.buff_apply_id += 1;
    }
    // 刚抽到「不公的契约」、还没签：立刻挂成 pending，
    // 下一关开局就会弹出五选一面板（不然只能等某个关卡开局的 roll_contract 补）
    if (variable_struct_exists(_ex, "b3_contract_on") && _s.b3_contract == "") {
        _s.b3_contract_pending    = true;
        _s.b3_contract_pending_ms = current_time;
    }
    if (variable_struct_exists(_ex, "b3_slow_bullet"))  _s.b3_slow_bullet += _ex.b3_slow_bullet;
    if (variable_struct_exists(_ex, "b3_major_atk"))    _s.b3_major_atk   += _ex.b3_major_atk;

    // 我是老曙：本局鼠军血量随机 ×3~×729（3 的 1~6 次方）
    if (variable_struct_exists(_en, "b3_e_hp_roll")) {
        _s.b3_e_hp_pow += (power(3, irandom_range(1, 6)) - 1);
    }
    // 顶点的合奏 / 小指的聚散：每种鼠军给鼠军生命的增量
    if (variable_struct_exists(_en, "b3_kind_hp"))    _s.b3_kind_hp_add += _en.b3_kind_hp;
    if (variable_struct_exists(_en, "b3_same_hp"))    _s.b3_kind_hp_add += _en.b3_same_hp;
    if (variable_struct_exists(_en, "b3_ninja"))      _s.b3_ninja        = true;

    // 残响乐团：把残响组十条的卡片侧效果再结算一次（等价翻倍）
    if (variable_struct_exists(_ex, "b3_resonance")) {
        // 顺序很重要：先补算（这时 b3_resonance 还是 false，res_mult 仍是 1），
        // 再把开关打开。反过来的话「补算一次」会和读取处的 ×2 叠成 ×3。
        hex_b3_reapply_resonance();
        _s.b3_resonance = true;
    }

    // Hana 的四卦：选过之后才在下一关开局弹面板
    if (variable_struct_exists(_ex, "b3_hana_pick")) {
        _s.b3_hana_done = true;
        _s.b3_hana_used = true;
    }
    if (variable_struct_exists(_ex, "b3_hana_free3")) {
        _s.b3_free3 = 3;
    }

    // ── 组 / 契约 ──
    if (variable_struct_exists(_ex, "b3_group")) {
        var _gp = _ex.b3_group;
        if (array_index_of(_s.b3_group, _gp) == -1) array_push(_s.b3_group, _gp);
    }
    if (variable_struct_exists(_ex, "b3_finger_rule")) _s.b3_finger_rule = true;
    if (variable_struct_exists(_ex, "b3_contract_off")) _s.b3_contract_off = true;

    return true;
}

// ══════════════════════ 卡片侧读取口 ══════════════════════

/// @function hex_b3_attack_major(_id)
/// @desc 是否「攻击类」大分类（产能 / 防御 / 增幅 / 辅助 不算）
function hex_b3_attack_major(_id) {
    var _c = card_get_category(_id);
    if (is_undefined(_c)) return false;
    var _majors = ["直射类", "投掷类", "多向类", "专业防空类", "喷壶类",
                   "追踪类", "非远程类", "灰烬类"];
    return (array_index_of(_majors, _c.major) != -1);
}

/// @function hex_b3_is_pierce_card(_id)
/// @desc 穿透卡：子分类为「直线穿透类 / 过火穿透类」
function hex_b3_is_pierce_card(_id) {
    var _c = card_get_category(_id);
    if (is_undefined(_c)) return false;
    if (_c.minor == "直线穿透类") return true;
    if (_c.sub == "过火穿透类") return true;
    if (_c.minor == "过火穿透类") return true;
    return false;
}

/// @function hex_b3_atk_factor(_plant_id)
/// @desc 挂在 hex_atk_mult_for_card 末端的攻击系数（二期：针对分类 / 特定卡）
function hex_b3_atk_factor(_plant_id) {
    if (!hex_enabled()) return 1.0;
    if (!variable_global_exists("hex_state")) return 1.0;
    if (!is_struct(global.hex_state)) return 1.0;
    if (!hex_b3_ensure()) return 1.0;
    var _s = global.hex_state;
    var _m = 1.0;

    // 唯我独尊 / 演出的高潮 / 拇指的阶级：全属性
    // 唯我独尊 / 演出的高潮 不属于五指组，不参与后巷 / 残响翻倍
    var _g5  = hex_b3_fr() * hex_b3_res_mult();
    var _all = _s.b3_all_stat + _s.b3_run_stat + _s.b3_thumb_atk * _g5;
    if (_all != 0) _m *= (1 + _all);

    // 环指的艺术（五指组，后巷的统治者可翻倍） / 顶点的合奏 / 起源：读场上实时计数
    var _add = _s.b3_seen_atk * hex_b3_fr() * hex_b3_res_mult() * _s.b3_seen_type_n
             + _s.b3_major_atk * _s.b3_major_kinds
             + _s.b3_death_cause_atk * hex_b3_cause_count();
    if (_add != 0) _m *= (1 + _add);

    // 指定卡
    if (variable_struct_exists(_s.b3_id_atk, _plant_id)) _m *= _s.b3_id_atk[$ _plant_id];

    var _cat = card_get_category(_plant_id);
    if (!is_undefined(_cat)) {
        // 普通人 / 通天之人：平射类加强、其余攻击卡削弱
        if (_s.b3_direct_atk != 0 || _s.b3_other_atk != 0) {
            if (_cat.major == "直射类") {
                _m *= (1 + _s.b3_direct_atk);
            } else if (hex_b3_attack_major(_plant_id)) {
                _m *= max(0.05, 1 + _s.b3_other_atk);
            }
        }
        // 这不是外挂：穿透卡加强
        if (_s.b3_pierce_atk != 0 && hex_b3_is_pierce_card(_plant_id)) {
            _m *= (1 + _s.b3_pierce_atk);
        }
        // 值得托付的信任：本波随机分类翻倍，其余攻击卡减半
        if (_s.b3_pick_cat != "" && hex_b3_attack_major(_plant_id)) {
            if (_cat.major == _s.b3_pick_cat) _m *= 2.0;
            else                              _m *= 0.5;
        }
    }
    return _m;
}

/// @function hex_b3_res_mult()
/// @desc 残响乐团：残响组十条的卡片侧效果再结算一次（读取端乘 2）。
///       数值型增量（atk/hp/cycle）在 apply 时已经重放过一遍；
///       这里负责「开关 / 布尔型」词条（拇指 / 食指 / 聚散 / 渴血 …）的那一份。
function hex_b3_res_mult() {
    if (!variable_global_exists("hex_state") || !is_struct(global.hex_state)) return 1.0;
    if (!variable_struct_exists(global.hex_state, "b3_resonance")) return 1.0;
    return global.hex_state.b3_resonance ? 2.0 : 1.0;
}

/// @function hex_b3_fr()
/// @desc 后巷的统治者：五指组加成倍率（没拿就是 1.0，拿了就是 2.0）
function hex_b3_fr() {
    if (!variable_global_exists("hex_state") || !is_struct(global.hex_state)) return 1.0;
    if (!variable_struct_exists(global.hex_state, "b3_finger_rule")) return 1.0;
    return global.hex_state.b3_finger_rule ? 2.0 : 1.0;
}

/// @function hex_b3_adj_count(_inst)
/// @desc 小指的聚散：与该卡四邻相邻、且大分类相同的卡有几张。实时算，
///       不依赖每秒刷新的缓存字段——放置/拆除后当帧就该生效。
function hex_b3_adj_count(_inst) {
    if (!instance_exists(_inst)) return 0;
    if (!variable_instance_exists(_inst, "grid_col")) return 0;
    if (!variable_instance_exists(_inst, "grid_row")) return 0;
    var _pid = variable_instance_exists(_inst, "plant_id") ? _inst.plant_id : "";
    if (_pid == "" || _pid == "player") return 0;
    var _cat = card_get_category(_pid);
    if (is_undefined(_cat)) return 0;
    var _n = 0;
    var _cnt = instance_number(obj_card_parent);
    for (var i = 0; i < _cnt; i++) {
        var _o = instance_find(obj_card_parent, i);
        if (!instance_exists(_o)) continue;
        if (_o.id == _inst.id) continue;
        if (!variable_instance_exists(_o, "plant_id")) continue;
        if (_o.plant_id == "player") continue;
        if (abs(_o.grid_col - _inst.grid_col) + abs(_o.grid_row - _inst.grid_row) != 1) continue;
        var _c2 = card_get_category(_o.plant_id);
        if (is_undefined(_c2)) continue;
        if (_c2.major == _cat.major) _n += 1;
    }
    return _n;
}

/// @function hex_b3_no_stop_attack()
/// @desc 疑神疑鬼：攻击类美食在场上没有鼠军时也不停火
function hex_b3_no_stop_attack() {
    if (!hex_enabled()) return false;
    if (!variable_hex_b3_state()) return false;
    return global.hex_state.b3_no_stop;
}

/// @function hex_b3_adj_mult(_inst)
/// @desc 小指的聚散：每张相邻同类 +10%，上限 +100%（后巷的统治者翻倍到 +200%）
function hex_b3_adj_mult(_inst) {
    if (!hex_enabled()) return 1.0;
    if (!variable_global_exists("hex_state") || !is_struct(global.hex_state)) return 1.0;
    if (!hex_b3_ensure()) return 1.0;
    var _s = global.hex_state;
    if (!_s.b3_adj_on) return 1.0;
    var _n = hex_b3_adj_count(_inst);
    if (_n <= 0) return 1.0;
    var _g = hex_b3_fr() * hex_b3_res_mult();
    return 1 + min(1.0 * _g, 0.10 * _n * _g);
}

/// @function hex_b3_inst_atk(_inst)
/// @desc 需要实例上下文的攻击倍率（蓄力 / 相邻 / 婚介所 / 岩浆 / 全属性）
function hex_b3_inst_atk(_inst) {
    if (!hex_enabled()) return 1.0;
    if (!instance_exists(_inst)) return 1.0;
    if (!variable_global_exists("hex_state") || !is_struct(global.hex_state)) return 1.0;
    if (!hex_b3_ensure()) return 1.0;
    var _s = global.hex_state;
    var _m = 1.0;

    // 力量契约：攻击 +100%
    _m *= hex_b3_contract_atk_mult();

    // 知识收集：不攻击蓄力到 200%，持续攻击衰减到 50%
    if (variable_instance_exists(_inst, "b3_charge")) {
        _m *= (0.5 + 1.5 * clamp(_inst.b3_charge / 10, 0, 1));
    }
    // 小指的聚散：相邻同分类每张 +10%（上限 +100%），实时算
    _m *= hex_b3_adj_mult(_inst);
    // 婚介所：被点名的两张攻击 +50%，其余 -50%
    if (_s.b3_couple_sec > 0) {
        var _hot = false;
        if (variable_struct_exists(_s.b3_couple_hot, _inst.plant_id)) _hot = true;
        if (_hot) _m *= 1.5;
        else      _m *= 0.5;
    }
    // 喷涌的地脉：站在岩浆格上
    if (_s.b3_lava_bonus > 0 && variable_instance_exists(_inst, "b3_on_lava") && _inst.b3_on_lava) {
        _m *= (1 + _s.b3_lava_bonus);
    }
    // 食指的指令：命中标记后的全属性
    if (_s.b3_mark_card_bonus != 0) _m *= (1 + _s.b3_mark_card_bonus * hex_b3_fr() * hex_b3_res_mult());
    // 中指的义理：叠层
    if (_s.b3_finger_stacks > 0 && _s.b3_finger_atk > 0) {
        _m *= (1 + _s.b3_finger_atk * hex_b3_fr() * hex_b3_res_mult() * _s.b3_finger_stacks);
    }
    // 海洋的婚礼：海神 / 海洋女神 / 海底卡全属性翻倍
    if (variable_instance_exists(_inst, "b3_sea_double") && _inst.b3_sea_double) _m *= 2.0;

    return _m;
}

/// @function hex_b3_inst_cycle(_inst)
function hex_b3_inst_cycle(_inst) {
    if (!hex_enabled()) return 1.0;
    if (!instance_exists(_inst)) return 1.0;
    if (!variable_global_exists("hex_state") || !is_struct(global.hex_state)) return 1.0;
    if (!hex_b3_ensure()) return 1.0;
    var _s = global.hex_state;
    var _m = 1.0;

    // 神速契约：攻速 +100%
    _m *= hex_b3_contract_cycle_mult();

    var _g5  = hex_b3_fr() * hex_b3_res_mult();
    var _all = _s.b3_all_stat + _s.b3_run_stat + _s.b3_thumb_atk * _g5;
    if (_all != 0) _m *= max(0.15, 1 - _all * 0.5);   // 攻速按一半计入，避免与攻击叠成指数

    if (_s.b3_lava_bonus > 0 && variable_instance_exists(_inst, "b3_on_lava") && _inst.b3_on_lava) {
        _m *= (1 - min(0.6, _s.b3_lava_bonus));
    }
    if (_s.b3_mark_card_bonus != 0) _m *= max(0.2, 1 - _s.b3_mark_card_bonus * hex_b3_fr() * hex_b3_res_mult() * 0.5);
    if (_s.b3_finger_stacks > 0 && _s.b3_finger_cycle > 0) {
        _m *= max(0.2, 1 - _s.b3_finger_cycle * hex_b3_fr() * hex_b3_res_mult() * _s.b3_finger_stacks);
    }
    // 小指的聚散：相邻同类每张 +10% 攻速
    _m /= hex_b3_adj_mult(_inst);
    if (variable_instance_exists(_inst, "b3_sea_double") && _inst.b3_sea_double) _m *= 0.5;

    return _m;
}

/// @function hex_b3_inst_hp(_inst)
/// @desc 生命上限倍率（只乘在「纯上限」上，不掺取长补短）
function hex_b3_inst_hp(_inst) {
    if (!hex_enabled()) return 1.0;
    if (!instance_exists(_inst)) return 1.0;
    if (!variable_global_exists("hex_state") || !is_struct(global.hex_state)) return 1.0;
    if (!hex_b3_ensure()) return 1.0;
    var _s = global.hex_state;
    var _m = 1.0;

    var _g5  = hex_b3_fr() * hex_b3_res_mult();
    var _all = _s.b3_all_stat + _s.b3_run_stat + _s.b3_thumb_atk * _g5;
    if (_all != 0) _m *= (1 + _all);

    if (_s.b3_mark_card_bonus != 0) _m *= (1 + _s.b3_mark_card_bonus * hex_b3_fr() * hex_b3_res_mult());
    if (_s.b3_finger_stacks > 0 && _s.b3_finger_atk > 0) _m *= (1 + _s.b3_finger_atk * hex_b3_fr() * hex_b3_res_mult() * _s.b3_finger_stacks);
    // 小指的聚散：相邻同类每张 +10% 生命上限
    _m *= hex_b3_adj_mult(_inst);
    if (variable_instance_exists(_inst, "b3_sea_double") && _inst.b3_sea_double) _m *= 2.0;

    // 血魔的渴血：满血溢出转上限（按 base 的百分比累加）
    if (variable_instance_exists(_inst, "b3_hp_gain") && _inst.b3_hp_gain > 0) {
        _m *= (1 + min(_inst.b3_hp_gain, _s.b3_lifesteal_cap - 1));
    }
    return _m;
}

/// @function hex_b3_hp_loss(_inst)
/// @desc 生存下去的勇气：受伤被扣掉的生命上限（绝对值，由重算处减去）
function hex_b3_hp_loss(_inst) {
    if (!hex_enabled()) return 0;
    if (!instance_exists(_inst)) return 0;
    if (!variable_instance_exists(_inst, "b3_hp_loss")) return 0;
    return max(0, _inst.b3_hp_loss);
}

/// @function hex_b3_hp_active(_inst)
/// @desc 二期是否有可能改到这张卡的生命上限。重算处靠它决定要不要重设 max_hp，
///       漏了就变成「上限涨了血不涨」或者「别的系统临时改的上限被拉回基准」
function hex_b3_hp_active(_inst) {
    if (!hex_enabled()) return false;
    if (!variable_hex_b3_state()) return false;
    var _s = global.hex_state;
    if (_s.b3_all_stat != 0) return true;
    if (_s.b3_run_stat != 0) return true;
    if (_s.b3_thumb_atk != 0) return true;
    if (_s.b3_mark_card_bonus != 0) return true;
    if (_s.b3_finger_stacks > 0 && _s.b3_finger_atk > 0) return true;
    if (_s.b3_adj_on) return true;    // 小指的聚散：邻接变化会改上限
    if (instance_exists(_inst)) {
        if (variable_instance_exists(_inst, "b3_sea_double") && _inst.b3_sea_double) return true;
        if (variable_instance_exists(_inst, "b3_hp_gain") && _inst.b3_hp_gain > 0) return true;
        if (variable_instance_exists(_inst, "b3_hp_loss") && _inst.b3_hp_loss > 0) return true;
    }
    return false;
}

/// @function hex_b3_cost_markup()
/// @desc 直面恐惧：火苗消耗 ×1.5（在 hex_batch2_cost 里乘）
function hex_b3_cost_markup() {
    if (!hex_enabled()) return 1.0;
    if (!variable_global_exists("hex_state") || !is_struct(global.hex_state)) return 1.0;
    if (!hex_b3_ensure()) return 1.0;
    var _s = global.hex_state;
    var _m = 1.0;
    if (_s.b3_first_free) _m *= 1.5;
    // 自由契约：每 30 秒滚一次全队耗能系数（-40%~+80%）
    if (variable_struct_exists(_s, "b3_contract_free_mult")) {
        if (_s.b3_contract_free_mult != 1.0) _m *= _s.b3_contract_free_mult;
    }
    return _m;
}

/// @function hex_b3_cost_for(_card_id, _base)
/// @desc 自由契约：个别卡片被改成固定价格
function hex_b3_cost_for(_card_id, _base) {
    if (!hex_enabled()) return _base;
    if (!variable_global_exists("hex_state") || !is_struct(global.hex_state)) return _base;
    if (!hex_b3_ensure()) return _base;
    var _s = global.hex_state;
    if (!variable_struct_exists(_s, "b3_cost_override")) return _base;
    if (!is_struct(_s.b3_cost_override)) return _base;
    if (!variable_struct_exists(_s.b3_cost_override, _card_id)) return _base;
    return max(0, _s.b3_cost_override[$ _card_id]);
}

/// @function hex_b3_first_place_free(_card_id)
/// @desc 直面恐惧：本局该卡第一次放置免费（每张卡各一次）
function hex_b3_first_place_free(_card_id) {
    if (!hex_enabled()) return false;
    if (!variable_global_exists("hex_state") || !is_struct(global.hex_state)) return false;
    if (!hex_b3_ensure()) return false;
    var _s = global.hex_state;
    if (!_s.b3_first_free) return false;
    if (_s.b3_contract != "" && _s.b3_contract_off) return false;
    if (variable_struct_exists(_s.b3_placed_once, _card_id)) return false;
    _s.b3_placed_once[$ _card_id] = true;
    return true;
}

/// @function hex_b3_slot_cd_mult()
function hex_b3_slot_cd_mult() {
    if (!hex_enabled()) return 1.0;
    if (!variable_global_exists("hex_state") || !is_struct(global.hex_state)) return 1.0;
    if (!hex_b3_ensure()) return 1.0;
    return clamp(global.hex_state.b3_slot_cd, 0.25, 4.0);
}

/// @function hex_b3_prod_mult(_plant_id)
/// @desc 江人皇：产能类火苗产量倍率
function hex_b3_prod_mult(_plant_id) {
    if (!hex_enabled()) return 1.0;
    if (!variable_global_exists("hex_state") || !is_struct(global.hex_state)) return 1.0;
    if (!hex_b3_ensure()) return 1.0;
    var _s = global.hex_state;
    if (_s.b3_prod_mult == 1.0) return 1.0;
    var _cat = card_get_category(_plant_id);
    if (is_undefined(_cat)) return 1.0;
    if (_cat.major != "产能类") return 1.0;
    return _s.b3_prod_mult;
}

/// @function hex_b3_gem_cd_mult()
function hex_b3_gem_cd_mult() {
    if (!hex_enabled()) return 1.0;
    if (!variable_global_exists("hex_state") || !is_struct(global.hex_state)) return 1.0;
    if (!hex_b3_ensure()) return 1.0;
    return clamp(global.hex_state.b3_gem_cd, 0.1, 2.0);
}

/// @function hex_b3_cause_count()
/// @desc 起源：本局已经出现过的死亡方式数量（位掩码 1/2/4/8）
function hex_b3_cause_count() {
    if (!variable_global_exists("hex_state") || !is_struct(global.hex_state)) return 0;
    if (!hex_b3_ensure()) return 0;
    var _m = global.hex_state.b3_cause_mask;
    var _n = 0;
    if ((_m & 1) != 0) _n += 1;
    if ((_m & 2) != 0) _n += 1;
    if ((_m & 4) != 0) _n += 1;
    if ((_m & 8) != 0) _n += 1;
    // 上限由词条给（默认 4；目前位掩码也只有 4 位，留着是为了以后加死亡方式不用改这里）
    return min(_n, global.hex_state.b3_death_cause_cap);
}

/// @function hex_b3_reapply_resonance()
/// @desc 残响乐团：把「残响组」已经持有的词条再结算一次卡片侧数值。
///       实现方式是把 hex_card_only_apply 置真后重跑 hex_apply_core，
///       老鼠侧在这一轮被跳过，所以不会顺带把鼠军也翻倍。
function hex_b3_reapply_resonance() {
    if (!variable_global_exists("hex_state") || !is_struct(global.hex_state)) return;
    var _s = global.hex_state;
    if (_s.b3_resonance_done) return;

    var _group = ["hex_221", "hex_222", "hex_223", "hex_224", "hex_225",
                  "hex_226", "hex_227", "hex_228", "hex_229", "hex_230"];
    var _owned = [];
    for (var i = 0; i < array_length(_s.picked); i++) {
        if (array_index_of(_group, _s.picked[i].id) != -1) array_push(_owned, _s.picked[i].id);
    }
    for (var k = 0; k < array_length(_s.persist); k++) {
        if (array_index_of(_group, _s.persist[k].id) != -1
            && array_index_of(_owned, _s.persist[k].id) == -1) {
            array_push(_owned, _s.persist[k].id);
        }
    }
    // 一条都没拿到就先别打完成标记，等真正握有残响组时再补算
    if (array_length(_owned) == 0) return;
    _s.b3_resonance_done = true;

    global.hex_card_only_apply = true;
    for (var j = 0; j < array_length(_owned); j++) hex_apply_core(_owned[j]);
    global.hex_card_only_apply = false;

    if (variable_global_exists("buff_apply_id")) global.buff_apply_id += 1;
}

// ══════════════════════ 老鼠侧读取口 ══════════════════════

/// @function hex_b3_seen_type_add(_mouse_id)
/// @desc 记录本关见过的鼠军类型（环指的艺术 / 顶点的合奏）
function hex_b3_seen_type_add(_mouse_id) {
    if (!hex_enabled()) return;
    if (!hex_b3_ensure()) return;
    if (_mouse_id == "") return;
    var _s = global.hex_state;
    if (variable_struct_exists(_s.b3_seen_type, _mouse_id)) return;
    _s.b3_seen_type[$ _mouse_id] = true;
    _s.b3_seen_type_n += 1;
}

/// @function hex_b3_enemy_hp_extra()
/// @desc 挂在 hex_enemy_mult("hp") 上的额外倍率（出场即生效的那部分）
function hex_b3_enemy_hp_extra() {
    if (!hex_enabled()) return 1.0;
    if (!variable_hex_b3_state()) return 1.0;
    var _s = global.hex_state;
    var _add = 0;

    // 环指的艺术：卡组每有一种美食分类，鼠军生命 +5%
    _add += _s.b3_deck_hp * _s.b3_deck_kinds;
    // 顶点的合奏 / 小指的聚散：场上每有一种鼠军，鼠军生命 +X%（上限 50%）
    // 小指属于五指组，后巷的统治者会让鼠军侧减半
    if (_s.b3_kind_hp_add > 0 && _s.b3_seen_type_n > 0) {
        var _kh = _s.b3_kind_hp_add;
        if (hex_b3_fr() > 1.0) _kh *= 0.5;
        _add += min(0.5, _kh * _s.b3_seen_type_n);
    }
    // 我是老曙：本局随机 3^X 倍血量
    _add += _s.b3_e_hp_pow;

    return max(0.2, 1 + _add);
}

/// @function variable_hex_b3_state()
/// @desc 内部小工具：状态存在且已补齐
function variable_hex_b3_state() {
    if (!variable_global_exists("hex_state")) return false;
    if (!is_struct(global.hex_state)) return false;
    return hex_b3_ensure();
}

/// @function hex_b3_enemy_atk_extra()
/// @desc 老鼠攻击的额外倍率。挂在 hex_enemy_mult("atk") 的夹逼**之外**，
///       专门给「按实例 / 按波次 roll 出来」的加成用（这类加成不该被 0.3~3.0 吃掉）。
///       普通的固定增量走 e_atk 进夹逼，不要塞这里。
function hex_b3_enemy_atk_extra() {
    if (!hex_enabled()) return 1.0;
    if (!variable_hex_b3_state()) return 1.0;
    var _s = global.hex_state;
    var _m = 1.0;
    if (_s.b3_e_atk_add != 0) _m *= (1 + _s.b3_e_atk_add);
    return _m;
}

/// @function hex_b3_infected_swap(_type)
/// @desc 病毒系列：把普通鼠军换成跨服（感染）鼠军。返回 "" 表示不换
function hex_b3_infected_swap(_type) {
    if (!hex_enabled()) return "";
    if (!variable_hex_b3_state()) return "";
    var _s = global.hex_state;
    if (_s.b3_infected_p <= 0) return "";
    if (!variable_global_exists("enemy_map")) return "";
    if (!ds_exists(global.enemy_map, ds_type_map)) return "";
    if (_type == "") return "";
    if (string_pos("infected_", _type) == 1) return "";
    var _alt = "infected_" + _type;
    if (!ds_map_exists(global.enemy_map, _alt)) return "";
    if (random(1) >= _s.b3_infected_p) return "";
    return _alt;
}

/// @function hex_b3_enemy_spawn(_inst)
/// @desc 出生瞬间的二期标记：随机减伤 roll / 寒冷 / 秒杀保护 / 同种计数
function hex_b3_enemy_spawn(_inst) {
    if (!hex_enabled()) return;
    if (!instance_exists(_inst)) return;
    if (!variable_hex_b3_state()) return;
    var _s = global.hex_state;

    if (variable_instance_exists(_inst, "mouse_id")) hex_b3_seen_type_add(string(_inst.mouse_id));

    // 演出的高潮：每只老鼠 -10~+10 固定减伤
    if (_s.b3_e_dr_roll > 0) _inst.b3_dr_roll = irandom_range(-_s.b3_e_dr_roll, _s.b3_e_dr_roll);

    // 拥抱过去：非 BOSS 永久 50% 寒冷（移速减半、啃咬变慢）
    if (_s.b3_chill) {
        var _boss = false;
        if (variable_instance_exists(_inst, "is_boss")) _boss = _inst.is_boss;
        if (!_boss) {
            if (variable_instance_exists(_inst, "move_speed")) _inst.move_speed *= 0.5;
            if (variable_instance_exists(_inst, "atk_cycle"))  _inst.atk_cycle *= 1.5;
            _inst.is_slowdown = true;
        }
    }

    // 中指的义理（鼠军侧）：本关已经死过老鼠，新出场的这只也吃同一份累计生命加成
    // （在场的那批已经在阵亡那一刻直接加过，这里只补给后来者，不会重复叠加）
    if (variable_struct_exists(_s, "b3_finger_hp_add") && _s.b3_finger_hp_add > 0
        && variable_instance_exists(_inst, "maxhp")) {
        var _old_max = max(1, _inst.maxhp);
        _inst.maxhp = round(_inst.maxhp * (1 + _s.b3_finger_hp_add));
        _inst.hp    = min(_inst.maxhp, _inst.hp * (_inst.maxhp / _old_max));
    }

    // 小指的聚散（鼠军侧）：同种鼠军每只 +5% 生命（上限 50%）
    if (variable_struct_exists(_s, "b3_kind_hp_add") && _s.b3_kind_hp_add > 0) {
        var _same = 0;
        with (obj_enemy_parent) {
            if (self.id != _inst.id && self.mouse_id == _inst.mouse_id) _same += 1;
        }
        if (_same > 0) {
            var _mult = 1 + min(0.5, _s.b3_kind_hp_add * _same);
            _inst.maxhp = max(1, round(_inst.maxhp * _mult));
            _inst.hp    = min(_inst.hp * _mult, _inst.maxhp);
        }
    }

    // 释放忍术：忍者鼠进场时前移 4 格并召唤一只同类
    if (_s.b3_ninja && variable_instance_exists(_inst, "mouse_id")) {
        if (string_pos("ninja", string(_inst.mouse_id)) > 0) {
            if (variable_instance_exists(_inst, "x") && variable_global_exists("grid_cell_size_x")) {
                _inst.x = max(global.grid_offset_x, _inst.x - 4 * global.grid_cell_size_x);
            }
            var _sum = instance_create_depth(_inst.x + irandom_range(-20, 20), _inst.y,
                                             _inst.depth, _inst.object_index);
            if (instance_exists(_sum)) {
                hex_enemy_scale(_sum);
                _sum.can_dropped = false;
            }
        }
    }

    // Hana 的四卦（鼠军侧第三项）：前三只出场时复制自身
    if (_s.b3_clone_left > 0) {
        _s.b3_clone_left -= 1;
        var _cl = instance_create_depth(_inst.x + 40, _inst.y, _inst.depth, _inst.object_index);
        if (instance_exists(_cl)) {
            hex_enemy_scale(_cl);
            _cl.can_dropped = false;
        }
    }
}

/// @function hex_b3_enemy_damage_pre(_inst, _dmg)
/// @desc 老鼠受伤前置（在 hex_batch2_enemy_damage_take 之后调用）：
///       固定减伤 / ±X 抖动 / 首次伤害倍率 / 对 BOSS / 对跨服鼠军 / 决斗递增 / 受伤累加
function hex_b3_enemy_damage_pre(_inst, _dmg, _src = noone) {
    if (!hex_enabled()) return _dmg;
    if (!instance_exists(_inst)) return _dmg;
    if (!variable_hex_b3_state()) return _dmg;
    var _s = global.hex_state;
    var _d = _dmg;
    var _is_boss = false;
    if (variable_instance_exists(_inst, "is_boss")) _is_boss = _inst.is_boss;

    // 冻实的冰块：减速类子弹伤害 +100%
    if (_s.b3_slow_bullet > 0 && instance_exists(_src)) {
        if (variable_instance_exists(_src, "is_slowdown") && _src.is_slowdown) {
            _d *= (1 + _s.b3_slow_bullet);
        }
    }

    // 当头棒喝（美食侧）：该卡的第一发子弹伤害 ×10
    if (_s.b3_first_shot && instance_exists(_src)) {
        if (variable_instance_exists(_src, "hex_src_inst") && instance_exists(_src.hex_src_inst)) {
            var _card = _src.hex_src_inst;
            if (!variable_instance_exists(_card, "b3_shot_done")) _card.b3_shot_done = false;
            if (!_card.b3_shot_done) {
                _card.b3_shot_done = true;
                _d *= 10;
            }
        }
    }

    // 生死界限：每发子弹 ±45
    if (_s.b3_dmg_jitter > 0) {
        _d = max(1, _d + irandom_range(-_s.b3_dmg_jitter, _s.b3_dmg_jitter));
    }

    // 您的盾牌：老鼠固定减伤
    if (_s.b3_e_flat_dr > 0) _d = max(1, _d - _s.b3_e_flat_dr);

    // 食指的指令·鼠军侧：标记鼠在场 → 其他鼠军受到的伤害 -23%（等效全属性 +30%）；
    // 标记鼠刚死 → 30 秒内鼠军受到的伤害 ×2（等效生命 -50%）
    if (_s.b3_mark_on) {
        if (_s.b3_mark_penalty_ms > 0 && current_time < _s.b3_mark_penalty_ms) {
            _d *= 2.0;
        } else if (_s.b3_mark_enemy != noone && instance_exists(_s.b3_mark_enemy)
                   && _s.b3_mark_enemy != _inst) {
            _d *= 0.77;
        }
    }

    // 演出的高潮：每只老鼠自己的 -10~+10
    if (variable_instance_exists(_inst, "b3_dr_roll") && _inst.b3_dr_roll != 0) {
        _d = max(1, _d + _inst.b3_dr_roll * -1);
    }

    // 当头棒喝：老鼠受到的第一次伤害 ×N
    if (_s.b3_first_hit_mult > 1) {
        if (!variable_instance_exists(_inst, "b3_first_hit_done")) _inst.b3_first_hit_done = false;
        if (!_inst.b3_first_hit_done) {
            _inst.b3_first_hit_done = true;
            _d *= _s.b3_first_hit_mult;
        }
    }

    // 残响的终曲 / 呼朋唤友：对 BOSS 伤害
    if (_s.b3_boss_dmg > 0 && _is_boss) _d *= (1 + _s.b3_boss_dmg);

    // 病毒系列：对跨服鼠军伤害
    if (_s.b3_infected_dmg > 0 && variable_instance_exists(_inst, "mouse_id")) {
        if (string_pos("infected_", string(_inst.mouse_id)) == 1) _d *= (1 + _s.b3_infected_dmg);
    }

    // 情报收集：情报岛查看过的鼠军受伤 +20%，没看过的 -20%
    if (_s.b3_info && variable_instance_exists(_inst, "mouse_id")) {
        _d *= hex_b3_info_mult(string(_inst.mouse_id));
    }

    // 决斗：对同一目标连续命中递增（每次 +X，封顶 25%）
    if (_s.b3_duel_step > 0) {
        if (!variable_instance_exists(_inst, "b3_duel_n")) _inst.b3_duel_n = 0;
        _inst.b3_duel_n += 1;
        _d *= (1 + min(0.25, _s.b3_duel_step * _inst.b3_duel_n));
    }

    // 齿轮的烟气（鼠军侧）：每受一次伤，后续受伤 +2.5%
    if (_s.b3_enemy_taken_add > 0) {
        if (!variable_instance_exists(_inst, "b3_taken_n")) _inst.b3_taken_n = 0;
        var _bonus = min(_s.b3_enemy_taken_cap, _s.b3_enemy_taken_add * _inst.b3_taken_n);
        _d *= (1 + _bonus);
    }

    // 悬丝的傀儡：BOSS 把最多 500 点伤害转移给场上随机鼠军
    if (_s.b3_boss_transfer > 0 && _is_boss) {
        var _transfer = min(_s.b3_boss_transfer, _d * 0.5);
        var _n = instance_number(obj_enemy_parent);
        if (_n > 1) {
            var _t = noone;
            for (var i = 0; i < 6; i++) {
                var _cand = instance_find(obj_enemy_parent, irandom(_n - 1));
                if (instance_exists(_cand) && _cand.id != _inst.id && _cand.hp > 0) { _t = _cand; break; }
            }
            if (_t != noone) {
                _t.hp -= _transfer;
                _d -= _transfer;
            }
        }
    }

    // 守护他人的决意：致死伤害时保命（5 秒内 hp 不低于 1）
    if (_s.b3_lethal_guard_ms > 0 && variable_instance_exists(_inst, "hp")) {
        if (!variable_instance_exists(_inst, "b3_guard_until")) _inst.b3_guard_until = 0;
        if (_inst.b3_guard_until > 0 && current_time < _inst.b3_guard_until) {
            if (_inst.hp - _d <= 0) _d = max(0, _inst.hp - 1);
        } else if (_inst.hp - _d <= 0) {
            _inst.b3_guard_until = current_time + _s.b3_lethal_guard_ms;
            _d = max(0, _inst.hp - 1);
        }
    }

    return max(0, _d);
}

/// @function hex_b3_enemy_damage_post(_inst, _dmg)
/// @desc 老鼠受伤后置：计受伤层数 / 血魔的渴血（美食吸血）/ 起源（致命一击来源）
function hex_b3_enemy_damage_post(_inst, _dmg, _src = noone) {
    if (!hex_enabled()) return;
    if (!instance_exists(_inst)) return;
    if (!variable_hex_b3_state()) return;
    var _s = global.hex_state;

    // 齿轮的烟气：本次受过伤，层数 +1
    if (_s.b3_enemy_taken_add > 0) {
        if (!variable_instance_exists(_inst, "b3_taken_n")) _inst.b3_taken_n = 0;
        _inst.b3_taken_n += 1;
    }

    // 血魔的渴血：造成伤害的美食按伤害量回血，满血转上限
    if (_s.b3_lifesteal && _dmg > 0) {
        var _card = noone;
        if (instance_exists(_src)) {
            if (variable_instance_exists(_src, "hex_src_inst")) _card = _src.hex_src_inst;
            if (!instance_exists(_card) && _src.object_index == obj_card_parent) _card = _src;
        }
        // 归属兜底：伤害不是 obj_bullet_parent 打的（灰烬 / 火焰 / 近战 / 词条伤害），
        // 或者子弹没认领到来源时，退化成「离这只老鼠最近的攻击态卡片」。
        // 没有这一步，渴血在实机上几乎永远找不到施法者。
        if (!instance_exists(_card) && instance_exists(_inst)) {
            var _best_d = 999999;
            with (obj_card_parent) {
                if (self.plant_id != "player") {
                    var _dd = point_distance(_inst.x, _inst.y, self.x, self.y);
                    if (self.state == CARD_STATE.ATTACK) _dd *= 0.5;   // 优先正在开火的
                    if (_dd < _best_d && _dd < 420) { _best_d = _dd; _card = self.id; }
                }
            }
        }
        if (instance_exists(_card) && variable_instance_exists(_card, "plant_id")
            && _card.plant_id != "player") {
            var _missing = _card.max_hp - _card.hp;
            if (_missing > 0.5) {
                // 没满血：先补血，补满后剩余部分转上限
                var _heal = min(_missing, _dmg);
                _card.hp = min(_card.max_hp, _card.hp + _heal);
                _dmg = max(0, _dmg - _heal);
            }
            if (_dmg > 0) {
                if (!variable_instance_exists(_card, "b3_hp_gain")) _card.b3_hp_gain = 0;
                var _cap  = _s.b3_lifesteal_cap - 1;
                var _base = variable_instance_exists(_card, "base_max_hp")
                            ? max(1, _card.base_max_hp) : max(1, _card.max_hp);
                if (_card.b3_hp_gain < _cap) {
                    // 按「这一下打掉的血 / 基础血」换算，至少给 1%，否则小伤害永远看不出变化
                    _card.b3_hp_gain = min(_cap, _card.b3_hp_gain + max(0.01, _dmg / _base));
                    if (variable_global_exists("buff_apply_id")) global.buff_apply_id += 1;
                }
            }
        }
    }

    // 起源：记录「被子弹击杀」这一种死亡方式（真正判定在 Destroy 里）
    if (_s.b3_death_cause_atk > 0 && variable_instance_exists(_inst, "hp") && _inst.hp <= 0) {
        _inst.b3_died_by_bullet = true;
    }
}

// ══════════════════════ 卡片侧钩子 ══════════════════════

/// @function hex_b3_card_damage(_card, _enemy, _dmg)
/// @desc 卡片受击前的统一处理：减伤 / 固定减伤 / 受伤累加 / 生存下去的勇气
function hex_b3_card_damage(_card, _enemy, _dmg) {
    if (!hex_enabled()) return _dmg;
    if (!instance_exists(_card)) return _dmg;
    if (!variable_hex_b3_state()) return _dmg;
    var _s = global.hex_state;
    var _d = _dmg;
    var _pid = "";
    if (variable_instance_exists(_card, "plant_id")) _pid = _card.plant_id;
    if (_pid == "player") {
        // 悬丝的傀儡：人物有独立的无敌规则，不吃卡片侧的减伤
        return _d;
    }

    // 鲨鱼的厚皮：受到伤害 -20%
    if (_s.b3_card_dr > 0) _d *= max(0.1, 1 - _s.b3_card_dr);
    // 您的盾牌：固定减伤 25
    if (_s.b3_card_flat_dr > 0) _d = max(1, _d - _s.b3_card_flat_dr);

    // 齿轮的烟气（美食侧）：每受一次伤，后续受伤 +2%
    if (_s.b3_card_taken_add > 0) {
        if (!variable_instance_exists(_card, "b3_taken_n")) _card.b3_taken_n = 0;
        _d *= (1 + min(_s.b3_card_taken_cap, _s.b3_card_taken_add * _card.b3_taken_n));
    }

    // 生存下去的勇气：受伤同时扣最大生命（下限为基础生命的 10%）
    if (_s.b3_hp_on_hit && variable_instance_exists(_card, "max_hp")) {
        if (!variable_instance_exists(_card, "b3_hp_loss")) _card.b3_hp_loss = 0;
        var _base = _card.max_hp;
        if (variable_instance_exists(_card, "base_max_hp")) _base = _card.base_max_hp;
        var _room = max(0, _base * 0.9 - _card.b3_hp_loss);
        _card.b3_hp_loss += min(_room, _d);
        if (variable_global_exists("buff_apply_id")) global.buff_apply_id += 1;
    }

    // 血魔的渴血（鼠军侧）：老鼠啃咬美食时按伤害回血（BOSS 不回）
    if (_s.b3_lifesteal && instance_exists(_enemy)) {
        var _boss = false;
        if (variable_instance_exists(_enemy, "is_boss")) _boss = _enemy.is_boss;
        if (!_boss) _enemy.hp = min(_enemy.maxhp, _enemy.hp + _d);
    }

    return _d;
}

/// @function hex_b3_card_hit_after(_card, _enemy, _dmg)
/// @desc 卡片受伤后置：记一次受伤 / 记住最后一个攻击者（鲨鱼的厚皮用）
function hex_b3_card_hit_after(_card, _enemy, _dmg) {
    if (!hex_enabled()) return;
    if (!instance_exists(_card)) return;
    if (!variable_hex_b3_state()) return;
    var _s = global.hex_state;
    if (_s.b3_card_taken_add > 0) {
        if (!variable_instance_exists(_card, "b3_taken_n")) _card.b3_taken_n = 0;
        _card.b3_taken_n += 1;
    }
    if (instance_exists(_enemy)) _card.b3_last_enemy = _enemy;
}

/// @function hex_b3_card_lethal(_card)
/// @desc 卡片（含人物）致死拦截。在 obj_card_parent/Other_12 顶部调用，
///       返回 true 表示已经拦下（hp 被拉回），调用方不用再处理。
function hex_b3_card_lethal(_card) {
    if (!hex_enabled()) return false;
    if (!instance_exists(_card)) return false;
    if (!variable_hex_b3_state()) return false;
    if (!variable_instance_exists(_card, "hp")) return false;
    if (_card.hp > 0) return false;
    var _s = global.hex_state;
    var _pid = "";
    if (variable_instance_exists(_card, "plant_id")) _pid = _card.plant_id;

    // 悬丝的傀儡：人物致死免疫 + 30 秒无敌（每次进关卡一次）
    if (_pid == "player" && _s.b3_player_invuln) {
        if (!variable_instance_exists(_card, "b3_invuln_used")) _card.b3_invuln_used = false;
        if (!_card.b3_invuln_used) {
            _card.b3_invuln_used = true;
            _card.hp = max(1, _card.max_hp);
            _card.invincible = true;
            _card.b3_inv_until = current_time + 30000;
            return true;
        }
        return false;
    }

    // 孤狼的高傲：卡片的第一次致死被免疫并回满
    if (_pid != "" && _pid != "player" && _s.b3_last_stand) {
        if (!variable_instance_exists(_card, "b3_stand_used")) _card.b3_stand_used = false;
        if (!_card.b3_stand_used) {
            _card.b3_stand_used = true;
            _card.hp = _card.max_hp;
            return true;
        }
    }
    return false;
}

/// @function hex_b3_card_destroyed(_card)
/// @desc 卡片阵亡：以我残躯化烈火（该格火焰）/ 中指的义理（全队叠层）/ 鲨鱼的厚皮（击杀者回血）
function hex_b3_card_destroyed(_card) {
    if (!hex_enabled()) return;
    if (!instance_exists(_card)) return;
    if (!variable_hex_b3_state()) return;
    var _s = global.hex_state;
    var _pid = "";
    if (variable_instance_exists(_card, "plant_id")) _pid = _card.plant_id;
    if (_pid == "player" || _pid == "") return;

    // 以我残躯化烈火：该格生成 10 秒火焰
    if (_s.b3_death_fire > 0) {
        var _col = variable_instance_exists(_card, "grid_col") ? _card.grid_col : -1;
        var _row = variable_instance_exists(_card, "grid_row") ? _card.grid_row : -1;
        if (_col >= 0 && _row >= 0) hex_b3_spawn_fire(_col, _row, _s.b3_death_fire, 600);
    }

    // 中指的义理：其余在场美食叠一层
    if (_s.b3_finger_atk > 0 && _s.b3_finger_stacks < _s.b3_finger_cap) {
        _s.b3_finger_stacks += 1;
        if (variable_global_exists("buff_apply_id")) global.buff_apply_id += 1;
    }

    // 鲨鱼的厚皮：凶手回 20% 上限
    if (_s.b3_card_dr > 0 && variable_instance_exists(_card, "b3_last_enemy")) {
        var _e = _card.b3_last_enemy;
        if (instance_exists(_e) && variable_instance_exists(_e, "maxhp")) {
            var _boss = false;
            if (variable_instance_exists(_e, "is_boss")) _boss = _e.is_boss;
            if (!_boss) _e.hp = min(_e.maxhp, _e.hp + _e.maxhp * 0.2);
        }
    }
}

/// @function hex_b3_spawn_fire(_col, _row, _dmg, _frames)
/// @desc 生成一格玩家侧的火焰（后羿神火，“只烧老鼠不烧自己人”）
function hex_b3_spawn_fire(_col, _row, _dmg, _frames) {
    if (!variable_global_exists("grid_offset_x")) return noone;
    if (_col < 0 || _row < 0) return noone;
    if (_col >= global.grid_cols || _row >= global.grid_rows) return noone;
    var _wp = get_world_position_from_grid(_col, _row);
    var _f = instance_create_depth(_wp.x, _wp.y, -1200, obj_houyi_god_fire);
    if (!instance_exists(_f)) return noone;
    _f.damage   = max(1, round(_dmg));
    _f.grid_col = _col;
    _f.grid_row = _row;
    _f.hex_life = max(30, round(_frames));
    return _f;
}

// ══════════════════════ 老鼠死亡 ══════════════════════

/// @function hex_b3_on_enemy_death(_inst)
/// @desc 鼠军死亡：中指的义理（同类加血）/ 重燃的火光（复制）/ 鼠鼠爱财宝（掉金币）/
///       起源（死亡方式）/ 以我残躯化烈火（熔岩）
function hex_b3_on_enemy_death(_inst) {
    if (!hex_enabled()) return;
    if (!instance_exists(_inst)) return;
    if (!variable_hex_b3_state()) return;
    var _s = global.hex_state;

    var _is_boss = false;
    if (variable_instance_exists(_inst, "is_boss")) _is_boss = _inst.is_boss;

    // 中指的义理：其余在场鼠军生命 +2%（后巷的统治者会让五指组鼠军侧减半）
    if (_s.b3_finger_hp > 0) {
        var _fh = _s.b3_finger_hp * ((hex_b3_fr() > 1.0) ? 0.5 : 1.0);
        // 累计量：之后才出场的鼠军靠它补上同一份加成（在 hex_b3_enemy_spawn 里读）
        _s.b3_finger_hp_add += _fh;
        with (obj_enemy_parent) {
            var _is_b = variable_instance_exists(self.id, "is_boss") ? self.is_boss : false;
            if (self.id != _inst.id && !_is_b && self.maxhp > 0) {
                var _old_max = self.maxhp;
                self.maxhp = round(self.maxhp * (1 + _fh));
                // 先按比例涨血再夹逼，否则拿新上限当分母会把血按比例削掉
                self.hp = min(self.maxhp, self.hp * (self.maxhp / _old_max));
            }
        }
    }

    // 起源：四种死亡方式各触发一次 → 全队攻击 +X
    if (_s.b3_death_cause_atk > 0) {
        var _bit = 0;
        if (variable_instance_exists(_inst, "is_blown_away") && _inst.is_blown_away) _bit = 1;
        else if (variable_instance_exists(_inst, "ash_death") && _inst.ash_death) _bit = 2;
        else if (variable_instance_exists(_inst, "crush_kill") && _inst.crush_kill) _bit = 4;
        else _bit = 8;
        if ((_s.b3_cause_mask & _bit) == 0) {
            _s.b3_cause_mask |= _bit;
            if (variable_global_exists("buff_apply_id")) global.buff_apply_id += 1;
        }
    }

    // 鼠鼠爱财宝：掉落金币
    if (_s.b3_coin > 0 && variable_instance_exists(_inst, "x")) {
        var _v = _s.b3_coin;
        if (_s.b3_coin_rare > 0 && random(1) < _s.b3_coin_p) _v = _s.b3_coin_rare;
        var _c = instance_create_depth(_inst.x, _inst.y - 50, _inst.depth - 200, obj_coin);
        if (instance_exists(_c)) _c.value = _v;
    }

    // 以我残躯化烈火：该格熔岩
    if (_s.b3_e_death_lava > 0 && !_is_boss) {
        if (variable_instance_exists(_inst, "grid_col") && _inst.grid_col >= 0
            && _inst.grid_row >= 0) {
            var _fx = instance_create_depth(_inst.x, _inst.y, -1300, obj_vajra_lava_effect);
            if (instance_exists(_fx)) {
                _fx.target_col = _inst.grid_col;
                _fx.target_row = _inst.grid_row;
                _fx.hex_life   = round(_s.b3_e_death_lava * 60);
            }
        }
    }

    // 重燃的火光：5% 复制一只（每秒衰减 5% 生命）
    if (_s.b3_clone_p > 0 && !_is_boss) {
        if (random(1) < _s.b3_clone_p) {
            var _cl = instance_create_depth(_inst.x, _inst.y, _inst.depth, _inst.object_index);
            if (instance_exists(_cl)) {
                hex_enemy_scale(_cl);
                _cl.b3_decay_until = 0;
                _cl.b3_decay_pct   = 0.05;
                _cl.can_dropped    = false;
            }
        }
    }
}

// ══════════════════════ BOSS 入场 ══════════════════════

/// @function hex_b3_on_boss_enter(_boss)
/// @desc 呼朋唤友：BOSS 入场时再叫一只同类（半血），本局一次
function hex_b3_on_boss_enter(_boss) {
    if (!hex_enabled()) return;
    if (!variable_hex_b3_state()) return;
    var _s = global.hex_state;
    if (!_s.b3_boss_extra || _s.b3_boss_extra_done) return;
    if (!instance_exists(_boss)) return;
    _s.b3_boss_extra_done = true;
    var _dup = instance_create_depth(_boss.x + 60, _boss.y, _boss.depth, _boss.object_index);
    if (instance_exists(_dup)) {
        _dup.maxhp = max(1, round(_boss.maxhp * 0.5));
        _dup.hp    = _dup.maxhp;
        _dup.is_boss = true;
    }
}

// ══════════════════════ 子弹来源（近似归属） ══════════════════════

/// @function hex_b3_bullet_tag(_bullet)
/// @desc 子弹出生第一帧：按出生位置就近认领一张卡片作为来源。
///       子弹都是「卡片所在格向外发射」，所以用 1 格半径 + 优先攻击态判定，
///       拿到的是近似归属，足够「血魔的渴血 / 当头棒喝 / 重燃的火光」这类叙事用。
function hex_b3_bullet_tag(_bullet) {
    if (!hex_enabled()) return;
    if (!instance_exists(_bullet)) return;
    if (variable_instance_exists(_bullet, "hex_src_inst")) return;
    _bullet.hex_src_inst = noone;
    _bullet.hex_src_id   = "";
    var _best = noone;
    var _best_d = 999999;
    var _fallback = noone;
    var _fallback_d = 999999;
    with (obj_card_parent) {
        if (self.plant_id != "player") {
            var _d = point_distance(_bullet.x, _bullet.y, self.x, self.y);
            // 兜底：全场最近的卡（不管多远），保证「血魔的渴血 / 当头棒喝」总有归属
            if (_d < _fallback_d) { _fallback_d = _d; _fallback = self.id; }
            if (_d < 130) {
                var _pref = _d;
                if (self.state != CARD_STATE.ATTACK) _pref += 200;   // 优先认领正在攻击的卡
                if (_pref < _best_d) { _best_d = _pref; _best = self.id; }
            }
        }
    }
    if (_best == noone) _best = _fallback;
    if (_best != noone) {
        _bullet.hex_src_inst = _best;
        if (variable_instance_exists(_best, "plant_id")) _bullet.hex_src_id = _best.plant_id;
    }
}

/// @function hex_b3_bullet_hit(_bullet, _enemy)
/// @desc 子弹命中老鼠：重燃的火光（该格 3 秒火焰）/ 当头棒喝（该卡第一发 ×10）
function hex_b3_bullet_hit(_bullet, _enemy) {
    if (!hex_enabled()) return;
    if (!variable_hex_b3_state()) return;
    if (!instance_exists(_enemy)) return;
    var _s = global.hex_state;

    // 重燃的火光：命中格生成 3 秒火焰，伤害取该卡攻击
    if (_s.b3_bullet_fire > 0 && instance_exists(_bullet)) {
        if (!variable_instance_exists(_bullet, "b3_fire_done")) _bullet.b3_fire_done = false;
        if (!_bullet.b3_fire_done) {
            _bullet.b3_fire_done = true;
            var _col = variable_instance_exists(_enemy, "grid_col") ? _enemy.grid_col : -1;
            var _row = variable_instance_exists(_enemy, "grid_row") ? _enemy.grid_row : -1;
            var _dmg = 10;
            if (variable_instance_exists(_bullet, "hex_src_inst") && instance_exists(_bullet.hex_src_inst)) {
                if (variable_instance_exists(_bullet.hex_src_inst, "atk")) _dmg = _bullet.hex_src_inst.atk;
            } else if (variable_instance_exists(_bullet, "damage")) {
                _dmg = _bullet.damage;
            }
            if (_col >= 0 && _row >= 0) hex_b3_spawn_fire(_col, _row, _dmg, 180);
        }
    }
}

// ══════════════════════ 波次 / 局内开局 ══════════════════════

/// @function hex_b3_on_battle_init()
/// @desc 进战斗时的一次性结算：类别打乱 / 四卦 / 随机全属性 / 契约 / 卡组统计 / Hana
function hex_b3_on_battle_init() {
    if (!hex_enabled()) return;
    if (!variable_hex_b3_state()) return;
    var _s = global.hex_state;

    hex_b3_scroll_thumbs();
    hex_b3_count_deck_kinds();
    hex_b3_sea_judge();
    hex_b3_shuffle_categories();
    hex_b3_roll_contract();
    hex_b3_continue_mark();
    _s.b3_mark_enemy_ms = current_time;

    // Hana 的四卦：一局只弹一次（选完置 used，之后不再弹）
    if (_s.b3_hana && !variable_struct_exists(_s, "b3_hana_used")) _s.b3_hana_used = false;
    if (_s.b3_hana && !_s.b3_hana_used && !_s.b3_hana_done) {
        _s.b3_hana_pending = true;
        // 四卦的代价：鼠军侧开局随机一项（攻击 +20% / 生命 +30% / 前三只出场复制自身）
        hex_b3_hana_enemy_roll();
    }

    // 中指的义理 / 起源 等实时计数在 tick 里维护，这里先算一次
    hex_b3_refresh_counts();
}

/// @function hex_b3_refresh_counts()
/// @desc 维护「场上美食大分类种数」（顶点的合奏用）
function hex_b3_refresh_counts() {
    if (!variable_global_exists("hex_state") || !is_struct(global.hex_state)) return;
    if (!hex_b3_ensure()) return;
    var _s = global.hex_state;
    var _seen = {};
    var _n = 0;
    with (obj_card_parent) {
        if (self.plant_id != "player") {
            var _cat = card_get_category(self.plant_id);
            if (!is_undefined(_cat)) {
                if (!variable_struct_exists(_seen, _cat.major)) {
                    _seen[$ _cat.major] = true;
                    _n += 1;
                }
            }
        }
    }
    _s.b3_major_kinds = _n;
}

/// @function hex_b3_count_deck_kinds()
/// @desc 环指的艺术：统计卡组里的大分类种数
function hex_b3_count_deck_kinds() {
    var _s = global.hex_state;
    _s.b3_deck_kinds = 0;
    if (!variable_global_exists("selected_deck")) return;
    if (!ds_exists(global.selected_deck, ds_type_list)) return;
    var _seen = {};
    var _len = ds_list_size(global.selected_deck);
    for (var i = 0; i < _len; i++) {
        var _e = global.selected_deck[| i];
        var _cid = hex_b3_deck_card_id(_e);
        if (_cid == "") continue;
        var _cat = card_get_category(_e.card_id);
        if (is_undefined(_cat)) continue;
        if (variable_struct_exists(_seen, _cat.major)) continue;
        _seen[$ _cat.major] = true;
        _s.b3_deck_kinds += 1;
    }
}

/// @function hex_b3_deck_card_id(_e)
/// @desc 从卡组元素里取 card_id。注意：global.selected_deck 存的是 ds_map
///       （用 deck_entry[? "card_id"] 访问），不是 struct —— 之前三处遍历
///       都写成 is_struct(_e) 过滤，结果拇指的阶级 / 环指的艺术 / 海洋的婚礼
///       一条都没生效。这里统一兼容 struct / ds_map / 纯字符串三种写法。
function hex_b3_deck_card_id(_e) {
    if (is_struct(_e)) {
        if (variable_struct_exists(_e, "card_id")) return string(_e.card_id);
        return "";
    }
    if (is_string(_e)) return _e;
    if (is_real(_e)) {
        if (ds_map_exists(_e, "card_id")) {
            var _v = _e[? "card_id"];
            if (is_string(_v)) return _v;
        }
    }
    return "";
}

/// @function hex_b3_scroll_thumbs()
/// @desc 拇指的阶级：扫卡组，取「金卡 > 融合卡 > 二转 > 一转」里最高的那一档，
///       整局给全队全属性加成（金 100% / 融合 50% / 二转 20% / 一转 10%）
function hex_b3_scroll_thumbs() {
    var _s = global.hex_state;
    var _best = 0;
    if (!variable_global_exists("selected_deck")) return;
    if (!ds_exists(global.selected_deck, ds_type_list)) return;
    var _len = ds_list_size(global.selected_deck);
    for (var i = 0; i < _len; i++) {
        var _e = global.selected_deck[| i];
        var _cid = hex_b3_deck_card_id(_e);
        if (_cid == "") continue;
        // 金卡
        if (gacha_is_gold_card(_cid)) _best = max(_best, 1.0);
        // 融合卡
        if (string_pos("ronghe", _cid) == 1) _best = max(_best, 0.5);
        // 转职形态
        var _sh = 0;
        var _info = get_card_info_simple(_cid);
        if (_info != false && variable_struct_exists(_info, "shape")) _sh = _info.shape;
        if (_sh >= 2) _best = max(_best, 0.2);
        else if (_sh == 1) _best = max(_best, 0.1);
    }
    _s.b3_thumb_atk = _best;
}

/// @function hex_b3_sea_judge()
/// @desc 海洋的婚礼：卡组同时有海神与海洋女神时，给这两张 + 四张海底卡打标
function hex_b3_sea_judge() {
    var _s = global.hex_state;
    _s.b3_sea_ok = false;
    // 没有「海洋的婚礼」这条词条就什么都别做
    if (!variable_struct_exists(_s, "b3_sea") || !_s.b3_sea) return;
    if (!variable_global_exists("selected_deck")) return;
    if (!ds_exists(global.selected_deck, ds_type_list)) return;
    var _has_p = false;
    var _has_h = false;
    var _len = ds_list_size(global.selected_deck);
    for (var i = 0; i < _len; i++) {
        var _e = global.selected_deck[| i];
        var _cid = hex_b3_deck_card_id(_e);
        if (_cid == "") continue;
        if (_cid == "poseidon")    _has_p = true;
        if (_cid == "haiyang_god") _has_h = true;
    }
    if (!_has_p || !_has_h) return;
    _s.b3_sea_ok = true;
    _s.b3_enemy_drain_sec = max(_s.b3_enemy_drain_sec, 1);
    with (obj_card_parent) {
        if (self.plant_id == "poseidon" || self.plant_id == "haiyang_god"
            || self.plant_id == "coal_starfish" || self.plant_id == "curry_lobster_cannon"
            || self.plant_id == "horseshoe_crab_bread" || self.plant_id == "nut_frier") {
            self.b3_sea_double = true;
        }
    }
    if (variable_global_exists("buff_apply_id")) global.buff_apply_id += 1;
}

/// @function hex_b3_sea_card(_plant_id)
/// @desc 海底卡：新放置的卡也要打上「海洋的婚礼」双倍标记。
///       只有词条生效且海神+海洋女神同时在卡组时（b3_sea_ok）才返回 true，
///       否则一张普通海底卡也会被翻倍。
function hex_b3_sea_card(_plant_id) {
    if (!hex_enabled()) return false;
    if (!variable_hex_b3_state()) return false;
    if (!variable_struct_exists(global.hex_state, "b3_sea_ok")) return false;
    if (!global.hex_state.b3_sea_ok) return false;
    if (_plant_id == "poseidon" || _plant_id == "haiyang_god"
        || _plant_id == "coal_starfish" || _plant_id == "curry_lobster_cannon"
        || _plant_id == "horseshoe_crab_bread" || _plant_id == "nut_frier") return true;
    return false;
}

/// @function hex_b3_shuffle_categories()
/// @desc 昂首阔步的信念：把攻击类卡的所属大分类随机重排（羁绊跟着乱）
function hex_b3_shuffle_categories() {
    if (!hex_enabled()) return;
    if (!variable_hex_b3_state()) return;
    var _s = global.hex_state;
    if (!variable_struct_exists(_s, "b3_shuffle") || !_s.b3_shuffle) return;
    if (variable_global_exists("hex_b3_shuffled") && global.hex_b3_shuffled) return;
    global.hex_b3_shuffled = true;
    if (!variable_global_exists("card_category_map")) return;
    if (!ds_exists(global.card_category_map, ds_type_map)) return;

    var _majors = ["直射类", "追踪类", "投掷类", "喷壶类", "多向类", "专业防空类"];
    var _keys = ds_map_keys_to_array(global.card_category_map);
    for (var i = 0; i < array_length(_keys); i++) {
        var _k = _keys[i];
        var _cat = ds_map_find_value(global.card_category_map, _k);
        if (!is_struct(_cat)) continue;
        if (array_index_of(_majors, _cat.major) == -1) continue;
        _cat.major = _majors[irandom(array_length(_majors) - 1)];
        ds_map_set(global.card_category_map, _k, _cat);
    }
}

/// @function hex_b3_roll_contract()
/// @desc 不公的契约：开局弹五选一（玩家自己挑），面板没弹出来就退化成随机
function hex_b3_roll_contract() {
    var _s = global.hex_state;
    if (_s.b3_contract != "") return;
    if (!variable_struct_exists(_s, "b3_contract_on") || !_s.b3_contract_on) return;
    _s.b3_contract_pending = true;
    _s.b3_contract_pending_ms = current_time;
}

/// @function hex_b3_contract_offer()
/// @desc 五张契约牌面
function hex_b3_contract_offer() {
    return ["hex_contract_1", "hex_contract_2", "hex_contract_3",
            "hex_contract_4", "hex_contract_5"];
}

/// @function hex_b3_contract_fallback()
/// @desc 保底：面板被弃权 / 一直没选，就随机签一种，避免词条整个空转
function hex_b3_contract_fallback() {
    if (!hex_enabled()) return;
    if (!variable_hex_b3_state()) return;
    var _s = global.hex_state;
    if (!_s.b3_contract_on) return;
    if (_s.b3_contract != "") return;

    var _panel_open = variable_global_exists("hex_pick_open") && global.hex_pick_open;
    var _need = false;
    // ① 面板已经弹过、现在也关掉了，却还是没签
    if (_s.b3_contract_show && !_panel_open) _need = true;
    // ② 面板压根没弹出来（30 秒兜底）
    if (_s.b3_contract_pending && current_time - _s.b3_contract_pending_ms > 30000) _need = true;
    if (!_need) return;

    _s.b3_contract_pending = false;
    _s.b3_contract_show    = false;
    var _all = ["light", "power", "free", "speed", "buff"];
    _s.b3_contract = _all[irandom(array_length(_all) - 1)];
    _s.b3_contract_ms = current_time;
    if (variable_global_exists("buff_apply_id")) global.buff_apply_id += 1;
}

/// @function hex_b3_contract_on(_name)
/// @desc 当前契约是不是 _name 且没被「残响乐团」抹掉
function hex_b3_contract_on(_name) {
    if (!hex_enabled()) return false;
    if (!variable_hex_b3_state()) return false;
    var _s = global.hex_state;
    if (_s.b3_contract != _name) return false;
    return !_s.b3_contract_off;
}

/// @function hex_b3_contract_atk_mult()
/// @desc 力量契约：攻击 +100%
function hex_b3_contract_atk_mult() {
    return hex_b3_contract_on("power") ? 2.0 : 1.0;
}

/// @function hex_b3_contract_cycle_mult()
/// @desc 神速契约：攻速 +100%（间隔减半）
function hex_b3_contract_cycle_mult() {
    return hex_b3_contract_on("speed") ? 0.5 : 1.0;
}

/// @function hex_b3_contract_buff_mult()
/// @desc 增幅契约：增幅效果 +100%（十字范围那一半没做，见文档 4.9）
function hex_b3_contract_buff_mult() {
    return hex_b3_contract_on("buff") ? 2.0 : 1.0;
}

/// @function hex_b3_contract_flame_flat()
/// @desc 光明契约：每个火苗价值 +50（溢出惩罚在 obj_flame 里结算）
function hex_b3_contract_flame_flat() {
    return hex_b3_contract_on("light") ? 50 : 0;
}

/// @function hex_b3_continue_mark()
/// @desc 食指的指令：从「当前可种植的卡槽」里挑一张打标记。
///       标记的是卡槽里的卡（玩家下一张能种的那个），不是场上已经种下的。
function hex_b3_continue_mark() {
    if (!hex_enabled()) return;
    if (!variable_hex_b3_state()) return;
    var _s = global.hex_state;
    if (!variable_struct_exists(_s, "b3_mark_on") || !_s.b3_mark_on) return;

    // 收集卡槽里真实的 card_id。优先只取「现在就能种」的（冷却已好），
    // 一张都没好再退回全部卡槽 —— 否则玩家会看着一张灰着的卡被标记，种不了。
    var _pool  = [];
    var _pool2 = [];
    var _cn = instance_number(obj_card_slot);
    for (var i = 0; i < _cn; i++) {
        var _sl = instance_find(obj_card_slot, i);
        if (!instance_exists(_sl)) continue;
        if (!variable_instance_exists(_sl, "card_id")) continue;
        var _cid = _sl.card_id;
        if (_cid == "" || _cid == "lihe") continue;
        array_push(_pool2, _cid);
        var _rdy = variable_instance_exists(_sl, "is_ready") ? _sl.is_ready : true;
        if (_rdy) array_push(_pool, _cid);
    }
    if (array_length(_pool) == 0) _pool = _pool2;

    // 卡槽空了（还没建出来 / 全用光）就退化成「场上随便一张」
    if (array_length(_pool) == 0) {
        with (obj_card_parent) {
            if (self.plant_id != "player" && self.plant_id != "") array_push(_pool, self.plant_id);
        }
    }
    if (array_length(_pool) == 0) { _s.b3_mark_card = ""; return; }

    var _pick = _pool[irandom(array_length(_pool) - 1)];
    if (_pick == _s.b3_mark_card && array_length(_pool) > 1) {
        // 别连续标记同一张，玩家要能看出「换目标了」
        for (var k = 0; k < 8; k++) {
            var _t = _pool[irandom(array_length(_pool) - 1)];
            if (_t != _s.b3_mark_card) { _pick = _t; break; }
        }
    }
    _s.b3_mark_card = _pick;
}

/// @function hex_b3_mark_icon(_x, _y, _size)
/// @desc 食指的标记图案：把 spr_hex_mark 画成指定大小，带一圈呼吸光
function hex_b3_mark_icon(_x, _y, _size) {
    if (!hex_enabled()) return;
    if (!variable_hex_b3_state()) return;
    if (!variable_struct_exists(global.hex_state, "b3_mark_on")) return;
    if (!global.hex_state.b3_mark_on) return;
    var _pulse = 1 + 0.08 * sin(current_time / 160);
    var _sz = _size * _pulse;
    draw_set_alpha(0.9);
    draw_sprite_ext(spr_hex_mark, 0, _x, _y, _sz / sprite_get_width(spr_hex_mark),
                    _sz / sprite_get_height(spr_hex_mark), 0, c_white, 1);
    draw_set_alpha(1);
}

/// @function hex_b3_on_place(_card_id)
/// @desc 食指的指令：检查这一次放置的是不是被标记的那张
function hex_b3_on_place(_card_id) {
    if (!hex_enabled()) return;
    if (!variable_hex_b3_state()) return;
    var _s = global.hex_state;
    if (!variable_struct_exists(_s, "b3_mark_on") || !_s.b3_mark_on) return;
    if (_s.b3_mark_card == "") return;
    if (_card_id == _s.b3_mark_card) {
        _s.b3_mark_card_bonus += 0.20;
    } else {
        _s.b3_mark_card_bonus -= 0.10;
    }
    _s.b3_mark_card_bonus = clamp(_s.b3_mark_card_bonus, -0.8, 2.0);
    _s.b3_mark_card = "";
    if (variable_global_exists("buff_apply_id")) global.buff_apply_id += 1;
}

/// @function hex_b3_on_wave_start()
/// @desc 每波开始：生存下去的勇气（恢复上限 / 老鼠回满）/ 值得托付的信任（重随分类）/
///       拥抱过去（重置暂停次数）/ Hana
function hex_b3_on_wave_start() {
    if (!hex_enabled()) return;
    if (!variable_hex_b3_state()) return;
    var _s = global.hex_state;

    // 生存下去的勇气：所有美食的最大生命恢复
    if (_s.b3_hp_on_hit) {
        with (obj_card_parent) {
            if (self.plant_id != "player" && variable_instance_exists(self.id, "b3_hp_loss")) {
                self.b3_hp_loss = 0;
            }
        }
        if (variable_global_exists("buff_apply_id")) global.buff_apply_id += 1;
        // 老鼠回满血
        with (obj_enemy_parent) { self.hp = self.maxhp; }
    }

    // 值得托付的信任：每波重随一个攻击分类
    if (variable_struct_exists(_s, "b3_pick_on") && _s.b3_pick_on) {
        var _cats = ["直射类", "追踪类", "投掷类", "喷壶类"];
        _s.b3_pick_cat = _cats[irandom(array_length(_cats) - 1)];
    }

    // 婚介所：每波清掉上一波的点名
    if (_s.b3_couple_sec > 0) _s.b3_couple_hot = {};

    // 食指的指令：没有标记就补一个
    hex_b3_continue_mark();

    if (variable_global_exists("buff_apply_id")) global.buff_apply_id += 1;
}

/// @function hex_b3_on_pause()
/// @desc 拥抱过去：每暂停一次记一次，回来时随机带走这么多张卡
function hex_b3_on_pause() {
    if (!hex_enabled()) return;
    if (!variable_hex_b3_state()) return;
    var _s = global.hex_state;
    if (!_s.b3_pause_kills) return;
    if (!variable_struct_exists(_s, "b3_pause_n")) _s.b3_pause_n = 0;
    _s.b3_pause_n += 1;
}

/// @function hex_b3_apply_pause_kills()
/// @desc 暂停回来：按暂停次数随机吃掉卡片
function hex_b3_apply_pause_kills() {
    if (!hex_enabled()) return;
    if (!variable_hex_b3_state()) return;
    var _s = global.hex_state;
    if (!_s.b3_pause_kills) return;
    if (!variable_struct_exists(_s, "b3_pause_n")) return;
    var _n = _s.b3_pause_n;
    _s.b3_pause_n = 0;
    for (var i = 0; i < _n; i++) {
        var _cnt = instance_number(obj_card_parent);
        if (_cnt <= 0) return;
        var _c = instance_find(obj_card_parent, irandom(_cnt - 1));
        if (instance_exists(_c) && _c.plant_id != "player") _c.hp = 0;
    }
}

// ══════════════════════ 每帧 ══════════════════════

/// @function hex_b3_tick()
/// @desc 二期周期总入口，由 hex_periodic_run() 每帧调用
function hex_b3_tick() {
    if (!hex_enabled()) return;
    if (!variable_hex_b3_state()) return;
    var _s = global.hex_state;

    // ── 暂停边沿检测：暂停来源有五处（ESC / 空格 / 放置提示 / 结算），
    //    在总入口统一检测，比逐个改暂停点安全 ──
    var _paused_now = variable_global_exists("is_paused") && global.is_paused;
    if (!variable_global_exists("hex_b3_pause_prev")) global.hex_b3_pause_prev = false;
    if (_paused_now && !global.hex_b3_pause_prev) {
        hex_b3_on_pause();
    } else if (!_paused_now && global.hex_b3_pause_prev) {
        hex_b3_apply_pause_kills();
    }
    global.hex_b3_pause_prev = _paused_now;

    // ── 时间 / 速度：暂停时也要处理（否则暂停菜单期间速度锁不生效）──
    if (instance_exists(obj_battle)) {
        if (_s.b3_time_slow) {
            // 「时间」只在「拿起来还没放下」这段窗口里减速：
            // 判据必须是「卡槽真的被选中且还活着」，光看 selected_slot != noone
            // 会在卡槽被销毁后永远为真 —— 那就成了一整局卡在 12 帧。
            var _dragging = false;
            if (variable_global_exists("selected_slot") && global.selected_slot != noone) {
                var _sel = global.selected_slot;
                if (instance_exists(_sel)) {
                    _dragging = variable_instance_exists(_sel, "is_selected") ? _sel.is_selected : true;
                }
            }
            if (_dragging) {
                // 记下进减速之前的真实帧率，放卡后按它还原（不是硬写 60）
                var _now_spd = game_get_speed(gamespeed_fps);
                if (_now_spd != 12) {
                    _s.b3_speed_prev = _now_spd;
                    game_set_speed(12, gamespeed_fps);
                }
            } else if (game_get_speed(gamespeed_fps) == 12) {
                var _restore = (variable_struct_exists(_s, "b3_speed_prev") && _s.b3_speed_prev > 12)
                             ? _s.b3_speed_prev : 60;
                game_set_speed(_restore, gamespeed_fps);
                _s.b3_speed_prev = 0;
            }
        }
        if (_s.b3_speed_lock && !global.is_paused && !_s.b3_time_slow) {
            if (game_get_speed(gamespeed_fps) != 120) game_set_speed(120, gamespeed_fps);
        }
    }

    // 暂停时不推进周期效果
    if (variable_global_exists("is_paused") && global.is_paused) return;

    // ── 每帧：攻击态免疫控制 / 无敌到期 ──
    if (_s.b3_control_immune) {
        with (obj_card_parent) {
            if (self.plant_id != "player") {
                self.frozen_timer = 0;
                self.is_frozen    = false;
                if (self.state == CARD_STATE.SLEEP) {
                    self.state = CARD_STATE.IDLE;
                    self.awake_buff_timer = 0;
                }
            }
        }
    }
    with (obj_card_parent) {
        if (variable_instance_exists(self.id, "b3_inv_until") && self.b3_inv_until > 0) {
            if (current_time >= self.b3_inv_until) {
                self.b3_inv_until = 0;
                self.invincible = false;
            }
        }
        // 知识收集：不在攻击态就蓄力，攻击态就衰减
        if (_s.b3_charge_on) {
            if (!variable_instance_exists(self.id, "b3_charge")) self.b3_charge = 0;
            if (self.state == CARD_STATE.ATTACK) {
                if (self.b3_charge > 0) self.b3_charge -= 0.05;
            } else {
                if (self.b3_charge < 10) self.b3_charge += 0.05;
            }
            self.b3_charge = clamp(self.b3_charge, 0, 10);
        }
        // 派送箱：在场满 N 秒后每秒扣血
        if (_s.b3_decay_sec > 0) {
            if (!variable_instance_exists(self.id, "b3_born")) self.b3_born = current_time;
            if (current_time - self.b3_born >= _s.b3_decay_sec * 1000) {
                if (!variable_instance_exists(self.id, "b3_decay_ms")) self.b3_decay_ms = current_time;
                if (current_time - self.b3_decay_ms >= 1000) {
                    self.b3_decay_ms = current_time;
                    self.hp -= _s.b3_decay_hp;
                }
            }
        }
        // 生存下去的勇气：上限流失同步到血条
        if (_s.b3_hp_on_hit && variable_instance_exists(self.id, "b3_hp_loss")) {
            // 由 obj_mod_battle_manager 的重算统一处理，这里不动
        }
    }

    // ── 小指的聚散：邻接关系一变就逼所有卡重算 ──
    // obj_mod_battle_manager 只在 buff_apply_id 变化时重算 atk/cycle/max_hp，
    // 而「普通卡放置 / 铲除」不会打这个脏标记 —— 不在这里补一刀，
    // 聚散就只有刷新那一刻的数字，玩家永远看不到加成。
    if (_s.b3_adj_on) {
        var _adj_sig = "";
        var _card_n  = instance_number(obj_card_parent);
        for (var _ci = 0; _ci < _card_n; _ci++) {
            var _cc = instance_find(obj_card_parent, _ci);
            if (!instance_exists(_cc)) continue;
            if (!variable_instance_exists(_cc, "plant_id")) continue;
            if (_cc.plant_id == "player") continue;
            if (!variable_instance_exists(_cc, "grid_col")) continue;
            _adj_sig += string(_cc.grid_col) + "." + string(_cc.grid_row) + ":" + string(_cc.plant_id) + "|";
        }
        if (!variable_struct_exists(_s, "b3_adj_sig")) _s.b3_adj_sig = "";
        if (_adj_sig != _s.b3_adj_sig) {
            _s.b3_adj_sig = _adj_sig;
            if (variable_global_exists("buff_apply_id")) global.buff_apply_id += 1;
        }
    }

    // ── 每秒块 ──
    if (current_time - _s.b3_sec_ms >= 1000) {
        _s.b3_sec_ms = current_time;
        hex_b3_second_block();
    }

    // ── 各周期效果 ──
    if (_s.b3_decay_sec > 0) { /* 已在每帧块处理 */ }

    if (_s.b3_reaper_sec > 0 && current_time - _s.b3_reaper_ms >= _s.b3_reaper_sec * 1000) {
        _s.b3_reaper_ms = current_time;
        hex_b3_reap();
    }
    if (_s.b3_bomb_sec > 0 && current_time - _s.b3_bomb_ms >= _s.b3_bomb_sec * 1000) {
        _s.b3_bomb_ms = current_time;
        hex_b3_bomb();
    }
    if (_s.b3_ghost_sec > 0 && current_time - _s.b3_ghost_ms >= _s.b3_ghost_sec * 1000) {
        _s.b3_ghost_ms = current_time;
        hex_b3_spawn_ghost();
    }
    if (_s.b3_freeze_sec > 0 && current_time - _s.b3_freeze_ms >= _s.b3_freeze_sec * 1000) {
        _s.b3_freeze_ms = current_time;
        hex_b3_freeze_all();
    }
    if (_s.b3_eat_sec > 0 && current_time - _s.b3_eat_ms >= _s.b3_eat_sec * 1000) {
        _s.b3_eat_ms = current_time;
        hex_b3_eat_card();
    }
    if (_s.b3_couple_sec > 0 && current_time - _s.b3_couple_ms >= _s.b3_couple_sec * 1000) {
        _s.b3_couple_ms = current_time;
        hex_b3_roll_couple();
    }
    if (_s.b3_lava_sec > 0 && current_time - _s.b3_lava_ms >= _s.b3_lava_sec * 1000) {
        _s.b3_lava_ms = current_time;
        hex_b3_spawn_lava();
    }

    // 食指的指令：每 30 秒换一只标记鼠
    if (variable_struct_exists(_s, "b3_mark_on") && _s.b3_mark_on) {
        if (_s.b3_mark_enemy != noone && !instance_exists(_s.b3_mark_enemy)) _s.b3_mark_enemy = noone;
        if (current_time - _s.b3_mark_enemy_ms >= 30000) {
            _s.b3_mark_enemy_ms = current_time;
            _s.b3_mark_enemy = hex_b3_pick_enemy();
        }
        // 标记鼠死亡 → 全场鼠军 30 秒 -50%
        if (_s.b3_mark_enemy != noone && !instance_exists(_s.b3_mark_enemy)) {
            _s.b3_mark_enemy = noone;
            _s.b3_mark_penalty_ms = current_time + 30000;
        }
    }

    // 食指的指令·卡片侧：标记要一直挂在「当前可种植的那张卡」上。
    // 只在换波时挑一次是不够的 —— 玩家把那张种下去了、或者卡槽换了，
    // 标记就空着，面板上什么都看不到。这里每隔 2 秒补一次。
    if (variable_struct_exists(_s, "b3_mark_on") && _s.b3_mark_on) {
        var _need_mark = (_s.b3_mark_card == "");
        if (!_need_mark) {
            var _still = false;
            var _sn = instance_number(obj_card_slot);
            for (var _si = 0; _si < _sn; _si++) {
                var _sl = instance_find(obj_card_slot, _si);
                if (!instance_exists(_sl)) continue;
                if (!variable_instance_exists(_sl, "card_id")) continue;
                if (_sl.card_id == _s.b3_mark_card) { _still = true; break; }
            }
            if (!_still) _need_mark = true;
        }
        if (_need_mark && current_time - _s.b3_mark_card_ms >= 2000) {
            _s.b3_mark_card_ms = current_time;
            hex_b3_continue_mark();
        }
    }

    // 复制体衰减
    with (obj_enemy_parent) {
        if (variable_instance_exists(self.id, "b3_decay_pct") && self.b3_decay_pct > 0) {
            if (current_time - self.b3_decay_until >= 1000) {
                self.b3_decay_until = current_time;
                self.hp -= self.maxhp * self.b3_decay_pct;
            }
        }
    }
}

/// @function hex_b3_second_block()
/// @desc 每秒结算：鼠军溺水 / 契约惩罚 / 海洋婚礼
function hex_b3_second_block() {
    var _s = global.hex_state;

    // 不公的契约：面板没弹 / 被弃权时兜底随机签一种
    hex_b3_contract_fallback();

    // 自由契约：每 30 秒重滚一次全队耗能
    if (hex_b3_contract_on("free")) {
        if (current_time - _s.b3_contract_free_ms >= 30000) {
            _s.b3_contract_free_ms = current_time;
            _s.b3_contract_free_mult = random_range(0.6, 1.8);
        }
    }

    // 派生标记：相邻同分类 / 站在熔岩上 / 大分类种数
    hex_b3_refresh_card_flags();
    hex_b3_refresh_counts();

    // 海洋的婚礼：海底卡免窒息
    if (_s.b3_sea) {
        with (obj_card_parent) {
            if (self.plant_id == "coal_starfish" || self.plant_id == "curry_lobster_cannon"
                || self.plant_id == "horseshoe_crab_bread" || self.plant_id == "nut_frier") {
                if (variable_instance_exists(self.id, "drown_timer")) self.drown_timer = 0;
            }
        }
    }

    // 海洋的婚礼：鼠军每秒 -1% 最大生命
    if (_s.b3_enemy_drain_sec > 0) {
        with (obj_enemy_parent) {
            if (self.hp > 0) self.hp -= self.maxhp * 0.01;
        }
    }

    // 契约：力量 / 神速 的惩罚（非攻击态每秒 -1% 上限）
    if (_s.b3_contract != "" && !_s.b3_contract_off) {
        if (_s.b3_contract == "power" || _s.b3_contract == "speed") {
            with (obj_card_parent) {
                if (self.plant_id != "player" && hex_b3_attack_major(self.plant_id)) {
                    if (self.state != CARD_STATE.ATTACK) {
                        if (!variable_instance_exists(self.id, "b3_not_atk_ms")) self.b3_not_atk_ms = current_time;
                        if (current_time - self.b3_not_atk_ms >= 1000) {
                            self.b3_not_atk_ms = current_time;
                            if (!variable_instance_exists(self.id, "b3_contract_loss")) self.b3_contract_loss = 0;
                            self.b3_contract_loss += self.max_hp * 0.01;
                            self.hp -= self.max_hp * 0.01;
                        }
                    } else {
                        self.b3_not_atk_ms = current_time;
                    }
                }
            }
        }
    }

    // 自由契约：每 30 秒随机改一张卡的耗火
    if (_s.b3_contract == "free" && !_s.b3_contract_off) {
        if (current_time - _s.b3_contract_ms >= 30000) {
            _s.b3_contract_ms = current_time;
            if (instance_exists(obj_card_slot)) {
                var _n = instance_number(obj_card_slot);
                var _slot = instance_find(obj_card_slot, irandom(_n - 1));
                if (instance_exists(_slot) && variable_instance_exists(_slot, "card_id")) {
                    if (!variable_struct_exists(_s, "b3_cost_override")) _s.b3_cost_override = {};
                    var _v = irandom_range(-100, 200) * 5;
                    _s.b3_cost_override[$ _slot.card_id] = max(0, _v);
                }
            }
        }
    }
}

/// @function hex_b3_pick_enemy()
/// @desc 随机挑一只非 BOSS 鼠军
function hex_b3_pick_enemy() {
    var _cnt = instance_number(obj_enemy_parent);
    if (_cnt <= 0) return noone;
    for (var i = 0; i < 10; i++) {
        var _e = instance_find(obj_enemy_parent, irandom(_cnt - 1));
        if (instance_exists(_e) && !_e.is_boss && _e.hp > 0) return _e;
    }
    return noone;
}

/// @function hex_b3_reap()
/// @desc 死神临近：随机带走一张卡 + 一只鼠
function hex_b3_reap() {
    var _cnt = instance_number(obj_card_parent);
    if (_cnt > 0) {
        var _c = instance_find(obj_card_parent, irandom(_cnt - 1));
        if (instance_exists(_c) && _c.plant_id != "player") _c.hp = 0;
    }
    var _en = instance_number(obj_enemy_parent);
    if (_en > 0) {
        var _e = instance_find(obj_enemy_parent, irandom(_en - 1));
        if (instance_exists(_e)) _e.hp = 0;
    }
}

/// @function hex_b3_bomb()
/// @desc 爆破区：每 30 秒在随机空格丢一颗既有的可乐炸弹 / 冰桶炸弹（走真实卡片流程）
function hex_b3_bomb() {
    if (!variable_global_exists("grid_cols") || !variable_global_exists("grid_rows")) return;
    var _col = irandom(global.grid_cols - 1);
    var _row = irandom(global.grid_rows - 1);

    // 只落在空格上：叠在已有美食身上会互相盖住，还容易把卡挤掉
    if (variable_global_exists("grid_plants")) {
        var _cell = ds_grid_get(global.grid_plants, _col, _row);
        if (ds_exists(_cell, ds_type_list) && ds_list_size(_cell) > 0) return;
    }

    var _wp = get_world_position_from_grid(_col, _row);
    if (is_undefined(_wp)) return;

    // 两种既有炸弹随机一个。注意：**不能**用 deck_get_card_data 做前置判断，
    // 它查的是玩家自己的卡组 —— 卡组里没带炸弹就永远返回 noone，
    // 「爆破区」会静默哑火（这就是实机上看到「和表里写的不一样」的原因）。
    var _types = [obj_coke_bomb, obj_ice_bucket_bomb];
    var _obj   = _types[irandom(array_length(_types) - 1)];
    var _cid   = (_obj == obj_coke_bomb) ? "coke_bomb" : "ice_bucket_bomb";

    // 借道礼盒生成的上下文，走和正常卡完全一样的实例化流程
    global.random_gift_spawn_context = {
        card_id: _cid,
        shape: 0,
        level: 0,
        skill: 0,
        source: "hex_bomb",
        terrain_adapted: true
    };
    var _inst = instance_create_depth(_wp.x, _wp.y, 0, _obj);
    global.random_gift_spawn_context = undefined;
    if (!instance_exists(_inst)) return;
    card_created(_inst, _col, _row);
    _inst.depth = calculate_plant_depth(_col, _row, _inst.plant_type);
    _inst.random_gift_result = true;
}

/// @function hex_b3_spawn_ghost()
/// @desc 疑神疑鬼：第 9 列随机行刷一只幽灵鼠
function hex_b3_spawn_ghost() {
    if (!variable_global_exists("grid_cols") || !variable_global_exists("grid_rows")) return;
    if (!variable_global_exists("enemy_map")) return;
    if (!ds_exists(global.enemy_map, ds_type_map)) return;
    var _row = irandom(global.grid_rows - 1);
    var _col = 8;
    var _wp = get_world_position_from_grid(_col, _row);
    if (is_undefined(_wp)) return;
    var _e = instance_create_depth(_wp.x + 30, _wp.y + 38, 0, obj_ghost_mouse);
    if (instance_exists(_e)) {
        hex_enemy_scale(_e);
        _e.grid_row = _row;
        _e.grid_col = _col;
    }
}

/// @function hex_b3_freeze_all()
/// @desc 冰冰冰：全场卡片与老鼠冻结 5 秒
function hex_b3_freeze_all() {
    with (obj_card_parent) {
        if (self.plant_id != "player") {
            self.frozen_timer = 300;
            self.is_frozen = true;
        }
    }
    with (obj_enemy_parent) {
        self.frozen_timer = 300;
        self.is_frozen = true;
        self.current_frozen = true;
    }
}

/// @function hex_b3_eat_card()
/// @desc deepseek：随机吃掉一张卡（直接死，不含人物）
function hex_b3_eat_card() {
    var _cnt = instance_number(obj_card_parent);
    if (_cnt <= 0) return;
    for (var i = 0; i < 8; i++) {
        var _c = instance_find(obj_card_parent, irandom(_cnt - 1));
        if (instance_exists(_c) && _c.plant_id != "player") { _c.hp = 0; return; }
    }
}

/// @function hex_b3_roll_couple()
/// @desc 婚介所：随机两张卡攻击 +50%，其余 -50%（按 card_id 点名）
function hex_b3_roll_couple() {
    var _s = global.hex_state;
    _s.b3_couple_hot = {};
    if (!instance_exists(obj_card_parent)) return;
    var _ids = [];
    with (obj_card_parent) {
        if (self.plant_id != "player" && array_index_of(_ids, self.plant_id) == -1) array_push(_ids, self.plant_id);
    }
    if (array_length(_ids) == 0) return;
    for (var i = 0; i < 2; i++) {
        _s.b3_couple_hot[$ _ids[irandom(array_length(_ids) - 1)]] = true;
    }
    if (variable_global_exists("buff_apply_id")) global.buff_apply_id += 1;
}

/// @function hex_b3_spawn_lava()
/// @desc 喷涌的地脉：随机五格生成临时熔岩（1 分钟）
function hex_b3_spawn_lava() {
    if (!variable_global_exists("grid_cols") || !variable_global_exists("grid_rows")) return;
    for (var i = 0; i < 5; i++) {
        var _col = irandom(global.grid_cols - 1);
        var _row = irandom(global.grid_rows - 1);
        var _fx = instance_create_depth(0, 0, -1300, obj_vajra_lava_effect);
        if (instance_exists(_fx)) {
            _fx.target_col = _col;
            _fx.target_row = _row;
            _fx.hex_life   = 3600;
        }
    }
}

/// @function hex_b3_refresh_card_flags()
/// @desc 每秒刷新一次卡片的派生标记：相邻同分类（小指的聚散）/ 站在岩浆上（喷涌的地脉）
function hex_b3_refresh_card_flags() {
    var _s = global.hex_state;
    var _adj_on = _s.b3_adj_on;

    with (obj_card_parent) {
        if (self.plant_id != "player") {
            // 隔壁同大分类的张数
            if (_adj_on) {
                var _me     = self.id;
                var _myrow  = self.grid_row;
                var _mycol  = self.grid_col;
                var _cat    = card_get_category(self.plant_id);
                var _n      = 0;
                if (!is_undefined(_cat)) {
                    var _cnt = instance_number(obj_card_parent);
                    for (var i = 0; i < _cnt; i++) {
                        var _o = instance_find(obj_card_parent, i);
                        if (!instance_exists(_o)) continue;
                        if (_o.id == _me) continue;
                        if (_o.plant_id == "player") continue;
                        var _c2 = card_get_category(_o.plant_id);
                        if (is_undefined(_c2)) continue;
                        if (_c2.major != _cat.major) continue;
                        if (abs(_o.grid_col - _mycol) + abs(_o.grid_row - _myrow) == 1) _n += 1;
                    }
                }
                self.b3_adj = min(1.0, 0.10 * _n);
            }
        }
    }

    // 站在熔岩格上（喷涌的地脉）：先全部清掉，再按格打标
    if (_s.b3_lava_bonus > 0) {
        with (obj_card_parent) { if (self.plant_id != "player") self.b3_on_lava = false; }
        var _lava_n = instance_number(obj_lava);
        for (var k = 0; k < _lava_n; k++) {
            var _lv = instance_find(obj_lava, k);
            if (!instance_exists(_lv)) continue;
            var _lrow = _lv.row;
            var _lcol = _lv.col;
            with (obj_card_parent) {
                if (self.plant_id != "player" && self.grid_row == _lrow && self.grid_col == _lcol) {
                    self.b3_on_lava = true;
                }
            }
        }
    }
}

// ══════════════════════ 面板 ══════════════════════

/// @function hex_b3_panel_extra(_id)
/// @desc 宾邦：确认一条后再随机白送一条池内词条
function hex_b3_panel_extra(_id) {
    if (!hex_enabled()) return;
    if (!variable_hex_b3_state()) return;
    if (!global.hex_state.b3_extra_pick) return;
    if (!variable_global_exists("hex_ids")) return;
    var _cands = [];
    for (var i = 0; i < array_length(global.hex_ids); i++) {
        var _cid = global.hex_ids[i];
        if (_cid == _id) continue;
        if (!hex_pickable(_cid)) continue;
        array_push(_cands, _cid);
    }
    if (array_length(_cands) == 0) return;
    hex_apply(_cands[irandom(array_length(_cands) - 1)]);
}

/// @function hex_b3_pick_all_on()
function hex_b3_pick_all_on() {
    if (!hex_enabled()) return false;
    if (!variable_hex_b3_state()) return false;
    return global.hex_state.b3_pick_all;
}

// ══════════════════════ 卡组 / 结算 ══════════════════════

/// @function hex_b3_on_win()
/// @desc 低语耳环：每局结束随机为卡片提升等级（按岛屿上限）
function hex_b3_on_win() {
    if (!hex_enabled()) return;
    if (!variable_hex_b3_state()) return;
    var _s = global.hex_state;
    if (!variable_struct_exists(_s, "b3_levelup") || !_s.b3_levelup) return;
    if (!variable_global_exists("save_data") || !is_struct(global.save_data)) return;

    // 岛屿上限：美味 6 / 火山 9 / 浮空 13 / 其它 13
    var _cap = 13;
    var _map = global.map_id;
    if (_map == "delicious_island" || _map == "milkshake_base") _cap = 6;
    if (_map == "volcano_island") _cap = 9;

    var _times = 3;
    var _changed = false;
    var _pool = [];
    if (variable_global_exists("selected_deck") && ds_exists(global.selected_deck, ds_type_list)) {
        var _len = ds_list_size(global.selected_deck);
        for (var k = 0; k < _len; k++) {
            var _e = global.selected_deck[| k];
            var _cid = "";
            // 卡组元素是 ds_map（deck_entry[? "card_id"]），不是 struct ——
            // 原来只认 is_struct，结果整条词条一次都没生效
            if (is_struct(_e)) {
                if (variable_struct_exists(_e, "card_id")) _cid = _e.card_id;
            } else if (is_real(_e)) {
                if (ds_map_exists(_e, "card_id")) _cid = _e[? "card_id"];
            } else if (is_string(_e)) {
                _cid = _e;
            }
            if (_cid != "" && array_get_index(_pool, _cid) == -1) array_push(_pool, _cid);
        }
    }
    // 兜底：卡组读不到就用玩家牌堆（player_deck 是 id/data 交替）
    if (array_length(_pool) == 0 && variable_global_exists("player_deck")
        && ds_exists(global.player_deck, ds_type_list)) {
        var _pl = ds_list_size(global.player_deck);
        for (var k2 = 0; k2 < _pl; k2 += 2) {
            var _cid2 = global.player_deck[| k2];
            if (is_string(_cid2) && _cid2 != "" && array_get_index(_pool, _cid2) == -1) array_push(_pool, _cid2);
        }
    }
    if (array_length(_pool) == 0) return;

    // 随机挑 3 张（不重复），每张 +1~2 级；到顶的剔掉换下一张
    var _done  = 0;
    var _guard = 0;
    while (_done < _times && array_length(_pool) > 0 && _guard < 32) {
        _guard += 1;
        var _pi   = irandom(array_length(_pool) - 1);
        var _pick = _pool[_pi];
        if (hex_b3_levelup_card(_pick, _cap)) {
            _changed = true;
            _done   += 1;
        }
        array_delete(_pool, _pi, 1);
    }

    // hex_on_win() 已经在它自己内部落过盘了，这里改的是存档里的等级，
    // 不补一次保存的话本次提升会丢
    if (_changed && variable_global_exists("save_slot")) save_file(global.save_slot);
}

/// @function hex_b3_levelup_card(_card_id, _cap)
/// @desc 低语耳环：把一张卡的等级（星级）提 1~2 级。真实存档字段是
///       save_data.unlocked_cards[] 里的 { id, level }，不是 save_data.cards
function hex_b3_levelup_card(_card_id, _cap) {
    if (!variable_global_exists("save_data") || !is_struct(global.save_data)) return false;
    if (!variable_struct_exists(global.save_data, "unlocked_cards")) return false;
    var _cards = global.save_data.unlocked_cards;
    if (is_undefined(_cards) || !is_array(_cards)) return false;
    for (var i = 0; i < array_length(_cards); i++) {
        var _c = _cards[i];
        if (!is_struct(_c)) continue;
        if (!variable_struct_exists(_c, "id")) continue;
        if (_c.id != _card_id) continue;
        if (!variable_struct_exists(_c, "level")) continue;
        // 真正的上限是这张卡自己记录的 max_level（进度相关），岛屿上限只是外层封顶
        var _cap2 = _cap;
        if (variable_struct_exists(_c, "max_level") && _c.max_level > 0) {
            _cap2 = min(_cap, _c.max_level);
        }
        if (_c.level >= _cap2) return false;
        _c.level = min(_cap2, _c.level + irandom_range(1, 2));
        return true;
    }
    return false;
}

// ══════════════════════ 唯我独尊 / 情报收集 ══════════════════════

/// @function hex_b3_unique_block(_plant_id)
/// @desc 唯我独尊：同一种美食场上只能有一张
function hex_b3_unique_block(_plant_id) {
    if (!hex_enabled()) return false;
    if (!variable_hex_b3_state()) return false;
    if (!global.hex_state.b3_unique) return false;
    if (_plant_id == "" || _plant_id == "player") return false;
    var _n = 0;
    with (obj_card_parent) {
        if (self.plant_id == _plant_id && self.hp > 0) _n += 1;
    }
    return (_n > 0);
}

/// @function hex_b3_free3_try()
/// @desc Hana 的卦·免：开局前三张免费
function hex_b3_free3_try() {
    if (!hex_enabled()) return false;
    if (!variable_hex_b3_state()) return false;
    var _s = global.hex_state;
    if (_s.b3_free3 <= 0) return false;
    _s.b3_free3 -= 1;
    return true;
}

/// @function hex_b3_info_mark(_mouse_id)
/// @desc 情报收集：在情报岛查看过这只鼠后记一笔（跨存档）
function hex_b3_info_mark(_mouse_id) {
    if (_mouse_id == "") return;
    if (!variable_global_exists("save_data")) return;
    if (!is_struct(global.save_data)) return;
    if (!variable_struct_exists(global.save_data, "b3_info_seen")) {
        global.save_data.b3_info_seen = [];
    }
    var _a = global.save_data.b3_info_seen;
    if (array_index_of(_a, _mouse_id) != -1) return;
    array_push(_a, _mouse_id);
    global.save_data.b3_info_seen = _a;
}

/// @function hex_b3_info_mult(_mouse_id)
/// @desc 情报收集：查看过 +20%，没看过 -20%
function hex_b3_info_mult(_mouse_id) {
    if (!hex_enabled()) return 1.0;
    if (!variable_hex_b3_state()) return 1.0;
    if (!global.hex_state.b3_info) return 1.0;
    if (_mouse_id == "") return 1.0;
    if (!variable_global_exists("save_data") || !is_struct(global.save_data)) return 1.0;
    if (!variable_struct_exists(global.save_data, "b3_info_seen")) return 0.8;
    var _a = global.save_data.b3_info_seen;
    if (array_contains(_a, _mouse_id)) return 1.2;
    return 0.8;
}

// ══════════════════════ Hana 的四卦 ══════════════════════

/// @function hex_b3_hana_offer()
/// @desc 四卦的四个选项
function hex_b3_hana_offer() {
    return ["hex_hana_1", "hex_hana_2", "hex_hana_3", "hex_hana_4"];
}

/// @function hex_b3_hana_enemy_roll()
/// @desc Hana 的鼠军侧：开局随机一项（鼠军攻击 +20% / 生命 +30% / 前三只出场时复制自身）
function hex_b3_hana_enemy_roll() {
    if (!hex_enabled()) return;
    if (!variable_hex_b3_state()) return;
    var _s = global.hex_state;
    if (!variable_struct_exists(_s, "b3_hana_enemy")) _s.b3_hana_enemy = -1;
    if (_s.b3_hana_enemy >= 0) return;
    _s.b3_hana_enemy = irandom(2);
    if (_s.b3_hana_enemy == 0) {
        _s.e_atk *= 1.20;
    } else if (_s.b3_hana_enemy == 1) {
        _s.e_hp *= 1.30;
    } else {
        _s.b3_clone_left = 3;
    }
    hex_sync_globals();
}

// ══════════════════════ 词条表 ══════════════════════

/// @function hex_register_batch3()
/// @desc 注册二期词条（hex_185 ~ hex_259，66 条）。由 hex_registry_init() 调用
function hex_register_batch3() {

    // ══════════ A 组：可直接落地（47 条）══════════

    hex_register("hex_185", {
        tier: 1, form: "A", name: "以我残躯化烈火",
        card_desc: "美食阵亡时在该格留下 10 秒火焰（伤害 50）",
        enemy_desc: "鼠军阵亡时在该格生成 10 秒临时熔岩",
        stack: 1, impl: true,
        ex: { b3_death_fire: 50 }, en: { b3_e_death_lava: 10 }
    });
    hex_register("hex_186", {
        tier: 0, form: "A", name: "喷涌的地脉",
        card_desc: "站在熔岩上的美食攻击与攻速 +20%",
        enemy_desc: "每 20 秒随机五格生成 1 分钟临时熔岩",
        stack: 1, impl: true,
        ex: { b3_lava: [20, 0.20] }, en: {}
    });
    hex_register("hex_190", {
        tier: 1, form: "A", name: "中指的义理",
        card_desc: "美食阵亡时其余美食叠一层：全队攻击与攻速 +10%（最多 20 层）",
        enemy_desc: "鼠军阵亡时其余鼠军生命 +2%",
        stack: 1, impl: true,
        ex: { b3_finger: [0.10, 0.05, 20] }, en: { b3_finger_hp: 0.02 }
    });
    hex_register("hex_191", {
        tier: 1, form: "A", name: "拇指的阶级",
        card_desc: "卡组含金卡全队全属性 +100%，融合卡 +50%，二转卡 +20%，一转卡 +10%（取最高）",
        enemy_desc: "无",
        stack: 1, impl: true,
        ex: { b3_thumb: true }, en: {}
    });
    hex_register("hex_192", {
        tier: 1, form: "A", name: "环指的艺术",
        card_desc: "本关每出没一种鼠军，全队攻击 +5%",
        enemy_desc: "卡组每有一种美食分类，鼠军生命 +5%",
        stack: 1, impl: true,
        ex: { b3_seen_atk: 0.05 }, en: { b3_deck_hp: 0.05 }
    });
    hex_register("hex_193", {
        tier: 1, form: "A", name: "食指的指令",
        card_desc: "每 30 秒标记一张美食：下次种下的正是它则全队全属性 +20%，否则 -10%",
        enemy_desc: "每 30 秒标记一只鼠军：它在场时鼠军全属性 +30%，它死后鼠军 30 秒内 -50% 生命",
        stack: 1, impl: true,
        ex: { b3_mark: true }, en: {}
    });
    hex_register("hex_194", {
        tier: 1, form: "A", name: "小指的聚散",
        card_desc: "相邻的同类美食每张给彼此 +10% 全属性（上限 +100%）",
        enemy_desc: "同种鼠军每多一只，该种鼠军生命 +5%（上限 +50%）",
        stack: 1, impl: true,
        ex: { b3_adj: true }, en: { b3_same_hp: 0.05 }
    });
    hex_register("hex_199", {
        tier: 2, form: "C", name: "愈加善良的希望",
        card_desc: "全队攻击 -25%、生命 -25%、攻速 -25%",
        enemy_desc: "鼠军攻击 -25%、生命 -25%、移速 -25%",
        stack: 1, impl: true,
        ex: { atk: -0.25, hp: -0.25, cycle: 0.25 },
        en: { e_atk: -0.25, e_hp: -0.25, e_spd: -0.25 }
    });
    hex_register("hex_200", {
        tier: 2, form: "C", name: "生存下去的勇气",
        card_desc: "美食受伤时同时失去等量生命上限；每波开始恢复",
        enemy_desc: "每波开始场上鼠军回满血",
        stack: 1, impl: true,
        ex: { b3_hp_on_hit: true }, en: {}
    });
    hex_register("hex_202", {
        tier: 2, form: "A", name: "守护他人的决意",
        card_desc: "全队伤害 +30%，免疫冻结与沉睡",
        enemy_desc: "鼠军受到致命伤害时 5 秒内不死（每只一次）",
        stack: 1, impl: true,
        ex: { atk: 0.30, b3_control_immune: true }, en: { b3_lethal_guard: 5 }
    });
    hex_register("hex_203", {
        tier: 2, form: "A", name: "值得托付的信任",
        card_desc: "每波随机一个攻击分类伤害翻倍，其余攻击卡伤害减半",
        enemy_desc: "无",
        stack: 1, impl: true,
        ex: { b3_pick: true }, en: {}
    });
    hex_register("hex_204", {
        tier: 2, form: "A", name: "直面恐惧斩断循环",
        card_desc: "本局每张美食第一次放置免费，但卡片费用 ×1.5",
        enemy_desc: "无",
        stack: 1, impl: true,
        ex: { b3_first_free: true }, en: {}
    });
    hex_register("hex_205", {
        tier: 2, form: "C", name: "拥抱过去创造未来",
        card_desc: "强制锁定 2 倍速；每暂停一次，回来时随机一张美食阵亡",
        enemy_desc: "非 BOSS 鼠军永久 50% 寒冷（移速减半、啃咬变慢）",
        stack: 1, impl: true,
        ex: { b3_speed_lock: true, b3_pause_kills: true }, en: { b3_chill: true }
    });
    hex_register("hex_210", {
        tier: 1, form: "A", name: "生死界限",
        card_desc: "每一发子弹的伤害随机 ±45",
        enemy_desc: "无",
        stack: 1, impl: true,
        ex: {}, en: { b3_dmg_jitter: 45 }
    });
    hex_register("hex_212", {
        tier: 1, form: "A", name: "满腔热血",
        card_desc: "全队攻击 -30%，场上每张美食再 +2%（上限 +60%）",
        enemy_desc: "无",
        stack: 1, impl: true,
        ex: { atk: -0.30, per_card_atk: [0.02, 0.60] }, en: {}
    });
    hex_register("hex_214", {
        tier: 1, form: "A", name: "派送箱",
        card_desc: "全队攻速 ×2；美食在场满 30 秒后每秒扣 5 点生命",
        enemy_desc: "无",
        stack: 1, impl: true,
        ex: { cycle: -0.5, b3_decay: [30, 5] }, en: {}
    });
    hex_register("hex_215", {
        tier: 1, form: "A", name: "知识收集",
        card_desc: "不攻击时 10 秒内攻击渐增至 200%，持续攻击时渐降至 50%",
        enemy_desc: "无",
        stack: 1, impl: true,
        ex: { b3_charge: true }, en: {}
    });
    hex_register("hex_217", {
        tier: 1, form: "A", name: "唯我独尊",
        card_desc: "每种美食只能同时存在一张，但全属性 +50%",
        enemy_desc: "无",
        stack: 1, impl: true,
        ex: { b3_all_stat: 0.50, b3_unique: true }, en: {}
    });
    hex_register("hex_218", {
        tier: 1, form: "A", name: "释放忍术",
        card_desc: "火影章鱼烧攻击 +100%",
        enemy_desc: "忍者鼠进场时前移 4 格并召唤一只同类",
        stack: 1, impl: true,
        ex: { b3_id_atk: [ ["takoyaki", 1.0] ] }, en: { b3_ninja: true }
    });
    hex_register("hex_221", {
        tier: 1, form: "A", name: "重燃的火光",
        card_desc: "美食子弹命中鼠军时在该格生成 3 秒火焰（伤害取该卡攻击）",
        enemy_desc: "鼠军死亡时 5% 生成一只每秒流失 5% 生命的复制（BOSS 除外）",
        stack: 1, impl: true,
        ex: { b3_bullet_fire: 1 }, en: { b3_clone: [0.05, 0.05] }
    });
    hex_register("hex_222", {
        tier: 0, form: "A", name: "齿轮的烟气",
        card_desc: "美食每受一次伤，之后受到的伤害 +2%（上限 +30%）",
        enemy_desc: "鼠军每受一次伤，之后受到的伤害 +2.5%（上限 +50%）",
        stack: 1, impl: true,
        ex: { b3_card_taken: [0.02, 0.30] }, en: { b3_enemy_taken: [0.025, 0.50] }
    });
    hex_register("hex_223", {
        tier: 1, form: "A", name: "鲨鱼的厚皮",
        card_desc: "美食受到的伤害 -20%，且免疫灰烬秒杀",
        enemy_desc: "鼠军杀死美食时回复自身 20% 生命上限（BOSS 除外）",
        stack: 1, impl: true,
        ex: { b3_card_dr: 0.20, b3_ash_proof: true }, en: {}
    });
    hex_register("hex_224", {
        tier: 1, form: "A", name: "顶点的合奏",
        card_desc: "场上每有一种大分类，全队攻击 +10%",
        enemy_desc: "场上每有一种鼠军，鼠军生命 +2%（上限 +50%）",
        stack: 1, impl: true,
        ex: { b3_major_atk: 0.10 }, en: { b3_kind_hp: 0.02 }
    });
    hex_register("hex_225", {
        tier: 0, form: "A", name: "演出的高潮",
        card_desc: "本局全队随机获得 1%~100% 全属性",
        enemy_desc: "每只鼠军出生时随机获得 -10~+10 点伤害减免",
        stack: 1, impl: true,
        ex: { b3_run_stat: true }, en: { b3_e_dr_roll: 10 }
    });
    hex_register("hex_226", {
        tier: 1, form: "A", name: "孤狼的高傲",
        card_desc: "美食第一次受到致死伤害时免疫并回满生命",
        enemy_desc: "鼠军攻击 +50%",
        stack: 1, impl: true,
        ex: { b3_last_stand: true }, en: { e_atk: 0.50 }
    });
    hex_register("hex_227", {
        tier: 1, form: "A", name: "悬丝的傀儡",
        card_desc: "人物受到致死伤害时免疫并无敌 30 秒（每次进关一次）",
        enemy_desc: "BOSS 受伤时最多把 500 点伤害转移给场上随机鼠军",
        stack: 1, impl: true,
        ex: { b3_player_guard: true }, en: { b3_boss_transfer: 500 }
    });
    hex_register("hex_230", {
        tier: 2, form: "A", name: "残响的终曲",
        card_desc: "对 BOSS 造成的伤害 +100%",
        enemy_desc: "无",
        stack: 1, impl: true,
        ex: {}, en: { b3_boss_dmg: 1.0 }
    });
    hex_register("hex_233", {
        tier: 1, form: "A", name: "时间",
        card_desc: "从点起美食到它被放下的这段时间里，游戏速度降到 1/5；放下即恢复",
        enemy_desc: "无",
        stack: 1, impl: true,
        ex: { b3_time_slow: true }, en: {}
    });
    hex_register("hex_234", {
        tier: 2, form: "A", name: "我是老曙",
        card_desc: "所有美食攻击 +200%、冷却 -50%",
        enemy_desc: "本局鼠军血量随机 ×3~×729",
        stack: 1, impl: true,
        ex: { atk: 2.0, cycle: -0.5 },
        en: { b3_e_hp_roll: true }
    });
    hex_register("hex_238", {
        tier: 0, form: "A", name: "呼朋唤友",
        card_desc: "对 BOSS 伤害 +50%",
        enemy_desc: "BOSS 首次出现时再出现一只同类（半血）",
        stack: 1, impl: true,
        ex: {}, en: { b3_boss_dmg: 0.5, b3_boss_extra: true }
    });
    hex_register("hex_239", {
        tier: 1, form: "A", name: "冻实的冰块",
        card_desc: "减速类子弹伤害 +100%",
        enemy_desc: "鼠军的减速效果减弱 30%",
        stack: 1, impl: true,
        ex: { b3_slow_bullet: 1.0 }, en: { e_slow_resist: 0.30 }
    });
    hex_register("hex_240", {
        tier: 0, form: "A", name: "爆破区",
        card_desc: "每 30 秒在随机格生成一颗既有炸弹（可乐炸弹 / 冰桶炸弹）",
        enemy_desc: "无",
        stack: 1, impl: true,
        ex: { b3_bomb_sec: 30 }, en: {}
    });
    hex_register("hex_241", {
        tier: 2, form: "A", name: "鼠鼠爱财宝",
        card_desc: "无",
        enemy_desc: "鼠军死亡掉落 100 金币（1% 概率 5000）",
        stack: 1, impl: true,
        ex: {}, en: { b3_coin: [100, 5000, 0.01] }
    });
    hex_register("hex_242", {
        tier: 1, form: "A", name: "当头棒喝",
        card_desc: "每张美食的第一发子弹伤害 ×10",
        enemy_desc: "每只鼠军受到的第一次伤害 ×10",
        stack: 1, impl: true,
        ex: { b3_first_shot: true }, en: { b3_first_hit: 10 }
    });
    hex_register("hex_243", {
        tier: 0, form: "A", name: "疑神疑鬼",
        card_desc: "攻击类美食在场上没有鼠军目标时也不会停止攻击（照常空放）",
        enemy_desc: "每 30 秒在第 9 列随机行生成一只幽灵鼠",
        stack: 1, impl: true,
        ex: { b3_no_stop: true }, en: { b3_ghost_sec: 30 }
    });
    hex_register("hex_244", {
        tier: 0, form: "C", name: "地广人稀",
        card_desc: "所有卡槽冷却时间翻倍",
        enemy_desc: "出怪量减半",
        stack: 1, impl: true,
        ex: { b3_slot_cd: 2.0 }, en: { e_count: -0.5 }
    });
    hex_register("hex_245", {
        tier: 0, form: "C", name: "死神临近",
        card_desc: "每 10 秒随机带走一张美食",
        enemy_desc: "每 10 秒随机带走一只鼠军（含 BOSS）",
        stack: 1, impl: true,
        ex: { b3_reaper_sec: 10 }, en: {}
    });
    hex_register("hex_247", {
        tier: 1, form: "A", name: "普通人",
        card_desc: "平射类攻击 +100%，其它攻击卡攻击 -50%（产能除外）",
        enemy_desc: "鼠军移速 +10%",
        stack: 1, impl: true,
        ex: { b3_direct_atk: 1.0, b3_other_atk: -0.5 }, en: { e_spd: 0.10 }
    });
    hex_register("hex_248", {
        tier: 2, form: "A", name: "通天之人",
        card_desc: "平射类攻击 +300%，其它攻击卡攻击 -90%（产能除外）",
        enemy_desc: "鼠军移速 +30%",
        stack: 1, impl: true,
        ex: { b3_direct_atk: 3.0, b3_other_atk: -0.9 }, en: { e_spd: 0.30 }
    });
    hex_register("hex_250", {
        tier: 1, form: "A", name: "真·雷神",
        card_desc: "雷神系卡片攻击 +250%",
        enemy_desc: "鼠军生命 +100%，移速 +20%",
        stack: 1, impl: true,
        ex: { b3_id_atk: [ ["thor", 2.5], ["rongheleishen", 2.5] ] },
        en: { e_hp: 1.0, e_spd: 0.20 }
    });
    hex_register("hex_252", {
        tier: 1, form: "A", name: "宾邦",
        card_desc: "每次获取词条时，额外随机获得一条池内词条",
        enemy_desc: "无",
        stack: 1, impl: true,
        ex: { b3_extra_pick: true }, en: {}
    });
    hex_register("hex_253", {
        tier: 2, form: "A", name: "领主阳伞",
        card_desc: "无法自行选择，直接获得牌面上的全部词条",
        enemy_desc: "无",
        stack: 1, impl: true,
        ex: { b3_pick_all: true }, en: {}
    });
    hex_register("hex_255", {
        tier: 0, form: "A", name: "冰冰冰",
        card_desc: "每 20 秒全场美食与鼠军冻结 5 秒",
        enemy_desc: "无",
        stack: 1, impl: true,
        ex: { b3_freeze_sec: 20 }, en: {}
    });
    hex_register("hex_256", {
        tier: 1, form: "C", name: "deepseek",
        card_desc: "全队攻击 +25%、攻速 +25%；每 10 秒随机一张美食被吃掉",
        enemy_desc: "出怪量 +20%",
        stack: 1, impl: true,
        ex: { atk: 0.25, cycle: -0.20, b3_eat_sec: 10 }, en: { e_count: 0.20 }
    });
    hex_register("hex_257", {
        tier: 1, form: "C", name: "扫福瑞",
        card_desc: "卡片费用 -25%，全队攻击 -30%",
        enemy_desc: "无",
        stack: 1, impl: true,
        ex: { cost: -0.25, atk: -0.30 }, en: {}
    });
    hex_register("hex_258", {
        tier: 1, form: "A", name: "江人皇",
        card_desc: "产能类美食的火苗产量 ×2",
        enemy_desc: "鼠军移速 +40%",
        stack: 1, impl: true,
        ex: { b3_prod_mult: 1.0 }, en: { e_spd: 0.40 }
    });
    hex_register("hex_259", {
        tier: 2, form: "A", name: "婚介所",
        card_desc: "每 5 秒随机两张美食攻击 +50%，其余美食攻击 -50%",
        enemy_desc: "鼠军生命 +33%",
        stack: 1, impl: true,
        ex: { b3_couple_sec: 5 }, en: { e_hp: 0.33 }
    });

    // ══════════ B 组：需要补一层机制（19 条）══════════

    hex_register("hex_187", {
        tier: 0, form: "A", name: "病毒泄露",
        card_desc: "所有美食对跨服鼠军的伤害 +20%",
        enemy_desc: "有对应跨服鼠军的鼠军生成时 5% 概率替换",
        stack: 1, impl: true,
        ex: {}, en: { b3_infected: [0.20, 0.05] }
    });
    hex_register("hex_188", {
        tier: 1, form: "A", name: "病毒爆发",
        card_desc: "所有美食对跨服鼠军的伤害 +30%",
        enemy_desc: "生成时 20% 概率替换成跨服鼠军",
        stack: 1, impl: true,
        ex: {}, en: { b3_infected: [0.30, 0.20] }
    });
    hex_register("hex_189", {
        tier: 2, form: "A", name: "生化危机",
        card_desc: "所有美食对跨服鼠军的伤害 +50%",
        enemy_desc: "生成的鼠军一律换成对应的跨服鼠军",
        stack: 1, impl: true,
        ex: {}, en: { b3_infected: [0.50, 1.0] }
    });
    hex_register("hex_195", {
        tier: 2, form: "A", name: "后巷的统治者",
        card_desc: "五指组（义理 / 阶级 / 艺术 / 指令 / 聚散）的加成翻倍",
        enemy_desc: "五指组的鼠军侧效果减半",
        stack: 1, impl: true,
        // 前置：必须已经握有整个五指组，否则不进池
        require: ["hex_190", "hex_191", "hex_192", "hex_193", "hex_194"],
        ex: { b3_finger_rule: true, b3_group: "五指" }, en: {}
    });
    hex_register("hex_197", {
        tier: 1, form: "A", name: "昂首阔步的信念",
        card_desc: "所有攻击类美食所属分类随机打乱（共鸣随之变化）",
        enemy_desc: "无",
        stack: 1, impl: true,
        ex: { b3_shuffle: true }, en: {}
    });
    hex_register("hex_207", {
        tier: 1, form: "A", name: "Hana的四卦",
        card_desc: "开局四选一：攻击 +20% / 生命 +30% / 火苗 +1000 / 前三张免费",
        enemy_desc: "开局随机一项：鼠军攻击 +20% / 生命 +30% / 前三只出场时复制自身",
        stack: 1, impl: true,
        ex: { b3_hana: true }, en: {}
    });
    hex_register("hex_209", {
        tier: 0, form: "A", name: "您的盾牌",
        card_desc: "美食获得 25 点固定减伤",
        enemy_desc: "鼠军获得 50 点固定减伤",
        stack: 1, impl: true,
        ex: { b3_card_flat_dr: 25 }, en: { b3_e_flat_dr: 50 }
    });
    hex_register("hex_211", {
        tier: 1, form: "A", name: "决斗",
        card_desc: "对同一目标连续命中时伤害递增（每次 +5%，最高 +25%）",
        enemy_desc: "无",
        stack: 1, impl: true,
        ex: {}, en: { b3_duel_step: 0.05 }
    });
    hex_register("hex_213", {
        tier: 1, form: "A", name: "情报收集",
        card_desc: "在情报岛查看过的鼠军受伤 +20%，未查看过的 -20%",
        enemy_desc: "无",
        stack: 1, impl: true,
        ex: { b3_info: true }, en: {}
    });
    hex_register("hex_228", {
        tier: 0, form: "A", name: "血魔的渴血",
        card_desc: "美食造成伤害时回复等量生命，满血则转为生命上限（上限 +300%）",
        enemy_desc: "非 BOSS 鼠军啃咬美食时回复等量生命",
        stack: 1, impl: true,
        ex: { b3_lifesteal: true }, en: {}
    });
    hex_register("hex_229", {
        tier: 2, form: "C", name: "不公的契约",
        card_desc: "开局随机签订一种契约：光明 / 力量 / 自由 / 神速 / 增幅",
        enemy_desc: "无（负面已在契约里）",
        stack: 1, impl: true,
        ex: { b3_contract_on: true }, en: {}
    });
    hex_register("hex_231", {
        tier: 2, form: "A", name: "残响乐团",
        card_desc: "残响组十条词条的卡片侧效果再结算一次；不公契约的负面失效",
        enemy_desc: "鼠军全属性 -80%",
        stack: 1, impl: true,
        // 前置：残响组十条必须全部握在手里，抽不齐就永远不进池
        require: ["hex_221", "hex_222", "hex_223", "hex_224", "hex_225",
                  "hex_226", "hex_227", "hex_228", "hex_229", "hex_230"],
        ex: { b3_resonance: true, b3_contract_off: true },
        en: { e_hp: -0.80, e_atk: -0.80, e_spd: -0.80 }
    });
    hex_register("hex_232", {
        tier: 2, form: "A", name: "起源",
        card_desc: "本局鼠军每出现过一种死亡方式（撞飞 / 灰烬 / 压扁 / 子弹），全队伤害 +20%",
        enemy_desc: "无",
        stack: 1, impl: true,
        ex: { b3_death_cause_atk: 0.20 }, en: {}
    });
    hex_register("hex_235", {
        tier: 0, form: "A", name: "微微发亮的宝石",
        card_desc: "武器宝石技能冷却 -10%",
        enemy_desc: "无",
        stack: 1, impl: true,
        ex: { b3_gem_cd: -0.10 }, en: {}
    });
    hex_register("hex_236", {
        tier: 1, form: "A", name: "闪耀光芒的宝石",
        card_desc: "武器宝石技能冷却 -20%",
        enemy_desc: "无",
        stack: 1, impl: true,
        ex: { b3_gem_cd: -0.20 }, en: {}
    });
    hex_register("hex_237", {
        tier: 2, form: "A", name: "璀璨夺目的宝石",
        card_desc: "武器宝石技能冷却 -50%",
        enemy_desc: "无",
        stack: 1, impl: true,
        ex: { b3_gem_cd: -0.50 }, en: {}
    });
    hex_register("hex_246", {
        tier: 1, form: "A", name: "海洋的婚礼",
        card_desc: "同时携带海神与海洋女神时，这两张与四张海底卡全属性翻倍，海底卡在其他地形不会窒息",
        enemy_desc: "鼠军每秒流失 1% 最大生命",
        stack: 1, impl: true,
        ex: { b3_sea: true }, en: {}
    });
    hex_register("hex_249", {
        tier: 0, form: "A", name: "这不是外挂",
        card_desc: "穿透类卡片攻击 +30%，火苗获取 -50%",
        enemy_desc: "无",
        stack: 1, impl: true,
        ex: { b3_pierce_atk: 0.30, flame_growth: -0.50 }, en: {}
    });
    hex_register("hex_254", {
        tier: 2, form: "A", name: "低声耳环",
        card_desc: "每局结束时随机为卡组里的卡片提升 1~2 级（美味岛上限 6 星，火山岛 9 星，其它 13 星）",
        enemy_desc: "无",
        stack: 1, impl: true,
        ex: { b3_levelup: true }, en: {}
    });

    // ══════════ Hana 的四卦（面板专用，不进随机池）══════════
    hex_register("hex_hana_1", {
        tier: 1, form: "A", name: "卦·攻",
        card_desc: "全队攻击 +20%", enemy_desc: "无",
        stack: 1, impl: true, no_roll: true,
        ex: { atk: 0.20, b3_hana_pick: true }, en: {}
    });
    hex_register("hex_hana_2", {
        tier: 1, form: "A", name: "卦·守",
        card_desc: "全队生命 +30%", enemy_desc: "无",
        stack: 1, impl: true, no_roll: true,
        ex: { hp: 0.30, b3_hana_pick: true }, en: {}
    });
    hex_register("hex_hana_3", {
        tier: 1, form: "A", name: "卦·火",
        card_desc: "开局火苗 +1000", enemy_desc: "无",
        stack: 1, impl: true, no_roll: true,
        ex: { flame_start: 1000, b3_hana_pick: true }, en: {}
    });
    hex_register("hex_hana_4", {
        tier: 1, form: "A", name: "卦·免",
        card_desc: "开局前三张美食免费", enemy_desc: "无",
        stack: 1, impl: true, no_roll: true,
        ex: { b3_hana_free3: true, b3_hana_pick: true }, en: {}
    });

    // ══════════ 不公的契约：开局五选一（面板专用，不进随机池）══════════
    hex_register("hex_contract_1", {
        tier: 1, form: "A", name: "契约·光明",
        card_desc: "每个火苗价值 +50", enemy_desc: "无",
        stack: 1, impl: true, no_roll: true,
        ex: { b3_contract_pick: "light" }, en: {}
    });
    hex_register("hex_contract_2", {
        tier: 1, form: "A", name: "契约·力量",
        card_desc: "全队攻击 +100%", enemy_desc: "美食不在攻击状态时每秒流失 1% 生命上限",
        stack: 1, impl: true, no_roll: true,
        ex: { b3_contract_pick: "power" }, en: {}
    });
    hex_register("hex_contract_3", {
        tier: 1, form: "A", name: "契约·自由",
        card_desc: "每 30 秒随机改变一次全队火苗消耗（-40%~+80%）", enemy_desc: "无",
        stack: 1, impl: true, no_roll: true,
        ex: { b3_contract_pick: "free" }, en: {}
    });
    hex_register("hex_contract_4", {
        tier: 1, form: "A", name: "契约·神速",
        card_desc: "全队攻速 +100%", enemy_desc: "美食不在攻击状态时每秒流失 1% 生命上限",
        stack: 1, impl: true, no_roll: true,
        ex: { b3_contract_pick: "speed" }, en: {}
    });
    hex_register("hex_contract_5", {
        tier: 1, form: "A", name: "契约·增幅",
        card_desc: "增幅类卡片的增幅效果 +100%", enemy_desc: "无",
        stack: 1, impl: true, no_roll: true,
        ex: { b3_contract_pick: "buff" }, en: {}
    });

    return true;
}
