function cross_server_shop_init()
{
    var _cross_server_goods = [
        // 卡片本体的商品在下面直接注册；这份名单只管「改价 + 打跨服标」。
        // 归属只看 cross_server_shop 字段：有标 → 只在跨服；没标 → 只在普通商店。
        "baibianshe", "double_blade_snake", "laipishe", "magic_chicken", "xuanfengniu",
        "zhanqima", "niuyouguo", "fashishe", "huanyingshe", "master_shield", "hades_scythe", "zeus_bolt", "star_wand", "rose_shield", "aladdin_lamp",
        "divine_blessing_gem", "divine_protect_gem", "divine_holy_gem", "divine_shenji_gem", "ghost_strike_gem", "ghost_spark_gem", "ghost_pact_gem", "ghost_caijue_gem",
        "zeus_shadow_gem", "zeus_power_gem", "zeus_anger_gem", "zeus_ren_gem", "star_wand_gem_1", "star_wand_gem_2", "star_wand_gem_3", "star_wand_gem_4", "star_wand_gem_5",
        "rose_shield_gem_1", "rose_shield_gem_2", "rose_shield_gem_3", "rose_shield_gem_4", "rose_shield_gem_5",
        "aladdin_lamp_gem_1", "aladdin_lamp_gem_2", "aladdin_lamp_gem_3", "aladdin_lamp_gem_4", "aladdin_lamp_gem_5",
        // 金刚马 / 蛇蛇酒 / 转龙壶：本体商品也在本文件注册（见下面的直接注册块）
        "jingangma", "sheshejiu", "zhuanlonghu",
        "yanyantu", "wugushe", "kuileima", "yufengma", "fenjima", "yanhuangma", "yinhema", "xiandima", "starrabbit", "wuxingshe"
    ];

    var _cross_server_prices = {
        baibianshe: {cost: "1510", shop: "silver"}, double_blade_snake: {cost: "1320", shop: "silver"}, laipishe: {cost: "1320", shop: "silver"},
        magic_chicken: {cost: "1130", shop: "silver"}, xuanfengniu: {cost: "1020", shop: "silver"},
        zhanqima: {cost: "1900", shop: "silver"},
        // 法师蛇 / 幻影蛇：本体在跨服白银页
        fashishe: {cost: "2000", shop: "silver"},
        huanyingshe: {cost: "1700", shop: "silver"},
        niuyouguo: {cost: "2030", shop: "silver"},
        master_shield: {cost: "900", shop: "silver"}, hades_scythe: {cost: "900", shop: "silver"}, zeus_bolt: {cost: "900", shop: "silver"},
        divine_blessing_gem: {cost: "900", shop: "silver"}, divine_protect_gem: {cost: "900", shop: "silver"}, divine_holy_gem: {cost: "900", shop: "silver"}, divine_shenji_gem: {cost: "900", shop: "silver"},
        ghost_strike_gem: {cost: "900", shop: "silver"}, ghost_spark_gem: {cost: "900", shop: "silver"}, ghost_pact_gem: {cost: "900", shop: "silver"}, ghost_caijue_gem: {cost: "900", shop: "silver"},
        zeus_shadow_gem: {cost: "900", shop: "silver"}, zeus_power_gem: {cost: "900", shop: "silver"}, zeus_anger_gem: {cost: "900", shop: "silver"}, zeus_ren_gem: {cost: "900", shop: "silver"},
        star_wand: {cost: "500", shop: "gold"}, star_wand_gem_1: {cost: "500", shop: "gold"}, star_wand_gem_2: {cost: "750", shop: "gold"}, star_wand_gem_3: {cost: "500", shop: "gold"}, star_wand_gem_4: {cost: "500", shop: "gold"}, star_wand_gem_5: {cost: "500", shop: "gold"},
        rose_shield: {cost: "500", shop: "gold"}, rose_shield_gem_1: {cost: "500", shop: "gold"}, rose_shield_gem_2: {cost: "500", shop: "gold"}, rose_shield_gem_3: {cost: "500", shop: "gold"}, rose_shield_gem_4: {cost: "500", shop: "gold"}, rose_shield_gem_5: {cost: "750", shop: "gold"},
        aladdin_lamp: {cost: "500", shop: "gold"}, aladdin_lamp_gem_1: {cost: "500", shop: "gold"}, aladdin_lamp_gem_2: {cost: "750", shop: "gold"}, aladdin_lamp_gem_3: {cost: "500", shop: "gold"}, aladdin_lamp_gem_4: {cost: "500", shop: "gold"}, aladdin_lamp_gem_5: {cost: "500", shop: "gold"},
        yanyantu: {cost: "1900", shop: "silver"}, wugushe: {cost: "1900", shop: "silver"}, kuileima: {cost: "1900", shop: "silver"}, yufengma: {cost: "1900", shop: "silver"}, fenjima: {cost: "1900", shop: "silver"}, yanhuangma: {cost: "1900", shop: "silver"}, yinhema: {cost: "1900", shop: "silver"}, xiandima: {cost: "1900", shop: "silver"}, starrabbit: {cost: "1900", shop: "silver"},
        wuxingshe: {cost: "1500", shop: "silver"},
        // 2026-11-13 用户口径：三张新卡本体上跨服白银页
        jingangma: {cost: "3000", shop: "silver"},
        sheshejiu: {cost: "2500", shop: "silver"},
        zhuanlonghu: {cost: "2300", shop: "silver"}
    };

    // ── 只在跨服卖的商品，注册点就在这里（普通商店那两个文件不再出现）──
    register_goods("magic_chicken", { type: "card", cost: "1130", unlock_item_id: "magic_chicken", description: "幻幻鸡：复制成上一张放置的卡片", display_name: "幻幻鸡" });
    register_goods("baibianshe", { type: "card", cost: "1510", unlock_item_id: "baibianshe", description: "百变蛇：变身成为范围内上一张种下的卡片", display_name: "百变蛇" });
    register_goods("xuanfengniu", { type: "card", cost: "1020", unlock_item_id: "xuanfengniu", description: "旋风牛：吹走全屏特定空中老鼠，一转可清障，二转不需要格子", display_name: "旋风牛" });
    register_goods("laipishe", { type: "card", cost: "1320", unlock_item_id: "laipishe", description: "赖皮蛇：召唤沿固定轨迹飞行的海胆子弹，伤害轨迹上的海陆空老鼠", display_name: "赖皮蛇" });
    register_goods("double_blade_snake", { type: "card", cost: "1320", unlock_item_id: "double_blade_snake", description: "双刃蛇：向前发射2发穿透剑气子弹，可斩杀生命值≤15%的普通老鼠", display_name: "双刃蛇" });
    register_goods("zhanqima", { type: "card", cost: "1900", unlock_item_id: "zhanqima", description: "战旗马：5*5范围内主动攻击型卡片提高基础攻击力", display_name: "战旗马" });
    register_goods("niuyouguo", { type: "card", cost: "2030", unlock_item_id: "niuyouguo", description: "邪恶牛油果：向前方三个方向各发射1发穿透飞镖", display_name: "邪恶牛油果" });
    register_goods("wuxingshe", { type: "card", cost: "1500", unlock_item_id: "wuxingshe", description: "五行蛇：为3*3范围内5方向卡片增加攻击力", display_name: "五行蛇" });
    register_goods("fashishe", { type: "card", cost: "2000", unlock_item_id: "fashishe", description: "法师蛇：向前发射整行穿透毒子弹", display_name: "法师蛇" });
    register_goods("huanyingshe", { type: "card", cost: "1700", unlock_item_id: "huanyingshe", description: "幻影蛇：大范围发射可追踪的投掷类子弹", display_name: "幻影蛇" });
    register_goods("jingangma", { type: "card", cost: "3000", unlock_item_id: "jingangma", description: "金刚马：全屏索敌最远目标，发射追踪穿透音波，可伤害幽灵鼠", display_name: "金刚马" });
    register_goods("sheshejiu", { type: "card", cost: "2500", unlock_item_id: "sheshejiu", description: "蛇蛇酒：为3*3范围内卡片随机升星或者降星，持续一段时间后恢复", display_name: "蛇蛇酒" });
    register_goods("zhuanlonghu", { type: "card", cost: "2300", unlock_item_id: "zhuanlonghu", description: "转龙壶：缩减3*3范围内正在冷却的美食的冷却时间30%", display_name: "转龙壶" });

    // ── 跨服白银页卖的卡片本体 ────────────────────────────────────
    //   一 / 二转凭证已经在凭证页（credit_shop_init 的 credit_xxx_1/_2）卖，跨服不再出售任何
    //   转职商品 —— 这里只挂 0 形态。以后要加新卡往名单里加 id + 在 _cross_server_prices 补价目。
    var _cross_server_card_ids = ["yanyantu", "wugushe", "kuileima", "yufengma", "fenjima",
                                  "yanhuangma", "yinhema", "xiandima", "starrabbit"];
    for (var _z = 0; _z < array_length(_cross_server_card_ids); _z++) {
        var _zid = _cross_server_card_ids[_z];
        if (!variable_struct_exists(_cross_server_prices, _zid)) continue;

        var _template = _cross_server_prices[$ _zid];
        var _shape_data = get_plant_shape_data(_zid, 0);
        register_goods(_zid, {
            type: "card", card_id: _zid, card_shape: 0,
            cost: _template.cost, cross_server_shop: _template.shop,
            unlock_item_id: _zid,
            description: _shape_data[? "description"], display_name: _shape_data[? "name"]
        });
    }

    for (var _i = 0; _i < array_length(_cross_server_goods); _i++) {
        var _id = _cross_server_goods[_i];
        if (!ds_map_exists(global.goods_map, _id)) continue;
        var _goods = global.goods_map[? _id];
        if (variable_struct_exists(_cross_server_prices, _id)) {
            var _price = _cross_server_prices[$ _id];
            _goods.cost = _price.cost;
            _goods.cross_server_shop = _price.shop;
        }
    }

    // 卡类商品（含黄金页的一/二转凭证）的**说明文字**改用「情报岛」那一档的原文
    //   原来这些商品在 mod_shop_init 里写的是「金丝椰子果：解锁二转」这种一句话，
    //   情报岛才有真正的技能说明（如「金丝椰子果：跳起连续碾压3次前方3*3范围鼠军」）
    //   2026-10-28 用户要求：跨服商店的悬停说明与情报岛一致
    var _ck = ds_map_find_first(global.goods_map);
    while (!is_undefined(_ck)) {
        var _cg = global.goods_map[? _ck];
        if (is_struct(_cg) && variable_struct_exists(_cg, "cross_server_shop")
            && variable_struct_exists(_cg, "card_id") && variable_struct_exists(_cg, "card_shape")) {
            var _csd = get_plant_shape_data(_cg.card_id, _cg.card_shape);
            if (_csd != undefined && ds_map_exists(_csd, "description")) {
                var _cdesc = _csd[? "description"];
                if (is_string(_cdesc) && _cdesc != "") _cg.description = _cdesc;
            }
        }
        _ck = ds_map_find_next(global.goods_map, _ck);
    }

    // 后置宝石必须先兑换对应的前置宝石。
    var _gem_prerequisites = {
        star_wand_gem_5: "star_wand_gem_1",
        aladdin_lamp_gem_5: "aladdin_lamp_gem_1",
        rose_shield_gem_5: "rose_shield_gem_3"
    };
    var _prerequisite_ids = variable_struct_get_names(_gem_prerequisites);
    for (var _j = 0; _j < array_length(_prerequisite_ids); _j++) {
        var _goods_id = _prerequisite_ids[_j];
        if (!ds_map_exists(global.goods_map, _goods_id)) continue;
        global.goods_map[? _goods_id].required_gem_id = _gem_prerequisites[$ _goods_id];
    }

    // ── 跨服下架「进化后的武器 / 宝石」（2026-11-16 用户口径）───────────────
    //   跨服只留**进化底层**（链首那件，普通商店也在卖的那一档）；进化出来的形态一律下架
    //   —— 有了合成屋的神器/宝石进化，再从跨服直接买成品等于跳过进化，且价格也没台阶。
    //   判据唯一出口：mod_gear_evo_build().steps 的 .to（= 所有「被进化出来」的 id），
    //   别回 _cross_server_goods 名单里手删 —— 以后挪路线 / 加补强宝石又会漏。
    //   用 cross_server_hidden 打标，而不是 ds_map_delete：
    //     删 key 会让 required_weapon_id / required_gem_id 指向空键
    //     （obj_cross_server_shop/Draw_0:150 是直接取 map 的，会炸）。
    var _evo_steps = mod_gear_evo_build().steps;
    for (var _es = 0; _es < array_length(_evo_steps); _es++) {
        var _evo_to = _evo_steps[_es].to;
        if (ds_map_exists(global.goods_map, _evo_to)) {
            global.goods_map[? _evo_to].cross_server_hidden = true;
        }
    }
}
