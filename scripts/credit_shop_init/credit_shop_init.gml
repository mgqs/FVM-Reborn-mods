/// 转职凭证商店注册（2026-10-25 建；2026-10-27 按用户「魔塔价格奖励建议表.xlsx」**全量重写**）
/// 2026-10-28：`tower_floor` 按同表新增的「建议一转层数 / 建议二转层数」两列**逐卡重刷**
///   （195 条全部写死；旧值 = 表里的「层数(默认1-1)一转层 / 层数(默认15-1)二转层」列）
/// 商品 type = "credit"：只进商店新增的「转职凭证」页，不会出现在道具页/其它页
/// 字段：
///   coin_type     "prestige" = 花威望 / "gold" = 花金币
///   credit_shape  0 = 兑换项（不是凭证）/ 1 = 一转 / 2 = 二转（分类页签按它过滤）
///   reward_prestige  兑换项专用：买完加多少威望
///   tower_floor   爬塔门槛（**表里逐卡给了值就写在这里**；没写的走 transfer_credit.gml 的默认表）
///                  写法：`"12-2"` = 需通关魔塔 12-2 / `12` = 该层第一小关
///                  默认表 `credit_shop_tower_defaults()`：一转 1-1 / 二转 15-1 / 兑换项 35-3
///                  判定分两层：置灰只看 transfer_credit_buyable_locked()（形态不存在/已转职；**不限量**）；
///                  爬塔门槛与余额不足只在点购买时弹提示，不置灰
/// 🔴 **不开 display_name**：商店对凭证是用 transfer_credit_name_from_id(unlock_item_id) 实时取名，
///    写死的名字迟早过期（2026-10-27 已把老的 display_name 全部删掉）
/// ⚠️ 三/四/终转凭证在诸神商店（gods_shop_init 的 type "tvoucher"），不进这张表
function credit_shop_init()
{
    // ── 威望兑换（测试期临时项）：10000000 金币 → 100000 威望 ──
    register_goods("prestige_exchange_100000", {
        type: "credit",
        cost: "10000000",
        coin_type: "gold",
        credit_shape: 0,
        unlock_item_id: "prestige",
        // 🔴 兑换项**必须有 display_name**：它是唯一一条 credit_shape == 0 的商品，
        //    商店建按钮时走 `_ci.display_name` 分支（凭证走实时取名）→ 缺这个键直接崩，
        //    而且它被排序键垫到最后一页（第 13 页），所以表现为「商店第 13 页打不开」
        display_name: "威望",
        description: "用 10000000 金币兑换 100000 威望",
        reward_prestige: 100000
    });

    // ── 一转凭证（101 条）─────────────────────────────────────────
    register_goods("credit_wooden_plate_1", {
        type: "credit", cost: "900", coin_type: "prestige", credit_shape: 1,
        tower_floor: "1-1",
        unlock_item_id: transfer_credit_id("wooden_plate", 1),
        description: "一转凭证\n在合成屋-卡片转职中使用"
    });

    register_goods("credit_oil_lamp_1", {
        type: "credit", cost: "900", coin_type: "prestige", credit_shape: 1,
        tower_floor: "1-2",
        unlock_item_id: transfer_credit_id("oil_lamp", 1),
        description: "一转凭证\n在合成屋-卡片转职中使用"
    });

    register_goods("credit_goblet_lamp_1", {
        type: "credit", cost: "1900", coin_type: "prestige", credit_shape: 1,
        tower_floor: "1-2",
        unlock_item_id: transfer_credit_id("goblet_lamp", 1),
        description: "一转凭证\n在合成屋-卡片转职中使用"
    });

    register_goods("credit_gatlin_long_bao_1", {
        type: "credit", cost: "1900", coin_type: "prestige", credit_shape: 1,
        tower_floor: "1-1",
        unlock_item_id: transfer_credit_id("gatlin_long_bao", 1),
        description: "一转凭证\n在合成屋-卡片转职中使用"
    });

    register_goods("credit_iron_fishbone_1", {
        type: "credit", cost: "1100", coin_type: "prestige", credit_shape: 1,
        tower_floor: "3-2",
        unlock_item_id: transfer_credit_id("iron_fishbone", 1),
        description: "一转凭证\n在合成屋-卡片转职中使用"
    });

    register_goods("credit_rotating_coffee_pot_1", {
        type: "credit", cost: "1900", coin_type: "prestige", credit_shape: 1,
        tower_floor: "3-2",
        unlock_item_id: transfer_credit_id("rotating_coffee_pot", 1),
        description: "一转凭证\n在合成屋-卡片转职中使用"
    });

    register_goods("credit_takoyaki_1", {
        type: "credit", cost: "1900", coin_type: "prestige", credit_shape: 1,
        tower_floor: "1-1",
        unlock_item_id: transfer_credit_id("takoyaki", 1),
        description: "一转凭证\n在合成屋-卡片转职中使用"
    });

    register_goods("credit_large_fire_1", {
        type: "credit", cost: "1500", coin_type: "prestige", credit_shape: 1,
        tower_floor: "1-2",
        unlock_item_id: transfer_credit_id("large_fire", 1),
        description: "一转凭证\n在合成屋-卡片转职中使用"
    });

    register_goods("credit_small_fire_1", {
        type: "credit", cost: "1900", coin_type: "prestige", credit_shape: 1,
        tower_floor: "2-1",
        unlock_item_id: transfer_credit_id("small_fire", 1),
        description: "一转凭证\n在合成屋-卡片转职中使用"
    });

    register_goods("credit_ice_egg_boiler_pult_1", {
        type: "credit", cost: "1500", coin_type: "prestige", credit_shape: 1,
        tower_floor: "6-2",
        unlock_item_id: transfer_credit_id("ice_egg_boiler_pult", 1),
        description: "一转凭证\n在合成屋-卡片转职中使用"
    });

    register_goods("credit_cherry_pudding_1", {
        type: "credit", cost: "1900", coin_type: "prestige", credit_shape: 1,
        tower_floor: "6-2",
        unlock_item_id: transfer_credit_id("cherry_pudding", 1),
        description: "一转凭证\n在合成屋-卡片转职中使用"
    });

    register_goods("credit_melon_shield_1", {
        type: "credit", cost: "900", coin_type: "prestige", credit_shape: 1,
        tower_floor: "3-2",
        unlock_item_id: transfer_credit_id("melon_shield", 1),
        description: "一转凭证\n在合成屋-卡片转职中使用"
    });

    register_goods("credit_chocolate_pult_1", {
        type: "credit", cost: "1900", coin_type: "prestige", credit_shape: 1,
        tower_floor: "6-2",
        unlock_item_id: transfer_credit_id("chocolate_pult", 1),
        description: "一转凭证\n在合成屋-卡片转职中使用"
    });

    register_goods("credit_triple_wine_rack_1", {
        type: "credit", cost: "1900", coin_type: "prestige", credit_shape: 1,
        tower_floor: "3-2",
        unlock_item_id: transfer_credit_id("triple_wine_rack", 1),
        description: "一转凭证\n在合成屋-卡片转职中使用"
    });

    register_goods("credit_salad_pult_1", {
        type: "credit", cost: "1900", coin_type: "prestige", credit_shape: 1,
        tower_floor: "1-1",
        unlock_item_id: transfer_credit_id("salad_pult", 1),
        description: "一转凭证\n在合成屋-卡片转职中使用"
    });

    register_goods("credit_brazier_1", {
        type: "credit", cost: "6000", coin_type: "prestige", credit_shape: 1,
        tower_floor: "6-2",
        unlock_item_id: transfer_credit_id("brazier", 1),
        description: "一转凭证\n在合成屋-卡片转职中使用"
    });

    register_goods("credit_stinky_tofu_pult_1", {
        type: "credit", cost: "1900", coin_type: "prestige", credit_shape: 1,
        tower_floor: "3-2",
        unlock_item_id: transfer_credit_id("stinky_tofu_pult", 1),
        description: "一转凭证\n在合成屋-卡片转职中使用"
    });

    register_goods("credit_egg_boiler_pult_1", {
        type: "credit", cost: "1900", coin_type: "prestige", credit_shape: 1,
        tower_floor: "6-2",
        unlock_item_id: transfer_credit_id("egg_boiler_pult", 1),
        description: "一转凭证\n在合成屋-卡片转职中使用"
    });

    register_goods("credit_firework_dragon_1", {
        type: "credit", cost: "3800", coin_type: "prestige", credit_shape: 1,
        tower_floor: "13-2",
        unlock_item_id: transfer_credit_id("firework_dragon", 1),
        description: "一转凭证\n在合成屋-卡片转职中使用"
    });

    register_goods("credit_hamburger_1", {
        type: "credit", cost: "2400", coin_type: "prestige", credit_shape: 1,
        tower_floor: "9-2",
        unlock_item_id: transfer_credit_id("hamburger", 1),
        description: "一转凭证\n在合成屋-卡片转职中使用"
    });

    register_goods("credit_hotdog_cannon_1", {
        type: "credit", cost: "1900", coin_type: "prestige", credit_shape: 1,
        tower_floor: "9-2",
        unlock_item_id: transfer_credit_id("hotdog_cannon", 1),
        description: "一转凭证\n在合成屋-卡片转职中使用"
    });

    register_goods("credit_tar_sprayer_1", {
        type: "credit", cost: "3400", coin_type: "prestige", credit_shape: 1,
        tower_floor: "9-2",
        unlock_item_id: transfer_credit_id("tar_sprayer", 1),
        description: "一转凭证\n在合成屋-卡片转职中使用"
    });

    register_goods("credit_oden_pot_1", {
        type: "credit", cost: "6000", coin_type: "prestige", credit_shape: 1,
        tower_floor: "9-2",
        unlock_item_id: transfer_credit_id("oden_pot", 1),
        description: "一转凭证\n在合成屋-卡片转职中使用"
    });

    register_goods("credit_cotton_candy_1", {
        type: "credit", cost: "600", coin_type: "prestige", credit_shape: 1,
        tower_floor: "9-2",
        unlock_item_id: transfer_credit_id("cotton_candy", 1),
        description: "一转凭证\n在合成屋-卡片转职中使用"
    });

    register_goods("credit_flour_sack_1", {
        type: "credit", cost: "4000", coin_type: "prestige", credit_shape: 1,
        tower_floor: "6-2",
        unlock_item_id: transfer_credit_id("flour_sack", 1),
        description: "一转凭证\n在合成屋-卡片转职中使用"
    });

    register_goods("credit_coke_bomb_1", {
        type: "credit", cost: "5000", coin_type: "prestige", credit_shape: 1,
        tower_floor: "9-2",
        unlock_item_id: transfer_credit_id("coke_bomb", 1),
        description: "一转凭证\n在合成屋-卡片转职中使用"
    });

    register_goods("credit_wine_bottle_bomb_1", {
        type: "credit", cost: "5000", coin_type: "prestige", credit_shape: 1,
        tower_floor: "8-2",
        unlock_item_id: transfer_credit_id("wine_bottle_bomb", 1),
        description: "一转凭证\n在合成屋-卡片转职中使用"
    });

    register_goods("credit_whisky_bomb_1", {
        type: "credit", cost: "7000", coin_type: "prestige", credit_shape: 1,
        tower_floor: "8-2",
        unlock_item_id: transfer_credit_id("whisky_bomb", 1),
        description: "一转凭证\n在合成屋-卡片转职中使用"
    });

    register_goods("credit_ice_bucket_bomb_1", {
        type: "credit", cost: "5000", coin_type: "prestige", credit_shape: 1,
        tower_floor: "8-2",
        unlock_item_id: transfer_credit_id("ice_bucket_bomb", 1),
        description: "一转凭证\n在合成屋-卡片转职中使用"
    });

    register_goods("credit_kettle_bomb_1", {
        type: "credit", cost: "5000", coin_type: "prestige", credit_shape: 1,
        tower_floor: "8-2",
        unlock_item_id: transfer_credit_id("kettle_bomb", 1),
        description: "一转凭证\n在合成屋-卡片转职中使用"
    });

    register_goods("credit_pineapple_explosive_bread_1", {
        type: "credit", cost: "1100", coin_type: "prestige", credit_shape: 1,
        tower_floor: "6-1",
        unlock_item_id: transfer_credit_id("pineapple_explosive_bread", 1),
        description: "一转凭证\n在合成屋-卡片转职中使用"
    });

    register_goods("credit_ice_cream_1", {
        type: "credit", cost: "1900", coin_type: "prestige", credit_shape: 1,
        tower_floor: "15-1",
        unlock_item_id: transfer_credit_id("ice_cream", 1),
        description: "一转凭证\n在合成屋-卡片转职中使用"
    });

    register_goods("credit_lightning_baguette_1", {
        type: "credit", cost: "1900", coin_type: "prestige", credit_shape: 1,
        tower_floor: "8-1",
        unlock_item_id: transfer_credit_id("lightning_baguette", 1),
        description: "一转凭证\n在合成屋-卡片转职中使用"
    });

    register_goods("credit_chocolate_cannon_1", {
        type: "credit", cost: "1900", coin_type: "prestige", credit_shape: 1,
        tower_floor: "3-2",
        unlock_item_id: transfer_credit_id("chocolate_cannon", 1),
        description: "一转凭证\n在合成屋-卡片转职中使用"
    });

    register_goods("credit_coffee_cup_1", {
        type: "credit", cost: "1900", coin_type: "prestige", credit_shape: 1,
        tower_floor: "1-1",
        unlock_item_id: transfer_credit_id("coffee_cup", 1),
        description: "一转凭证\n在合成屋-卡片转职中使用"
    });

    register_goods("credit_chocolate_bread_1", {
        type: "credit", cost: "1900", coin_type: "prestige", credit_shape: 1,
        tower_floor: "3-2",
        unlock_item_id: transfer_credit_id("chocolate_bread", 1),
        description: "一转凭证\n在合成屋-卡片转职中使用"
    });

    register_goods("credit_coffee_pot_1", {
        type: "credit", cost: "1700", coin_type: "prestige", credit_shape: 1,
        tower_floor: "1-1",
        unlock_item_id: transfer_credit_id("coffee_pot", 1),
        description: "一转凭证\n在合成屋-卡片转职中使用"
    });

    register_goods("credit_double_water_pipe_1", {
        type: "credit", cost: "1500", coin_type: "prestige", credit_shape: 1,
        tower_floor: "6-2",
        unlock_item_id: transfer_credit_id("double_water_pipe", 1),
        description: "一转凭证\n在合成屋-卡片转职中使用"
    });

    register_goods("credit_mouse_clip_1", {
        type: "credit", cost: "1100", coin_type: "prestige", credit_shape: 1,
        tower_floor: "1-1",
        unlock_item_id: transfer_credit_id("mouse_clip", 1),
        description: "一转凭证\n在合成屋-卡片转职中使用"
    });

    register_goods("credit_soda_bubble_1", {
        type: "credit", cost: "2100", coin_type: "prestige", credit_shape: 1,
        tower_floor: "6-2",
        unlock_item_id: transfer_credit_id("soda_bubble", 1),
        description: "一转凭证\n在合成屋-卡片转职中使用"
    });

    register_goods("credit_durian_1", {
        type: "credit", cost: "7500", coin_type: "prestige", credit_shape: 1,
        tower_floor: "6-2",
        unlock_item_id: transfer_credit_id("durian", 1),
        description: "一转凭证\n在合成屋-卡片转职中使用"
    });

    register_goods("credit_coffee_grounds_1", {
        type: "credit", cost: "1000", coin_type: "prestige", credit_shape: 1,
        tower_floor: "2-2",
        unlock_item_id: transfer_credit_id("coffee_grounds", 1),
        description: "一转凭证\n在合成屋-卡片转职中使用"
    });

    register_goods("credit_sugar_ball_pult_1", {
        type: "credit", cost: "7600", coin_type: "prestige", credit_shape: 1,
        tower_floor: "6-2",
        unlock_item_id: transfer_credit_id("sugar_ball_pult", 1),
        description: "一转凭证\n在合成屋-卡片转职中使用"
    });

    register_goods("credit_dragon_fruit_1", {
        type: "credit", cost: "7500", coin_type: "prestige", credit_shape: 1,
        tower_floor: "9-2",
        unlock_item_id: transfer_credit_id("dragon_fruit", 1),
        description: "一转凭证\n在合成屋-卡片转职中使用"
    });

    register_goods("credit_rabbit_lantern_1", {
        type: "credit", cost: "7500", coin_type: "prestige", credit_shape: 1,
        tower_floor: "12-2",
        unlock_item_id: transfer_credit_id("rabbit_lantern", 1),
        description: "一转凭证\n在合成屋-卡片转职中使用"
    });

    register_goods("credit_xinjiang_fried_noodles_1", {
        type: "credit", cost: "4000", coin_type: "prestige", credit_shape: 1,
        tower_floor: "12-2",
        unlock_item_id: transfer_credit_id("xinjiang_fried_noodles", 1),
        description: "一转凭证\n在合成屋-卡片转职中使用"
    });

    register_goods("credit_aquarius_elve_1", {
        type: "credit", cost: "7000", coin_type: "prestige", credit_shape: 1,
        tower_floor: "12-2",
        unlock_item_id: transfer_credit_id("aquarius_elve", 1),
        description: "一转凭证\n在合成屋-卡片转职中使用"
    });

    register_goods("credit_king_long_bao_1", {
        type: "credit", cost: "4000", coin_type: "prestige", credit_shape: 1,
        tower_floor: "11-1",
        unlock_item_id: transfer_credit_id("king_long_bao", 1),
        description: "一转凭证\n在合成屋-卡片转职中使用"
    });

    register_goods("credit_king_triple_long_bao_1", {
        type: "credit", cost: "3000", coin_type: "prestige", credit_shape: 1,
        tower_floor: "12-2",
        unlock_item_id: transfer_credit_id("king_triple_long_bao", 1),
        description: "一转凭证\n在合成屋-卡片转职中使用"
    });

    register_goods("credit_pizza_oven_1", {
        type: "credit", cost: "4000", coin_type: "prestige", credit_shape: 1,
        tower_floor: "9-2",
        unlock_item_id: transfer_credit_id("pizza_oven", 1),
        description: "一转凭证\n在合成屋-卡片转职中使用"
    });

    register_goods("credit_chili_powder_1", {
        type: "credit", cost: "3000", coin_type: "prestige", credit_shape: 1,
        tower_floor: "7-2",
        unlock_item_id: transfer_credit_id("chili_powder", 1),
        description: "一转凭证\n在合成屋-卡片转职中使用"
    });

    register_goods("credit_bull_firework_1", {
        type: "credit", cost: "10000", coin_type: "prestige", credit_shape: 1,
        tower_floor: "15-2",
        unlock_item_id: transfer_credit_id("bull_firework", 1),
        description: "一转凭证\n在合成屋-卡片转职中使用"
    });

    register_goods("credit_curry_lobster_cannon_1", {
        type: "credit", cost: "5000", coin_type: "prestige", credit_shape: 1,
        tower_floor: "18-2",
        unlock_item_id: transfer_credit_id("curry_lobster_cannon", 1),
        description: "一转凭证\n在合成屋-卡片转职中使用"
    });

    register_goods("credit_beef_hotpot_1", {
        type: "credit", cost: "8000", coin_type: "prestige", credit_shape: 1,
        tower_floor: "15-2",
        unlock_item_id: transfer_credit_id("beef_hotpot", 1),
        description: "一转凭证\n在合成屋-卡片转职中使用"
    });

    register_goods("credit_spicy_pot_1", {
        type: "credit", cost: "8000", coin_type: "prestige", credit_shape: 1,
        tower_floor: "18-1",
        unlock_item_id: transfer_credit_id("spicy_pot", 1),
        description: "一转凭证\n在合成屋-卡片转职中使用"
    });

    register_goods("credit_pan_fried_bun_1", {
        type: "credit", cost: "8000", coin_type: "prestige", credit_shape: 1,
        tower_floor: "18-1",
        unlock_item_id: transfer_credit_id("pan_fried_bun", 1),
        description: "一转凭证\n在合成屋-卡片转职中使用"
    });

    register_goods("credit_horseshoe_crab_bread_1", {
        type: "credit", cost: "1500", coin_type: "prestige", credit_shape: 1,
        tower_floor: "18-2",
        unlock_item_id: transfer_credit_id("horseshoe_crab_bread", 1),
        description: "一转凭证\n在合成屋-卡片转职中使用"
    });

    register_goods("credit_tang_hu_lu_1", {
        type: "credit", cost: "8000", coin_type: "prestige", credit_shape: 1,
        tower_floor: "18-2",
        unlock_item_id: transfer_credit_id("tang_hu_lu", 1),
        description: "一转凭证\n在合成屋-卡片转职中使用"
    });

    register_goods("credit_coal_starfish_1", {
        type: "credit", cost: "3600", coin_type: "prestige", credit_shape: 1,
        tower_floor: "9-2",
        unlock_item_id: transfer_credit_id("coal_starfish", 1),
        description: "一转凭证\n在合成屋-卡片转职中使用"
    });

    register_goods("credit_corn_shooter_1", {
        type: "credit", cost: "3800", coin_type: "prestige", credit_shape: 1,
        tower_floor: "1-1",
        unlock_item_id: transfer_credit_id("corn_shooter", 1),
        description: "一转凭证\n在合成屋-卡片转职中使用"
    });

    register_goods("credit_shizi_1", {
        type: "credit", cost: "3800", coin_type: "prestige", credit_shape: 1,
        tower_floor: "3-2",
        unlock_item_id: transfer_credit_id("shizi", 1),
        description: "一转凭证\n在合成屋-卡片转职中使用"
    });

    register_goods("credit_juxie_1", {
        type: "credit", cost: "3800", coin_type: "prestige", credit_shape: 1,
        tower_floor: "1-1",
        unlock_item_id: transfer_credit_id("juxie", 1),
        description: "一转凭证\n在合成屋-卡片转职中使用"
    });

    register_goods("credit_shuangzi_1", {
        type: "credit", cost: "3800", coin_type: "prestige", credit_shape: 1,
        tower_floor: "3-2",
        unlock_item_id: transfer_credit_id("shuangzi", 1),
        description: "一转凭证\n在合成屋-卡片转职中使用"
    });

    register_goods("credit_warm_birds_1", {
        type: "credit", cost: "3000", coin_type: "prestige", credit_shape: 1,
        tower_floor: "3-2",
        unlock_item_id: transfer_credit_id("warm_birds", 1),
        description: "一转凭证\n在合成屋-卡片转职中使用"
    });

    register_goods("credit_hspeed_juicer_1", {
        type: "credit", cost: "5000", coin_type: "prestige", credit_shape: 1,
        tower_floor: "3-2",
        unlock_item_id: transfer_credit_id("hspeed_juicer", 1),
        description: "一转凭证\n在合成屋-卡片转职中使用"
    });

    register_goods("credit_shuangyu_1", {
        type: "credit", cost: "3800", coin_type: "prestige", credit_shape: 1,
        tower_floor: "6-2",
        unlock_item_id: transfer_credit_id("shuangyu", 1),
        description: "一转凭证\n在合成屋-卡片转职中使用"
    });

    register_goods("credit_tiancheng_1", {
        type: "credit", cost: "3000", coin_type: "prestige", credit_shape: 1,
        tower_floor: "6-2",
        unlock_item_id: transfer_credit_id("tiancheng", 1),
        description: "一转凭证\n在合成屋-卡片转职中使用"
    });

    register_goods("credit_chunv_1", {
        type: "credit", cost: "1800", coin_type: "prestige", credit_shape: 1,
        tower_floor: "3-2",
        unlock_item_id: transfer_credit_id("chunv", 1),
        description: "一转凭证\n在合成屋-卡片转职中使用"
    });

    register_goods("credit_sheshou_1", {
        type: "credit", cost: "3800", coin_type: "prestige", credit_shape: 1,
        tower_floor: "3-2",
        unlock_item_id: transfer_credit_id("sheshou", 1),
        description: "一转凭证\n在合成屋-卡片转职中使用"
    });

    register_goods("credit_mojie_1", {
        type: "credit", cost: "9000", coin_type: "prestige", credit_shape: 1,
        tower_floor: "6-2",
        unlock_item_id: transfer_credit_id("mojie", 1),
        description: "一转凭证\n在合成屋-卡片转职中使用"
    });

    register_goods("credit_jinniu_1", {
        type: "credit", cost: "12000", coin_type: "prestige", credit_shape: 1,
        tower_floor: "6-2",
        unlock_item_id: transfer_credit_id("jinniu", 1),
        description: "一转凭证\n在合成屋-卡片转职中使用"
    });

    register_goods("credit_berry_dessert_1", {
        type: "credit", cost: "6000", coin_type: "prestige", credit_shape: 1,
        tower_floor: "6-2",
        unlock_item_id: transfer_credit_id("berry_dessert", 1),
        description: "一转凭证\n在合成屋-卡片转职中使用"
    });

    register_goods("credit_mozhang_1", {
        type: "credit", cost: "10000", coin_type: "prestige", credit_shape: 1,
        tower_floor: "9-2",
        unlock_item_id: transfer_credit_id("mozhang", 1),
        description: "一转凭证\n在合成屋-卡片转职中使用"
    });

    register_goods("credit_grilled_lizard_pult_1", {
        type: "credit", cost: "7000", coin_type: "prestige", credit_shape: 1,
        tower_floor: "9-2",
        unlock_item_id: transfer_credit_id("grilled_lizard_pult", 1),
        description: "一转凭证\n在合成屋-卡片转职中使用"
    });

    register_goods("credit_spoon_rabbit_1", {
        type: "credit", cost: "5700", coin_type: "prestige", credit_shape: 1,
        tower_floor: "9-2",
        unlock_item_id: transfer_credit_id("spoon_rabbit", 1),
        description: "一转凭证\n在合成屋-卡片转职中使用"
    });

    register_goods("credit_donut_1", {
        type: "credit", cost: "7000", coin_type: "prestige", credit_shape: 1,
        tower_floor: "9-2",
        unlock_item_id: transfer_credit_id("donut", 1),
        description: "一转凭证\n在合成屋-卡片转职中使用"
    });

    register_goods("credit_wanpilong_1", {
        type: "credit", cost: "2400", coin_type: "prestige", credit_shape: 1,
        tower_floor: "1-1",
        unlock_item_id: transfer_credit_id("wanpilong", 1),
        description: "一转凭证\n在合成屋-卡片转职中使用"
    });

    register_goods("credit_pufferfish_1", {
        type: "credit", cost: "2400", coin_type: "prestige", credit_shape: 1,
        tower_floor: "1-1",
        unlock_item_id: transfer_credit_id("pufferfish", 1),
        description: "一转凭证\n在合成屋-卡片转职中使用"
    });

    register_goods("credit_zhiyumiao_1", {
        type: "credit", cost: "5000", coin_type: "prestige", credit_shape: 1,
        tower_floor: "1-1",
        unlock_item_id: transfer_credit_id("zhiyumiao", 1),
        description: "一转凭证\n在合成屋-卡片转职中使用"
    });

    register_goods("credit_dandantu_1", {
        type: "credit", cost: "2400", coin_type: "prestige", credit_shape: 1,
        tower_floor: "3-2",
        unlock_item_id: transfer_credit_id("dandantu", 1),
        description: "一转凭证\n在合成屋-卡片转职中使用"
    });

    register_goods("credit_shegengbao_1", {
        type: "credit", cost: "2850", coin_type: "prestige", credit_shape: 1,
        tower_floor: "3-2",
        unlock_item_id: transfer_credit_id("shegengbao", 1),
        description: "一转凭证\n在合成屋-卡片转职中使用"
    });

    register_goods("credit_baobaoji_1", {
        type: "credit", cost: "2500", coin_type: "prestige", credit_shape: 1,
        tower_floor: "6-2",
        unlock_item_id: transfer_credit_id("baobaoji", 1),
        description: "一转凭证\n在合成屋-卡片转职中使用"
    });

    register_goods("credit_nizhuanniu_1", {
        type: "credit", cost: "8000", coin_type: "prestige", credit_shape: 1,
        tower_floor: "7-2",
        unlock_item_id: transfer_credit_id("nizhuanniu", 1),
        description: "一转凭证\n在合成屋-卡片转职中使用"
    });

    register_goods("credit_liehuohu_1", {
        type: "credit", cost: "3800", coin_type: "prestige", credit_shape: 1,
        tower_floor: "8-1",
        unlock_item_id: transfer_credit_id("liehuohu", 1),
        description: "一转凭证\n在合成屋-卡片转职中使用"
    });

    register_goods("credit_double_blade_snake_1", {
        type: "credit", cost: "6800", coin_type: "prestige", credit_shape: 1,
        tower_floor: "9-2",
        unlock_item_id: transfer_credit_id("double_blade_snake", 1),
        description: "一转凭证\n在合成屋-卡片转职中使用"
    });

    register_goods("credit_xuanfengniu_1", {
        type: "credit", cost: "5000", coin_type: "prestige", credit_shape: 1,
        tower_floor: "9-2",
        unlock_item_id: transfer_credit_id("xuanfengniu", 1),
        description: "一转凭证\n在合成屋-卡片转职中使用"
    });

    register_goods("credit_qingse_shishi_1", {
        type: "credit", cost: "8000", coin_type: "prestige", credit_shape: 1,
        tower_floor: "12-2",
        unlock_item_id: transfer_credit_id("qingse_shishi", 1),
        description: "一转凭证\n在合成屋-卡片转职中使用"
    });

    register_goods("credit_anranxiaohunfan_1", {
        type: "credit", cost: "1900", coin_type: "prestige", credit_shape: 1,
        tower_floor: "11-2",
        unlock_item_id: transfer_credit_id("anranxiaohunfan", 1),
        description: "一转凭证\n在合成屋-卡片转职中使用"
    });

    register_goods("credit_laipishe_1", {
        type: "credit", cost: "8000", coin_type: "prestige", credit_shape: 1,
        tower_floor: "14-2",
        unlock_item_id: transfer_credit_id("laipishe", 1),
        description: "一转凭证\n在合成屋-卡片转职中使用"
    });

    register_goods("credit_baibianshe_1", {
        type: "credit", cost: "3800", coin_type: "prestige", credit_shape: 1,
        tower_floor: "14-1",
        unlock_item_id: transfer_credit_id("baibianshe", 1),
        description: "一转凭证\n在合成屋-卡片转职中使用"
    });

    register_goods("credit_baiyang_1", {
        type: "credit", cost: "10000", coin_type: "prestige", credit_shape: 1,
        tower_floor: "18-2",
        unlock_item_id: transfer_credit_id("baiyang", 1),
        description: "一转凭证\n在合成屋-卡片转职中使用"
    });

    register_goods("credit_cold_drew_1", {
        type: "credit", cost: "8000", coin_type: "prestige", credit_shape: 1,
        tower_floor: "18-2",
        unlock_item_id: transfer_credit_id("cold_drew", 1),
        description: "一转凭证\n在合成屋-卡片转职中使用"
    });

    register_goods("credit_athena_1", {
        type: "credit", cost: "10000", coin_type: "prestige", credit_shape: 1,
        tower_floor: "18-2",
        unlock_item_id: transfer_credit_id("athena", 1),
        description: "一转凭证\n在合成屋-卡片转职中使用"
    });

    register_goods("credit_mixian_1", {
        type: "credit", cost: "2600", coin_type: "prestige", credit_shape: 1,
        tower_floor: "6-2",
        unlock_item_id: transfer_credit_id("mixian", 1),
        description: "一转凭证\n在合成屋-卡片转职中使用"
    });

    register_goods("credit_fushengcha_1", {
        type: "credit", cost: "5000", coin_type: "prestige", credit_shape: 1,
        tower_floor: "6-2",
        unlock_item_id: transfer_credit_id("fushengcha", 1),
        description: "一转凭证\n在合成屋-卡片转职中使用"
    });

    register_goods("credit_chunsun_1", {
        type: "credit", cost: "7000", coin_type: "prestige", credit_shape: 1,
        tower_floor: "3-2",
        unlock_item_id: transfer_credit_id("chunsun", 1),
        description: "一转凭证\n在合成屋-卡片转职中使用"
    });

    register_goods("credit_zhuzhujiaqiang_1", {
        type: "credit", cost: "7500", coin_type: "prestige", credit_shape: 1,
        tower_floor: "1-1",
        unlock_item_id: transfer_credit_id("zhuzhujiaqiang", 1),
        description: "一转凭证\n在合成屋-卡片转职中使用"
    });

    register_goods("credit_hongliukaochuan_1", {
        type: "credit", cost: "7000", coin_type: "prestige", credit_shape: 1,
        tower_floor: "15-2",
        unlock_item_id: transfer_credit_id("hongliukaochuan", 1),
        description: "一转凭证\n在合成屋-卡片转职中使用"
    });

    register_goods("credit_huagao_1", {
        type: "credit", cost: "9000", coin_type: "prestige", credit_shape: 1,
        tower_floor: "6-2",
        unlock_item_id: transfer_credit_id("huagao", 1),
        description: "一转凭证\n在合成屋-卡片转职中使用"
    });

    register_goods("credit_shuanggu_1", {
        type: "credit", cost: "2600", coin_type: "prestige", credit_shape: 1,
        tower_floor: "1-2",
        unlock_item_id: transfer_credit_id("shuanggu", 1),
        description: "一转凭证\n在合成屋-卡片转职中使用"
    });

    // 换气扇（ventilation_fan）：表里那行「电风扇」就是它（2026-10-28 用户确认对应关系）
    //   一转 = 超能草扇 / 二转 = SSR草扇；价按表里「一转威望 5000 / 二转威望总 22500」，
    //   门槛按「建议层数」3-2 / 15-1
    register_goods("credit_ventilation_fan_1", {
        type: "credit", cost: "5000", coin_type: "prestige", credit_shape: 1,
        tower_floor: "3-2",
        unlock_item_id: transfer_credit_id("ventilation_fan", 1),
        description: "一转凭证\n在合成屋-卡片转职中使用"
    });

    // ── 二转凭证（97 条）─────────────────────────────────────────
    register_goods("credit_wooden_plate_2", {
        type: "credit", cost: "11400", coin_type: "prestige", credit_shape: 2,
        tower_floor: "12-1",
        unlock_item_id: transfer_credit_id("wooden_plate", 2),
        description: "二转凭证\n在合成屋-卡片转职中使用"
    });

    register_goods("credit_goblet_lamp_2", {
        type: "credit", cost: "11700", coin_type: "prestige", credit_shape: 2,
        tower_floor: "16-2",
        unlock_item_id: transfer_credit_id("goblet_lamp", 2),
        description: "二转凭证\n在合成屋-卡片转职中使用"
    });

    register_goods("credit_gatlin_long_bao_2", {
        type: "credit", cost: "8700", coin_type: "prestige", credit_shape: 2,
        tower_floor: "23-2",
        unlock_item_id: transfer_credit_id("gatlin_long_bao", 2),
        description: "二转凭证\n在合成屋-卡片转职中使用"
    });

    register_goods("credit_iron_fishbone_2", {
        type: "credit", cost: "7200", coin_type: "prestige", credit_shape: 2,
        tower_floor: "15-2",
        unlock_item_id: transfer_credit_id("iron_fishbone", 2),
        description: "二转凭证\n在合成屋-卡片转职中使用"
    });

    register_goods("credit_rotating_coffee_pot_2", {
        type: "credit", cost: "10500", coin_type: "prestige", credit_shape: 2,
        tower_floor: "27-2",
        unlock_item_id: transfer_credit_id("rotating_coffee_pot", 2),
        description: "二转凭证\n在合成屋-卡片转职中使用"
    });

    register_goods("credit_takoyaki_2", {
        type: "credit", cost: "8700", coin_type: "prestige", credit_shape: 2,
        tower_floor: "18-2",
        unlock_item_id: transfer_credit_id("takoyaki", 2),
        description: "二转凭证\n在合成屋-卡片转职中使用"
    });

    register_goods("credit_large_fire_2", {
        type: "credit", cost: "7200", coin_type: "prestige", credit_shape: 2,
        tower_floor: "15-1",
        unlock_item_id: transfer_credit_id("large_fire", 2),
        description: "二转凭证\n在合成屋-卡片转职中使用"
    });

    register_goods("credit_small_fire_2", {
        type: "credit", cost: "11700", coin_type: "prestige", credit_shape: 2,
        tower_floor: "17-1",
        unlock_item_id: transfer_credit_id("small_fire", 2),
        description: "二转凭证\n在合成屋-卡片转职中使用"
    });

    register_goods("credit_ice_egg_boiler_pult_2", {
        type: "credit", cost: "7200", coin_type: "prestige", credit_shape: 2,
        tower_floor: "18-2",
        unlock_item_id: transfer_credit_id("ice_egg_boiler_pult", 2),
        description: "二转凭证\n在合成屋-卡片转职中使用"
    });

    register_goods("credit_cherry_pudding_2", {
        type: "credit", cost: "9000", coin_type: "prestige", credit_shape: 2,
        tower_floor: "28-2",
        unlock_item_id: transfer_credit_id("cherry_pudding", 2),
        description: "二转凭证\n在合成屋-卡片转职中使用"
    });

    register_goods("credit_melon_shield_2", {
        type: "credit", cost: "10500", coin_type: "prestige", credit_shape: 2,
        tower_floor: "18-2",
        unlock_item_id: transfer_credit_id("melon_shield", 2),
        description: "二转凭证\n在合成屋-卡片转职中使用"
    });

    register_goods("credit_chocolate_pult_2", {
        type: "credit", cost: "11700", coin_type: "prestige", credit_shape: 2,
        tower_floor: "17-2",
        unlock_item_id: transfer_credit_id("chocolate_pult", 2),
        description: "二转凭证\n在合成屋-卡片转职中使用"
    });

    register_goods("credit_triple_wine_rack_2", {
        type: "credit", cost: "11700", coin_type: "prestige", credit_shape: 2,
        tower_floor: "24-2",
        unlock_item_id: transfer_credit_id("triple_wine_rack", 2),
        description: "二转凭证\n在合成屋-卡片转职中使用"
    });

    register_goods("credit_salad_pult_2", {
        type: "credit", cost: "11700", coin_type: "prestige", credit_shape: 2,
        tower_floor: "14-2",
        unlock_item_id: transfer_credit_id("salad_pult", 2),
        description: "二转凭证\n在合成屋-卡片转职中使用"
    });

    register_goods("credit_brazier_2", {
        type: "credit", cost: "27000", coin_type: "prestige", credit_shape: 2,
        tower_floor: "30-2",
        unlock_item_id: transfer_credit_id("brazier", 2),
        description: "二转凭证\n在合成屋-卡片转职中使用"
    });

    register_goods("credit_stinky_tofu_pult_2", {
        type: "credit", cost: "11700", coin_type: "prestige", credit_shape: 2,
        tower_floor: "21-2",
        unlock_item_id: transfer_credit_id("stinky_tofu_pult", 2),
        description: "二转凭证\n在合成屋-卡片转职中使用"
    });

    register_goods("credit_egg_boiler_pult_2", {
        type: "credit", cost: "11700", coin_type: "prestige", credit_shape: 2,
        tower_floor: "21-2",
        unlock_item_id: transfer_credit_id("egg_boiler_pult", 2),
        description: "二转凭证\n在合成屋-卡片转职中使用"
    });

    register_goods("credit_firework_dragon_2", {
        type: "credit", cost: "23400", coin_type: "prestige", credit_shape: 2,
        tower_floor: "22-2",
        unlock_item_id: transfer_credit_id("firework_dragon", 2),
        description: "二转凭证\n在合成屋-卡片转职中使用"
    });

    register_goods("credit_hamburger_2", {
        type: "credit", cost: "15000", coin_type: "prestige", credit_shape: 2,
        tower_floor: "27-2",
        unlock_item_id: transfer_credit_id("hamburger", 2),
        description: "二转凭证\n在合成屋-卡片转职中使用"
    });

    register_goods("credit_hotdog_cannon_2", {
        type: "credit", cost: "10500", coin_type: "prestige", credit_shape: 2,
        tower_floor: "21-2",
        unlock_item_id: transfer_credit_id("hotdog_cannon", 2),
        description: "二转凭证\n在合成屋-卡片转职中使用"
    });

    register_goods("credit_tar_sprayer_2", {
        type: "credit", cost: "16800", coin_type: "prestige", credit_shape: 2,
        tower_floor: "27-2",
        unlock_item_id: transfer_credit_id("tar_sprayer", 2),
        description: "二转凭证\n在合成屋-卡片转职中使用"
    });

    register_goods("credit_oden_pot_2", {
        type: "credit", cost: "24000", coin_type: "prestige", credit_shape: 2,
        tower_floor: "18-2",
        unlock_item_id: transfer_credit_id("oden_pot", 2),
        description: "二转凭证\n在合成屋-卡片转职中使用"
    });

    register_goods("credit_cotton_candy_2", {
        type: "credit", cost: "7500", coin_type: "prestige", credit_shape: 2,
        tower_floor: "24-2",
        unlock_item_id: transfer_credit_id("cotton_candy", 2),
        description: "二转凭证\n在合成屋-卡片转职中使用"
    });

    register_goods("credit_flour_sack_2", {
        type: "credit", cost: "18000", coin_type: "prestige", credit_shape: 2,
        tower_floor: "21-2",
        unlock_item_id: transfer_credit_id("flour_sack", 2),
        description: "二转凭证\n在合成屋-卡片转职中使用"
    });

    register_goods("credit_coke_bomb_2", {
        type: "credit", cost: "22500", coin_type: "prestige", credit_shape: 2,
        tower_floor: "24-2",
        unlock_item_id: transfer_credit_id("coke_bomb", 2),
        description: "二转凭证\n在合成屋-卡片转职中使用"
    });

    register_goods("credit_wine_bottle_bomb_2", {
        type: "credit", cost: "22500", coin_type: "prestige", credit_shape: 2,
        tower_floor: "24-2",
        unlock_item_id: transfer_credit_id("wine_bottle_bomb", 2),
        description: "二转凭证\n在合成屋-卡片转职中使用"
    });

    register_goods("credit_whisky_bomb_2", {
        type: "credit", cost: "29700", coin_type: "prestige", credit_shape: 2,
        tower_floor: "23-2",
        unlock_item_id: transfer_credit_id("whisky_bomb", 2),
        description: "二转凭证\n在合成屋-卡片转职中使用"
    });

    register_goods("credit_ice_bucket_bomb_2", {
        type: "credit", cost: "22500", coin_type: "prestige", credit_shape: 2,
        tower_floor: "18-2",
        unlock_item_id: transfer_credit_id("ice_bucket_bomb", 2),
        description: "二转凭证\n在合成屋-卡片转职中使用"
    });

    register_goods("credit_kettle_bomb_2", {
        type: "credit", cost: "22500", coin_type: "prestige", credit_shape: 2,
        tower_floor: "22-2",
        unlock_item_id: transfer_credit_id("kettle_bomb", 2),
        description: "二转凭证\n在合成屋-卡片转职中使用"
    });

    register_goods("credit_pineapple_explosive_bread_2", {
        type: "credit", cost: "5400", coin_type: "prestige", credit_shape: 2,
        tower_floor: "24-2",
        unlock_item_id: transfer_credit_id("pineapple_explosive_bread", 2),
        description: "二转凭证\n在合成屋-卡片转职中使用"
    });

    register_goods("credit_ice_cream_2", {
        type: "credit", cost: "8700", coin_type: "prestige", credit_shape: 2,
        tower_floor: "28-2",
        unlock_item_id: transfer_credit_id("ice_cream", 2),
        description: "二转凭证\n在合成屋-卡片转职中使用"
    });

    register_goods("credit_lightning_baguette_2", {
        type: "credit", cost: "11700", coin_type: "prestige", credit_shape: 2,
        tower_floor: "25-2",
        unlock_item_id: transfer_credit_id("lightning_baguette", 2),
        description: "二转凭证\n在合成屋-卡片转职中使用"
    });

    register_goods("credit_chocolate_cannon_2", {
        type: "credit", cost: "10500", coin_type: "prestige", credit_shape: 2,
        tower_floor: "26-2",
        unlock_item_id: transfer_credit_id("chocolate_cannon", 2),
        description: "二转凭证\n在合成屋-卡片转职中使用"
    });

    register_goods("credit_coffee_cup_2", {
        type: "credit", cost: "8700", coin_type: "prestige", credit_shape: 2,
        tower_floor: "12-1",
        unlock_item_id: transfer_credit_id("coffee_cup", 2),
        description: "二转凭证\n在合成屋-卡片转职中使用"
    });

    register_goods("credit_coffee_pot_2", {
        type: "credit", cost: "8400", coin_type: "prestige", credit_shape: 2,
        tower_floor: "18-2",
        unlock_item_id: transfer_credit_id("coffee_pot", 2),
        description: "二转凭证\n在合成屋-卡片转职中使用"
    });

    register_goods("credit_double_water_pipe_2", {
        type: "credit", cost: "7200", coin_type: "prestige", credit_shape: 2,
        tower_floor: "24-1",
        unlock_item_id: transfer_credit_id("double_water_pipe", 2),
        description: "二转凭证\n在合成屋-卡片转职中使用"
    });

    register_goods("credit_mouse_clip_2", {
        type: "credit", cost: "7200", coin_type: "prestige", credit_shape: 2,
        tower_floor: "10-2",
        unlock_item_id: transfer_credit_id("mouse_clip", 2),
        description: "二转凭证\n在合成屋-卡片转职中使用"
    });

    register_goods("credit_durian_2", {
        type: "credit", cost: "33750", coin_type: "prestige", credit_shape: 2,
        tower_floor: "29-1",
        unlock_item_id: transfer_credit_id("durian", 2),
        description: "二转凭证\n在合成屋-卡片转职中使用"
    });

    register_goods("credit_coffee_grounds_2", {
        type: "credit", cost: "9000", coin_type: "prestige", credit_shape: 2,
        tower_floor: "11-1",
        unlock_item_id: transfer_credit_id("coffee_grounds", 2),
        description: "二转凭证\n在合成屋-卡片转职中使用"
    });

    register_goods("credit_sugar_ball_pult_2", {
        type: "credit", cost: "32700", coin_type: "prestige", credit_shape: 2,
        tower_floor: "21-2",
        unlock_item_id: transfer_credit_id("sugar_ball_pult", 2),
        description: "二转凭证\n在合成屋-卡片转职中使用"
    });

    register_goods("credit_dragon_fruit_2", {
        type: "credit", cost: "33750", coin_type: "prestige", credit_shape: 2,
        tower_floor: "25-2",
        unlock_item_id: transfer_credit_id("dragon_fruit", 2),
        description: "二转凭证\n在合成屋-卡片转职中使用"
    });

    register_goods("credit_rabbit_lantern_2", {
        type: "credit", cost: "33750", coin_type: "prestige", credit_shape: 2,
        tower_floor: "24-2",
        unlock_item_id: transfer_credit_id("rabbit_lantern", 2),
        description: "二转凭证\n在合成屋-卡片转职中使用"
    });

    register_goods("credit_xinjiang_fried_noodles_2", {
        type: "credit", cost: "15000", coin_type: "prestige", credit_shape: 2,
        tower_floor: "24-2",
        unlock_item_id: transfer_credit_id("xinjiang_fried_noodles", 2),
        description: "二转凭证\n在合成屋-卡片转职中使用"
    });

    register_goods("credit_aquarius_elve_2", {
        type: "credit", cost: "29700", coin_type: "prestige", credit_shape: 2,
        tower_floor: "18-2",
        unlock_item_id: transfer_credit_id("aquarius_elve", 2),
        description: "二转凭证\n在合成屋-卡片转职中使用"
    });

    register_goods("credit_king_long_bao_2", {
        type: "credit", cost: "13500", coin_type: "prestige", credit_shape: 2,
        unlock_item_id: transfer_credit_id("king_long_bao", 2),
        description: "二转凭证\n在合成屋-卡片转职中使用"
    });

    register_goods("credit_king_triple_long_bao_2", {
        type: "credit", cost: "10500", coin_type: "prestige", credit_shape: 2,
        tower_floor: "25-2",
        unlock_item_id: transfer_credit_id("king_triple_long_bao", 2),
        description: "二转凭证\n在合成屋-卡片转职中使用"
    });

    register_goods("credit_pizza_oven_2", {
        type: "credit", cost: "15000", coin_type: "prestige", credit_shape: 2,
        tower_floor: "25-2",
        unlock_item_id: transfer_credit_id("pizza_oven", 2),
        description: "二转凭证\n在合成屋-卡片转职中使用"
    });

    register_goods("credit_chili_powder_2", {
        type: "credit", cost: "23400", coin_type: "prestige", credit_shape: 2,
        tower_floor: "20-1",
        unlock_item_id: transfer_credit_id("chili_powder", 2),
        description: "二转凭证\n在合成屋-卡片转职中使用"
    });

    register_goods("credit_bull_firework_2", {
        type: "credit", cost: "45000", coin_type: "prestige", credit_shape: 2,
        tower_floor: "26-1",
        unlock_item_id: transfer_credit_id("bull_firework", 2),
        description: "二转凭证\n在合成屋-卡片转职中使用"
    });

    register_goods("credit_curry_lobster_cannon_2", {
        type: "credit", cost: "16500", coin_type: "prestige", credit_shape: 2,
        tower_floor: "27-2",
        unlock_item_id: transfer_credit_id("curry_lobster_cannon", 2),
        description: "二转凭证\n在合成屋-卡片转职中使用"
    });

    register_goods("credit_beef_hotpot_2", {
        type: "credit", cost: "30000", coin_type: "prestige", credit_shape: 2,
        tower_floor: "29-1",
        unlock_item_id: transfer_credit_id("beef_hotpot", 2),
        description: "二转凭证\n在合成屋-卡片转职中使用"
    });

    register_goods("credit_spicy_pot_2", {
        type: "credit", cost: "30000", coin_type: "prestige", credit_shape: 2,
        tower_floor: "30-2",
        unlock_item_id: transfer_credit_id("spicy_pot", 2),
        description: "二转凭证\n在合成屋-卡片转职中使用"
    });

    register_goods("credit_pan_fried_bun_2", {
        type: "credit", cost: "30000", coin_type: "prestige", credit_shape: 2,
        tower_floor: "28-1",
        unlock_item_id: transfer_credit_id("pan_fried_bun", 2),
        description: "二转凭证\n在合成屋-卡片转职中使用"
    });

    register_goods("credit_tang_hu_lu_2", {
        type: "credit", cost: "30000", coin_type: "prestige", credit_shape: 2,
        tower_floor: "27-2",
        unlock_item_id: transfer_credit_id("tang_hu_lu", 2),
        description: "二转凭证\n在合成屋-卡片转职中使用"
    });

    register_goods("credit_coal_starfish_2", {
        type: "credit", cost: "10500", coin_type: "prestige", credit_shape: 2,
        tower_floor: "25-2",
        unlock_item_id: transfer_credit_id("coal_starfish", 2),
        description: "二转凭证\n在合成屋-卡片转职中使用"
    });

    register_goods("credit_corn_shooter_2", {
        type: "credit", cost: "17400", coin_type: "prestige", credit_shape: 2,
        tower_floor: "27-2",
        unlock_item_id: transfer_credit_id("corn_shooter", 2),
        description: "二转凭证\n在合成屋-卡片转职中使用"
    });

    register_goods("credit_shizi_2", {
        type: "credit", cost: "21000", coin_type: "prestige", credit_shape: 2,
        tower_floor: "27-2",
        unlock_item_id: transfer_credit_id("shizi", 2),
        description: "二转凭证\n在合成屋-卡片转职中使用"
    });

    register_goods("credit_juxie_2", {
        type: "credit", cost: "17400", coin_type: "prestige", credit_shape: 2,
        tower_floor: "18-2",
        unlock_item_id: transfer_credit_id("juxie", 2),
        description: "二转凭证\n在合成屋-卡片转职中使用"
    });

    register_goods("credit_shuangzi_2", {
        type: "credit", cost: "23400", coin_type: "prestige", credit_shape: 2,
        tower_floor: "18-2",
        unlock_item_id: transfer_credit_id("shuangzi", 2),
        description: "二转凭证\n在合成屋-卡片转职中使用"
    });

    register_goods("credit_warm_birds_2", {
        type: "credit", cost: "14400", coin_type: "prestige", credit_shape: 2,
        tower_floor: "18-2",
        unlock_item_id: transfer_credit_id("warm_birds", 2),
        description: "二转凭证\n在合成屋-卡片转职中使用"
    });

    register_goods("credit_hspeed_juicer_2", {
        type: "credit", cost: "18000", coin_type: "prestige", credit_shape: 2,
        tower_floor: "27-2",
        unlock_item_id: transfer_credit_id("hspeed_juicer", 2),
        description: "二转凭证\n在合成屋-卡片转职中使用"
    });

    register_goods("credit_shuangyu_2", {
        type: "credit", cost: "23400", coin_type: "prestige", credit_shape: 2,
        tower_floor: "24-2",
        unlock_item_id: transfer_credit_id("shuangyu", 2),
        description: "二转凭证\n在合成屋-卡片转职中使用"
    });

    register_goods("credit_tiancheng_2", {
        type: "credit", cost: "14400", coin_type: "prestige", credit_shape: 2,
        tower_floor: "24-2",
        unlock_item_id: transfer_credit_id("tiancheng", 2),
        description: "二转凭证\n在合成屋-卡片转职中使用"
    });

    register_goods("credit_chunv_2", {
        type: "credit", cost: "21000", coin_type: "prestige", credit_shape: 2,
        tower_floor: "21-2",
        unlock_item_id: transfer_credit_id("chunv", 2),
        description: "二转凭证\n在合成屋-卡片转职中使用"
    });

    register_goods("credit_sheshou_2", {
        type: "credit", cost: "23400", coin_type: "prestige", credit_shape: 2,
        tower_floor: "24-2",
        unlock_item_id: transfer_credit_id("sheshou", 2),
        description: "二转凭证\n在合成屋-卡片转职中使用"
    });

    register_goods("credit_mojie_2", {
        type: "credit", cost: "40500", coin_type: "prestige", credit_shape: 2,
        tower_floor: "23-2",
        unlock_item_id: transfer_credit_id("mojie", 2),
        description: "二转凭证\n在合成屋-卡片转职中使用"
    });

    register_goods("credit_jinniu_2", {
        type: "credit", cost: "54000", coin_type: "prestige", credit_shape: 2,
        tower_floor: "28-2",
        unlock_item_id: transfer_credit_id("jinniu", 2),
        description: "二转凭证\n在合成屋-卡片转职中使用"
    });

    register_goods("credit_berry_dessert_2", {
        type: "credit", cost: "28500", coin_type: "prestige", credit_shape: 2,
        tower_floor: "29-2",
        unlock_item_id: transfer_credit_id("berry_dessert", 2),
        description: "二转凭证\n在合成屋-卡片转职中使用"
    });

    register_goods("credit_mozhang_2", {
        type: "credit", cost: "36000", coin_type: "prestige", credit_shape: 2,
        tower_floor: "30-2",
        unlock_item_id: transfer_credit_id("mozhang", 2),
        description: "二转凭证\n在合成屋-卡片转职中使用"
    });

    register_goods("credit_grilled_lizard_pult_2", {
        type: "credit", cost: "31500", coin_type: "prestige", credit_shape: 2,
        tower_floor: "24-2",
        unlock_item_id: transfer_credit_id("grilled_lizard_pult", 2),
        description: "二转凭证\n在合成屋-卡片转职中使用"
    });

    register_goods("credit_spoon_rabbit_2", {
        type: "credit", cost: "35100", coin_type: "prestige", credit_shape: 2,
        tower_floor: "24-2",
        unlock_item_id: transfer_credit_id("spoon_rabbit", 2),
        description: "二转凭证\n在合成屋-卡片转职中使用"
    });

    register_goods("credit_donut_2", {
        type: "credit", cost: "33000", coin_type: "prestige", credit_shape: 2,
        tower_floor: "21-2",
        unlock_item_id: transfer_credit_id("donut", 2),
        description: "二转凭证\n在合成屋-卡片转职中使用"
    });

    register_goods("credit_wanpilong_2", {
        type: "credit", cost: "15000", coin_type: "prestige", credit_shape: 2,
        tower_floor: "12-2",
        unlock_item_id: transfer_credit_id("wanpilong", 2),
        description: "二转凭证\n在合成屋-卡片转职中使用"
    });

    register_goods("credit_pufferfish_2", {
        type: "credit", cost: "15000", coin_type: "prestige", credit_shape: 2,
        tower_floor: "21-2",
        unlock_item_id: transfer_credit_id("pufferfish", 2),
        description: "二转凭证\n在合成屋-卡片转职中使用"
    });

    register_goods("credit_zhiyumiao_2", {
        type: "credit", cost: "22500", coin_type: "prestige", credit_shape: 2,
        tower_floor: "12-2",
        unlock_item_id: transfer_credit_id("zhiyumiao", 2),
        description: "二转凭证\n在合成屋-卡片转职中使用"
    });

    register_goods("credit_dandantu_2", {
        type: "credit", cost: "15000", coin_type: "prestige", credit_shape: 2,
        tower_floor: "15-2",
        unlock_item_id: transfer_credit_id("dandantu", 2),
        description: "二转凭证\n在合成屋-卡片转职中使用"
    });

    register_goods("credit_shegengbao_2", {
        type: "credit", cost: "17550", coin_type: "prestige", credit_shape: 2,
        tower_floor: "12-2",
        unlock_item_id: transfer_credit_id("shegengbao", 2),
        description: "二转凭证\n在合成屋-卡片转职中使用"
    });

    register_goods("credit_baobaoji_2", {
        type: "credit", cost: "22500", coin_type: "prestige", credit_shape: 2,
        tower_floor: "21-2",
        unlock_item_id: transfer_credit_id("baobaoji", 2),
        description: "二转凭证\n在合成屋-卡片转职中使用"
    });

    register_goods("credit_nizhuanniu_2", {
        type: "credit", cost: "36000", coin_type: "prestige", credit_shape: 2,
        tower_floor: "24-1",
        unlock_item_id: transfer_credit_id("nizhuanniu", 2),
        description: "二转凭证\n在合成屋-卡片转职中使用"
    });

    register_goods("credit_liehuohu_2", {
        type: "credit", cost: "23400", coin_type: "prestige", credit_shape: 2,
        tower_floor: "25-1",
        unlock_item_id: transfer_credit_id("liehuohu", 2),
        description: "二转凭证\n在合成屋-卡片转职中使用"
    });

    register_goods("credit_double_blade_snake_2", {
        type: "credit", cost: "33600", coin_type: "prestige", credit_shape: 2,
        tower_floor: "27-1",
        unlock_item_id: transfer_credit_id("double_blade_snake", 2),
        description: "二转凭证\n在合成屋-卡片转职中使用"
    });

    register_goods("credit_xuanfengniu_2", {
        type: "credit", cost: "45000", coin_type: "prestige", credit_shape: 2,
        tower_floor: "27-2",
        unlock_item_id: transfer_credit_id("xuanfengniu", 2),
        description: "二转凭证\n在合成屋-卡片转职中使用"
    });

    register_goods("credit_qingse_shishi_2", {
        type: "credit", cost: "36000", coin_type: "prestige", credit_shape: 2,
        tower_floor: "21-2",
        unlock_item_id: transfer_credit_id("qingse_shishi", 2),
        description: "二转凭证\n在合成屋-卡片转职中使用"
    });

    register_goods("credit_anranxiaohunfan_2", {
        type: "credit", cost: "8700", coin_type: "prestige", credit_shape: 2,
        tower_floor: "21-2",
        unlock_item_id: transfer_credit_id("anranxiaohunfan", 2),
        description: "二转凭证\n在合成屋-卡片转职中使用"
    });

    register_goods("credit_laipishe_2", {
        type: "credit", cost: "30000", coin_type: "prestige", credit_shape: 2,
        tower_floor: "28-1",
        unlock_item_id: transfer_credit_id("laipishe", 2),
        description: "二转凭证\n在合成屋-卡片转职中使用"
    });

    register_goods("credit_baibianshe_2", {
        type: "credit", cost: "17400", coin_type: "prestige", credit_shape: 2,
        tower_floor: "27-2",
        unlock_item_id: transfer_credit_id("baibianshe", 2),
        description: "二转凭证\n在合成屋-卡片转职中使用"
    });

    register_goods("credit_baiyang_2", {
        type: "credit", cost: "45000", coin_type: "prestige", credit_shape: 2,
        tower_floor: "25-2",
        unlock_item_id: transfer_credit_id("baiyang", 2),
        description: "二转凭证\n在合成屋-卡片转职中使用"
    });

    register_goods("credit_cold_drew_2", {
        type: "credit", cost: "28500", coin_type: "prestige", credit_shape: 2,
        tower_floor: "32-2",
        unlock_item_id: transfer_credit_id("cold_drew", 2),
        description: "二转凭证\n在合成屋-卡片转职中使用"
    });

    register_goods("credit_athena_2", {
        type: "credit", cost: "33000", coin_type: "prestige", credit_shape: 2,
        tower_floor: "26-1",
        unlock_item_id: transfer_credit_id("athena", 2),
        description: "二转凭证\n在合成屋-卡片转职中使用"
    });

    register_goods("credit_mixian_2", {
        type: "credit", cost: "12000", coin_type: "prestige", credit_shape: 2,
        tower_floor: "12-2",
        unlock_item_id: transfer_credit_id("mixian", 2),
        description: "二转凭证\n在合成屋-卡片转职中使用"
    });

    register_goods("credit_fushengcha_2", {
        type: "credit", cost: "16500", coin_type: "prestige", credit_shape: 2,
        tower_floor: "21-2",
        unlock_item_id: transfer_credit_id("fushengcha", 2),
        description: "二转凭证\n在合成屋-卡片转职中使用"
    });

    register_goods("credit_chunsun_2", {
        type: "credit", cost: "27000", coin_type: "prestige", credit_shape: 2,
        tower_floor: "21-2",
        unlock_item_id: transfer_credit_id("chunsun", 2),
        description: "二转凭证\n在合成屋-卡片转职中使用"
    });

    register_goods("credit_zhuzhujiaqiang_2", {
        type: "credit", cost: "27000", coin_type: "prestige", credit_shape: 2,
        tower_floor: "29-2",
        unlock_item_id: transfer_credit_id("zhuzhujiaqiang", 2),
        description: "二转凭证\n在合成屋-卡片转职中使用"
    });

    register_goods("credit_hongliukaochuan_2", {
        type: "credit", cost: "24000", coin_type: "prestige", credit_shape: 2,
        tower_floor: "33-2",
        unlock_item_id: transfer_credit_id("hongliukaochuan", 2),
        description: "二转凭证\n在合成屋-卡片转职中使用"
    });

    register_goods("credit_huagao_2", {
        type: "credit", cost: "25500", coin_type: "prestige", credit_shape: 2,
        tower_floor: "15-2",
        unlock_item_id: transfer_credit_id("huagao", 2),
        description: "二转凭证\n在合成屋-卡片转职中使用"
    });

    register_goods("credit_shuanggu_2", {
        type: "credit", cost: "11100", coin_type: "prestige", credit_shape: 2,
        tower_floor: "16-1",
        unlock_item_id: transfer_credit_id("shuanggu", 2),
        description: "二转凭证\n在合成屋-卡片转职中使用"
    });

    register_goods("credit_ventilation_fan_2", {
        type: "credit", cost: "22500", coin_type: "prestige", credit_shape: 2,
        tower_floor: "15-1",
        unlock_item_id: transfer_credit_id("ventilation_fan", 2),
        description: "二转凭证\n在合成屋-卡片转职中使用"
    });
}
