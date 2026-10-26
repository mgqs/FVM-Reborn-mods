/// 转职凭证商店注册（2026-10-25 建，2026-10-26 按用户「威望价格.xlsx」全量上架）
/// 商品 type = "credit"：只进商店新增的「转职凭证」页，不会出现在道具页/其它页
/// 字段：
///   coin_type     "prestige" = 花威望 / "gold" = 花金币
///   credit_shape  0 = 兑换项（不是凭证）/ 1 = 一转 / 2 = 二转（分类页签按它过滤）
///   reward_prestige  兑换项专用：买完加多少威望
///   tower_floor   爬塔门槛（现在全没写 = 不限制；用户 2026-10-26：本轮只做价格，门槛后续再填）
///                  写法：`"12-2"` = 需通关魔塔 12-2（层-小关）/ `12` = 该层第一小关 / 不写 = 不限
///                  判定分两层：置灰只看 transfer_credit_buyable_locked()（形态不存在/已持有/已转职）；
///                  爬塔门槛与余额不足只在点购买时弹提示，不置灰
/// 🔴 **不开 display_name**：商店对凭证是用 transfer_credit_name_from_id(unlock_item_id) 实时取名，
///    这字段对 credit_shape > 0 的商品根本不读；兑换项才用它。
/// ⚠️ 只上架价格表里写了价的卡（56 张 / 108 条）；没写价的一律不加入（用户 2026-10-26）。
///    4 张只有一转有价（巧克力面包 / 老虎蟹面包 / 油灯 / 苏打气泡）——工程里它们本来只有 0、1 两形态。
function credit_shop_init()
{
    // ── 威望兑换（测试期临时项）：10000000 金币 → 100000 威望 ──
    register_goods("prestige_exchange_100000", {
        type: "credit",
        cost: "10000000",
        coin_type: "gold",
        credit_shape: 0,
        unlock_item_id: "prestige",
        display_name: "威望 x10万",
        description: "用 10000000 金币兑换 100000 威望\n（测试期临时项，正式版会移除）",
        reward_prestige: 100000
    });

    register_goods("credit_beef_hotpot_1", {
        type: "credit", cost: "8000", coin_type: "prestige", credit_shape: 1,
        unlock_item_id: transfer_credit_id("beef_hotpot", 1),
        description: "肥牛火锅（一转凭证）\n在合成屋-卡片转职中使用"
    });
    register_goods("credit_beef_hotpot_2", {
        type: "credit", cost: "30000", coin_type: "prestige", credit_shape: 2,
        unlock_item_id: transfer_credit_id("beef_hotpot", 2),
        description: "肥牛火锅（二转凭证）\n在合成屋-卡片转职中使用"
    });
    register_goods("credit_berry_dessert_1", {
        type: "credit", cost: "6000", coin_type: "prestige", credit_shape: 1,
        unlock_item_id: transfer_credit_id("berry_dessert", 1),
        description: "莓果点心（一转凭证）\n在合成屋-卡片转职中使用"
    });
    register_goods("credit_berry_dessert_2", {
        type: "credit", cost: "28500", coin_type: "prestige", credit_shape: 2,
        unlock_item_id: transfer_credit_id("berry_dessert", 2),
        description: "莓果点心（二转凭证）\n在合成屋-卡片转职中使用"
    });
    register_goods("credit_brazier_1", {
        type: "credit", cost: "6000", coin_type: "prestige", credit_shape: 1,
        unlock_item_id: transfer_credit_id("brazier", 1),
        description: "火盆（一转凭证）\n在合成屋-卡片转职中使用"
    });
    register_goods("credit_brazier_2", {
        type: "credit", cost: "27000", coin_type: "prestige", credit_shape: 2,
        unlock_item_id: transfer_credit_id("brazier", 2),
        description: "火盆（二转凭证）\n在合成屋-卡片转职中使用"
    });
    register_goods("credit_cherry_pudding_1", {
        type: "credit", cost: "1900", coin_type: "prestige", credit_shape: 1,
        unlock_item_id: transfer_credit_id("cherry_pudding", 1),
        description: "樱桃反弹布丁（一转凭证）\n在合成屋-卡片转职中使用"
    });
    register_goods("credit_cherry_pudding_2", {
        type: "credit", cost: "9000", coin_type: "prestige", credit_shape: 2,
        unlock_item_id: transfer_credit_id("cherry_pudding", 2),
        description: "樱桃反弹布丁（二转凭证）\n在合成屋-卡片转职中使用"
    });
    register_goods("credit_chili_powder_1", {
        type: "credit", cost: "3000", coin_type: "prestige", credit_shape: 1,
        unlock_item_id: transfer_credit_id("chili_powder", 1),
        description: "辣椒粉（一转凭证）\n在合成屋-卡片转职中使用"
    });
    register_goods("credit_chili_powder_2", {
        type: "credit", cost: "23400", coin_type: "prestige", credit_shape: 2,
        unlock_item_id: transfer_credit_id("chili_powder", 2),
        description: "辣椒粉（二转凭证）\n在合成屋-卡片转职中使用"
    });
    register_goods("credit_chocolate_bread_1", {
        type: "credit", cost: "1900", coin_type: "prestige", credit_shape: 1,
        unlock_item_id: transfer_credit_id("chocolate_bread", 1),
        description: "巧克力面包（一转凭证）\n在合成屋-卡片转职中使用"
    });
    register_goods("credit_chocolate_cannon_1", {
        type: "credit", cost: "1900", coin_type: "prestige", credit_shape: 1,
        unlock_item_id: transfer_credit_id("chocolate_cannon", 1),
        description: "巧克力大炮（一转凭证）\n在合成屋-卡片转职中使用"
    });
    register_goods("credit_chocolate_cannon_2", {
        type: "credit", cost: "10500", coin_type: "prestige", credit_shape: 2,
        unlock_item_id: transfer_credit_id("chocolate_cannon", 2),
        description: "巧克力大炮（二转凭证）\n在合成屋-卡片转职中使用"
    });
    register_goods("credit_chunsun_1", {
        type: "credit", cost: "7000", coin_type: "prestige", credit_shape: 1,
        unlock_item_id: transfer_credit_id("chunsun", 1),
        description: "泡椒春笋（一转凭证）\n在合成屋-卡片转职中使用"
    });
    register_goods("credit_chunsun_2", {
        type: "credit", cost: "27000", coin_type: "prestige", credit_shape: 2,
        unlock_item_id: transfer_credit_id("chunsun", 2),
        description: "泡椒春笋（二转凭证）\n在合成屋-卡片转职中使用"
    });
    register_goods("credit_coal_starfish_1", {
        type: "credit", cost: "3600", coin_type: "prestige", credit_shape: 1,
        unlock_item_id: transfer_credit_id("coal_starfish", 1),
        description: "炭烧海星（一转凭证）\n在合成屋-卡片转职中使用"
    });
    register_goods("credit_coal_starfish_2", {
        type: "credit", cost: "10500", coin_type: "prestige", credit_shape: 2,
        unlock_item_id: transfer_credit_id("coal_starfish", 2),
        description: "炭烧海星（二转凭证）\n在合成屋-卡片转职中使用"
    });
    register_goods("credit_coffee_cup_1", {
        type: "credit", cost: "1900", coin_type: "prestige", credit_shape: 1,
        unlock_item_id: transfer_credit_id("coffee_cup", 1),
        description: "咖啡杯（一转凭证）\n在合成屋-卡片转职中使用"
    });
    register_goods("credit_coffee_cup_2", {
        type: "credit", cost: "8700", coin_type: "prestige", credit_shape: 2,
        unlock_item_id: transfer_credit_id("coffee_cup", 2),
        description: "咖啡杯（二转凭证）\n在合成屋-卡片转职中使用"
    });
    register_goods("credit_coffee_grounds_1", {
        type: "credit", cost: "1000", coin_type: "prestige", credit_shape: 1,
        unlock_item_id: transfer_credit_id("coffee_grounds", 1),
        description: "咖啡粉（一转凭证）\n在合成屋-卡片转职中使用"
    });
    register_goods("credit_coffee_grounds_2", {
        type: "credit", cost: "9000", coin_type: "prestige", credit_shape: 2,
        unlock_item_id: transfer_credit_id("coffee_grounds", 2),
        description: "咖啡粉（二转凭证）\n在合成屋-卡片转职中使用"
    });
    register_goods("credit_coffee_pot_1", {
        type: "credit", cost: "1700", coin_type: "prestige", credit_shape: 1,
        unlock_item_id: transfer_credit_id("coffee_pot", 1),
        description: "咖啡喷壶（一转凭证）\n在合成屋-卡片转职中使用"
    });
    register_goods("credit_coffee_pot_2", {
        type: "credit", cost: "8400", coin_type: "prestige", credit_shape: 2,
        unlock_item_id: transfer_credit_id("coffee_pot", 2),
        description: "咖啡喷壶（二转凭证）\n在合成屋-卡片转职中使用"
    });
    register_goods("credit_cold_drew_1", {
        type: "credit", cost: "8000", coin_type: "prestige", credit_shape: 1,
        unlock_item_id: transfer_credit_id("cold_drew", 1),
        description: "冰块冷萃机（一转凭证）\n在合成屋-卡片转职中使用"
    });
    register_goods("credit_cold_drew_2", {
        type: "credit", cost: "28500", coin_type: "prestige", credit_shape: 2,
        unlock_item_id: transfer_credit_id("cold_drew", 2),
        description: "冰块冷萃机（二转凭证）\n在合成屋-卡片转职中使用"
    });
    register_goods("credit_cotton_candy_1", {
        type: "credit", cost: "600", coin_type: "prestige", credit_shape: 1,
        unlock_item_id: transfer_credit_id("cotton_candy", 1),
        description: "棉花糖（一转凭证）\n在合成屋-卡片转职中使用"
    });
    register_goods("credit_cotton_candy_2", {
        type: "credit", cost: "7500", coin_type: "prestige", credit_shape: 2,
        unlock_item_id: transfer_credit_id("cotton_candy", 2),
        description: "棉花糖（二转凭证）\n在合成屋-卡片转职中使用"
    });
    register_goods("credit_curry_lobster_cannon_1", {
        type: "credit", cost: "5000", coin_type: "prestige", credit_shape: 1,
        unlock_item_id: transfer_credit_id("curry_lobster_cannon", 1),
        description: "咖喱龙虾炮（一转凭证）\n在合成屋-卡片转职中使用"
    });
    register_goods("credit_curry_lobster_cannon_2", {
        type: "credit", cost: "16500", coin_type: "prestige", credit_shape: 2,
        unlock_item_id: transfer_credit_id("curry_lobster_cannon", 2),
        description: "咖喱龙虾炮（二转凭证）\n在合成屋-卡片转职中使用"
    });
    register_goods("credit_donut_1", {
        type: "credit", cost: "7000", coin_type: "prestige", credit_shape: 1,
        unlock_item_id: transfer_credit_id("donut", 1),
        description: "梦幻多拿滋（一转凭证）\n在合成屋-卡片转职中使用"
    });
    register_goods("credit_donut_2", {
        type: "credit", cost: "33000", coin_type: "prestige", credit_shape: 2,
        unlock_item_id: transfer_credit_id("donut", 2),
        description: "梦幻多拿滋（二转凭证）\n在合成屋-卡片转职中使用"
    });
    register_goods("credit_double_water_pipe_1", {
        type: "credit", cost: "1500", coin_type: "prestige", credit_shape: 1,
        unlock_item_id: transfer_credit_id("double_water_pipe", 1),
        description: "双向水管（一转凭证）\n在合成屋-卡片转职中使用"
    });
    register_goods("credit_double_water_pipe_2", {
        type: "credit", cost: "7200", coin_type: "prestige", credit_shape: 2,
        unlock_item_id: transfer_credit_id("double_water_pipe", 2),
        description: "双向水管（二转凭证）\n在合成屋-卡片转职中使用"
    });
    register_goods("credit_egg_boiler_pult_1", {
        type: "credit", cost: "1900", coin_type: "prestige", credit_shape: 1,
        unlock_item_id: transfer_credit_id("egg_boiler_pult", 1),
        description: "煮蛋器投手（一转凭证）\n在合成屋-卡片转职中使用"
    });
    register_goods("credit_egg_boiler_pult_2", {
        type: "credit", cost: "11700", coin_type: "prestige", credit_shape: 2,
        unlock_item_id: transfer_credit_id("egg_boiler_pult", 2),
        description: "煮蛋器投手（二转凭证）\n在合成屋-卡片转职中使用"
    });
    register_goods("credit_fushengcha_1", {
        type: "credit", cost: "5000", coin_type: "prestige", credit_shape: 1,
        unlock_item_id: transfer_credit_id("fushengcha", 1),
        description: "浮生茶（一转凭证）\n在合成屋-卡片转职中使用"
    });
    register_goods("credit_fushengcha_2", {
        type: "credit", cost: "16500", coin_type: "prestige", credit_shape: 2,
        unlock_item_id: transfer_credit_id("fushengcha", 2),
        description: "浮生茶（二转凭证）\n在合成屋-卡片转职中使用"
    });
    register_goods("credit_gatlin_long_bao_1", {
        type: "credit", cost: "1900", coin_type: "prestige", credit_shape: 1,
        unlock_item_id: transfer_credit_id("gatlin_long_bao", 1),
        description: "机枪小笼包（一转凭证）\n在合成屋-卡片转职中使用"
    });
    register_goods("credit_gatlin_long_bao_2", {
        type: "credit", cost: "8700", coin_type: "prestige", credit_shape: 2,
        unlock_item_id: transfer_credit_id("gatlin_long_bao", 2),
        description: "机枪小笼包（二转凭证）\n在合成屋-卡片转职中使用"
    });
    register_goods("credit_goblet_lamp_1", {
        type: "credit", cost: "1900", coin_type: "prestige", credit_shape: 1,
        unlock_item_id: transfer_credit_id("goblet_lamp", 1),
        description: "酒杯灯（一转凭证）\n在合成屋-卡片转职中使用"
    });
    register_goods("credit_goblet_lamp_2", {
        type: "credit", cost: "11700", coin_type: "prestige", credit_shape: 2,
        unlock_item_id: transfer_credit_id("goblet_lamp", 2),
        description: "酒杯灯（二转凭证）\n在合成屋-卡片转职中使用"
    });
    register_goods("credit_grilled_lizard_pult_1", {
        type: "credit", cost: "7000", coin_type: "prestige", credit_shape: 1,
        unlock_item_id: transfer_credit_id("grilled_lizard_pult", 1),
        description: "烤蜥蜴投手（一转凭证）\n在合成屋-卡片转职中使用"
    });
    register_goods("credit_grilled_lizard_pult_2", {
        type: "credit", cost: "31500", coin_type: "prestige", credit_shape: 2,
        unlock_item_id: transfer_credit_id("grilled_lizard_pult", 2),
        description: "烤蜥蜴投手（二转凭证）\n在合成屋-卡片转职中使用"
    });
    register_goods("credit_hamburger_1", {
        type: "credit", cost: "2400", coin_type: "prestige", credit_shape: 1,
        unlock_item_id: transfer_credit_id("hamburger", 1),
        description: "汉堡包（一转凭证）\n在合成屋-卡片转职中使用"
    });
    register_goods("credit_hamburger_2", {
        type: "credit", cost: "15000", coin_type: "prestige", credit_shape: 2,
        unlock_item_id: transfer_credit_id("hamburger", 2),
        description: "汉堡包（二转凭证）\n在合成屋-卡片转职中使用"
    });
    register_goods("credit_hongliukaochuan_1", {
        type: "credit", cost: "7000", coin_type: "prestige", credit_shape: 1,
        unlock_item_id: transfer_credit_id("hongliukaochuan", 1),
        description: "红柳烤串机（一转凭证）\n在合成屋-卡片转职中使用"
    });
    register_goods("credit_hongliukaochuan_2", {
        type: "credit", cost: "24000", coin_type: "prestige", credit_shape: 2,
        unlock_item_id: transfer_credit_id("hongliukaochuan", 2),
        description: "红柳烤串机（二转凭证）\n在合成屋-卡片转职中使用"
    });
    register_goods("credit_horseshoe_crab_bread_1", {
        type: "credit", cost: "1500", coin_type: "prestige", credit_shape: 1,
        unlock_item_id: transfer_credit_id("horseshoe_crab_bread", 1),
        description: "老虎蟹面包（一转凭证）\n在合成屋-卡片转职中使用"
    });
    register_goods("credit_hotdog_cannon_1", {
        type: "credit", cost: "1900", coin_type: "prestige", credit_shape: 1,
        unlock_item_id: transfer_credit_id("hotdog_cannon", 1),
        description: "热狗大炮（一转凭证）\n在合成屋-卡片转职中使用"
    });
    register_goods("credit_hotdog_cannon_2", {
        type: "credit", cost: "10500", coin_type: "prestige", credit_shape: 2,
        unlock_item_id: transfer_credit_id("hotdog_cannon", 2),
        description: "热狗大炮（二转凭证）\n在合成屋-卡片转职中使用"
    });
    register_goods("credit_hspeed_juicer_1", {
        type: "credit", cost: "5000", coin_type: "prestige", credit_shape: 1,
        unlock_item_id: transfer_credit_id("hspeed_juicer", 1),
        description: "加速榨汁机（一转凭证）\n在合成屋-卡片转职中使用"
    });
    register_goods("credit_hspeed_juicer_2", {
        type: "credit", cost: "18000", coin_type: "prestige", credit_shape: 2,
        unlock_item_id: transfer_credit_id("hspeed_juicer", 2),
        description: "加速榨汁机（二转凭证）\n在合成屋-卡片转职中使用"
    });
    register_goods("credit_huagao_1", {
        type: "credit", cost: "9000", coin_type: "prestige", credit_shape: 1,
        unlock_item_id: transfer_credit_id("huagao", 1),
        description: "灯影花糕（一转凭证）\n在合成屋-卡片转职中使用"
    });
    register_goods("credit_huagao_2", {
        type: "credit", cost: "25500", coin_type: "prestige", credit_shape: 2,
        unlock_item_id: transfer_credit_id("huagao", 2),
        description: "灯影花糕（二转凭证）\n在合成屋-卡片转职中使用"
    });
    register_goods("credit_ice_bucket_bomb_1", {
        type: "credit", cost: "5000", coin_type: "prestige", credit_shape: 1,
        unlock_item_id: transfer_credit_id("ice_bucket_bomb", 1),
        description: "冰桶炸弹（一转凭证）\n在合成屋-卡片转职中使用"
    });
    register_goods("credit_ice_bucket_bomb_2", {
        type: "credit", cost: "22500", coin_type: "prestige", credit_shape: 2,
        unlock_item_id: transfer_credit_id("ice_bucket_bomb", 2),
        description: "冰桶炸弹（二转凭证）\n在合成屋-卡片转职中使用"
    });
    register_goods("credit_ice_cream_1", {
        type: "credit", cost: "1900", coin_type: "prestige", credit_shape: 1,
        unlock_item_id: transfer_credit_id("ice_cream", 1),
        description: "冰激凌（一转凭证）\n在合成屋-卡片转职中使用"
    });
    register_goods("credit_ice_cream_2", {
        type: "credit", cost: "8700", coin_type: "prestige", credit_shape: 2,
        unlock_item_id: transfer_credit_id("ice_cream", 2),
        description: "冰激凌（二转凭证）\n在合成屋-卡片转职中使用"
    });
    register_goods("credit_ice_egg_boiler_pult_1", {
        type: "credit", cost: "1650", coin_type: "prestige", credit_shape: 1,
        unlock_item_id: transfer_credit_id("ice_egg_boiler_pult", 1),
        description: "冰煮蛋器（一转凭证）\n在合成屋-卡片转职中使用"
    });
    register_goods("credit_ice_egg_boiler_pult_2", {
        type: "credit", cost: "7200", coin_type: "prestige", credit_shape: 2,
        unlock_item_id: transfer_credit_id("ice_egg_boiler_pult", 2),
        description: "冰煮蛋器（二转凭证）\n在合成屋-卡片转职中使用"
    });
    register_goods("credit_iron_fishbone_1", {
        type: "credit", cost: "1100", coin_type: "prestige", credit_shape: 1,
        unlock_item_id: transfer_credit_id("iron_fishbone", 1),
        description: "钢鱼刺（一转凭证）\n在合成屋-卡片转职中使用"
    });
    register_goods("credit_iron_fishbone_2", {
        type: "credit", cost: "7200", coin_type: "prestige", credit_shape: 2,
        unlock_item_id: transfer_credit_id("iron_fishbone", 2),
        description: "钢鱼刺（二转凭证）\n在合成屋-卡片转职中使用"
    });
    register_goods("credit_king_long_bao_1", {
        type: "credit", cost: "4000", coin_type: "prestige", credit_shape: 1,
        unlock_item_id: transfer_credit_id("king_long_bao", 1),
        description: "国王小笼包（一转凭证）\n在合成屋-卡片转职中使用"
    });
    register_goods("credit_king_long_bao_2", {
        type: "credit", cost: "13500", coin_type: "prestige", credit_shape: 2,
        unlock_item_id: transfer_credit_id("king_long_bao", 2),
        description: "国王小笼包（二转凭证）\n在合成屋-卡片转职中使用"
    });
    register_goods("credit_king_triple_long_bao_1", {
        type: "credit", cost: "3000", coin_type: "prestige", credit_shape: 1,
        unlock_item_id: transfer_credit_id("king_triple_long_bao", 1),
        description: "三向国王小笼包（一转凭证）\n在合成屋-卡片转职中使用"
    });
    register_goods("credit_king_triple_long_bao_2", {
        type: "credit", cost: "10500", coin_type: "prestige", credit_shape: 2,
        unlock_item_id: transfer_credit_id("king_triple_long_bao", 2),
        description: "三向国王小笼包（二转凭证）\n在合成屋-卡片转职中使用"
    });
    register_goods("credit_large_fire_1", {
        type: "credit", cost: "1500", coin_type: "prestige", credit_shape: 1,
        unlock_item_id: transfer_credit_id("large_fire", 1),
        description: "大火炉（一转凭证）\n在合成屋-卡片转职中使用"
    });
    register_goods("credit_large_fire_2", {
        type: "credit", cost: "7200", coin_type: "prestige", credit_shape: 2,
        unlock_item_id: transfer_credit_id("large_fire", 2),
        description: "大火炉（二转凭证）\n在合成屋-卡片转职中使用"
    });
    register_goods("credit_lightning_baguette_1", {
        type: "credit", cost: "1900", coin_type: "prestige", credit_shape: 1,
        unlock_item_id: transfer_credit_id("lightning_baguette", 1),
        description: "雷电长棍面包（一转凭证）\n在合成屋-卡片转职中使用"
    });
    register_goods("credit_lightning_baguette_2", {
        type: "credit", cost: "11700", coin_type: "prestige", credit_shape: 2,
        unlock_item_id: transfer_credit_id("lightning_baguette", 2),
        description: "雷电长棍面包（二转凭证）\n在合成屋-卡片转职中使用"
    });
    register_goods("credit_melon_shield_1", {
        type: "credit", cost: "900", coin_type: "prestige", credit_shape: 1,
        unlock_item_id: transfer_credit_id("melon_shield", 1),
        description: "瓜皮护罩（一转凭证）\n在合成屋-卡片转职中使用"
    });
    register_goods("credit_melon_shield_2", {
        type: "credit", cost: "10500", coin_type: "prestige", credit_shape: 2,
        unlock_item_id: transfer_credit_id("melon_shield", 2),
        description: "瓜皮护罩（二转凭证）\n在合成屋-卡片转职中使用"
    });
    register_goods("credit_mixian_1", {
        type: "credit", cost: "2600", coin_type: "prestige", credit_shape: 1,
        unlock_item_id: transfer_credit_id("mixian", 1),
        description: "桥头米线（一转凭证）\n在合成屋-卡片转职中使用"
    });
    register_goods("credit_mixian_2", {
        type: "credit", cost: "12000", coin_type: "prestige", credit_shape: 2,
        unlock_item_id: transfer_credit_id("mixian", 2),
        description: "桥头米线（二转凭证）\n在合成屋-卡片转职中使用"
    });
    register_goods("credit_mouse_clip_1", {
        type: "credit", cost: "1100", coin_type: "prestige", credit_shape: 1,
        unlock_item_id: transfer_credit_id("mouse_clip", 1),
        description: "老鼠夹子（一转凭证）\n在合成屋-卡片转职中使用"
    });
    register_goods("credit_mouse_clip_2", {
        type: "credit", cost: "7200", coin_type: "prestige", credit_shape: 2,
        unlock_item_id: transfer_credit_id("mouse_clip", 2),
        description: "老鼠夹子（二转凭证）\n在合成屋-卡片转职中使用"
    });
    register_goods("credit_oden_pot_1", {
        type: "credit", cost: "6000", coin_type: "prestige", credit_shape: 1,
        unlock_item_id: transfer_credit_id("oden_pot", 1),
        description: "关东煮喷锅（一转凭证）\n在合成屋-卡片转职中使用"
    });
    register_goods("credit_oden_pot_2", {
        type: "credit", cost: "24000", coin_type: "prestige", credit_shape: 2,
        unlock_item_id: transfer_credit_id("oden_pot", 2),
        description: "关东煮喷锅（二转凭证）\n在合成屋-卡片转职中使用"
    });
    register_goods("credit_oil_lamp_1", {
        type: "credit", cost: "900", coin_type: "prestige", credit_shape: 1,
        unlock_item_id: transfer_credit_id("oil_lamp", 1),
        description: "油灯（一转凭证）\n在合成屋-卡片转职中使用"
    });
    register_goods("credit_pan_fried_bun_1", {
        type: "credit", cost: "8000", coin_type: "prestige", credit_shape: 1,
        unlock_item_id: transfer_credit_id("pan_fried_bun", 1),
        description: "生煎锅（一转凭证）\n在合成屋-卡片转职中使用"
    });
    register_goods("credit_pan_fried_bun_2", {
        type: "credit", cost: "30000", coin_type: "prestige", credit_shape: 2,
        unlock_item_id: transfer_credit_id("pan_fried_bun", 2),
        description: "生煎锅（二转凭证）\n在合成屋-卡片转职中使用"
    });
    register_goods("credit_pineapple_explosive_bread_1", {
        type: "credit", cost: "1100", coin_type: "prestige", credit_shape: 1,
        unlock_item_id: transfer_credit_id("pineapple_explosive_bread", 1),
        description: "菠萝爆炸面包（一转凭证）\n在合成屋-卡片转职中使用"
    });
    register_goods("credit_pineapple_explosive_bread_2", {
        type: "credit", cost: "5400", coin_type: "prestige", credit_shape: 2,
        unlock_item_id: transfer_credit_id("pineapple_explosive_bread", 2),
        description: "菠萝爆炸面包（二转凭证）\n在合成屋-卡片转职中使用"
    });
    register_goods("credit_pizza_oven_1", {
        type: "credit", cost: "4000", coin_type: "prestige", credit_shape: 1,
        unlock_item_id: transfer_credit_id("pizza_oven", 1),
        description: "迷你披萨炉（一转凭证）\n在合成屋-卡片转职中使用"
    });
    register_goods("credit_pizza_oven_2", {
        type: "credit", cost: "15000", coin_type: "prestige", credit_shape: 2,
        unlock_item_id: transfer_credit_id("pizza_oven", 2),
        description: "迷你披萨炉（二转凭证）\n在合成屋-卡片转职中使用"
    });
    register_goods("credit_rotating_coffee_pot_1", {
        type: "credit", cost: "1900", coin_type: "prestige", credit_shape: 1,
        unlock_item_id: transfer_credit_id("rotating_coffee_pot", 1),
        description: "旋转咖啡喷壶（一转凭证）\n在合成屋-卡片转职中使用"
    });
    register_goods("credit_rotating_coffee_pot_2", {
        type: "credit", cost: "10500", coin_type: "prestige", credit_shape: 2,
        unlock_item_id: transfer_credit_id("rotating_coffee_pot", 2),
        description: "旋转咖啡喷壶（二转凭证）\n在合成屋-卡片转职中使用"
    });
    register_goods("credit_shuanggu_1", {
        type: "credit", cost: "2600", coin_type: "prestige", credit_shape: 1,
        unlock_item_id: transfer_credit_id("shuanggu", 1),
        description: "蚝油双菇（一转凭证）\n在合成屋-卡片转职中使用"
    });
    register_goods("credit_shuanggu_2", {
        type: "credit", cost: "11100", coin_type: "prestige", credit_shape: 2,
        unlock_item_id: transfer_credit_id("shuanggu", 2),
        description: "蚝油双菇（二转凭证）\n在合成屋-卡片转职中使用"
    });
    register_goods("credit_small_fire_1", {
        type: "credit", cost: "1900", coin_type: "prestige", credit_shape: 1,
        unlock_item_id: transfer_credit_id("small_fire", 1),
        description: "小火炉（一转凭证）\n在合成屋-卡片转职中使用"
    });
    register_goods("credit_small_fire_2", {
        type: "credit", cost: "11700", coin_type: "prestige", credit_shape: 2,
        unlock_item_id: transfer_credit_id("small_fire", 2),
        description: "小火炉（二转凭证）\n在合成屋-卡片转职中使用"
    });
    register_goods("credit_soda_bubble_1", {
        type: "credit", cost: "2100", coin_type: "prestige", credit_shape: 1,
        unlock_item_id: transfer_credit_id("soda_bubble", 1),
        description: "苏打气泡（一转凭证）\n在合成屋-卡片转职中使用"
    });
    register_goods("credit_spicy_pot_1", {
        type: "credit", cost: "8000", coin_type: "prestige", credit_shape: 1,
        unlock_item_id: transfer_credit_id("spicy_pot", 1),
        description: "麻辣香锅（一转凭证）\n在合成屋-卡片转职中使用"
    });
    register_goods("credit_spicy_pot_2", {
        type: "credit", cost: "30000", coin_type: "prestige", credit_shape: 2,
        unlock_item_id: transfer_credit_id("spicy_pot", 2),
        description: "麻辣香锅（二转凭证）\n在合成屋-卡片转职中使用"
    });
    register_goods("credit_sugar_ball_pult_1", {
        type: "credit", cost: "7600", coin_type: "prestige", credit_shape: 1,
        unlock_item_id: transfer_credit_id("sugar_ball_pult", 1),
        description: "全能糖球投手（一转凭证）\n在合成屋-卡片转职中使用"
    });
    register_goods("credit_sugar_ball_pult_2", {
        type: "credit", cost: "32700", coin_type: "prestige", credit_shape: 2,
        unlock_item_id: transfer_credit_id("sugar_ball_pult", 2),
        description: "全能糖球投手（二转凭证）\n在合成屋-卡片转职中使用"
    });
    register_goods("credit_takoyaki_1", {
        type: "credit", cost: "1900", coin_type: "prestige", credit_shape: 1,
        unlock_item_id: transfer_credit_id("takoyaki", 1),
        description: "章鱼烧（一转凭证）\n在合成屋-卡片转职中使用"
    });
    register_goods("credit_takoyaki_2", {
        type: "credit", cost: "8700", coin_type: "prestige", credit_shape: 2,
        unlock_item_id: transfer_credit_id("takoyaki", 2),
        description: "章鱼烧（二转凭证）\n在合成屋-卡片转职中使用"
    });
    register_goods("credit_tang_hu_lu_1", {
        type: "credit", cost: "8000", coin_type: "prestige", credit_shape: 1,
        unlock_item_id: transfer_credit_id("tang_hu_lu", 1),
        description: "糖葫芦炮弹（一转凭证）\n在合成屋-卡片转职中使用"
    });
    register_goods("credit_tang_hu_lu_2", {
        type: "credit", cost: "30000", coin_type: "prestige", credit_shape: 2,
        unlock_item_id: transfer_credit_id("tang_hu_lu", 2),
        description: "糖葫芦炮弹（二转凭证）\n在合成屋-卡片转职中使用"
    });
    register_goods("credit_triple_wine_rack_1", {
        type: "credit", cost: "1900", coin_type: "prestige", credit_shape: 1,
        unlock_item_id: transfer_credit_id("triple_wine_rack", 1),
        description: "三线酒架（一转凭证）\n在合成屋-卡片转职中使用"
    });
    register_goods("credit_triple_wine_rack_2", {
        type: "credit", cost: "11700", coin_type: "prestige", credit_shape: 2,
        unlock_item_id: transfer_credit_id("triple_wine_rack", 2),
        description: "三线酒架（二转凭证）\n在合成屋-卡片转职中使用"
    });
    register_goods("credit_whisky_bomb_1", {
        type: "credit", cost: "7000", coin_type: "prestige", credit_shape: 1,
        unlock_item_id: transfer_credit_id("whisky_bomb", 1),
        description: "威士忌炸弹（一转凭证）\n在合成屋-卡片转职中使用"
    });
    register_goods("credit_whisky_bomb_2", {
        type: "credit", cost: "29700", coin_type: "prestige", credit_shape: 2,
        unlock_item_id: transfer_credit_id("whisky_bomb", 2),
        description: "威士忌炸弹（二转凭证）\n在合成屋-卡片转职中使用"
    });
    register_goods("credit_wooden_plate_1", {
        type: "credit", cost: "900", coin_type: "prestige", credit_shape: 1,
        unlock_item_id: transfer_credit_id("wooden_plate", 1),
        description: "木盘子（一转凭证）\n在合成屋-卡片转职中使用"
    });
    register_goods("credit_wooden_plate_2", {
        type: "credit", cost: "11400", coin_type: "prestige", credit_shape: 2,
        unlock_item_id: transfer_credit_id("wooden_plate", 2),
        description: "木盘子（二转凭证）\n在合成屋-卡片转职中使用"
    });
    register_goods("credit_xinjiang_fried_noodles_1", {
        type: "credit", cost: "4000", coin_type: "prestige", credit_shape: 1,
        unlock_item_id: transfer_credit_id("xinjiang_fried_noodles", 1),
        description: "新疆炒面（一转凭证）\n在合成屋-卡片转职中使用"
    });
    register_goods("credit_xinjiang_fried_noodles_2", {
        type: "credit", cost: "15000", coin_type: "prestige", credit_shape: 2,
        unlock_item_id: transfer_credit_id("xinjiang_fried_noodles", 2),
        description: "新疆炒面（二转凭证）\n在合成屋-卡片转职中使用"
    });
}
