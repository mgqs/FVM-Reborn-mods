function cross_server_shop_init()
{
    var _cross_server_goods = [
        "baibianshe", "double_blade_snake", "laipishe", "spoon_rabbit", "magic_chicken", "xuanfengniu",
        "zhanqima", "zhanqima_1", "zhanqima_2", "hongliukaochuan_1", "hongliukaochuan_2", "yeziguo", "yeziguo_1", "yeziguo_2", "niuyouguo", "niuyouguo_1", "niuyouguo_2", "master_shield", "hades_scythe", "zeus_bolt", "star_wand", "rose_shield", "aladdin_lamp",
        "divine_blessing_gem", "divine_protect_gem", "divine_holy_gem", "divine_shenji_gem", "ghost_strike_gem", "ghost_spark_gem", "ghost_pact_gem", "ghost_caijue_gem",
        "zeus_shadow_gem", "zeus_power_gem", "zeus_anger_gem", "zeus_ren_gem", "star_wand_gem_1", "star_wand_gem_2", "star_wand_gem_3", "star_wand_gem_4", "star_wand_gem_5",
        "rose_shield_gem_1", "rose_shield_gem_2", "rose_shield_gem_3", "rose_shield_gem_4", "rose_shield_gem_5",
        "aladdin_lamp_gem_1", "aladdin_lamp_gem_2", "aladdin_lamp_gem_3", "aladdin_lamp_gem_4", "aladdin_lamp_gem_5",
        "yanyantu", "yanyantu_1", "yanyantu_2", "wugushe", "wugushe_1", "wugushe_2", "kuileima", "kuileima_1", "kuileima_2", "yufengma", "yufengma_1", "yufengma_2", "fenjima", "fenjima_1", "fenjima_2", "guiyuanma", "guiyuanma_1", "guiyuanma_2", "yanhuangma", "yanhuangma_1", "yanhuangma_2", "yinhema", "yinhema_1", "yinhema_2", "xiandima", "xiandima_1", "xiandima_2", "xingqiongma", "xingqiongma_1", "xingqiongma_2", "starrabbit", "starrabbit_1", "starrabbit_2", "yinghuoshe", "yinghuoshe_1", "yinghuoshe_2", "wuxingshe"
    ];

    var _cross_server_prices = {
        baibianshe: {cost: "1510", shop: "silver"}, double_blade_snake: {cost: "1320", shop: "silver"}, laipishe: {cost: "1320", shop: "silver"},
        spoon_rabbit: {cost: "1130", shop: "silver"}, magic_chicken: {cost: "1130", shop: "silver"}, xuanfengniu: {cost: "1020", shop: "silver"},
        zhanqima: {cost: "1900", shop: "silver"}, zhanqima_1: {cost: "225", shop: "gold"}, zhanqima_2: {cost: "228", shop: "gold"},
        hongliukaochuan_1: {cost: "390", shop: "gold"}, hongliukaochuan_2: {cost: "365", shop: "gold"},
        yeziguo: {cost: "1130", shop: "silver"},
        yeziguo_1: {cost: "130", shop: "gold"}, yeziguo_2: {cost: "133", shop: "gold"},
        niuyouguo: {cost: "2030", shop: "silver"},
        niuyouguo_1: {cost: "240", shop: "gold"}, niuyouguo_2: {cost: "243", shop: "gold"},
        chunsun: {cost: "1000", shop: "silver"},
        chunsun_1: {cost: "115", shop: "gold"}, chunsun_2: {cost: "118", shop: "gold"},
        master_shield: {cost: "900", shop: "silver"}, hades_scythe: {cost: "900", shop: "silver"}, zeus_bolt: {cost: "900", shop: "silver"},
        divine_blessing_gem: {cost: "900", shop: "silver"}, divine_protect_gem: {cost: "900", shop: "silver"}, divine_holy_gem: {cost: "900", shop: "silver"}, divine_shenji_gem: {cost: "900", shop: "silver"},
        ghost_strike_gem: {cost: "900", shop: "silver"}, ghost_spark_gem: {cost: "900", shop: "silver"}, ghost_pact_gem: {cost: "900", shop: "silver"}, ghost_caijue_gem: {cost: "900", shop: "silver"},
        zeus_shadow_gem: {cost: "900", shop: "silver"}, zeus_power_gem: {cost: "900", shop: "silver"}, zeus_anger_gem: {cost: "900", shop: "silver"}, zeus_ren_gem: {cost: "900", shop: "silver"},
        star_wand: {cost: "500", shop: "gold"}, star_wand_gem_1: {cost: "500", shop: "gold"}, star_wand_gem_2: {cost: "750", shop: "gold"}, star_wand_gem_3: {cost: "500", shop: "gold"}, star_wand_gem_4: {cost: "500", shop: "gold"}, star_wand_gem_5: {cost: "500", shop: "gold"},
        rose_shield: {cost: "500", shop: "gold"}, rose_shield_gem_1: {cost: "500", shop: "gold"}, rose_shield_gem_2: {cost: "500", shop: "gold"}, rose_shield_gem_3: {cost: "500", shop: "gold"}, rose_shield_gem_4: {cost: "500", shop: "gold"}, rose_shield_gem_5: {cost: "750", shop: "gold"},
        aladdin_lamp: {cost: "500", shop: "gold"}, aladdin_lamp_gem_1: {cost: "500", shop: "gold"}, aladdin_lamp_gem_2: {cost: "750", shop: "gold"}, aladdin_lamp_gem_3: {cost: "500", shop: "gold"}, aladdin_lamp_gem_4: {cost: "500", shop: "gold"}, aladdin_lamp_gem_5: {cost: "500", shop: "gold"},
        yanyantu: {cost: "1900", shop: "silver"}, wugushe: {cost: "1900", shop: "silver"}, kuileima: {cost: "1900", shop: "silver"}, yufengma: {cost: "1900", shop: "silver"}, fenjima: {cost: "1900", shop: "silver"}, guiyuanma: {cost: "1900", shop: "silver"}, yanhuangma: {cost: "1900", shop: "silver"}, yinhema: {cost: "1900", shop: "silver"}, xiandima: {cost: "1900", shop: "silver"}, xingqiongma: {cost: "1900", shop: "silver"}, yanyantu_1: {cost: "225", shop: "gold"}, yanyantu_2: {cost: "228", shop: "gold"}, wugushe_1: {cost: "225", shop: "gold"}, wugushe_2: {cost: "228", shop: "gold"}, kuileima_1: {cost: "225", shop: "gold"}, kuileima_2: {cost: "228", shop: "gold"}, yufengma_1: {cost: "225", shop: "gold"}, yufengma_2: {cost: "228", shop: "gold"}, fenjima_1: {cost: "225", shop: "gold"}, fenjima_2: {cost: "228", shop: "gold"}, guiyuanma_1: {cost: "225", shop: "gold"}, guiyuanma_2: {cost: "228", shop: "gold"}, yanhuangma_1: {cost: "225", shop: "gold"}, yanhuangma_2: {cost: "228", shop: "gold"}, yinhema_1: {cost: "225", shop: "gold"}, yinhema_2: {cost: "228", shop: "gold"}, xiandima_1: {cost: "225", shop: "gold"}, xiandima_2: {cost: "228", shop: "gold"}, xingqiongma_1: {cost: "225", shop: "gold"}, xingqiongma_2: {cost: "228", shop: "gold"},
        wuxingshe: {cost: "1500", shop: "silver"}
    };

    // 新生肖 / 泡椒春笋仅在跨服商店兑换，三个形态的价格取自 _cross_server_prices（没写自己价目的回落战旗马那一档）。
    // 米线本体为松露大厅首通奖励，一转 / 二转改为魔塔关卡首通奖励（1-1 给一转、13-1 给二转），跨服商店不再上架。
    // 烤串机本体为百味关首通奖励、泡椒春笋本体为赤霞渡（日）首通奖励（2026-10-27），
    // 两者本体从跨服商店下架，只保留一转 / 二转在黄金页签兑换。
    var _cross_server_card_ids = ["yanyantu","wugushe","kuileima","yufengma","fenjima","guiyuanma","yanhuangma","yinhema","xiandima","xingqiongma","starrabbit","yinghuoshe","chunsun"];
    var _base_form_level_reward = ["chunsun"];
    for (var _z = 0; _z < array_length(_cross_server_card_ids); _z++) {
        var _zid = _cross_server_card_ids[_z];
        for (var _shape = 0; _shape < 3; _shape++) {
            // 本体改为关卡首通奖励的卡：不在商店注册 0 形态（既不上跨服，也不进金币商店）。
            if (_shape == 0 && array_get_index(_base_form_level_reward, _zid) != -1) continue;
            var _suffix = _shape == 0 ? "" : "_" + string(_shape);
            var _price_id = _zid + _suffix;
            var _template = variable_struct_exists(_cross_server_prices, _price_id) ? _cross_server_prices[$ _price_id] : _cross_server_prices[$ "zhanqima" + _suffix];
            var _shape_data = get_plant_shape_data(_zid,_shape);
            var _entry = {
                type: "card", card_id: _zid, card_shape: _shape,
                cost: _template.cost, cross_server_shop: _template.shop,
                unlock_item_id: _zid,
                description: _shape_data[? "description"], display_name: _shape_data[? "name"]
            };
            if (_shape > 0) _entry.required_card_shape = _shape - 1;
            register_goods(_zid + _suffix, _entry);
        }
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
