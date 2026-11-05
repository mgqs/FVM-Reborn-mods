/// 跨服章节关卡 id → 关卡序号（0 起）；非跨服关卡返回 -1
/// 约定：ancient_castle_N / nightmare_sky_N / zhuore_N 都属于跨服章节，奖励走 cross_server_reward()。
/// 项目里原本有 9 处写死 string_pos("ancient_castle_", id) == 1，新增跨服章节一律走这里，
/// 不要再复制前缀判断（否则奖励会落到普通关分支去读 rewards[].gold 而报错）。
function cross_server_level_index(_id){
    var _prefixes = ["ancient_castle_", "nightmare_sky_", "zhuore_"];
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
