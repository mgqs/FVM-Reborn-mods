/// =====================================================================
/// card_attack_target —— 情报岛「可以攻击」行的数据源（白名单制）
///   ① card_attack_target_data()    白名单：卡片 → target_type（形态差异写成数组）
///      只在表里（或例外区）的卡才显示这一行，没列出的一律不显示。
///   ② card_attack_target_exclude() 生成了也不显示的卡（写了 target_type 但实际不出伤害）
///   ③ card_attack_target_override() 口径与 target_type 对不上的卡，手写覆盖（按形态）
///      写了这里的卡不再写进 ①，显示只读这里
///   ④ card_attack_text()           拼成「陆地鼠军丨潜水丨空军」；障碍默认不显示
///   ①② 由 桌面/fvm的ai/生成卡牌可攻击表.py 维护，③ 手写脚本不动。
///   判定口径的唯一真相仍是 scripts/can_target_on。
/// =====================================================================

function card_attack_target_data()
{
    static _d = {
        "12yinliao": "normal",
        "aquarius_elve": "normal",
        "athena": "track",
        "beef_hotpot": "pierce",
        "brahma": "normal",
        "bull_firework": "normal",
        "caihongshe": "normal",
        "cat_box": "normal",
        "cat_chest": "normal",
        "chili_powder": "normal",
        "chocolate_cannon": "throw",
        "chocolate_pult": "throw",
        "chunsun": "all",
        "coal_starfish": "normal",
        "coffee_cup": "normal",
        "coffee_pot": "pierce",
        "coke_bomb": "all",
        "cold_drew": "all",
        "corn_shooter": "normal",
        "curry_lobster_cannon": "track",
        "dandantu": "normal",
        "dangdanghu": "throw",
        "delicacy_firework": "normal",
        "dianman": "rotate",
        "donut": "air",
        "double_blade_snake": "normal",
        "double_ice_long_bao": "normal",
        "double_long_bao": "normal",
        "double_water_pipe": "normal",
        "doumaobang": ["normal", "track", "track", "track"],
        "dragon_fruit": ["d_fruit", "all", "all", "all"],
        "durian": "rotate",
        "egg_boiler_pult": "throw",
        "eightcake": "throw",
        "fangkongmiao": "air_only",
        "fenjima": "normal",
        "fishbone": "pierce",
        "flour_sack": "normal",
        "gaia": "normal",
        "galaxy_horse": "all",
        "gatlin_ice_long_bao": "normal",
        "gatlin_long_bao": "normal",
        "ghost_god": "normal",
        "gongjiang_god": "air",
        "grilled_lizard_pult": "throw",
        "guangming_god": ["d_fruit", "all", "all", "all"],
        "guiyuanma": "normal",
        "hamburger": "throw",
        "heian_god": "all",
        "hera": "normal",
        "honeytrap": "track",
        "hongliukaochuan": "normal",
        "hotdog_cannon": "air",
        "houyi_god": "normal",
        "huagao": "normal",
        "huanyingshe": "throw",
        "hufa_god": "normal",
        "hundun_god": "normal",
        "huojianzhu": "track",
        "ice_bucket_bomb": "normal",
        "ice_egg_boiler_pult": "throw",
        "ice_god": "track",
        "ice_long_bao": "normal",
        "iron_fishbone": "pierce",
        "jingangma": "pierce",
        "juxie": "track",
        "kettle_bomb": "normal",
        "king_long_bao": "normal",
        "king_triple_long_bao": "normal",
        "kuileima": "all",
        "laipishe": "air",
        "lizi_god": "throw",
        "love_god": "normal",
        "mianbao": "all",
        "mixian": "all",
        "mojie": "normal",
        "moon_god": "track",
        "niuyouguo": "pierce_air",
        "nizhuanniu": "all",
        "nut_frier": "normal",
        "oden_pot": "pierce",
        "odin": "normal",
        "pan_fried_bun": "throw",
        "panduola_god": "all",
        "pizza_oven": "air",
        "poseidon": "all",
        "power_god": "air_only",
        "pufferfish": "all",
        "qiedanlong": "throw",
        "qingse_shishi": ["normal", "normal", "all", "all"],
        "qishui": "normal",
        "rabbit_lantern": "all",
        "rig": "normal",
        "ronghedan_god": "throw",
        "ronghedapao": "throw",
        "ronghehaixing": "track",
        "ronghehuopen": "all",
        "ronghekafei": "normal",
        "ronghesanxian": "normal",
        "rongheshuanggu": "air",
        "rotating_coffee_pot": "rotate",
        "salad_pult": "throw",
        "sausage": "air",
        "sheshou": "normal",
        "shiliu_baobao_bing": "all",
        "shizi": "all",
        "shuanggu": "air",
        "shuangyu": "throw",
        "skewer_bomb": "normal",
        "snowrabbit": "all",
        "spicy_pot": "pierce",
        "spoon_rabbit": "throw",
        "starrabbit": "normal",
        "steel_wool": "all",
        "stinky_tofu_pult": "throw",
        "sugar_ball_pult": "throw",
        "sugar_roxburghii": "pierce",
        "takoyaki": "track",
        "tanchitu": "normal",
        "tang_hu_lu": "air_only",
        "tangchaolizi": "throw",
        "tanhuanghu": "air",
        "tar_sprayer": "pierce",
        "thor": "throw",
        "tiancheng": "normal",
        "time_god": "all",
        "triple_ice_long_bao": "normal",
        "triple_long_bao": "normal",
        "triple_wine_rack": "normal",
        "tunshilong": "all",
        "war_god": "normal",
        "water_tea_cup": "normal",
        "whisky_bomb": "normal",
        "wine_bottle_bomb": "normal",
        "wugushe": "all",
        "xiandima": "normal",
        "xiao_long_bao": "normal",
        "xinjiang_fried_noodles": "normal",
        "xuanzhuan_ronghe": "rotate",
        "yanhuangma": "normal",
        "yeziguo": "normal",
        "yinghuoshe": "all",
        "ymir": "throw",
        "youyu_god": "normal",
        "yinyangshe": "pierce",
        "yuanqiniu": "rotate",
        "yuansushe": "pierce",
        "yufengma": "normal",
        "zeus": "track",
        "zhuanzhuanji": "rotate",
        "zhurong": "throw",
        "zhuzhuliaoliji": "normal"
    };
    return _d;
}

function card_attack_target_exclude()
{
    return [
        "sheshejiu", "shiguangji", "xuanfengniu", "zhuanlonghu"
    ];
}

function card_attack_target_override()
{
    static _o = {
        // 这三张子弹更宽：bbq/法师蛇是灼烧格·毒格的自身机制，天蝎座是二转随机效果，按卡片索敌口径盖回
        "bbq": "陆地鼠军",
        "fashishe": "陆地鼠军",
        "tianxie": "陆地鼠军",
        "shennong_god": ["陆地鼠军", "陆地鼠军", "陆地鼠军丨空军丨地鼠", "陆地鼠军丨空军丨地鼠"],
        "sheng_huo": ["陆地鼠军丨非主流丨幽灵", "陆地鼠军丨非主流丨幽灵", "陆地鼠军丨空军丨非主流丨地鼠丨幽灵", "陆地鼠军丨空军丨非主流丨地鼠丨幽灵"],
        // 恶作剧神：子弹打 空中 / 陆地 / 潜水 / 地下（没有单一类型名能表达，手写覆盖）
        "joker": "陆地鼠军丨空军丨潜水丨地鼠",
        // 结界马：结界内只打 空 / 陆 / 地鼠军（卡面原文），没有单一 target_type 能表达
        "jiejiema": "陆地鼠军丨空军丨地鼠"
    };
    return _o;
}

function card_attack_target_of(_id, _shape)
{
    var _d = card_attack_target_data();
    if (!variable_struct_exists(_d, _id)) return "normal";
    var _v = _d[$ _id];
    if (is_array(_v)) return _v[clamp(_shape, 0, array_length(_v) - 1)];
    return _v;
}

function card_attack_text(_id, _shape)
{
    var _o = card_attack_target_override();
    if (variable_struct_exists(_o, _id)) {
        var _ov = _o[$ _id];
        if (is_array(_ov)) return _ov[clamp(_shape, 0, array_length(_ov) - 1)];
        return _ov;
    }
    static _m = {
        "normal":     "陆地鼠军",
        "throw":      "陆地鼠军丨潜水",
        "track":      "陆地鼠军丨潜水丨空军",
        "air":        "陆地鼠军丨空军",
        "air_only":   "空军",
        "pierce":     "陆地鼠军丨非主流丨幽灵",
        "pierce_air": "陆地鼠军丨空军",
        "rotate":     "陆地鼠军丨空军丨非主流丨地鼠丨幽灵",
        "d_fruit":    "陆地鼠军丨空军丨非主流丨地鼠丨幽灵",
        "all":        "陆地鼠军丨潜水丨空军丨非主流丨地鼠丨幽灵"
    };
    var _t = card_attack_target_of(_id, _shape);
    if (variable_struct_exists(_m, _t)) return _m[$ _t];
    return "陆地鼠军";
}

function card_attack_shown(_id)
{
    if (array_contains(card_attack_target_exclude(), _id)) return false;
    if (variable_struct_exists(card_attack_target_override(), _id)) return true;
    return variable_struct_exists(card_attack_target_data(), _id);
}
