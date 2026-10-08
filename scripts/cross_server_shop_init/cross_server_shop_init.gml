function cross_server_shop_init()
{
    var _cross_server_goods = [
        "baibianshe", "double_blade_snake", "laipishe", "spoon_rabbit", "magic_chicken", "xuanfengniu",
        "zhanqima", "zhanqima_1", "zhanqima_2", "hongliukaochuan", "hongliukaochuan_1", "hongliukaochuan_2", "yeziguo", "yeziguo_1", "yeziguo_2", "master_shield", "hades_scythe", "zeus_bolt", "star_wand", "rose_shield", "aladdin_lamp",
        "divine_blessing_gem", "divine_protect_gem", "divine_holy_gem", "divine_shenji_gem", "ghost_strike_gem", "ghost_spark_gem", "ghost_pact_gem", "ghost_caijue_gem",
        "zeus_shadow_gem", "zeus_power_gem", "zeus_anger_gem", "zeus_ren_gem", "star_wand_gem_1", "star_wand_gem_2", "star_wand_gem_3", "star_wand_gem_4", "star_wand_gem_5",
        "rose_shield_gem_1", "rose_shield_gem_2", "rose_shield_gem_3", "rose_shield_gem_4", "rose_shield_gem_5",
        "aladdin_lamp_gem_1", "aladdin_lamp_gem_2", "aladdin_lamp_gem_3", "aladdin_lamp_gem_4", "aladdin_lamp_gem_5"
    ];

    var _cross_server_prices = {
        baibianshe: {cost: "1510", shop: "silver"}, double_blade_snake: {cost: "1320", shop: "silver"}, laipishe: {cost: "1320", shop: "silver"},
        spoon_rabbit: {cost: "1130", shop: "silver"}, magic_chicken: {cost: "1130", shop: "silver"}, xuanfengniu: {cost: "1020", shop: "silver"},
        zhanqima: {cost: "1900", shop: "silver"}, zhanqima_1: {cost: "450", shop: "gold"}, zhanqima_2: {cost: "910", shop: "gold"},
        hongliukaochuan: {cost: "1650", shop: "silver"},
        hongliukaochuan_1: {cost: "390", shop: "gold"}, hongliukaochuan_2: {cost: "730", shop: "gold"},
        yeziguo: {cost: "1130", shop: "silver"},
        yeziguo_1: {cost: "260", shop: "gold"}, yeziguo_2: {cost: "530", shop: "gold"},
        master_shield: {cost: "900", shop: "silver"}, hades_scythe: {cost: "900", shop: "silver"}, zeus_bolt: {cost: "900", shop: "silver"},
        divine_blessing_gem: {cost: "900", shop: "silver"}, divine_protect_gem: {cost: "900", shop: "silver"}, divine_holy_gem: {cost: "900", shop: "silver"}, divine_shenji_gem: {cost: "900", shop: "silver"},
        ghost_strike_gem: {cost: "900", shop: "silver"}, ghost_spark_gem: {cost: "900", shop: "silver"}, ghost_pact_gem: {cost: "900", shop: "silver"}, ghost_caijue_gem: {cost: "900", shop: "silver"},
        zeus_shadow_gem: {cost: "900", shop: "silver"}, zeus_power_gem: {cost: "900", shop: "silver"}, zeus_anger_gem: {cost: "900", shop: "silver"}, zeus_ren_gem: {cost: "900", shop: "silver"},
        star_wand: {cost: "500", shop: "gold"}, star_wand_gem_1: {cost: "500", shop: "gold"}, star_wand_gem_2: {cost: "750", shop: "gold"}, star_wand_gem_3: {cost: "500", shop: "gold"}, star_wand_gem_4: {cost: "500", shop: "gold"}, star_wand_gem_5: {cost: "500", shop: "gold"},
        rose_shield: {cost: "500", shop: "gold"}, rose_shield_gem_1: {cost: "500", shop: "gold"}, rose_shield_gem_2: {cost: "500", shop: "gold"}, rose_shield_gem_3: {cost: "500", shop: "gold"}, rose_shield_gem_4: {cost: "500", shop: "gold"}, rose_shield_gem_5: {cost: "750", shop: "gold"},
        aladdin_lamp: {cost: "500", shop: "gold"}, aladdin_lamp_gem_1: {cost: "500", shop: "gold"}, aladdin_lamp_gem_2: {cost: "750", shop: "gold"}, aladdin_lamp_gem_3: {cost: "500", shop: "gold"}, aladdin_lamp_gem_4: {cost: "500", shop: "gold"}, aladdin_lamp_gem_5: {cost: "500", shop: "gold"}
    };

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
