/// =====================================================================
/// card_buff_category —— 卡片分类独立模块
/// 数据来源：docs/卡片分类.md（175 张卡；三级分类：大分类 / 小分类 / 子分类）
/// 职责：只提供「分类数据 + 查询 API」，不直接参与战斗逻辑。
///       增幅系统（mod_buff_init / 战斗管理器 / 炎焱兔 / 音盒马）按需消费本模块。
/// 维护：数据由 docs/卡片分类.md 解析生成，分类结构调整后需同步刷新数据表。
/// =====================================================================

/// @func card_category_init()
/// @desc 建立全局分类注册表与反向索引（每局启动调用一次）
function card_category_init()
{
    global.card_category_map = ds_map_create();    // card_id -> {major, minor, sub}
    global.card_category_index = ds_map_create();  // 分类名 -> ds_list(card_id)

    var _data = card_category_data();
    for (var i = 0; i < array_length(_data); i++)
    {
        var _row = _data[i];
        var _id = _row[0];
        var _major = _row[1];
        var _minor = _row[2];
        var _sub = _row[3];

        ds_map_set(global.card_category_map, _id, { major: _major, minor: _minor, sub: _sub });

        card_category_index_add(_major, _id);
        card_category_index_add(_minor, _id);
        if (_sub != "")
            card_category_index_add(_sub, _id);
    }

    show_debug_message("卡片分类模块初始化完成：" + string(ds_map_size(global.card_category_map)) + " 张卡");
}

/// @func card_category_data()
/// @desc 返回 [{card_id, 大分类, 小分类, 子分类}] 原始数据
function card_category_data()
{
    return [
        ["double_water_pipe", "直射类", "水管类", ""],
        ["tiancheng", "直射类", "水管类", ""],
        ["war_god", "直射类", "水管类", ""],
        ["triple_wine_rack", "直射类", "三线类", ""],
        ["sheshou", "直射类", "三线类", ""],
        ["love_god", "直射类", "三线类", ""],
        ["xiao_long_bao", "直射类", "传统直线类", ""],
        ["ice_long_bao", "直射类", "传统直线类", ""],
        ["double_long_bao", "直射类", "传统直线类", ""],
        ["double_ice_long_bao", "直射类", "传统直线类", ""],
        ["triple_long_bao", "直射类", "传统直线类", ""],
        ["triple_ice_long_bao", "直射类", "传统直线类", ""],
        ["coffee_cup", "直射类", "传统直线类", ""],
        ["water_tea_cup", "直射类", "传统直线类", ""],
        ["corn_shooter", "直射类", "传统直线类", ""],
        ["gatlin_long_bao", "直射类", "传统直线类", ""],
        ["gatlin_ice_long_bao", "直射类", "传统直线类", ""],
        ["king_long_bao", "直射类", "传统直线类", ""],
        ["king_triple_long_bao", "直射类", "传统直线类", ""],
        ["fenjima", "直射类", "特殊直线类", ""],
        ["double_blade_snake", "直射类", "直线穿透类", ""],
        ["yufengma", "直射类", "直线穿透类", ""],
        ["laipishe", "直射类", "固定轨迹类", ""],
        ["pizza_oven", "直射类", "固定轨迹类", ""],
        ["gongjiang_god", "直射类", "固定轨迹类", ""],
        ["huagao", "直射类", "固定轨迹类", ""],
        ["yanhuangma", "直射类", "固定轨迹类", ""],
        ["shennong_god", "直射类", "固定轨迹类", ""],
        ["tar_sprayer", "直射类", "过火穿透类", ""],
        ["odin", "直射类", "过火穿透类", ""],
        ["houyi_god", "直射类", "过火穿透类", ""],
        ["spoon_rabbit", "投掷类", "多线投手", ""],
        ["ymir", "投掷类", "多线投手", ""],
        ["sugar_ball_pult", "投掷类", "多线投手", ""],
        ["egg_boiler_pult", "投掷类", "单线投手", ""],
        ["ice_egg_boiler_pult", "投掷类", "单线投手", ""],
        ["ronghedan_god", "投掷类", "单线投手", ""],
        ["grilled_lizard_pult", "投掷类", "单线投手", ""],
        ["shuangyu", "投掷类", "单线投手", ""],
        ["thor", "投掷类", "单线投手", ""],
        ["salad_pult", "投掷类", "单线投手", ""],
        ["chocolate_pult", "投掷类", "单线投手", ""],
        ["stinky_tofu_pult", "投掷类", "单线投手", ""],
        ["pan_fried_bun", "投掷类", "灼烧投手", ""],
        ["zhurong", "投掷类", "灼烧投手", ""],
        ["lizi_god", "投掷类", "灼烧投手", ""],
        ["coal_starfish", "多向类", "海星类", ""],
        ["ronghehaixing", "多向类", "海星类", ""],
        ["ghost_god", "多向类", "海星类", ""],
        ["starrabbit", "多向类", "类海星类", ""],
        ["rig", "多向类", "类海星类", ""],
        ["youyu_god", "多向类", "类海星类", ""],
        ["niuyouguo", "多向类", "三向类", ""],
        ["brazier", "增幅类", "子弹增幅", "平射增幅"],
        ["ronghehuopen", "增幅类", "子弹增幅", "平射增幅"],
        ["ronghesanxian", "直射类", "三线类", ""],
        ["jinniu", "增幅类", "子弹增幅", "平射增幅"],
        ["fire_god", "增幅类", "子弹增幅", "平射增幅"],
        ["blueberry_tower", "增幅类", "子弹增幅", "投掷增幅"],
        ["zhuzhujiaqiang", "增幅类", "子弹增幅", "投掷增幅"],
        ["fruit_tart", "增幅类", "子弹增幅", "投掷增幅"],
        ["aurora", "增幅类", "子弹增幅", "投掷增幅"],
        ["berry_dessert", "增幅类", "名单类增幅", "追踪增幅"],
        ["xiangshui_god", "增幅类", "名单类增幅", "追踪增幅"],
        ["fengrao_god", "增幅类", "名单类增幅", "五向增幅"],
        ["hspeed_juicer", "增幅类", "名单类增幅", "喷壶增幅"],
        ["mozhang", "增幅类", "名单类增幅", "喷壶增幅"],
        ["haiyang_god", "增幅类", "名单类增幅", "喷壶增幅"],
        ["yinhema", "增幅类", "名单类增幅", "固定轨迹增幅"],
        ["fushengcha", "增幅类", "名单类增幅", "固定轨迹增幅"],
        ["mixian", "辅助类", "地形类", ""],
        ["yanyantu", "增幅类", "名单类增幅", "产能增幅"],
        ["zhanqima", "增幅类", "全能增幅", ""],
        ["small_fire", "产能类", "主职产火", "常规型"],
        ["goblet_lamp", "产能类", "主职产火", "常规型"],
        ["large_fire", "产能类", "主职产火", "常规型"],
        ["shuangzi", "产能类", "主职产火", "常规型"],
        ["warm_birds", "产能类", "主职产火", "常规型"],
        ["sun_god", "产能类", "主职产火", "常规型"],
        ["firework_dragon", "产能类", "主职产火", "特殊型"],
        ["firework_dragon_real", "产能类", "主职产火", "特殊型"],
        ["shegengbao", "产能类", "主职产火", "特殊型"],
        ["liehuohu", "产能类", "储能产火", ""],
        ["cherry_pudding", "辅助类", "反弹类", ""],
        ["water_god", "辅助类", "反弹类", ""],
        ["wooden_plate", "辅助类", "承载类", ""],
        ["lingrong_god", "辅助类", "承载类", ""],
        ["cotton_candy", "辅助类", "承载类", ""],
        ["soda_bubble", "辅助类", "承载类", ""],
        ["ice_cream", "辅助类", "冷却类", ""],
        ["time_god", "辅助类", "冷却类", ""],
        ["magic_chicken", "辅助类", "种卡类", ""],
        ["baibianshe", "辅助类", "种卡类", ""],
        ["brahma", "辅助类", "种卡类", ""],
        ["wanpilong", "辅助类", "种卡类", ""],
        ["anranxiaohunfan", "辅助类", "种卡类", ""],
        ["xingqiongma", "辅助类", "种卡类", ""],
        ["lihe", "辅助类", "种卡类", ""],
        ["chongsheng_god", "辅助类", "种卡类", ""],
        ["clotho", "辅助类", "变星类", ""],
        ["oil_lamp", "辅助类", "地形类", ""],
        ["yinghuoshe", "辅助类", "地形类", ""],
        ["ventilation_fan", "辅助类", "地形类", ""],
        ["baobaoji", "辅助类", "地形类", ""],
        ["xuanfengniu", "辅助类", "地形类", ""],
        ["wooden_cork", "辅助类", "地形类", ""],
        ["zhiyumiao", "辅助类", "增益类", ""],
        ["12yinliao", "辅助类", "增益类", ""],
        ["coffee_grounds", "辅助类", "增益类", ""],
        ["kuileima", "辅助类", "伤害转移类", ""],
        ["cat_chest", "辅助类", "怪物转移类", ""],
        ["cat_box", "辅助类", "怪物转移类", ""],
        ["nizhuanniu", "辅助类", "怪物转移类", ""],
        ["tang_hu_lu", "专业防空类", "纯对空类", ""],
        ["power_god", "专业防空类", "纯对空类", ""],
        ["sausage", "专业防空类", "陆空兼备类", ""],
        ["hotdog_cannon", "专业防空类", "陆空兼备类", ""],
        ["donut", "专业防空类", "陆空兼备类", ""],
        ["joker", "专业防空类", "陆空兼备类", ""],
        ["shuanggu", "专业防空类", "陆空兼备类", ""],
        ["rongheshuanggu", "专业防空类", "陆空兼备类", ""],
        ["coffee_pot", "喷壶类", "直线喷壶类", ""],
        ["oden_pot", "喷壶类", "直线喷壶类", ""],
        ["beef_hotpot", "喷壶类", "直线喷壶类", ""],
        ["spicy_pot", "喷壶类", "直线喷壶类", ""],
        ["sheng_huo", "喷壶类", "直线喷壶类", ""],
        ["rotating_coffee_pot", "喷壶类", "旋转喷壶类", ""],
        ["shizi", "喷壶类", "旋转喷壶类", ""],
        ["wugushe", "喷壶类", "旋转喷壶类", ""],
        ["poseidon", "喷壶类", "旋转喷壶类", ""],
        ["hongliukaochuan", "喷壶类", "旋转喷壶类", ""],
        ["hufa_god", "喷壶类", "旋转喷壶类", ""],
        ["takoyaki", "追踪类", "飞镖追踪", ""],
        ["juxie", "追踪类", "飞镖追踪", ""],
        ["moon_god", "追踪类", "飞镖追踪", ""],
        ["athena", "追踪类", "群轰追踪", ""],
        ["curry_lobster_cannon", "追踪类", "群轰追踪", ""],
        ["zeus", "追踪类", "群轰追踪", ""],
        ["ice_god", "追踪类", "散点追踪", ""],
        ["cold_drew", "追踪类", "散点追踪", ""],
        ["xiandima", "追踪类", "集火追踪", ""],
        ["guiyuanma", "追踪类", "特殊追踪", ""],
        ["hamburger", "非远程类", "吞噬类", ""],
        ["hundun_god", "非远程类", "吞噬类", ""],
        ["lightning_baguette", "非远程类", "连携类", ""],
        ["xinjiang_fried_noodles", "非远程类", "近战类", ""],
        ["iron_fishbone", "非远程类", "鱼刺类", ""],
        ["fishbone", "非远程类", "鱼刺类", ""],
        ["chocolate_cannon", "灰烬类", "轰炸类", ""],
        ["ronghedapao", "灰烬类", "轰炸类", ""],
        ["ronghekafei", "直射类", "传统直线类", ""],
        ["gaia", "灰烬类", "轰炸类", ""],
        ["durian", "灰烬类", "持续类", ""],
        ["dragon_fruit", "灰烬类", "持续类", ""],
        ["heian_god", "灰烬类", "持续类", ""],
        ["guangming_god", "灰烬类", "持续类", ""],
        ["mojie", "灰烬类", "持续类", ""],
        ["chunsun", "灰烬类", "持续类", ""],
        ["coke_bomb", "灰烬类", "瞬发类", "爆炸类"],
        ["kettle_bomb", "灰烬类", "瞬发类", "爆炸类"],
        ["wine_bottle_bomb", "灰烬类", "瞬发类", "爆炸类"],
        ["whisky_bomb", "灰烬类", "瞬发类", "爆炸类"],
        ["panduola_god", "灰烬类", "瞬发类", "爆炸类"],
        ["rabbit_lantern", "灰烬类", "瞬发类", "爆炸类"],
        ["delicacy_firework", "灰烬类", "瞬发类", "爆炸类"],
        ["ice_bucket_bomb", "灰烬类", "瞬发类", "爆炸类"],
        ["aquarius_elve", "灰烬类", "瞬发类", "爆炸类"],
        ["pufferfish", "灰烬类", "瞬发类", "爆炸类"],
        ["baiyang", "灰烬类", "瞬发类", "冲撞类"],
        ["bull_firework", "灰烬类", "瞬发类", "冲撞类"],
        ["save_god", "灰烬类", "瞬发类", "冲撞类"],
        ["yeziguo", "灰烬类", "触发类", "碾压类"],
        ["qingse_shishi", "灰烬类", "触发类", "碾压类"],
        ["flour_sack", "灰烬类", "触发类", "碾压类"],
        ["mouse_clip", "灰烬类", "触发类", "常规类"],
        ["steel_wool", "灰烬类", "触发类", "常规类"],
        ["skewer_bomb", "灰烬类", "触发类", "常规类"],
        ["chili_powder", "灰烬类", "触发类", "常规类"],
        ["dandantu", "灰烬类", "触发类", "常规类"],
        ["toast_bread", "防御类", "面包类", ""],
        ["chocolate_bread", "防御类", "面包类", ""],
        ["pineapple_explosive_bread", "防御类", "面包类", ""],
        ["horseshoe_crab_bread", "防御类", "面包类", ""],
        ["melon_shield", "防御类", "护罩类", ""],
        ["hera", "防御类", "护罩类", ""],
        ["chunv", "防御类", "护罩类", ""]
    ];
}

/// @func card_category_index_add(_name, _id)
/// @desc 向反向索引追加一条（内部使用）
function card_category_index_add(_name, _id)
{
    if (!ds_map_exists(global.card_category_index, _name))
        ds_map_set(global.card_category_index, _name, ds_list_create());

    ds_list_add(ds_map_find_value(global.card_category_index, _name), _id);
}

/// @func card_get_category(_id)
/// @desc card_id -> {major, minor, sub}；未注册返回 undefined
function card_get_category(_id)
{
    if (!variable_global_exists("card_category_map"))
        return undefined;
    if (!ds_map_exists(global.card_category_map, _id))
        return undefined;

    return ds_map_find_value(global.card_category_map, _id);
}

/// @func card_get_major(_id)
/// @desc 取卡片大分类；未注册返回 ""
function card_get_major(_id)
{
    var _c = card_get_category(_id);
    return (_c == undefined) ? "" : _c.major;
}

/// @func card_get_minor(_id)
/// @desc 取卡片小分类；未注册返回 ""
function card_get_minor(_id)
{
    var _c = card_get_category(_id);
    return (_c == undefined) ? "" : _c.minor;
}

/// @func card_get_sub(_id)
/// @desc 取卡片子分类；无子分类或未注册返回 ""
function card_get_sub(_id)
{
    var _c = card_get_category(_id);
    return (_c == undefined) ? "" : _c.sub;
}

/// @func card_in_category(_id, _name)
/// @desc 卡片的任一级分类名是否等于 _name
function card_in_category(_id, _name)
{
    var _c = card_get_category(_id);
    if (_c == undefined)
        return false;

    return (_c.major == _name || _c.minor == _name || _c.sub == _name);
}

/// @func get_cards_in_category(_name)
/// @desc 返回该分类名下的 card_id 列表（ds_list）；不存在返回 undefined
function get_cards_in_category(_name)
{
    if (!variable_global_exists("card_category_index"))
        return undefined;
    if (!ds_map_exists(global.card_category_index, _name))
        return undefined;

    return ds_map_find_value(global.card_category_index, _name);
}

/// @func card_category_buff_group_name(_group)
/// @desc 增幅分组键 -> 分类名（分组的唯一映射来源）
function card_category_buff_group_name(_group)
{
    switch (_group)
    {
        case "thrower":  return "投掷类";
        case "tracker":  return "追踪类";
        case "five_dir": return "多向类";
        case "sprayer":  return "喷壶类";
    }

    return "";
}

/// @func mod_apply_category_buff_map()
/// @desc 按分类重建 global.plant_buff_map 的增幅分组，覆盖手工维护的旧分组
///       仅覆盖这 4 个「可网格化」分组；固定轨迹 / 产能 / 全体 由各自对象实现。
/// @return {real} 写入的卡片条目数
function mod_apply_category_buff_map()
{
    if (!variable_global_exists("card_category_index"))
        return 0;

    var _groups = ["thrower", "tracker", "five_dir", "sprayer"];
    var _total = 0;

    for (var g = 0; g < array_length(_groups); g++)
    {
        var _group = _groups[g];
        var _list = get_cards_in_category(card_category_buff_group_name(_group));

        if (_list == undefined)
            continue;

        for (var i = 0; i < ds_list_size(_list); i++)
        {
            var _card_id = ds_list_find_value(_list, i);
            var _allowed = false;
            switch (_group)
            {
                case "thrower": _allowed = card_in_category(_card_id, "投掷类") || _card_id == "gaia"; break;
                case "tracker": _allowed = _card_id == "guiyuanma" || _card_id == "takoyaki" || _card_id == "juxie" || _card_id == "moon_god" || _card_id == "yufengma" || _card_id == "gaia"; break;
                // niuyouguo（邪恶牛油果）：分类上是多向类，但不吃多向类拐 —— 只吃战旗马这类全体增幅
                case "five_dir": _allowed = card_in_category(_card_id, "多向类") && _card_id != "niuyouguo"; break;
                case "sprayer": _allowed = card_in_category(_card_id, "旋转喷壶类") || card_in_category(_card_id, "直线喷壶类") || _card_id == "hongliukaochuan" || _card_id == "hufa_god"; break;
            }
            if (_allowed)
            {
                ds_map_set(global.plant_buff_map, _card_id, _group);
                _total++;
            }
        }
    }

    // Cross-category targets named explicitly by the buff rules.
    ds_map_set(global.plant_buff_map, "yufengma", "tracker");
    var _advanced_tracker = get_cards_in_category("群轰追踪");
    for (var i = 0; i < ds_list_size(_advanced_tracker); i++)
        ds_map_set(global.plant_buff_map, ds_list_find_value(_advanced_tracker, i), "tracker_advanced");
    _advanced_tracker = get_cards_in_category("散点追踪");
    for (var i = 0; i < ds_list_size(_advanced_tracker); i++)
        ds_map_set(global.plant_buff_map, ds_list_find_value(_advanced_tracker, i), "tracker_advanced");

    // 冷萃机（散点追踪）同时吃两档追踪增幅：
    //   主类型 tracker_berry    = 莓果点心（apply_buff 里按 plant_id 单独写的那一格）
    //   次类型 tracker_advanced = 宴飨女神（散点追踪整体那一档），两者取较高倍率
    // ⚠️ 必须写在上面「散点追踪」循环之后：那条循环会把 cold_drew 覆盖成 tracker_advanced，
    //    导致莓果点心的格子写了却没人读（2026-10-22 修复）
    ds_map_set(global.plant_buff_map, "cold_drew", "tracker_berry");
    ds_map_set(global.plant_buff_map_2, "cold_drew", "tracker_advanced");
    ds_map_set(global.plant_buff_map, "power_god", "tracker_advanced");
    ds_map_set(global.plant_buff_map, "joker", "tracker_advanced");
    ds_map_set(global.plant_buff_map, "hongliukaochuan", "sprayer");
    ds_map_set(global.plant_buff_map, "hufa_god", "sprayer");
    ds_map_set(global.plant_buff_map, "gaia", "thrower");
    ds_map_set(global.plant_buff_map_2, "gaia", "tracker");

    show_debug_message("增幅分组按分类重建：" + string(_total) + " 条");
    return _total;
}
