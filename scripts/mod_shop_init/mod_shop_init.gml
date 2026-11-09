function mod_shop_init()
{
    register_goods("warm_birds", 
    {
        type: "card",
        cost: "40000",
        unlock_item_id: "warm_birds",
        description: "暖暖鸡：一次生产3朵火苗",
        display_name: "暖暖鸡"
    });
    register_goods("cold_drew",
    {
        type: "card",
        cost: "90000",
        unlock_item_id: "cold_drew",
        description: "冰块冷萃机：对全屏敌人发射至多4颗追踪冰块",
        display_name: "冰块冷萃机"
    });
    register_goods("berry_dessert", 
    {
        type: "card",
        cost: "60000",
        unlock_item_id: "berry_dessert",
        description: "莓果点心：为3x3范围内追踪类卡片提供增伤",
        display_name: "莓果点心"
    });
    register_goods("grilled_lizard_pult", 
    {
        type: "card",
        cost: "50000",
        unlock_item_id: "grilled_lizard_pult",
        description: "烤蜥蜴投手：向前投掷配料爆弹",
        display_name: "烤蜥蜴投手"
    });
    register_goods("blueberry_tower", 
    {
        type: "card",
        cost: "80000",
        unlock_item_id: "blueberry_tower",
        description: "蓝莓信号塔塔：为本行投掷卡片增加攻击力",
        display_name: "蓝莓信号塔塔"
    });
    register_goods("zhuzhujiaqiang", 
    {
        type: "card",
        cost: "150000",
        unlock_item_id: "zhuzhujiaqiang",
        description: "猪猪加强器：为本行投掷类卡片增加攻击力",
        display_name: "猪猪加强器"
    });
    register_goods("donut", 
    {
        type: "card",
        cost: "100000",
        unlock_item_id: "donut",
        description: "梦幻多拿滋：连续攻击本行鼠军，优先空军",
        display_name: "梦幻多拿滋"
    });
    register_goods("spoon_rabbit", 
    {
        type: "card",
        cost: "80000",            // 2026-11-09 用户：从跨服挪回本体，定价 8 万
        unlock_item_id: "spoon_rabbit",
        description: "勺勺兔：向前方3行投射子弹",
        display_name: "勺勺兔"
    });
    register_goods("hspeed_juicer", 
    {
        type: "card",
        cost: "80000",
        unlock_item_id: "hspeed_juicer",
        description: "加速榨汁机：为3x3范围内喷壶类卡片提供增伤",
        display_name: "加速榨汁机"
    });
    register_goods("master_shield", 
    {
        type: "weapon",
        cost: "150000",
        unlock_item_id: "master_shield",
            required_weapon_id: "gods_shield",
        description: "主宰之盾：增加800生命值",
        display_name: "主宰之盾"
    });
    register_goods("divine_blessing_gem", 
    {
        type: "gem",
        cost: "150000",
        unlock_item_id: "divine_blessing_gem",
        description: "神佑之眼：产生火苗",
        display_name: "神佑之眼"
    });
    register_goods("divine_protect_gem", 
    {
        type: "gem",
        cost: "150000",
        unlock_item_id: "divine_protect_gem",
        description: "神护之眼：为周围卡片增加攻击力",
        display_name: "神护之眼"
    });
    register_goods("divine_holy_gem", 
    {
        type: "gem",
        cost: "150000",
        unlock_item_id: "divine_holy_gem",
        description: "神圣之眼：伤害并减速5x5范围内的敌人",
        display_name: "神圣之眼"
    });
    register_goods("divine_shenji_gem",
    {
        type: "gem",
        cost: "150000",
        unlock_item_id: "divine_shenji_gem",
        description: "神忌之眼：每2.5秒对5×5范围敌人造成反伤与流血伤害",
        display_name: "神忌之眼"
    });

    register_goods("gods_shield",
    {
        type: "weapon",
        cost: "200000",
        unlock_item_id: "gods_shield",
        description: "诸神之盾：增加500生命值，镶嵌宝石时提供增益效果",
        display_name: "诸神之盾"
    });
    register_goods("death_scythe",
    {
        type: "weapon",
        cost: "200000",
        unlock_item_id: "death_scythe",
        description: "死神镰刀：O形轨迹发射旋转镰刀",
        display_name: "死神镰刀"
    });
    register_goods("poseidon_dart_gun_gem_1",
    {
        type: "gem",
        cost: "200000",
        unlock_item_id: "poseidon_dart_gun_gem_1",
        description: "魔影圣衣：海神镖枪子弹获得溅射伤害",
        display_name: "魔影圣衣"
    });
    register_goods("poseidon_dart_gun_gem_2",
    {
        type: "gem",
        cost: "200000",
        unlock_item_id: "poseidon_dart_gun_gem_2",
        description: "魔影蛮力：增加海神镖枪伤害",
        display_name: "魔影蛮力"
    });
    register_goods("poseidon_dart_gun_gem_3",
    {
        type: "gem",
        cost: "200000",
        unlock_item_id: "poseidon_dart_gun_gem_3",
        description: "魔影超刃：增加海神镖枪子弹数量",
        display_name: "魔影超刃"
    });
    register_goods("poseidon_dart_gun_gem_4",
    {
        type: "gem",
        cost: "200000",
        unlock_item_id: "poseidon_dart_gun_gem_4",
        description: "魔影迅疾：增加海神镖枪攻速",
        display_name: "魔影迅疾"
    });
    register_goods("gods_shield_gem_1",
    {
        type: "gem",
        cost: "200000",
        unlock_item_id: "gods_shield_gem_1",
        description: "光能之源：生产大量火苗",
        display_name: "光能之源"
    });
    register_goods("gods_shield_gem_2",
    {
        type: "gem",
        cost: "200000",
        unlock_item_id: "gods_shield_gem_2",
        description: "撕裂之源：撕裂3x3范围内的敌人",
        display_name: "撕裂之源"
    });
    register_goods("gods_shield_gem_3",
    {
        type: "gem",
        cost: "200000",
        unlock_item_id: "gods_shield_gem_3",
        description: "永恒之源：为5x5范围内的卡片提升攻击力",
        display_name: "永恒之源"
    });
    register_goods("gods_shield_gem_4",
    {
        type: "gem",
        cost: "200000",
        unlock_item_id: "gods_shield_gem_4",
        description: "生命之源：提升5x5范围内卡片的最大生命值",
        display_name: "生命之源"
    });
    register_goods("death_scythe_gem_1",
    {
        type: "gem",
        cost: "200000",
        unlock_item_id: "death_scythe_gem_1",
        description: "死神一击：增加死神镰刀伤害",
        display_name: "死神一击"
    });
    register_goods("death_scythe_gem_2",
    {
        type: "gem",
        cost: "200000",
        unlock_item_id: "death_scythe_gem_2",
        description: "死神收割：增加死神镰刀攻速",
        display_name: "死神收割"
    });
    register_goods("death_scythe_gem_3",
    {
        type: "gem",
        cost: "200000",
        unlock_item_id: "death_scythe_gem_3",
        description: "死神苏醒：增加死神镰刀子弹数量",
        display_name: "死神苏醒"
    });
    register_goods("death_scythe_gem_4",
    {
        type: "gem",
        cost: "200000",
        unlock_item_id: "death_scythe_gem_4",
        description: "死神意志：额外增加死神镰刀攻击并改变子弹形态",
        display_name: "死神意志"
    });
    register_goods("hades_scythe", 
    {
        type: "weapon",
        cost: "250000",
        unlock_item_id: "hades_scythe",
            required_weapon_id: "death_scythe",
        description: "冥王战镰：∞形轨迹发射旋转镰刀",
        display_name: "冥王战镰"
    });
    register_goods("ghost_strike_gem", 
    {
        type: "gem",
        cost: "250000",
        unlock_item_id: "ghost_strike_gem",
        description: "亡灵强袭：增加冥王战镰伤害",
        display_name: "亡灵强袭"
    });
    register_goods("ghost_spark_gem", 
    {
        type: "gem",
        cost: "250000",
        unlock_item_id: "ghost_spark_gem",
        description: "亡灵星火：增加冥王战镰攻速",
        display_name: "亡灵星火"
    });
    register_goods("ghost_pact_gem", 
    {
        type: "gem",
        cost: "250000",
        unlock_item_id: "ghost_pact_gem",
        description: "亡灵契约：增加冥王战镰子弹",
        display_name: "亡灵契约"
    });
    register_goods("ghost_caijue_gem",
    {
        type: "gem",
        cost: "250000",
        unlock_item_id: "ghost_caijue_gem",
        description: "亡灵裁决：冥王战镰所有子弹命中后减速4秒",
        display_name: "亡灵裁决"
    });
    register_goods("poseidon_dart_gun", 
    {
        type: "weapon",
        cost: "200000",
        unlock_item_id: "poseidon_dart_gun",
        description: "海神镖枪：连续发射追踪飞镖，可溅射",
        display_name: "海神镖枪"
    });
    register_goods("zeus_bolt", 
    {
        type: "weapon",
        cost: "200000",
        unlock_item_id: "zeus_bolt",
            required_weapon_id: "poseidon_dart_gun",
        description: "宙斯神弩：发射两个追踪飞镖攻击敌人",
        display_name: "宙斯神弩"
    });
    register_goods("zeus_shadow_gem", 
    {
        type: "gem",
        cost: "200000",
        unlock_item_id: "zeus_shadow_gem",
        description: "天神之影：增加宙斯神弩子弹溅射",
        display_name: "天神之影"
    });
    register_goods("zeus_power_gem", 
    {
        type: "gem",
        cost: "200000",
        unlock_item_id: "zeus_power_gem",
        description: "天神之力：增加宙斯神弩子弹伤害",
        display_name: "天神之力"
    });
    register_goods("zeus_anger_gem", 
    {
        type: "gem",
        cost: "200000",
        unlock_item_id: "zeus_anger_gem",
        description: "天神之怒：增加宙斯神弩子弹数量",
        display_name: "天神之怒"
    });
    register_goods("zeus_ren_gem",
    {
        type: "gem",
        cost: "200000",
        unlock_item_id: "zeus_ren_gem",
        description: "天神之刃：增加宙斯神弩攻击附加",
        display_name: "天神之刃"
    });
    register_goods("shuangzi", 
    {
        type: "card",
        cost: "40000",
        unlock_item_id: "shuangzi",
        description: "双子座精灵：一次性产出4朵火苗",
        display_name: "双子座精灵"
    });
    register_goods("sheshou", 
    {
        type: "card",
        cost: "30000",
        unlock_item_id: "sheshou",
        description: "射手座精灵：向前方三行射出4发强力子弹",
        display_name: "射手座精灵"
    });
    register_goods("tiancheng", 
    {
        type: "card",
        cost: "30000",
        unlock_item_id: "tiancheng",
        description: "天秤座精灵：向前后各射出3发比较强力的子弹",
        display_name: "天秤座精灵"
    });
    register_goods("shuangyu", 
    {
        type: "card",
        cost: "40000",
        unlock_item_id: "shuangyu",
        description: "双鱼座精灵：投掷两颗带有减速的冰鱼",
        display_name: "双鱼座精灵"
    });
    register_goods("juxie", 
    {
        type: "card",
        cost: "30000",
        unlock_item_id: "juxie",
        description: "巨蟹座精灵：发射4发强力钳子，全屏跟踪，海陆两栖",
        display_name: "巨蟹座精灵"
    });
    register_goods("shizi", 
    {
        type: "card",
        cost: "30000",
        unlock_item_id: "shizi",
        description: "狮子座精灵：5×5范围穿透打击",
        display_name: "狮子座精灵"
    });
    register_goods("jinniu", 
    {
        type: "card",
        cost: "25000",
        unlock_item_id: "jinniu",
        description: "金牛座精灵：点燃子弹",
        display_name: "金牛座精灵"
    });
    register_goods("chunv", 
    {
        type: "card",
        cost: "20000",
        unlock_item_id: "chunv",
        description: "处女座精灵：保护卡牌，并反弹伤害",
        display_name: "处女座精灵"
    });
    register_goods("baiyang", 
    {
        type: "card",
        cost: "10000",
        unlock_item_id: "baiyang",
        description: "白羊座精灵：冲撞清除一行鼠军",
        display_name: "白羊座精灵"
    });
    register_goods("mojie", 
    {
        type: "card",
        cost: "10000",
        unlock_item_id: "mojie",
        description: "摩羯座精灵：3×3范围内持续伤害并减速",
        display_name: "摩羯座精灵"
    });
    register_goods("athena", 
    {
        type: "card",
        cost: "30000",
        unlock_item_id: "athena",
        description: "雅典娜守护：全屏轰击，造成3×3范围伤害",
        display_name: "雅典娜守护"
    });
    register_goods("corn_shooter",
    {
        type: "card",
        cost: "20000",
        unlock_item_id: "corn_shooter",
        description: "玉蜀黍：发射三颗玉米",
        display_name: "玉蜀黍"
    });
    register_goods("star_wand",
    {
        type: "weapon",
        cost: "1000000",
        unlock_item_id: "star_wand",
        description: "星之神杖：召唤星之力全屏攻击，几率造成眩晕",
        display_name: "星之神杖"
    });
    register_goods("star_wand_gem_1",
    {
        type: "gem",
        cost: "1000000",
        unlock_item_id: "star_wand_gem_1",
        description: "星之焕：增幅星之力的溅射比率并改变星之力的形态",
        display_name: "星之焕"
    });
    register_goods("star_wand_gem_2",
    {
        type: "gem",
        cost: "1000000",
        unlock_item_id: "star_wand_gem_2",
        description: "星之吻：增幅星之力的伤害",
        display_name: "星之吻"
    });
    register_goods("star_wand_gem_3",
    {
        type: "gem",
        cost: "1000000",
        unlock_item_id: "star_wand_gem_3",
        description: "星之雨：增幅召唤星之力的数量",
        display_name: "星之雨"
    });
    register_goods("star_wand_gem_4",
    {
        type: "gem",
        cost: "1000000",
        unlock_item_id: "star_wand_gem_4",
        description: "星之闪：增幅召唤星之力的速度并增加眩晕几率",
        display_name: "星之闪"
    });
    register_goods("rose_shield",
    {
        type: "weapon",
        cost: "1000000",
        unlock_item_id: "rose_shield",
        description: "荆棘玫瑰：增加1000生命值，镶嵌宝石时提供超强增益效果",
        display_name: "荆棘玫瑰"
    });
    register_goods("rose_shield_gem_1",
    {
        type: "gem",
        cost: "1000000",
        unlock_item_id: "rose_shield_gem_1",
        description: "光合作用：生产极限量的火苗",
        display_name: "光合作用"
    });
    register_goods("rose_shield_gem_2",
    {
        type: "gem",
        cost: "1000000",
        unlock_item_id: "rose_shield_gem_2",
        description: "玫瑰之刺：周期性向8个方向发射荆棘子弹",
        display_name: "玫瑰之刺"
    });
    register_goods("rose_shield_gem_3",
    {
        type: "gem",
        cost: "1000000",
        unlock_item_id: "rose_shield_gem_3",
        description: "玫瑰之护：为5×5范围内的卡片提升攻击力(5×5外圈衰减)",
        display_name: "玫瑰之护"
    });
    register_goods("rose_shield_gem_4",
    {
        type: "gem",
        cost: "1000000",
        unlock_item_id: "rose_shield_gem_4",
        description: "玫瑰之绞：为5×7范围内的敌人造成巨额伤害",
        display_name: "玫瑰之绞"
    });
    register_goods("aladdin_lamp",
    {
        type: "weapon",
        cost: "1000000",
        unlock_item_id: "aladdin_lamp",
        description: "阿拉丁神灯：驱动灯神之力朝固定轨迹飞行",
        display_name: "阿拉丁神灯"
    });
    register_goods("aladdin_lamp_gem_1",
    {
        type: "gem",
        cost: "1000000",
        unlock_item_id: "aladdin_lamp_gem_1",
        description: "灯神原力：增加阿拉丁神灯的伤害",
        display_name: "灯神原力"
    });
    register_goods("aladdin_lamp_gem_2",
    {
        type: "gem",
        cost: "1000000",
        unlock_item_id: "aladdin_lamp_gem_2",
        description: "灯神疾速：增加阿拉丁神灯的攻击速度",
        display_name: "灯神疾速"
    });
    register_goods("aladdin_lamp_gem_3",
    {
        type: "gem",
        cost: "1000000",
        unlock_item_id: "aladdin_lamp_gem_3",
        description: "灯神召唤：增加阿拉丁神灯的子弹数量",
        display_name: "灯神召唤"
    });
    register_goods("aladdin_lamp_gem_4",
    {
        type: "gem",
        cost: "1000000",
        unlock_item_id: "aladdin_lamp_gem_4",
        description: "灯神迷雾：增加阿拉丁神灯的子弹溅射并改变子弹形态",
        display_name: "灯神迷雾"
    });
    register_goods("star_wand_gem_5",
    {
        type: "gem",
        cost: "1000000",
        unlock_item_id: "star_wand_gem_5",
        description: "星之耀：大幅增幅星之力的溅射比率并改变星之力的形态",
        display_name: "星之耀"
    });
    register_goods("rose_shield_gem_5",
    {
        type: "gem",
        cost: "1000000",
        unlock_item_id: "rose_shield_gem_5",
        description: "玫瑰之心：为5×7范围内的卡片巨幅提升攻击力(无衰减)",
        display_name: "玫瑰之心"
    });
    register_goods("aladdin_lamp_gem_5",
    {
        type: "gem",
        cost: "1000000",
        unlock_item_id: "aladdin_lamp_gem_5",
        description: "灯神涅槃：大幅增加阿拉丁神灯的伤害",
        display_name: "灯神涅槃"
    });

    register_goods("anranxiaohunfan",
    {
        type: "card",
        cost: "10000",
        unlock_item_id: "anranxiaohunfan",
        description: "黯然销魂饭：复活3*3范围内死亡的美食",
        display_name: "黯然销魂饭"
    });

    register_goods("12yinliao",
    {
        type: "card",
        cost: "12500",
        unlock_item_id: "12yinliao",
        description: "12饮料精灵：释放全屏美食，立即回满体力",
        display_name: "12饮料精灵"
    });


    register_goods("dandantu",
    {
        type: "card",
        cost: "10000",
        unlock_item_id: "dandantu",
        description: "蛋蛋兔：储存3x3范围内子弹伤害，死亡时释放穿透型子弹攻击整行老鼠",
        display_name: "蛋蛋兔"
    });
    register_goods("laipishe",
    {
        type: "card",
        cost: "100000",
        unlock_item_id: "laipishe",
        description: "赖皮蛇：召唤沿固定轨迹飞行的海胆子弹，伤害轨迹上的海陆空老鼠",
        display_name: "赖皮蛇"
    });
    register_goods("zhiyumiao",
    {
        type: "card",
        cost: "12500",
        unlock_item_id: "zhiyumiao",
        description: "治愈喵：为范围内卡片瞬间恢复5点体力，一转增加3秒补血Buff，二转全屏补血",
        display_name: "治愈喵"
    });
    register_goods("double_blade_snake",
    {
        type: "card",
        cost: "80000",
        unlock_item_id: "double_blade_snake",
        description: "双刃蛇：向前发射2发穿透剑气子弹，可斩杀生命值≤15%的普通老鼠",
        display_name: "双刃蛇"
    });
    register_goods("nizhuanniu",
    {
        type: "card",
        cost: "50000",
        unlock_item_id: "nizhuanniu",
        description: "逆转牛：将3*3范围内普通老鼠与地鼠逆转到其所在行的出生位置",
        display_name: "逆转牛"
    });
    register_goods("wanpilong",
    {
        type: "card",
        cost: "12500",
        unlock_item_id: "wanpilong",
        description: "顽皮龙：选择一张己方卡片，将其移动到周围5x5范围内的空格；瓜皮护罩、赫拉、春女可移动到已有卡片的格子",
        display_name: "顽皮龙"
    });
    register_goods("baobaoji",
    {
        type: "card",
        cost: "15000",
        unlock_item_id: "baobaoji",
        description: "爆爆鸡：部署时清除3×3范围内的路障、梯子和鼠洞",
        display_name: "爆爆鸡"
    });
    register_goods("qingse_shishi",
    {
        type: "card",
        cost: "60000",
        unlock_item_id: "qingse_shishi",
        description: "青涩柿柿：向前方一定范围内的老鼠发起重击",
        display_name: "青涩柿柿"
    });
    register_goods("zhanqima", { type: "card", cost: "1900", unlock_item_id: "zhanqima", description: "战旗马：5*5范围内主动攻击型卡片提高基础攻击力", display_name: "战旗马" });
    register_goods("zhanqima_1", { type: "card", card_id: "zhanqima", card_shape: 1, cost: "30000", unlock_item_id: "zhanqima", required_card_shape: 0, description: "飞天战旗马：增幅倍率提升", display_name: "飞天战旗马" });
    register_goods("zhanqima_2", { type: "card", card_id: "zhanqima", card_shape: 2, cost: "70000", unlock_item_id: "zhanqima", required_card_shape: 1, description: "燎原战旗马：增幅范围扩大至全屏", display_name: "燎原战旗马" });
    // 红柳烤串机（本体 / 茴香·一转 / 星火·二转）2026-11-03 注销：
    //   本体是百味关首通奖励（地图专属），一·二转改由威望商店卖凭证，
    //   这三条商品原来被 obj_shop_bg 的 cross_server_exchange_ids 隐藏、又不在跨服名单里，
    //   属于「哪儿都买不到」的死条目，已整段删除。

    register_goods("pufferfish",
    {
        type: "card",
        cost: "6666",
        unlock_item_id: "pufferfish",
        description: "爆辣河豚：种卡后清除全屏老鼠，或清除部分卡片",
        display_name: "爆辣河豚"
    });

    register_goods("shuanggu", { type: "card", cost: "20000", unlock_item_id: "shuanggu", description: "蚝油双菇：同时向前方发射对陆与对空子弹", display_name: "蚝油双菇" });

    register_goods("yeziguo", { type: "card", cost: "55000", unlock_item_id: "yeziguo", description: "椰子果：跳起碾压前方鼠军", display_name: "椰子果" });
    register_goods("yeziguo_1", { type: "card", card_id: "yeziguo", card_shape: 1, cost: "260", unlock_item_id: "yeziguo", required_card_shape: 0, description: "浓香椰子果：解锁一转", display_name: "浓香椰子果" });
    register_goods("yeziguo_2", { type: "card", card_id: "yeziguo", card_shape: 2, cost: "530", unlock_item_id: "yeziguo", required_card_shape: 1, description: "金丝椰子果：解锁二转", display_name: "金丝椰子果" });

    register_goods("niuyouguo", { type: "card", cost: "2030", unlock_item_id: "niuyouguo", description: "邪恶牛油果：向前方三个方向各发射1发穿透飞镖", display_name: "邪恶牛油果" });
    register_goods("niuyouguo_1", { type: "card", card_id: "niuyouguo", card_shape: 1, cost: "480", unlock_item_id: "niuyouguo", required_card_shape: 0, description: "沙沙牛油果：解锁一转", display_name: "沙沙牛油果" });
    register_goods("niuyouguo_2", { type: "card", card_id: "niuyouguo", card_shape: 2, cost: "970", unlock_item_id: "niuyouguo", required_card_shape: 1, description: "桑巴牛油果：解锁二转", display_name: "桑巴牛油果" });

    register_goods("wuxingshe", { type: "card", cost: "1500", unlock_item_id: "wuxingshe", description: "五行蛇：为3*3范围内5方向卡片增加攻击力", display_name: "五行蛇" });

    register_goods("bbq", { type: "card", cost: "35000", unlock_item_id: "bbq", description: "街头烤肉大师：沿本行发射穿透串串子弹", display_name: "街头烤肉大师" });
    register_goods("eightcake", { type: "card", cost: "20000", unlock_item_id: "eightcake", description: "8周年蛋糕：投掷蛋糕子弹，每3次攻击附带灼烧", display_name: "8周年蛋糕" });
    register_goods("tangchaolizi", { type: "card", cost: "60000", unlock_item_id: "tangchaolizi", description: "糖炒栗子：向前方喷出持续灼烧老鼠的滚烫栗子（3×3 十字灼烧）", display_name: "糖炒栗子" });

    register_goods("nengliangmiao", { type: "card", cost: "100000", unlock_item_id: "nengliangmiao", description: "能量喵：本行投掷类卡片加攻，直线子弹经其变为火子弹", display_name: "能量喵" });
    register_goods("maiya", { type: "card", cost: "20000", unlock_item_id: "maiya", description: "麦芽糖：可在海水与岩浆上承载卡片", display_name: "麦芽糖" });
    register_goods("guihuajiu", { type: "card", cost: "40000", unlock_item_id: "guihuajiu", description: "桂花酒：阻挡老鼠，被咬破时炸伤周围老鼠", display_name: "桂花酒" });


    //register_goods("zhuzhuliaoliji", { type: "card", cost: "250000", unlock_item_id: "zhuzhuliaoliji", description: "猪猪料理机：向五个方向各射出刀片", display_name: "猪猪料理机" });
    register_goods("budingwang", { type: "card", cost: "50000", unlock_item_id: "budingwang", description: "布丁汪：把穿过自己的子弹弹回去", display_name: "布丁汪" });
    register_goods("caihongshe", { type: "card", cost: "30000", unlock_item_id: "caihongshe", description: "彩虹蛇：保护被罩住的卡片并发射子弹", display_name: "彩虹蛇" });
    register_goods("meiweijishiqi", { type: "card", cost: "50000", unlock_item_id: "meiweijishiqi", description: "美味计时器：持续缩短本格卡片的冷却", display_name: "美味计时器" });
    register_goods("dangdanghu", { type: "card", cost: "60000", unlock_item_id: "dangdanghu", description: "铛铛虎：投掷高温糕饼，落点持续灼烧", display_name: "铛铛虎" });
    register_goods("dianman", { type: "card", cost: "80000", unlock_item_id: "dianman", description: "美味电鳗：范围内持续放电并定身", display_name: "美味电鳗" });
    register_goods("tanchitu", { type: "card", cost: "70000", unlock_item_id: "tanchitu", description: "贪吃兔：召唤一列兔子向前冲撞", display_name: "贪吃兔" });
    register_goods("tunshilong", { type: "card", cost: "50000", unlock_item_id: "tunshilong", description: "吞噬龙：吞掉周围的地面老鼠", display_name: "吞噬龙" });
    register_goods("xiangliaohu", { type: "card", cost: "150000", unlock_item_id: "xiangliaohu", description: "香料虎：为周围追踪卡片提升攻击力", display_name: "香料虎" });
    register_goods("zhuanzhuanji", { type: "card", cost: "40000", unlock_item_id: "zhuanzhuanji", description: "转转鸡：连续快速向周边攻击", display_name: "转转鸡" });
    register_goods("fashishe", { type: "card", cost: "2000", unlock_item_id: "fashishe", description: "法师蛇：向前发射整行穿透毒子弹", display_name: "法师蛇" });
    register_goods("fangkongmiao", { type: "card", cost: "75000", unlock_item_id: "fangkongmiao", description: "防空喵：高伤害轰炸空中鼠军", display_name: "防空喵" });
    register_goods("huojianzhu", { type: "card", cost: "80000", unlock_item_id: "huojianzhu", description: "火箭猪：全屏追踪攻击", display_name: "火箭猪" });
    register_goods("doumaobang", { type: "card", cost: "90000", unlock_item_id: "doumaobang", description: "逗猫棒：撞伤整行老鼠", display_name: "逗猫棒" });
    register_goods("honeytrap", { type: "card", cost: "110000", unlock_item_id: "honeytrap", description: "蜜糖陷阱：吸引强力蜜蜂集火攻击鼠军", display_name: "蜜糖陷阱" });
    register_goods("huanyingshe", { type: "card", cost: "1700", unlock_item_id: "huanyingshe", description: "幻影蛇：大范围发射可追踪的投掷类子弹", display_name: "幻影蛇" });
    register_goods("yinghuoshe", { type: "card", cost: "45000", unlock_item_id: "yinghuoshe", description: "萤火蛇：产火并照亮全场，伤害3*3范围内老鼠", display_name: "萤火蛇" });
    register_goods("guiyuanma", { type: "card", cost: "80000", unlock_item_id: "guiyuanma", description: "归元马：将前方3行范围内距离最近的普通老鼠送回起点并初始还原，斩杀低血量百分比精英", display_name: "归元马" });
    register_goods("xingqiongma", { type: "card", cost: "85000", unlock_item_id: "xingqiongma", description: "星穹马：复活5*5范围内1张死亡的卡片", display_name: "星穹马" });
    register_goods("tianxie", { type: "card", cost: "100000", unlock_item_id: "tianxie", description: "天蝎座精灵：猩红毒针，一行连续4格穿透伤害（无视障碍）", display_name: "天蝎座精灵" });
}
