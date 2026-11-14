/// =====================================================================
/// card_buff_category —— 卡片分类独立模块
/// 数据来源：docs/卡片分类.md（175 张卡；三级分类：大分类 / 小分类 / 子分类）
/// 职责：只提供「分类数据 + 查询 API」，不直接参与战斗逻辑。
///       增幅系统（scripts/buff_target / 战斗管理器 / 炎焱兔 / 音盒马 / 星轨神）按需消费本模块。
/// 维护：数据由 docs/卡片分类.md 解析生成，分类结构调整后需同步刷新数据表。
/// =====================================================================

/// @func card_category_init()
/// @desc 建立全局分类注册表与反向索引（每局启动调用一次）
function card_category_init()
{
    // 分类数据是增幅通道的唯一依据，重建时清掉通道缓存（2026-11-14）
    if (variable_global_exists("buff_channel_cache") && ds_exists(global.buff_channel_cache, ds_type_map))
        ds_map_clear(global.buff_channel_cache);

    global.card_category_map = ds_map_create();    // card_id -> {major, minor, sub, levels}
    global.card_category_index = ds_map_create();  // 分类名 -> ds_list(card_id)

    var _data = card_category_data();
    for (var i = 0; i < array_length(_data); i++)
    {
        var _row = _data[i];
        var _id = _row[0];

        // 第 0 位是 id，后面全是层级名：长度随意、允许空串（空串跳过）
        var _levels = [];
        for (var k = 1; k < array_length(_row); k++)
        {
            if (_row[k] == "") continue;
            array_push(_levels, _row[k]);
            card_category_index_add(_row[k], _id);
        }

        // 兼容字段：前 3 个非空层（旧代码读 major / minor / sub）
        var _major = array_length(_levels) > 0 ? _levels[0] : "";
        var _minor = array_length(_levels) > 1 ? _levels[1] : "";
        var _sub   = array_length(_levels) > 2 ? _levels[2] : "";

        ds_map_set(global.card_category_map, _id,
            { major: _major, minor: _minor, sub: _sub, levels: _levels });

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
        ["double_blade_snake", "直射类", "A型穿透类", ""],
        ["yufengma", "直射类", "A型穿透类", ""],
        ["yuansushe", "直射类", "A型穿透类", ""],   // 2026-11-13 新卡：元素蛇（四色循环弹）
        ["laipishe", "直射类", "固定轨迹类", ""],
        ["pizza_oven", "直射类", "固定轨迹类", ""],
        ["gongjiang_god", "直射类", "固定轨迹类", ""],
        ["huagao", "直射类", "固定轨迹类", ""],
        ["yanhuangma", "直射类", "固定轨迹类", ""],
        ["shennong_god", "直射类", "固定轨迹类", ""],
        ["tar_sprayer", "直射类", "B型穿透类", ""],
        ["odin", "直射类", "B型穿透类", ""],
        ["houyi_god", "直射类", "B型穿透类", ""],
        ["spoon_rabbit", "投掷类", "多线投手", "三线投手"],
        ["ymir", "投掷类", "多线投手", "三线投手"],
        ["sugar_ball_pult", "投掷类", "多线投手", "追踪投手"],
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
        ["coal_starfish", "多向类", "五向类", "海星类"],
        ["ronghehaixing", "多向类", "五向类", "海星类"],
        ["ghost_god", "多向类", "五向类", "海星类"],
        ["starrabbit", "多向类", "五向类", "类海星类", "扇形类"],
        ["nut_frier", "多向类", "五向类", "类海星类", "扇形类"],   // 官方 3.海星&竞技 A.扇形类
        ["rig", "多向类", "五向类", "类海星类", "扇形类"],
        ["youyu_god", "多向类", "类海星类", "章鱼类"],
        ["niuyouguo", "多向类", "类海星类", "扇形类"],
        ["brazier", "增幅类", "子弹类增幅", "平射增幅"],
        ["ronghehuopen", "增幅类", "子弹类增幅", "平射增幅"],
        ["ronghesanxian", "直射类", "三线类", ""],
        ["jinniu", "增幅类", "子弹类增幅", "平射增幅"],
        ["fire_god", "增幅类", "子弹类增幅", "平射增幅"],
        ["nengliangmiao", "增幅类", "子弹类增幅", "平射增幅"],
        ["blueberry_tower", "增幅类", "子弹类增幅", "投掷增幅"],
        ["zhuzhujiaqiang", "增幅类", "子弹类增幅", "投掷增幅"],
        ["fruit_tart", "增幅类", "子弹类增幅", "投掷增幅"],
        ["aurora", "增幅类", "子弹类增幅", "投掷增幅"],
        ["berry_dessert", "增幅类", "名单类增幅", "追踪增幅"],
        ["xiangshui_god", "增幅类", "名单类增幅", "追踪增幅"],
        ["fengrao_god", "增幅类", "名单类增幅", "五向增幅"],
        ["wuxingshe", "增幅类", "名单类增幅", "五向增幅"],
        ["hspeed_juicer", "增幅类", "名单类增幅", "喷壶增幅"],
        ["mozhang", "增幅类", "名单类增幅", "喷壶增幅"],
        ["haiyang_god", "增幅类", "名单类增幅", "喷壶增幅"],
        ["yinhema", "增幅类", "名单类增幅", "固定轨迹增幅"],
        ["fushengcha", "增幅类", "名单类增幅", "固定轨迹增幅"],
        ["xinggui_god", "增幅类", "名单类增幅", "固定轨迹增幅"],   // 2026-11-13 新卡：星轨神·阿斯特
        ["mixian", "辅助类", "场地类", ""],
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
        ["maiya", "辅助类", "承载类", ""],
        ["ice_cream", "辅助类", "冷却类", ""],
        ["time_god", "辅助类", "冷却类", ""],
        ["magic_chicken", "辅助类", "复制类", ""],
        ["baibianshe", "辅助类", "复制类", ""],
        ["brahma", "辅助类", "复制类", ""],
        ["wanpilong", "辅助类", "复制类", ""],
        ["anranxiaohunfan", "辅助类", "复制类", ""],
        ["xingqiongma", "辅助类", "复制类", ""],
        ["lihe", "辅助类", "复制类", ""],
        ["chongsheng_god", "辅助类", "复制类", ""],
        ["clotho", "辅助类", "变星类", ""],
        ["oil_lamp", "辅助类", "场地类", ""],
        ["yinghuoshe", "辅助类", "场地类", ""],
        ["ventilation_fan", "辅助类", "场地类", ""],
        ["baobaoji", "辅助类", "场地类", ""],
        ["xuanfengniu", "辅助类", "场地类", ""],
        ["wooden_cork", "辅助类", "场地类", ""],
        ["guihuajiu", "防御类", "面包类", ""],
        ["mianbao", "防御类", "面包类", ""],
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
        ["coffee_pot", "喷壶类", "咖啡喷壶类", ""],
        ["oden_pot", "喷壶类", "咖啡喷壶类", ""],
        ["beef_hotpot", "喷壶类", "咖啡喷壶类", ""],
        ["spicy_pot", "喷壶类", "咖啡喷壶类", ""],
        ["sheng_huo", "喷壶类", "咖啡喷壶类", ""],
        ["rotating_coffee_pot", "喷壶类", "旋转喷壶类", ""],
        ["xuanzhuan_ronghe", "喷壶类", "旋转喷壶类", ""],
        ["shizi", "喷壶类", "旋转喷壶类", ""],
        ["wugushe", "喷壶类", "旋转喷壶类", ""],
        ["poseidon", "喷壶类", "旋转喷壶类", ""],
        ["hongliukaochuan", "追踪类", "直线追踪", ""],
        ["hufa_god", "追踪类", "直线追踪", ""],
        ["takoyaki", "追踪类", "有轨迹追踪", "飞镖追踪"],
        ["juxie", "追踪类", "有轨迹追踪", "飞镖追踪"],
        ["moon_god", "追踪类", "有轨迹追踪", "飞镖追踪"],
        ["athena", "追踪类", "无轨迹追踪", "群轰追踪"],
        ["curry_lobster_cannon", "追踪类", "无轨迹追踪", "群轰追踪"],
        ["zeus", "追踪类", "无轨迹追踪", "群轰追踪"],
        ["ice_god", "追踪类", "无轨迹追踪", "散点追踪"],
        ["cold_drew", "追踪类", "无轨迹追踪", "散点追踪"],
        ["xiandima", "追踪类", "专注追踪", ""],
        ["guiyuanma", "追踪类", "有轨迹追踪", "特殊追踪"],
        ["hamburger", "非远程类", "吞噬类", ""],
        ["hundun_god", "非远程类", "吞噬类", ""],
        ["lightning_baguette", "非远程类", "连携类", ""],
        ["xinjiang_fried_noodles", "非远程类", "近战类", "拳击类"],
        ["iron_fishbone", "非远程类", "近战类", "鱼刺类"],
        ["fishbone", "非远程类", "近战类", "鱼刺类"],
        ["sugar_roxburghii", "非远程类", "近战类", "鱼刺类"],   // 官方 10.杂项 B.鱼刺类
        ["chocolate_cannon", "灰烬类", "轰炸型", ""],
        ["galaxy_horse", "灰烬类", "轰炸型", ""],   // 2026-11-13 新卡：银河马（陨石）
        ["ronghedapao", "灰烬类", "轰炸型", ""],
        ["ronghekafei", "直射类", "传统直线类", ""],
        ["gaia", "灰烬类", "轰炸型", ""],
        ["durian", "灰烬类", "持续型", ""],
        ["dragon_fruit", "灰烬类", "持续型", ""],
        ["heian_god", "灰烬类", "持续型", ""],
        ["guangming_god", "灰烬类", "持续型", ""],
        ["mojie", "灰烬类", "持续型", ""],
        ["chunsun", "灰烬类", "持续型", ""],
        ["coke_bomb", "灰烬类", "瞬爆型", "常规型"],
        ["kettle_bomb", "灰烬类", "瞬爆型", "常规型"],
        ["wine_bottle_bomb", "灰烬类", "瞬爆型", "常规型"],
        ["whisky_bomb", "灰烬类", "瞬爆型", "常规型"],
        ["panduola_god", "灰烬类", "瞬爆型", "常规型"],
        ["rabbit_lantern", "灰烬类", "瞬爆型", "常规型"],
        ["delicacy_firework", "灰烬类", "瞬爆型", "常规型"],
        ["ice_bucket_bomb", "灰烬类", "瞬爆型", "常规型"],
        ["aquarius_elve", "灰烬类", "瞬爆型", "常规型"],
        ["pufferfish", "灰烬类", "瞬爆型", "常规型"],
        ["baiyang", "灰烬类", "瞬爆型", "冲撞型"],
        ["bull_firework", "灰烬类", "瞬爆型", "冲撞型"],
        ["save_god", "灰烬类", "瞬爆型", "冲撞型"],
        ["yeziguo", "灰烬类", "触发型", "碾压型"],
        ["qingse_shishi", "灰烬类", "触发型", "碾压型"],
        ["flour_sack", "灰烬类", "触发型", "碾压型"],
        ["mouse_clip", "灰烬类", "触发型", "常规型"],
        ["steel_wool", "灰烬类", "触发型", "常规型"],
        ["skewer_bomb", "灰烬类", "触发型", "常规型"],
        ["chili_powder", "灰烬类", "触发型", "常规型"],
        ["dandantu", "灰烬类", "触发型", "常规型"],
        ["toast_bread", "防御类", "面包类", ""],
        ["chocolate_bread", "防御类", "面包类", ""],
        ["pineapple_explosive_bread", "防御类", "面包类", ""],
        ["horseshoe_crab_bread", "防御类", "面包类", ""],
        ["melon_shield", "防御类", "护罩类", ""],
        ["hera", "防御类", "护罩类", ""],
        ["chunv", "防御类", "护罩类", ""],
        ["bbq", "直射类", "B型穿透类", ""],
        ["eightcake", "投掷类", "单线投手", ""],
        ["tangchaolizi", "投掷类", "灼烧投手", ""],
        ["zhuzhuliaoliji", "多向类", "五向类", "海星类"],
        ["budingwang", "辅助类", "反弹类", ""],
        ["caihongshe", "防御类", "护罩类", ""],
        ["meiweijishiqi", "辅助类", "冷却类", ""],
        ["dangdanghu", "投掷类", "灼烧投手", ""],
        ["dianman", "灰烬类", "持续型", ""],
        ["tanchitu", "灰烬类", "瞬爆型", "冲撞型"],
        ["tunshilong", "非远程类", "吞噬类", ""],
        ["xiangliaohu", "增幅类", "名单类增幅", "追踪增幅"],
        ["zhuanzhuanji", "喷壶类", "旋转喷壶类", ""],
        ["fashishe", "直射类", "B型穿透类", ""],
        ["fangkongmiao", "专业防空类", "纯对空类", ""],
        ["huojianzhu", "追踪类", "无轨迹追踪", "群轰追踪"],
        ["doumaobang", "灰烬类", "瞬爆型", "冲撞型"],
        ["honeytrap", "追踪类", "专注追踪", ""],
        ["huanyingshe", "投掷类", "多线投手", "追踪投手"],
        ["tianxie", "直射类", "A型穿透类", ""],
        ["shiliu_baobao_bing", "灰烬类", "瞬爆型", "常规型"],
        ["jingangma", "追踪类", "直线追踪", ""],
        ["qiedanlong", "投掷类", "多线投手", "三线投手"],
        ["qishui", "直射类", "特殊直线类", ""],
        ["sheshejiu", "辅助类", "变星类", ""],
        ["shiguangji", "辅助类", "变星类", ""],
        ["snowrabbit", "追踪类", "无轨迹追踪", "散点追踪"],
        ["tanhuanghu", "专业防空类", "陆空兼备类", ""],
        ["yuanqiniu", "喷壶类", "旋转喷壶类", ""],
        ["zhuanlonghu", "辅助类", "冷却类", ""],
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

/// @func card_in_category_path(_id, _path)
/// @desc 按**完整路径**匹配分类：从大分类开始逐级比对，路径里的空串表示「跳过该层」
///   例：card_in_category_path("small_fire", ["产能类","主职产火","常规型"]) -> true
///   比 card_in_category 严：只写「常规型」不会命中别的分类里同名的一层。
function card_in_category_path(_id, _path)
{
    var _c = card_get_category(_id);
    if (_c == undefined) return false;

    // 卡片实际层级（已跳过空层）
    var _lv = _c.levels;

    // 目标层级（跳过空层）
    var _want = [];
    for (var i = 0; i < array_length(_path); i++){
        if (_path[i] != "") array_push(_want, _path[i]);
    }

    if (array_length(_want) == 0 || array_length(_want) > array_length(_lv)) return false;

    for (var i = 0; i < array_length(_want); i++){
        if (_lv[i] != _want[i]) return false;
    }
    return true;
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

    for (var i = 0; i < array_length(_c.levels); i++)
    {
        if (_c.levels[i] == _name) return true;
    }
    return false;
}

/// @func card_get_levels(_id)
/// @desc 这张卡的完整层级（从大分类到最细一层，已跳过空层）
function card_get_levels(_id)
{
    var _c = card_get_category(_id);
    if (_c == undefined) return [];
    return _c.levels;
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
