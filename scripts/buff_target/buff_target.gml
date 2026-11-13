/// =====================================================================
/// buff_target —— 增幅「谁增幅谁」的唯一数据表
///   数据来源：桌面\陌路の综合数据表.xlsx 的「4.增幅」「8.喷壶」「11.直射」
///   每一档 = 完整路径 paths + 点名 ids − 排除 exclude
///   优先级：exclude > ids > paths
///   paths 按「非空层级逐层前缀比对」：空槽会被压掉，所以
///     ["产能类","主职产火","常规型"] 只命中三层都齐的卡。
/// =====================================================================

/// @func buff_channel_order()
/// @desc 网格通道的固定顺序（必须与 mod_build_buff_grid 的 types 一一对应）
///   🔴 只放「有网格」的通道。战旗马那档（zhanqima）不是网格通道，不在这里，
///      判断谁吃战旗马请直接调 buff_channel_ok(id, "zhanqima")。
function buff_channel_order()
{
    return ["thrower", "sprayer", "sprayer_coffee", "sprayer_attach",
            "five_dir", "multi_dir",
            "track_berry", "track_spice", "track_feast", "track_feast4",
            "fixed_track", "production"];
}

/// @func sprayer_attach_ids()
/// @desc 喷壶「附加档」名单：目前只有弹珠汽水；以后有新的附加类卡往这里加
function sprayer_attach_ids()
{
    return ["qishui"];
}

/// @func buff_target_data()
/// @desc 每一档的目标：完整路径 + 点名 + 排除
///   🔴 表是纯数据（不含任何分类判断），static 缓存一次即可。
///      不缓存的话，每次 buff_channel_ok 都会重建 12 档结构体 + 几十个数组；
///      而战旗马是「每帧 × 每张卡」调一次，那样会白吃大量性能。
function buff_target_data()
{
    static _cache = undefined;
    if (is_struct(_cache)) return _cache;

    _cache = {
        // 投掷档：官方 4.增幅 r51「此类卡还可增幅[大地女神&导弹蛇&生煎锅类]」
        //   导弹蛇 / 生煎锅 本工程没有，只有大地女神要点名
        thrower: {
            paths: [["投掷类"]],
            ids: ["gaia"],
            exclude: []
        },
        // 旋喷档：旋转喷壶类 7 张 + 官方 r114 名单里分类却在追踪类的 3 张
        //   ⚠️ 这 3 张并进来之后和旋转喷壶类完全同待遇（含榨汁机）
        sprayer: {
            paths: [["喷壶类", "旋转喷壶类"]],
            ids: ["jingangma", "hongliukaochuan", "hufa_god"],
            exclude: []
        },
        // 咖啡档：官方 r112 / r113「本行[咖啡喷壶类]」—— 只有魔杖蛇 / 海洋写，写本行整行
        sprayer_coffee: {
            paths: [["喷壶类", "咖啡喷壶类"]],
            ids: [],
            exclude: []
        },
        // 附加档：官方 r112「[附加类] 5×5」/ r113「5×1[附加类]」，名单见 sprayer_attach_ids()
        sprayer_attach: {
            paths: [],
            ids: sprayer_attach_ids(),
            exclude: []
        },
        // 五向档：官方 4.增幅 C99 的五向名单 → 分类里「多向类-五向类」那一层
        //   鱿鱼 / 牛油果没有这一层，天然不吃
        five_dir: {
            paths: [["多向类", "五向类"]],
            ids: [],
            exclude: []
        },
        // 多向档：丰饶神三转追加 [多向类]；牛油果点名排除（用户口径：它不吃丰饶神）
        multi_dir: {
            paths: [["多向类"]],
            ids: [],
            exclude: ["niuyouguo"]
        },
        // 追踪三档（官方 r76~r80）：有轨迹追踪 / 无轨迹追踪 都在「追踪类」第二层
        track_berry: {
            paths: [["追踪类", "有轨迹追踪"]],
            ids: ["cold_drew"],
            exclude: []
        },
        track_spice: {
            paths: [["追踪类", "有轨迹追踪"]],
            // 大地女神：官方 12.炸弹1 r27「可被投掷增幅 & 香料虎 & 宴飨女神」
            ids: ["huojianzhu", "gaia"],
            exclude: []
        },
        track_feast: {
            paths: [["追踪类", "有轨迹追踪"]],
            ids: ["huojianzhu", "gaia", "yufengma", "galaxy_horse"],
            exclude: []
        },
        // 四转追加：无轨追踪 + 终转大力神 / 恶作剧神
        track_feast4: {
            paths: [["追踪类", "无轨迹追踪"]],
            ids: ["power_god", "joker"],
            exclude: []
        },
        // 固定轨迹档：官方 r129 名单 9 张，工程里存在的 6 张都在这一层
        fixed_track: {
            paths: [["直射类", "固定轨迹类"]],
            ids: [],
            exclude: []
        },
        // 产能档：官方 4.增幅 r135 / 5.产能 A5「主职产火·常规型」
        //   特殊型（花火龙 / 真·花火龙 / 蛇羹煲）与储能产火（烈火虎）不在名单里
        production: {
            paths: [["产能类", "主职产火", "常规型"]],
            ids: [],
            exclude: []
        },
        // ── 非网格乘区：战旗马 ────────────────────────────────────────
        //   官方写「增幅所有卡片」，本工程按 8 个攻击大分类收窄（2026-11-13 用户口径，战旗马是特意改的）。
        //   🔴 它不在 buff_channel_order 里：不是网格通道，只是借这张表管「谁吃战旗马」，
        //      免得再在 get_zhanqima_buff_multiplier() 里手抄一份大分类名。
        zhanqima: {
            paths: [["直射类"], ["投掷类"], ["多向类"], ["专业防空类"],
                    ["喷壶类"], ["追踪类"], ["非远程类"], ["灰烬类"]],
            ids: [],
            exclude: ["zhanqima"]
        }
    };

    return _cache;
}

/// @func buff_channel_ok(_id, _ch)
/// @desc 这张卡吃不吃这一档
function buff_channel_ok(_id, _ch)
{
    if (_id == "" || _id == "player") return false;

    var _t = buff_target_data();
    if (!variable_struct_exists(_t, _ch)) return false;

    var _row = _t[$ _ch];

    // 1) 排除最优先（点名排除）
    if (array_length(_row.exclude) > 0 && array_contains(_row.exclude, _id))
        return false;

    // 2) 点名（官方名单里分类对不上的少数卡）—— 不受 paths 影响
    if (array_length(_row.ids) > 0 && array_contains(_row.ids, _id))
        return true;

    // 3) 完整路径（严格：逐层比对，不会被别处同名的一层命中）
    if (variable_struct_exists(_row, "paths"))
    {
        for (var i = 0; i < array_length(_row.paths); i++)
        {
            if (card_in_category_path(_id, _row.paths[i])) return true;
        }
    }

    return false;
}

/// @func card_buff_channels(_id)
/// @desc 这张卡能吃的全部通道（按 buff_channel_order 排序，结果缓存）
function card_buff_channels(_id)
{
    if (!variable_global_exists("buff_channel_cache"))
        global.buff_channel_cache = ds_map_create();

    if (ds_map_exists(global.buff_channel_cache, _id))
        return ds_map_find_value(global.buff_channel_cache, _id);

    var _order = buff_channel_order();
    var _out = [];
    for (var i = 0; i < array_length(_order); i++)
    {
        if (buff_channel_ok(_id, _order[i])) array_push(_out, _order[i]);
    }

    ds_map_set(global.buff_channel_cache, _id, _out);
    return _out;
}

/// @func buff_channels_has(_id, _ch)
function buff_channels_has(_id, _ch)
{
    return array_contains(card_buff_channels(_id), _ch);
}

/// @func buff_channels_has_any(_id, _chs)
/// @desc 这几条通道里只要有一条吃就算吃（喷壶三档合并判断用）
function buff_channels_has_any(_id, _chs)
{
    var _c = card_buff_channels(_id);
    for (var i = 0; i < array_length(_chs); i++)
    {
        if (array_contains(_c, _chs[i])) return true;
    }
    return false;
}

/// @func buff_channel_multiplier(_pid, _ch, _c, _r)
/// @desc 单通道在该格的倍率（含叠加网格 / 极光）
///   三档各自一张网格，读哪张由 card_buff_channels 决定
function buff_channel_multiplier(_pid, _ch, _c, _r)
{
    if (!variable_global_exists("buff_grid")) return 1;

    var _g = ds_map_find_value(global.buff_grid, _ch);
    if (_g == undefined) return 1;

    var _v = _g[_c][_r];

    var _sg = ds_map_find_value(global.buff_stack_grid, _ch);
    if (_sg != undefined) _v = max(_v, _sg[_c][_r]);

    // 极光（aurora）走独立查询，原本只在 thrower 档里合进来
    if (_ch == "thrower") _v = max(_v, get_aurora_buff(_c, _r));

    return _v;
}

/// @func buff_channels_multiplier(_pid, _c, _r)
/// @desc 该卡所有可吃通道取最大（官服「同行多个取最大」）
function buff_channels_multiplier(_pid, _c, _r)
{
    var _chs = card_buff_channels(_pid);
    var _m = 1;
    for (var i = 0; i < array_length(_chs); i++)
    {
        _m = max(_m, buff_channel_multiplier(_pid, _chs[i], _c, _r));
    }
    return _m;
}
