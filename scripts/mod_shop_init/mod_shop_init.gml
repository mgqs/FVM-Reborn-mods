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
        cost: "60000",
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
        cost: "70000",
        unlock_item_id: "blueberry_tower",
        description: "蓝莓信号塔塔：为本行投掷卡片增加攻击力",
        display_name: "蓝莓信号塔塔"
    });
    register_goods("donut", 
    {
        type: "card",
        cost: "70000",
        unlock_item_id: "donut",
        description: "梦幻多拿滋：连续攻击本行鼠军，优先空军",
        display_name: "梦幻多拿滋"
    });
    register_goods("spoon_rabbit", 
    {
        type: "card",
        cost: "80000",
        unlock_item_id: "spoon_rabbit",
        description: "勺勺兔：向前方3行投射子弹",
        display_name: "勺勺兔"
    });
    register_goods("hspeed_juicer", 
    {
        type: "card",
        cost: "70000",
        unlock_item_id: "hspeed_juicer",
        description: "加速榨汁机：为3x3范围内喷壶类卡片提供增伤",
        display_name: "加速榨汁机"
    });
    register_goods("master_shield", 
    {
        type: "weapon",
        cost: "150000",
        unlock_item_id: "master_shield",
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
    register_goods("hades_scythe", 
    {
        type: "weapon",
        cost: "250000",
        unlock_item_id: "hades_scythe",
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
    register_goods("poseidon_dart_gun", 
    {
        type: "weapon",
        cost: "80000",
        unlock_item_id: "poseidon_dart_gun",
        description: "海神镖枪：发射两个追踪飞镖攻击敌人",
        display_name: "海神镖枪"
    });
    register_goods("zeus_bolt", 
    {
        type: "weapon",
        cost: "200000",
        unlock_item_id: "zeus_bolt",
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
    register_goods("shuangzi", 
    {
        type: "card",
        cost: "10000",
        unlock_item_id: "shuangzi",
        description: "双子座精灵：一次性产出4朵火苗",
        display_name: "双子座精灵"
    });
    register_goods("sheshou", 
    {
        type: "card",
        cost: "10000",
        unlock_item_id: "sheshou",
        description: "射手座精灵：向前方三行射出4发强力子弹",
        display_name: "射手座精灵"
    });
    register_goods("tiancheng", 
    {
        type: "card",
        cost: "10000",
        unlock_item_id: "tiancheng",
        description: "天秤座精灵：向前后各射出3发比较强力的子弹",
        display_name: "天秤座精灵"
    });
    register_goods("shuangyu", 
    {
        type: "card",
        cost: "10000",
        unlock_item_id: "shuangyu",
        description: "双鱼座精灵：投掷两颗带有减速的冰鱼",
        display_name: "双鱼座精灵"
    });
    register_goods("juxie", 
    {
        type: "card",
        cost: "10000",
        unlock_item_id: "juxie",
        description: "巨蟹座精灵：发射4发强力钳子，全屏跟踪",
        display_name: "巨蟹座精灵"
    });
    register_goods("shizi", 
    {
        type: "card",
        cost: "10000",
        unlock_item_id: "shizi",
        description: "狮子座精灵：5×5范围穿透打击",
        display_name: "狮子座精灵"
    });
    register_goods("jinniu", 
    {
        type: "card",
        cost: "10000",
        unlock_item_id: "jinniu",
        description: "金牛座精灵：点燃子弹",
        display_name: "金牛座精灵"
    });
    register_goods("sheshou", 
    {
        type: "card",
        cost: "10000",
        unlock_item_id: "sheshou",
        description: "射手座精灵：向前方三行射出4发强力子弹",
        display_name: "射手座精灵"
    });
    register_goods("chunv", 
    {
        type: "card",
        cost: "10000",
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
        cost: "50000",
        unlock_item_id: "corn_shooter",
        description: "玉蜀黍：发射三颗玉米",
        display_name: "玉蜀黍"
    });
    
}
