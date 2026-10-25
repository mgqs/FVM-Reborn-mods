/// 转职凭证商店注册（2026-10-25）
/// 商品 type = "credit"：只进商店新增的「转职凭证」页，不会出现在道具页/其它页
/// 字段：
///   coin_type     "prestige" = 花威望 / "gold" = 花金币
///   credit_shape  0 = 兑换项（不是凭证）/ 1 = 一转 / 2 = 二转（分类页签按它过滤）
///   reward_prestige  兑换项专用：买完加多少威望
///   tower_floor   【2026-10-26 新增】爬塔门槛，两种写法：
///                   `"12-2"` = 需通关魔塔 12-2（层-小关，推荐）
///                   `12`     = 需通关魔塔 12-1（只写层数时按该层第一小关算）
///                   不写 / 写 0 / 写 "" = 不限制
///                  判定分两层：**置灰 + 售完罩**只看「永久锁」`transfer_credit_buyable_locked()`
///                  （形态不存在 / 已持有 / 已转职）；**点购买时的提示文案**走 `transfer_credit_buyable()`，
///                  爬塔门槛和余额不足都只弹提示、不置灰（2026-10-26 用户定）
///                  进度取 transfer_credit_tower_done_key()（普通 + 精英都算，取最高那一关，编码 = 层×100+小关）
///                  提示词写成 `需通关魔塔 12-2`，由 transfer_credit_tower_key_text() 还原
/// ⚠️ 一条一个价，**不要改成循环生成**（用户 2026-10-25 明确）
function credit_shop_init()
{
    // ── 威望兑换（测试期临时项）：10000 金币 → 1000 威望 ──
    register_goods("prestige_exchange_1000", {
        type: "credit",
        cost: "10000",
        coin_type: "gold",
        credit_shape: 0,
        unlock_item_id: "prestige",
        display_name: "威望 x1000",
        description: "用 10000 金币兑换 1000 威望\n（测试期临时项，正式版会移除）",
        reward_prestige: 1000
    });

    register_goods("credit_small_fire_1", {
        type: "credit", cost: "100", coin_type: "prestige", credit_shape: 1,
        unlock_item_id: transfer_credit_id("small_fire", 1),
        display_name: "小火炉（一转凭证）",
        description: "小火炉（一转凭证）\n在合成屋-卡片转职中使用",
        tower_floor: 0
    });
    register_goods("credit_small_fire_2", {
        type: "credit", cost: "100", coin_type: "prestige", credit_shape: 2,
        unlock_item_id: transfer_credit_id("small_fire", 2),
        display_name: "小火炉（二转凭证）",
        description: "小火炉（二转凭证）\n在合成屋-卡片转职中使用",
        tower_floor: "1-1"
    });

    register_goods("credit_coal_starfish_1", {
        type: "credit", cost: "100", coin_type: "prestige", credit_shape: 1,
        unlock_item_id: transfer_credit_id("coal_starfish", 1),
        display_name: "炭烧海星（一转凭证）",
        description: "炭烧海星（一转凭证）\n在合成屋-卡片转职中使用"
    });
    register_goods("credit_coal_starfish_2", {
        type: "credit", cost: "100", coin_type: "prestige", credit_shape: 2,
        unlock_item_id: transfer_credit_id("coal_starfish", 2),
        display_name: "炭烧海星（二转凭证）",
        description: "炭烧海星（二转凭证）\n在合成屋-卡片转职中使用"
    });

    // ── 一转凭证 ──
    register_goods("credit_gatlin_long_bao_1", {
        type: "credit", cost: "100", coin_type: "prestige", credit_shape: 1,
        unlock_item_id: transfer_credit_id("gatlin_long_bao", 1),
        display_name: "机枪小笼包（一转凭证）",
        description: "机枪小笼包（一转凭证）\n在合成屋-卡片转职中使用"
    });
    register_goods("credit_ice_egg_boiler_pult_1", {
        type: "credit", cost: "100", coin_type: "prestige", credit_shape: 1,
        unlock_item_id: transfer_credit_id("ice_egg_boiler_pult", 1),
        display_name: "冰煮蛋器（一转凭证）",
        description: "冰煮蛋器（一转凭证）\n在合成屋-卡片转职中使用"
    });
    register_goods("credit_oden_pot_1", {
        type: "credit", cost: "100", coin_type: "prestige", credit_shape: 1,
        unlock_item_id: transfer_credit_id("oden_pot", 1),
        display_name: "关东煮喷锅（一转凭证）",
        description: "关东煮喷锅（一转凭证）\n在合成屋-卡片转职中使用"
    });

    // ── 二转凭证 ──
    register_goods("credit_gatlin_long_bao_2", {
        type: "credit", cost: "100", coin_type: "prestige", credit_shape: 2,
        unlock_item_id: transfer_credit_id("gatlin_long_bao", 2),
        display_name: "机枪小笼包（二转凭证）",
        description: "机枪小笼包（二转凭证）\n在合成屋-卡片转职中使用"
    });
    register_goods("credit_ice_egg_boiler_pult_2", {
        type: "credit", cost: "100", coin_type: "prestige", credit_shape: 2,
        unlock_item_id: transfer_credit_id("ice_egg_boiler_pult", 2),
        display_name: "冰煮蛋器（二转凭证）",
        description: "冰煮蛋器（二转凭证）\n在合成屋-卡片转职中使用"
    });
    register_goods("credit_oden_pot_2", {
        type: "credit", cost: "100", coin_type: "prestige", credit_shape: 2,
        unlock_item_id: transfer_credit_id("oden_pot", 2),
        display_name: "关东煮喷锅（二转凭证）",
        description: "关东煮喷锅（二转凭证）\n在合成屋-卡片转职中使用",
		tower_floor: "1-1"
    });
}
