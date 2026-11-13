function cross_server_shop_init()
{
    var _cross_server_goods = [
        // 这张表只负责「改价 + 打跨服标」，商品本体由 shop_init / mod_shop_init 注册。
        // 归属只看 cross_server_shop 字段：有标 → 只在跨服；没标 → 只在普通商店。
        "baibianshe", "double_blade_snake", "laipishe", "magic_chicken", "xuanfengniu",
        "zhanqima", "niuyouguo", "fashishe", "huanyingshe", "master_shield", "hades_scythe", "zeus_bolt", "star_wand", "rose_shield", "aladdin_lamp",
        "divine_blessing_gem", "divine_protect_gem", "divine_holy_gem", "divine_shenji_gem", "ghost_strike_gem", "ghost_spark_gem", "ghost_pact_gem", "ghost_caijue_gem",
        "zeus_shadow_gem", "zeus_power_gem", "zeus_anger_gem", "zeus_ren_gem", "star_wand_gem_1", "star_wand_gem_2", "star_wand_gem_3", "star_wand_gem_4", "star_wand_gem_5",
        "rose_shield_gem_1", "rose_shield_gem_2", "rose_shield_gem_3", "rose_shield_gem_4", "rose_shield_gem_5",
        "aladdin_lamp_gem_1", "aladdin_lamp_gem_2", "aladdin_lamp_gem_3", "aladdin_lamp_gem_4", "aladdin_lamp_gem_5",
        // 金刚马 / 蛇蛇酒 / 转龙壶：本体在跨服白银页（价目见下）；本体商品仍在 mod_shop_init 注册，这里只改价
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
}
