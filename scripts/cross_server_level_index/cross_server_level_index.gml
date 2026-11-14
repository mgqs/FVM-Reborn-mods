/// 跨服章节关卡 id → 关卡序号（0 起）；非跨服关卡返回 -1
/// 约定：ancient_castle_N / nightmare_sky_N / zhuore_N / shuihuo_N / wudu_N 都属于跨服章节，
/// 奖励走 cross_server_reward()。
/// 项目里原本有 9 处写死 string_pos("ancient_castle_", id) == 1，新增跨服章节一律走这里，
/// 不要再复制前缀判断（否则奖励会落到普通关分支去读 rewards[].gold 而报错）。
function cross_server_level_index(_id){
    var _prefixes = ["ancient_castle_", "nightmare_sky_", "zhuore_", "shuihuo_", "wudu_"];
    var _n = array_length(_prefixes);
    for (var i = 0; i < _n; i++){
        var _p = _prefixes[i];
        if (string_pos(_p, _id) == 1){
            var _tail = string_delete(_id, 1, string_length(_p));
            if (string_length(_tail) > 0 && string_digits(_tail) == _tail) return real(_tail);
            return 0;
        }
    }
    return -1;
}

/// 是否属于跨服章节（首通/重复通关奖励都走徽章档位）
function is_cross_server_level(_id){
    return cross_server_level_index(_id) >= 0;
}

/// 跨服章节奖励档位（唯一数据源）
/// @param _id       关卡 id
/// @param _is_first true = 首通 / false = 重复通关
/// @return struct {silver, gold_medal, coins}；非跨服关卡返回 undefined
/// 数值来源：
///   古堡 ancient_castle_N —— 项目原有硬编码档位，本次不动
///   天空 nightmare_sky_N  —— 用户 2026-11-04 的表「天空8~天空15」（按星级门槛排，正好是关卡 0~7）
///                           注：该表只有银/金两档，金币沿用古堡同档，待补
///   灼热地域 zhuore_N     —— 用户 2026-11-05 的两张表「首通 / 重复」，
///                           下标 0~7 对应 8 星炼狱之始 ~ 15 星炼狱之末；
///                           该表同样只有银/金，金币沿用古堡同档
///   水火之间 shuihuo_N / 巫毒研究所 wudu_N —— 用户 2026-11-14 的两张表「首通 / 首通后」，
///                           下标 0~7 对应 水火8~15 / 巫毒8~15（按星级门槛排，正好是关卡 0~7）
function cross_server_reward(_id, _is_first){
    var _i = cross_server_level_index(_id);
    if (_i < 0) return undefined;
    var _k = min(_i, 7);

    if (string_pos("zhuore_", _id) == 1){
        if (_is_first){
            var _s5 = [490, 670, 820, 915, 980, 945, 735, 525];
            var _g5 = [126, 198, 253, 331, 392, 553, 889, 1225];
            var _c5 = [60000, 84000, 104000, 129000, 140000, 160000, 190000, 220000];
            return { silver: _s5[_k], gold_medal: _g5[_k], coins: _c5[_k] };
        }
        var _s6 = [147, 201, 245, 275, 293, 283, 221, 157];
        var _g6 = [37, 59, 75, 99, 117, 165, 267, 367];
        var _c6 = [30000, 42000, 52000, 64500, 70000, 80000, 95000, 110000];
        return { silver: _s6[_k], gold_medal: _g6[_k], coins: _c6[_k] };
    }

    if (string_pos("nightmare_sky_", _id) == 1){
        if (_is_first){
            var _s1 = [420, 585, 690, 795, 840, 810, 630, 450];
            var _g1 = [108, 159, 216, 273, 336, 474, 762, 1050];
            var _c1 = [60000, 84000, 104000, 129000, 140000, 160000, 190000, 220000];
            return { silver: _s1[_k], gold_medal: _g1[_k], coins: _c1[_k] };
        }
        var _s2 = [125, 175, 207, 239, 251, 243, 189, 135];
        var _g2 = [33, 47, 65, 81, 101, 143, 229, 315];
        var _c2 = [30000, 42000, 52000, 64500, 70000, 80000, 95000, 110000];
        return { silver: _s2[_k], gold_medal: _g2[_k], coins: _c2[_k] };
    }

    if (string_pos("shuihuo_", _id) == 1){
        if (_is_first){
            var _s7 = [560, 780, 920, 1060, 1120, 1080, 840, 600];
            var _g7 = [144, 212, 288, 364, 448, 632, 1016, 1400];
            var _c7 = [96000, 136000, 168000, 200000, 224000, 256000, 304000, 352000];
            return { silver: _s7[_k], gold_medal: _g7[_k], coins: _c7[_k] };
        }
        var _s8 = [167, 233, 275, 317, 335, 323, 251, 179];
        var _g8 = [43, 63, 87, 109, 135, 189, 305, 419];
        var _c8 = [48000, 68000, 84000, 100000, 112000, 128000, 152000, 176000];
        return { silver: _s8[_k], gold_medal: _g8[_k], coins: _c8[_k] };
    }

    if (string_pos("wudu_", _id) == 1){
        if (_is_first){
            var _s9 = [630, 890, 1025, 1205, 1260, 1215, 945, 675];
            var _g9 = [162, 251, 325, 397, 504, 711, 1143, 1575];
            var _c9 = [108000, 157000, 188000, 224000, 252000, 288000, 342000, 396000];
            return { silver: _s9[_k], gold_medal: _g9[_k], coins: _c9[_k] };
        }
        var _s10 = [189, 267, 307, 361, 377, 365, 283, 203];
        var _g10 = [49, 75, 97, 119, 151, 213, 343, 473];
        var _c10 = [54000, 78500, 94000, 112000, 126000, 144000, 171000, 198000];
        return { silver: _s10[_k], gold_medal: _g10[_k], coins: _c10[_k] };
    }

    if (_is_first){
        var _s3 = [350, 400, 181, 240, 280, 395, 635, 875];
        var _g3 = [90, 120, 181, 240, 280, 395, 635, 875];
        var _c3 = [60000, 84000, 104000, 129000, 140000, 160000, 190000, 220000];
        return { silver: _s3[_k], gold_medal: _g3[_k], coins: _c3[_k] };
    }
    var _s4 = [105, 149, 169, 203, 209, 203, 157, 113];
    var _g4 = [27, 35, 55, 71, 83, 119, 191, 263];
    var _c4 = [30000, 42000, 52000, 64500, 70000, 80000, 95000, 110000];
    return { silver: _s4[_k], gold_medal: _g4[_k], coins: _c4[_k] };
}

/// @function cross_server_reward_mult()
/// @desc 跨服关卡奖励的**入账倍率**（唯一出口，别在结算里直接乘 reward_multiplier）
///       2026-11-14 用户口径：**跨服所有关卡不再享受难度等级奖励倍率**——档位表里的
///       银徽章 / 金徽章 / 金币就是实发数，不再随 美味1 / 火山1 / 浮空2 / 星际3 / 永恒4 / 不朽7 放大。
///       只保留海克斯的「关卡奖励倍率」（达摩克里斯之剑 ×10 / 搏一搏 翻倍或减半），
///       与魔塔威望 tower_prestige_grant_mult() 同一口径；非海克斯模式恒 1.0。
function cross_server_reward_mult(){
    if (!hex_enabled()) return 1.0;
    return hex_batch2_reward_mult();
}
