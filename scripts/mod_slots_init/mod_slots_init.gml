function mod_slots_init()
{
    register_card("gaia", obj_gaia, [
    {
        shape: 0,
        sprite: spr_gaia,
        cost: 350,
        cooldown: 2100,
        description: "盖亚神使：双连发射3*3范围爆炸的毁灭巨石",
        plant_type: "normal",
        feature_type: "normal",
        target_card: "none",
        is_gold: 1
    }, 
    {
        shape: 1,
        sprite: spr_gaia_1,
        cost: 350,
        cooldown: 2100,
        description: "盖亚圣神：双连发射3*3范围爆炸的毁灭巨石",
        plant_type: "normal",
        feature_type: "normal",
        target_card: "none",
        is_gold: 1
    }, 
    {
        shape: 2,
        sprite: spr_gaia_2,
        cost: 350,
        cooldown: 2100,
        description: "大地女神·盖亚：三连发射3*3范围爆炸的毁灭巨石",
        plant_type: "normal",
        feature_type: "normal",
        target_card: "none",
        is_gold: 1
    }, 
    {
        shape: 3,
        sprite: spr_gaia_3,
        cost: 350,
        cooldown: 2100,
        description: "至尊大地女神：三连发射5*5范围爆炸的毁灭巨石",
        plant_type: "normal",
        feature_type: "normal",
        target_card: "none",
        is_gold: 1
    }]);
    register_card("aurora", obj_aurora, [
    {
        shape: 0,
        sprite: spr_aurora_icon,
        cost: 190,
        cooldown: 1800,
        description: "欧若拉神使：为本行投掷类卡片增伤",
        plant_type: "normal",
        feature_type: "normal",
        target_card: "none",
        is_gold: 1,
        place_preview: spr_aurora
    }, 
    {
        shape: 1,
        sprite: spr_aurora_icon_1,
        cost: 190,
        cooldown: 1800,
        description: "欧若拉圣神：为本行投掷类卡片增伤，死亡后爆炸",
        plant_type: "normal",
        feature_type: "normal",
        target_card: "none",
        is_gold: 1,
        place_preview: spr_aurora_1
    }, 
    {
        shape: 2,
        sprite: spr_aurora_icon_2,
        cost: 190,
        cooldown: 1800,
        description: "曙光女神·欧若拉：为本行投掷类卡片增伤，死亡后爆炸",
        plant_type: "normal",
        feature_type: "normal",
        target_card: "none",
        is_gold: 1,
        place_preview: spr_aurora_2
    }, 
    {
        shape: 3,
        sprite: spr_aurora_icon_3,
        cost: 190,
        cooldown: 1800,
        description: "至尊曙光女神：为本行及相邻行投掷类卡片增伤，死亡后爆炸",
        plant_type: "normal",
        feature_type: "normal",
        target_card: "none",
        is_gold: 1,
        place_preview: spr_aurora_3
    }]);
    register_card("zhurong", obj_zhurong, [
    {
        shape: 0,
        sprite: spr_zhurong,
        cost: 245,
        cooldown: 420,
        description: "祝融神使：点燃前方3x3区域，持续灼烧敌人",
        plant_type: "normal",
        feature_type: "normal",
        target_card: "none",
        is_gold: 1
    }, 
    {
        shape: 1,
        sprite: spr_zhurong_1,
        cost: 245,
        cooldown: 420,
        description: "祝融圣神：点燃前方3x3区域，持续灼烧敌人",
        plant_type: "normal",
        feature_type: "normal",
        target_card: "none",
        is_gold: 1
    }, 
    {
        shape: 2,
        sprite: spr_zhurong_2,
        cost: 245,
        cooldown: 420,
        description: "赤帝·祝融：点燃前方5x5区域，持续灼烧敌人",
        plant_type: "normal",
        feature_type: "normal",
        target_card: "none",
        is_gold: 1
    }, 
    {
        shape: 3,
        sprite: spr_zhurong_3,
        cost: 245,
        cooldown: 420,
        description: "至尊赤帝：点燃前方7x5区域，持续灼烧敌人",
        plant_type: "normal",
        feature_type: "normal",
        target_card: "none",
        is_gold: 1
    }]);
    register_card("rig", obj_rig, [
    {
        shape: 0,
        sprite: spr_rig,
        cost: 185,
        cooldown: 420,
        description: "里格神使：前方5方向发射穿透子弹",
        plant_type: "normal",
        feature_type: "normal",
        target_card: "none",
        is_gold: 1
    }, 
    {
        shape: 1,
        sprite: spr_rig_1,
        cost: 260,
        cooldown: 420,
        description: "里格圣神：前方5方向发射穿透子弹",
        plant_type: "normal",
        feature_type: "normal",
        target_card: "none",
        is_gold: 1
    }, 
    {
        shape: 2,
        sprite: spr_rig_2,
        cost: 260,
        cooldown: 420,
        description: "守护神·里格：前方5方向发射穿透子弹",
        plant_type: "normal",
        feature_type: "normal",
        target_card: "none",
        is_gold: 1
    }, 
    {
        shape: 3,
        sprite: spr_rig_3,
        cost: 260,
        cooldown: 420,
        description: "至尊守护神：前方5方向发射穿透子弹",
        plant_type: "normal",
        feature_type: "normal",
        target_card: "none",
        is_gold: 1
    }]);
    register_card("brahma", obj_brahma, [
    {
        shape: 0,
        sprite: spr_brahma_icon,
        cost: 325,
        cooldown: 3300,
        description: "梵天神使：变身出多个上一次种下的卡片",
        plant_type: "coffee",
        feature_type: "normal",
        target_card: "none",
        is_gold: 1,
        place_preview: spr_brahma
    }, 
    {
        shape: 1,
        sprite: spr_brahma_icon_1,
        cost: 325,
        cooldown: 3300,
        description: "梵天圣神：变身出多个上一次种下的卡片",
        plant_type: "coffee",
        feature_type: "normal",
        target_card: "none",
        is_gold: 1,
        place_preview: spr_brahma_1
    }, 
    {
        shape: 2,
        sprite: spr_brahma_icon_2,
        cost: 325,
        cooldown: 3300,
        description: "创造神·梵天：变身出多个上一次种下的卡片",
        plant_type: "coffee",
        feature_type: "normal",
        target_card: "none",
        is_gold: 1,
        place_preview: spr_brahma_2
    }, 
    {
        shape: 3,
        sprite: spr_brahma_icon_3,
        cost: 325,
        cooldown: 3300,
        description: "至尊创造神：变身出多个上一次种下的卡片",
        plant_type: "coffee",
        feature_type: "normal",
        target_card: "none",
        is_gold: 1,
        place_preview: spr_brahma_3
    }]);
    register_card("clotho", obj_clotho, [
    {
        shape: 0,
        sprite: spr_clotho_icon,
        cost: 400,
        cooldown: 3600,
        description: "克洛托神使：随机改变范围内卡片星级，一段时间后恢复",
        plant_type: "coffee",
        feature_type: "normal",
        target_card: "none",
        is_gold: 1,
        place_preview: spr_clotho
    }, 
    {
        shape: 1,
        sprite: spr_clotho_icon_1,
        cost: 400,
        cooldown: 3600,
        description: "克洛托圣神：随机改变范围内卡片星级，一段时间后恢复",
        plant_type: "coffee",
        feature_type: "normal",
        target_card: "none",
        is_gold: 1,
        place_preview: spr_clotho_1
    }, 
    {
        shape: 2,
        sprite: spr_clotho_icon_2,
        cost: 400,
        cooldown: 3600,
        description: "命运女神·克洛托：随机改变范围内卡片星级，一段时间后恢复",
        plant_type: "coffee",
        feature_type: "normal",
        target_card: "none",
        is_gold: 1,
        place_preview: spr_clotho_2
    }, 
    {
        shape: 3,
        sprite: spr_clotho_icon_3,
        cost: 400,
        cooldown: 3600,
        description: "至尊命运女神：随机改变范围内卡片星级，一段时间后恢复",
        plant_type: "coffee",
        feature_type: "normal",
        target_card: "none",
        is_gold: 1,
        place_preview: spr_clotho_3
    }]);
    register_card("time_god", obj_time_god, [
    {
        shape: 0,
        sprite: spr_time_god,
        cost: 370,
        cooldown: 3600,
        description: "柯罗诺斯神使：持续给范围内卡片缩短冷却时间30%",
        plant_type: "coffee",
        feature_type: "normal",
        target_card: "none",
        is_gold: 1,
        place_preview: spr_time_god
    },
    {
        shape: 1,
        sprite: spr_time_god_1,
        cost: 370,
        cooldown: 3600,
        description: "柯罗诺斯圣神：放卡产生爆炸，持续缩减冷却30%",
        plant_type: "coffee",
        feature_type: "normal",
        target_card: "none",
        is_gold: 1,
        place_preview: spr_time_god_1
    },
    {
        shape: 2,
        sprite: spr_time_god_2,
        cost: 370,
        cooldown: 3600,
        description: "时间神·柯罗诺斯：范围扩大至5x5，冷却缩减50%",
        plant_type: "coffee",
        feature_type: "normal",
        target_card: "none",
        is_gold: 1,
        place_preview: spr_time_god_2
    },
    {
        shape: 3,
        sprite: spr_time_god_3,
        cost: 370,
        cooldown: 3600,
        description: "至尊时间神：范围扩大至全屏，冷却缩减100%",
        plant_type: "coffee",
        feature_type: "normal",
        target_card: "none",
        is_gold: 1,
        place_preview: spr_time_god_3
    }]);
    register_card("firework_dragon_real", obj_firework_dragon_real, [
    {
        shape: 0,
        sprite: spr_firework_dragon,
        cost: 150,
        cooldown: 420,
        description: "真·花火龙：释放产生大量火苗的烟花",
        plant_type: "normal",
        feature_type: "normal",
        target_card: "none",
        is_gold: 1
    }, 
    {
        shape: 1,
        sprite: spr_firework_dragon_1,
        cost: 150,
        cooldown: 420,
        description: "真·灼灼花火龙：释放产生大量火苗的烟花",
        plant_type: "normal",
        feature_type: "normal",
        target_card: "none",
        is_gold: 1
    }, 
    {
        shape: 2,
        sprite: spr_firework_dragon_icon_2,
        cost: 150,
        cooldown: 420,
        description: "真·炽焰花火龙：释放产生大量火苗的烟花",
        plant_type: "normal",
        feature_type: "normal",
        target_card: "none",
        is_gold: 1,
        place_preview: spr_firework_dragon_2
    }]);
    register_card("sun_god", obj_sun_god, [
    {
        shape: 0,
        sprite: spr_sun_god,
        cost: 200,
        cooldown: 1800,
        description: "阿波罗神使：一次生产六朵火苗",
        plant_type: "normal",
        feature_type: "normal",
        target_card: "none",
        is_gold: 1
    }, 
    {
        shape: 1,
        sprite: spr_sun_god_1,
        cost: 150,
        cooldown: 1500,
        description: "阿波罗圣神：一次生产八朵火苗",
        plant_type: "normal",
        feature_type: "normal",
        target_card: "none",
        is_gold: 1
    }, 
    {
        shape: 2,
        sprite: spr_sun_god_2,
        cost: 100,
        cooldown: 1200,
        description: "太阳神·阿波罗：一次生产十朵火苗",
        plant_type: "normal",
        feature_type: "normal",
        target_card: "none",
        is_gold: 1
    }, 
    {
        shape: 3,
        sprite: spr_sun_god_3_icon,
        cost: 25,
        cooldown: 600,
        description: "至尊太阳神：一次生产十二朵火苗",
        plant_type: "normal",
        feature_type: "normal",
        target_card: "none",
        is_gold: 1,
        place_preview: spr_sun_god_3
    }]);
    register_card("war_god", obj_war1_god, [
    {
        shape: 0,
        sprite: spr_war_god,
        cost: 150,
        cooldown: 420,
        description: "阿瑞斯神使：向前后两个方向发射子弹",
        plant_type: "normal",
        feature_type: "normal",
        target_card: "none",
        is_gold: 1
    }, 
    {
        shape: 1,
        sprite: spr_war_god_1,
        cost: 150,
        cooldown: 420,
        description: "阿瑞斯圣神：向前后两个方向发射子弹",
        plant_type: "normal",
        feature_type: "normal",
        target_card: "none",
        is_gold: 1
    }, 
    {
        shape: 2,
        sprite: spr_war_god_2,
        cost: 150,
        cooldown: 420,
        description: "战神·阿瑞斯：向前后两个方向发射子弹，",
        plant_type: "normal",
        feature_type: "normal",
        target_card: "none",
        is_gold: 1
    }, 
    {
        shape: 3,
        sprite: spr_war_god_3,
        cost: 150,
        cooldown: 420,
        description: "至尊战神：向前后两个方向发射子弹",
        plant_type: "normal",
        feature_type: "normal",
        target_card: "none",
        is_gold: 1
    }]);
    register_card("love_god", obj_love_god, [
    {
        shape: 0,
        sprite: spr_love_god,
        cost: 300,
        cooldown: 420,
        description: "丘比特神使：向前方三行射出6发强力子弹",
        plant_type: "normal",
        feature_type: "normal",
        target_card: "none",
        is_gold: 1
    }, 
    {
        shape: 1,
        sprite: spr_love_god_1,
        cost: 300,
        cooldown: 420,
        description: "丘比特圣神：向前方三行射出6发强力子弹",
        plant_type: "normal",
        feature_type: "normal",
        target_card: "none",
        is_gold: 1
    }, 
    {
        shape: 2,
        sprite: spr_love_god_2,
        cost: 300,
        cooldown: 420,
        description: "爱神·丘比特：向前方三行射出9发强力子弹",
        plant_type: "normal",
        feature_type: "normal",
        target_card: "none",
        is_gold: 1
    }, 
    {
        shape: 3,
        sprite: spr_love_god_3,
        cost: 300,
        cooldown: 420,
        description: "至尊爱神：向前方三行射出9发强力子弹",
        plant_type: "normal",
        feature_type: "normal",
        target_card: "none",
        is_gold: 1
    }]);
    register_card("thor", obj_thor, [
    {
        shape: 0,
        sprite: spr_thor_icon,
        cost: 200,
        cooldown: 420,
        description: "索尔神使：连续发出2发冰锤",
        plant_type: "normal",
        feature_type: "normal",
        target_card: "none",
        place_preview: spr_thor,
        is_gold: 1
    }, 
    {
        shape: 1,
        sprite: spr_thor_icon_1,
        cost: 200,
        cooldown: 420,
        description: "索尔圣神：连续发出3发冰锤",
        plant_type: "normal",
        feature_type: "normal",
        target_card: "none",
        place_preview: spr_thor_1,
        is_gold: 1
    }, 
    {
        shape: 2,
        sprite: spr_thor_icon_2,
        cost: 200,
        cooldown: 420,
        description: "雷神·索尔：连续发出3发冰锤，其中1发为超级冰锤",
        plant_type: "normal",
        feature_type: "normal",
        target_card: "none",
        place_preview: spr_thor_2,
        is_gold: 1
    }, 
    {
        shape: 3,
        sprite: spr_thor_icon_3,
        cost: 200,
        cooldown: 420,
        description: "至尊雷神：连续发出3发冰锤，其中1发为超级冰锤",
        plant_type: "normal",
        feature_type: "normal",
        target_card: "none",
        place_preview: spr_thor_3,
        is_gold: 1
    }]);
    register_card("moon_god", obj_moon_god, [
    {
        shape: 0,
        sprite: spr_moon_god,
        cost: 225,
        cooldown: 3000,
        description: "狄安娜神使：甩出六发追踪子弹",
        plant_type: "normal",
        feature_type: "normal",
        target_card: "none",
        is_gold: 1
    }, 
    {
        shape: 1,
        sprite: spr_moon_god_1,
        cost: 225,
        cooldown: 3000,
        description: "狄安娜圣神：甩出六发追踪子弹",
        plant_type: "normal",
        feature_type: "normal",
        target_card: "none",
        is_gold: 1
    }, 
    {
        shape: 2,
        sprite: spr_moon_god_2,
        cost: 225,
        cooldown: 3000,
        description: "月神·狄安娜：甩出六发追踪子弹",
        plant_type: "normal",
        feature_type: "normal",
        target_card: "none",
        is_gold: 1
    }, 
    {
        shape: 3,
        sprite: spr_moon_god_3,
        cost: 225,
        cooldown: 3000,
        description: "至尊月神：甩出六发追踪子弹",
        plant_type: "normal",
        feature_type: "normal",
        target_card: "none",
        is_gold: 1
    }]);
    register_card("poseidon", obj_poseidon, [
    {
        shape: 0,
        sprite: spr_poseidon,
        cost: 275,
        cooldown: 1800,
        description: "波塞冬神使：5*5范围穿透攻击",
        plant_type: "normal",
        feature_type: "normal",
        target_card: "none",
        is_gold: 1
    }, 
    {
        shape: 1,
        sprite: spr_poseidon_1,
        cost: 275,
        cooldown: 1800,
        description: "波塞冬圣神：5*5范围穿透攻击",
        plant_type: "normal",
        feature_type: "normal",
        target_card: "none",
        is_gold: 1
    }, 
    {
        shape: 2,
        sprite: spr_poseidon_2,
        cost: 275,
        cooldown: 1200,
        description: "海神·波塞冬：5*5范围穿透攻击",
        plant_type: "normal",
        feature_type: "normal",
        target_card: "none",
        is_gold: 1
    }, 
    {
        shape: 3,
        sprite: spr_poseidon_3,
        cost: 275,
        cooldown: 1200,
        description: "至尊海神：7*5范围穿透攻击",
        plant_type: "normal",
        feature_type: "normal",
        target_card: "none",
        is_gold: 1
    }]);
    register_card("odin", obj_odin, [
    {
        shape: 0,
        sprite: spr_odin,
        cost: 230,
        cooldown: 420,
        description: "奥丁神使：发射冈格尼尔穿透攻击敌人",
        plant_type: "normal",
        feature_type: "normal",
        target_card: "none",
        is_gold: 1
    }, 
    {
        shape: 1,
        sprite: spr_odin_1,
        cost: 230,
        cooldown: 420,
        description: "奥丁圣神：发射冈格尼尔穿透攻击敌人",
        plant_type: "normal",
        feature_type: "normal",
        target_card: "none",
        is_gold: 1
    }, 
    {
        shape: 2,
        sprite: spr_odin_2,
        cost: 230,
        cooldown: 420,
        description: "主神·奥丁：发射冈格尼尔穿透攻击敌人，发射两发",
        plant_type: "normal",
        feature_type: "normal",
        target_card: "none",
        is_gold: 1
    }, 
    {
        shape: 3,
        sprite: spr_odin_3,
        cost: 230,
        cooldown: 420,
        description: "至尊主神：发射冈格尼尔穿透攻击敌人，发射三发",
        plant_type: "normal",
        feature_type: "normal",
        target_card: "none",
        is_gold: 1
    }]);
    register_card("zeus", obj_zeus, [
    {
        shape: 0,
        sprite: spr_zeus,
        cost: 375,
        cooldown: 1200,
        description: "宙斯神使：全屏轰击，造成3×3范围伤害",
        plant_type: "normal",
        feature_type: "normal",
        target_card: "none",
        is_gold: 1
    }, 
    {
        shape: 1,
        sprite: spr_zeus_1,
        cost: 375,
        cooldown: 1200,
        description: "宙斯圣神：全屏轰击，造成3×3范围伤害",
        plant_type: "normal",
        feature_type: "normal",
        target_card: "none",
        is_gold: 1
    }, 
    {
        shape: 2,
        sprite: spr_zeus_2,
        cost: 375,
        cooldown: 1200,
        description: "天神·宙斯：全屏轰击，造成3×3范围伤害",
        plant_type: "normal",
        feature_type: "normal",
        target_card: "none",
        is_gold: 1
    }, 
    {
        shape: 3,
        sprite: spr_zeus_3,
        cost: 375,
        cooldown: 1200,
        description: "至尊天神：全屏轰击，造成3×3范围伤害",
        plant_type: "normal",
        feature_type: "normal",
        target_card: "none",
        is_gold: 1
    }]);
    register_card("ice_god", obj_ice_god, [
    {
        shape: 0,
        sprite: spr_ice_god,
        cost: 325,
        cooldown: 900,
        description: "典伊神使：召唤8颗冰晶轰击敌人",
        plant_type: "normal",
        feature_type: "normal",
        target_card: "none",
        is_gold: 1
    }, 
    {
        shape: 1,
        sprite: spr_ice_god_1,
        cost: 225,
        cooldown: 900,
        description: "典伊圣神：召唤8颗冰晶轰击敌人",
        plant_type: "normal",
        feature_type: "normal",
        target_card: "none",
        is_gold: 1
    }, 
    {
        shape: 2,
        sprite: spr_ice_god_2,
        cost: 225,
        cooldown: 900,
        description: "冰神·典伊：召唤10颗冰晶轰击敌人",
        plant_type: "normal",
        feature_type: "normal",
        target_card: "none",
        is_gold: 1
    }, 
    {
        shape: 3,
        sprite: spr_ice_god_3,
        cost: 225,
        cooldown: 900,
        description: "至尊冰神：召唤12颗冰晶轰击敌人",
        plant_type: "normal",
        feature_type: "normal",
        target_card: "none",
        is_gold: 1
    }]);
    register_card("ghost_god", obj_ghost_god, [
    {
        shape: 0,
        sprite: spr_ghost_god,
        cost: 225,
        cooldown: 3000,
        description: "哈迪斯神使：发射五向子弹",
        plant_type: "normal",
        feature_type: "normal",
        target_card: "none",
        is_gold: 1
    }, 
    {
        shape: 1,
        sprite: spr_ghost_god_1,
        cost: 225,
        cooldown: 3000,
        description: "哈迪斯圣神：发射五向子弹",
        plant_type: "normal",
        feature_type: "normal",
        target_card: "none",
        is_gold: 1
    }, 
    {
        shape: 2,
        sprite: spr_ghost_god_2,
        cost: 225,
        cooldown: 3000,
        description: "冥神·哈迪斯：发射五向子弹",
        plant_type: "normal",
        feature_type: "normal",
        target_card: "none",
        is_gold: 1
    }, 
    {
        shape: 3,
        sprite: spr_ghost_god_3,
        cost: 225,
        cooldown: 3000,
        description: "至尊冥神：发射五向子弹",
        plant_type: "normal",
        feature_type: "normal",
        target_card: "none",
        is_gold: 1
    }]);
    register_card("hera", obj_hera, [
    {
        shape: 0,
        sprite: spr_hera_icon_1,
        cost: 125,
        cooldown: 1800,
        description: "赫拉神使：保护被罩住的卡片",
        plant_type: "shield_outer",
        feature_type: "normal",
        target_card: "none",
        place_preview: spr_hera_outer_1,
        is_gold: 1
    }, 
    {
        shape: 1,
        sprite: spr_hera_icon_2,
        cost: 125,
        cooldown: 1800,
        description: "赫拉圣神：保护被罩住的卡片并反伤",
        plant_type: "shield_outer",
        feature_type: "normal",
        target_card: "none",
        place_preview: spr_hera_1_outer_1,
        is_gold: 1
    }, 
    {
        shape: 2,
        sprite: spr_hera_icon_3,
        cost: 125,
        cooldown: 1800,
        description: "天后·赫拉：保护被罩住的卡片并反伤",
        plant_type: "shield_outer",
        feature_type: "normal",
        target_card: "none",
        place_preview: spr_hera_2_outer_1,
        is_gold: 1
    }, 
    {
        shape: 3,
        sprite: spr_hera_icon_4,
        cost: 125,
        cooldown: 1800,
        description: "至尊天后：保护被罩住的卡片并反伤",
        plant_type: "shield_outer",
        feature_type: "normal",
        target_card: "none",
        place_preview: spr_hera_3_outer_1,
        is_gold: 1
    }]);
    register_card("fire_god", obj_fire_god, [
    {
        shape: 0,
        sprite: spr_fire_god,
        cost: 225,
        cooldown: 420,
        description: "洛基神使：点燃子弹",
        plant_type: "normal",
        feature_type: "normal",
        target_card: "none",
        is_gold: 1
    }, 
    {
        shape: 1,
        sprite: spr_fire_god_1,
        cost: 175,
        cooldown: 420,
        description: "洛基圣神：点燃子弹",
        plant_type: "normal",
        feature_type: "normal",
        target_card: "none",
        is_gold: 1
    }, 
    {
        shape: 2,
        sprite: spr_fire_god_2,
        cost: 175,
        cooldown: 420,
        description: "火神·洛基：点燃子弹",
        plant_type: "normal",
        feature_type: "normal",
        target_card: "none",
        is_gold: 1
    }, 
    {
        shape: 3,
        sprite: spr_fire_god_3,
        cost: 100,
        cooldown: 420,
        description: "至尊火神：点燃子弹",
        plant_type: "normal",
        feature_type: "normal",
        target_card: "none",
        is_gold: 1
    }]);
    register_card("water_god", obj_water_god, [
    {
        shape: 0,
        sprite: spr_water_god,
        cost: 150,
        cooldown: 420,
        description: "忒提丝神使：反弹子弹并附加伤害",
        plant_type: "normal",
        feature_type: "normal",
        target_card: "none",
        is_gold: 1
    }, 
    {
        shape: 1,
        sprite: spr_water_god_1,
        cost: 75,
        cooldown: 420,
        description: "忒提丝圣神：反弹子弹并附加伤害",
        plant_type: "normal",
        feature_type: "normal",
        target_card: "none",
        is_gold: 1
    }, 
    {
        shape: 2,
        sprite: spr_water_god_2_icon,
        cost: 75,
        cooldown: 420,
        description: "水神·忒提丝：反弹子弹并附加伤害",
        plant_type: "normal",
        feature_type: "normal",
        target_card: "none",
        is_gold: 1,
        place_preview: spr_water_god_2
    }, 
    {
        shape: 3,
        sprite: spr_water_god_3_icon,
        cost: 75,
        cooldown: 420,
        description: "至尊水神：反弹子弹并附加伤害",
        plant_type: "normal",
        feature_type: "normal",
        target_card: "none",
        is_gold: 1,
        place_preview: spr_water_god_3
    }]);
    register_card("power_god", obj_power_god, [
    {
        shape: 0,
        sprite: spr_power_god,
        cost: 275,
        cooldown: 420,
        description: "赫丘利神使：发射两发强力子弹追踪攻击空中鼠军",
        plant_type: "normal",
        feature_type: "normal",
        target_card: "none",
        is_gold: 1
    }, 
    {
        shape: 1,
        sprite: spr_power_god_1,
        cost: 275,
        cooldown: 420,
        description: "赫丘利圣神：发射两发强力子弹追踪攻击空中鼠军",
        plant_type: "normal",
        feature_type: "normal",
        target_card: "none",
        is_gold: 1
    }, 
    {
        shape: 2,
        sprite: spr_power_god_2,
        cost: 275,
        cooldown: 420,
        description: "大力神·赫丘利：发射三发强力子弹追踪攻击空中鼠军",
        plant_type: "normal",
        feature_type: "normal",
        target_card: "none",
        is_gold: 1
    }, 
    {
        shape: 3,
        sprite: spr_power_god_3,
        cost: 275,
        cooldown: 420,
        description: "至尊大力神：发射四发强力子弹追踪攻击空中鼠军",
        plant_type: "normal",
        feature_type: "normal",
        target_card: "none",
        is_gold: 1
    }]);
    register_card("sheng_huo", obj_sh, [
    {
        shape: 0,
        sprite: spr_sh,
        cost: 320,
        cooldown: 420,
        description: "赫斯提亚神使：施展火焰术，向前方3行释放神圣穿透型火焰，灼烧沿途鼠军",
        plant_type: "normal",
        feature_type: "normal",
        target_card: "none",
        is_gold: 1
    }, 
    {
        shape: 1,
        sprite: spr_sh_icon_1,
        cost: 320,
        cooldown: 420,
        description: "赫斯提亚圣神：施展火焰术，向前方3行释放神圣穿透型火焰，灼烧沿途鼠军",
        plant_type: "normal",
        feature_type: "normal",
        target_card: "none",
        is_gold: 1,
        place_preview: spr_sh_1
    }, 
    {
        shape: 2,
        sprite: spr_sh_icon_2,
        cost: 320,
        cooldown: 420,
        description: "圣火女神·赫斯提亚：施展火焰术，向前方3行释放神圣穿透型火焰，灼烧沿途鼠军",
        plant_type: "normal",
        feature_type: "normal",
        target_card: "none",
        is_gold: 1,
        place_preview: spr_sh_2
    }, 
    {
        shape: 3,
        sprite: spr_sh_icon_3,
        cost: 320,
        cooldown: 420,
        description: "至尊圣火女神：施展火焰术，向前方3行释放神圣穿透型火焰，灼烧沿途鼠军",
        plant_type: "normal",
        feature_type: "normal",
        target_card: "none",
        is_gold: 1,
        place_preview: spr_sh_3
    }]);
    register_card("save_god", obj_save_god, [
    {
        shape: 0,
        sprite: spr_save_god_0,
        cost: 375,
        cooldown: 1800,
        description: "灵鱼摩蹉神使：化身为4条灵鱼，冲撞沿途遇到的老鼠",
        plant_type: "normal",
        feature_type: "normal",
        target_card: "none",
        is_gold: 1
    }, 
    {
        shape: 1,
        sprite: spr_save_god_1,
        cost: 375,
        cooldown: 1800,
        description: "灵鱼摩蹉圣神：化身为4条灵鱼，冲撞沿途遇到的老鼠",
        plant_type: "coffee",
        feature_type: "normal",
        target_card: "none",
        is_gold: 1
    }, 
    {
        shape: 2,
        sprite: spr_save_god_2_icon,
        cost: 375,
        cooldown: 1800,
        description: "救世神·灵鱼摩蹉：化身为5条灵鱼，冲撞沿途遇到的老鼠",
        plant_type: "coffee",
        feature_type: "normal",
        target_card: "none",
        is_gold: 1,
        place_preview: spr_save_god_2
    }, 
    {
        shape: 3,
        sprite: spr_save_god_3_icon,
        cost: 375,
        cooldown: 1800,
        description: "至尊救世神：化身为7条灵鱼，冲撞沿途遇到的老鼠",
        plant_type: "coffee",
        feature_type: "normal",
        target_card: "none",
        is_gold: 1,
        place_preview: spr_save_god_3
    }]);
    register_card("ymir", obj_ymir, [
    {
        shape: 0,
        sprite: spr_ymir_icon,
        cost: 380,
        cooldown: 420,
        description: "尤弥尔神使：向前方三行投出共6发巨锤",
        plant_type: "normal",
        feature_type: "normal",
        target_card: "none",
        place_preview: spr_ymir,
        is_gold: 1
    }, 
    {
        shape: 1,
        sprite: spr_ymir_icon_1,
        cost: 380,
        cooldown: 420,
        description: "尤弥尔圣神：向前方三行投出共7发巨锤",
        plant_type: "normal",
        feature_type: "normal",
        target_card: "none",
        place_preview: spr_ymir_1,
        is_gold: 1
    }, 
    {
        shape: 2,
        sprite: spr_ymir_icon_2,
        cost: 380,
        cooldown: 420,
        description: "巨神·尤弥尔：向前方三行投出共9发巨锤",
        plant_type: "normal",
        feature_type: "normal",
        target_card: "none",
        place_preview: spr_ymir_2,
        is_gold: 1
    }, 
    {
        shape: 3,
        sprite: spr_ymir_icon_3,
        cost: 380,
        cooldown: 420,
        description: "至尊巨神：向前方三行投出共12发巨锤",
        plant_type: "normal",
        feature_type: "normal",
        target_card: "none",
        place_preview: spr_ymir_3,
        is_gold: 1
    }]);
    register_card("joker", obj_joker, [
    {
        shape: 0,
        sprite: spr_joker_icon,
        cost: 275,
        cooldown: 420,
        description: "埃罗斯神使：连续发射3发带有溅射效果的子弹，先后攻击本行空、地、水陆老鼠",
        plant_type: "normal",
        feature_type: "normal",
        target_card: "none",
        is_gold: 1,
        place_preview: spr_joker_0
    }, 
    {
        shape: 1,
        sprite: spr_joker_icon_1,
        cost: 275,
        cooldown: 420,
        description: "埃罗斯圣神：连续发射3发带有溅射效果的子弹，先后攻击本行空、地、水陆老鼠",
        plant_type: "normal",
        feature_type: "normal",
        target_card: "none",
        is_gold: 1,
        place_preview: spr_joker_1
    }, 
    {
        shape: 2,
        sprite: spr_joker_icon_2,
        cost: 275,
        cooldown: 420,
        description: "恶作剧神·埃罗斯：连续发射3发带有溅射效果的子弹，先后攻击本行空、地、水陆老鼠",
        plant_type: "normal",
        feature_type: "normal",
        target_card: "none",
        is_gold: 1,
        place_preview: spr_joker_2
    }, 
    {
        shape: 3,
        sprite: spr_joker_icon_3,
        cost: 275,
        cooldown: 420,
        description: "至尊恶作剧神：连续发射3发带有溅射效果的子弹，先后攻击本行空、地、水陆老鼠",
        plant_type: "normal",
        feature_type: "normal",
        target_card: "none",
        is_gold: 1,
        place_preview: spr_joker_3
    }]);
    register_card("athena", obj_athena, [
    {
        shape: 0,
        sprite: spr_athena,
        cost: 375,
        cooldown: 1200,
        description: "雅典娜守护：全屏轰击，造成3×3范围伤害",
        plant_type: "normal",
        feature_type: "normal",
        target_card: "none"
    }, 
    {
        shape: 1,
        sprite: spr_athena_1,
        cost: 375,
        cooldown: 1200,
        description: "雅典娜圣衣：全屏轰击，造成3×3范围伤害",
        plant_type: "normal",
        feature_type: "normal",
        target_card: "none"
    }, 
    {
        shape: 2,
        sprite: spr_athena_2,
        cost: 375,
        cooldown: 1200,
        description: "雅典娜光辉：全屏轰击，造成3×3范围伤害",
        plant_type: "normal",
        feature_type: "normal",
        target_card: "none"
    }]);
    register_card("shuangzi", obj_shuangzi, [
    {
        shape: 0,
        sprite: spr_shuangzi,
        cost: 200,
        cooldown: 3000,
        description: "双子座精灵：一次性产出4朵火苗",
        plant_type: "normal",
        feature_type: "normal",
        target_card: "none"
    }, 
    {
        shape: 1,
        sprite: spr_shuangzi_1,
        cost: 200,
        cooldown: 1800,
        description: "双子座战将：一次性产出4朵火苗",
        plant_type: "normal",
        feature_type: "normal",
        target_card: "none"
    }, 
    {
        shape: 2,
        sprite: spr_shuangzi_2,
        cost: 200,
        cooldown: 1200,
        description: "双子座星宿：一次性产出6朵火苗",
        plant_type: "normal",
        feature_type: "normal",
        target_card: "none"
    }]);
    register_card("sheshou", obj_sheshou, [
    {
        shape: 0,
        sprite: spr_sheshou,
        cost: 300,
        cooldown: 420,
        description: "射手座精灵：向前方三行射出4发强力子弹",
        plant_type: "normal",
        feature_type: "normal",
        target_card: "none"
    }, 
    {
        shape: 1,
        sprite: spr_sheshou_1,
        cost: 300,
        cooldown: 420,
        description: "射手座战将：向前方三行射出4发强力子弹",
        plant_type: "normal",
        feature_type: "normal",
        target_card: "none"
    }, 
    {
        shape: 2,
        sprite: spr_sheshou_2,
        cost: 300,
        cooldown: 420,
        description: "射手座星宿：向前方三行射出6发强力子弹",
        plant_type: "normal",
        feature_type: "normal",
        target_card: "none"
    }]);
    register_card("tiancheng", obj_tiancheng, [
    {
        shape: 0,
        sprite: spr_tiancheng,
        cost: 150,
        cooldown: 420,
        description: "天秤座精灵：向前后各射出3发比较强力的子弹",
        plant_type: "normal",
        feature_type: "normal",
        target_card: "none"
    }, 
    {
        shape: 1,
        sprite: spr_tiancheng_1,
        cost: 150,
        cooldown: 420,
        description: "天秤座战将：向前后各射出3发比较强力的子弹",
        plant_type: "normal",
        feature_type: "normal",
        target_card: "none"
    }, 
    {
        shape: 2,
        sprite: spr_tiancheng_2,
        cost: 150,
        cooldown: 420,
        description: "天秤座星宿：向前后各射出4发比较强力的子弹",
        plant_type: "normal",
        feature_type: "normal",
        target_card: "none"
    }]);
    register_card("shuangyu", obj_shuangyu, [
    {
        shape: 0,
        sprite: spr_shuangyu_icon,
        cost: 200,
        cooldown: 420,
        description: "双鱼座精灵：投掷两颗带有减速的冰鱼",
        plant_type: "normal",
        feature_type: "normal",
        target_card: "none",
        place_preview: spr_shuangyu
    }, 
    {
        shape: 1,
        sprite: spr_shuangyu_1_icon,
        cost: 200,
        cooldown: 420,
        description: "双鱼座战将：投掷两颗带有减速的冰鱼",
        plant_type: "normal",
        feature_type: "normal",
        target_card: "none",
        place_preview: spr_shuangyu_1
    }, 
    {
        shape: 2,
        sprite: spr_shuangyu_2_icon,
        cost: 200,
        cooldown: 420,
        description: "双鱼座星宿：投掷两颗带有减速的强力冰鱼",
        plant_type: "normal",
        feature_type: "normal",
        target_card: "none",
        place_preview: spr_shuangyu_2
    }]);
    register_card("juxie", obj_juxie, [
    {
        shape: 0,
        sprite: spr_juxie,
        cost: 225,
        cooldown: 1800,
        description: "巨蟹座精灵：发射4发强力钳子，全屏跟踪",
        plant_type: "normal",
        feature_type: "normal",
        target_card: "none"
    }, 
    {
        shape: 1,
        sprite: spr_juxie_1,
        cost: 225,
        cooldown: 1200,
        description: "巨蟹座战将：发射4发强力钳子，全屏跟踪",
        plant_type: "normal",
        feature_type: "normal",
        target_card: "none"
    }, 
    {
        shape: 2,
        sprite: spr_juxie_2,
        cost: 225,
        cooldown: 900,
        description: "巨蟹座星宿：发射6发强力钳子，全屏跟踪",
        plant_type: "normal",
        feature_type: "normal",
        target_card: "none"
    }]);
    register_card("shizi", obj_shizi, [
    {
        shape: 0,
        sprite: spr_shizi,
        cost: 275,
        cooldown: 1800,
        description: "狮子座精灵：5×5范围穿透打击",
        plant_type: "normal",
        feature_type: "normal",
        target_card: "none"
    }, 
    {
        shape: 1,
        sprite: spr_shizi_1,
        cost: 275,
        cooldown: 1200,
        description: "狮子座战将：5×5范围穿透打击",
        plant_type: "normal",
        feature_type: "normal",
        target_card: "none"
    }, 
    {
        shape: 2,
        sprite: spr_shizi_2,
        cost: 275,
        cooldown: 900,
        description: "狮子座星宿：5×5范围两次穿透打击",
        plant_type: "normal",
        feature_type: "normal",
        target_card: "none"
    }]);
    register_card("jinniu", obj_jinniu, [
    {
        shape: 0,
        sprite: spr_jinniu,
        cost: 225,
        cooldown: 420,
        description: "金牛座精灵：点燃子弹",
        plant_type: "normal",
        feature_type: "normal",
        target_card: "none"
    }, 
    {
        shape: 1,
        sprite: spr_jinniu_1,
        cost: 175,
        cooldown: 420,
        description: "金牛座战将：点燃子弹",
        plant_type: "normal",
        feature_type: "normal",
        target_card: "none"
    }, 
    {
        shape: 2,
        sprite: spr_jinniu_2,
        cost: 175,
        cooldown: 420,
        description: "金牛座星宿：点燃子弹",
        plant_type: "normal",
        feature_type: "normal",
        target_card: "none"
    }]);
    register_card("chunv", obj_chunv, [
    {
        shape: 0,
        sprite: spr_chunv_0_3,
        cost: 175,
        cooldown: 1800,
        description: "处女座精灵：保护卡牌，并反弹伤害",
        plant_type: "shield_outer",
        feature_type: "normal",
        target_card: "none"
    }, 
    {
        shape: 1,
        sprite: spr_chunv_1_4,
        cost: 200,
        cooldown: 1800,
        description: "处女座战将：保护卡牌，并反弹伤害",
        plant_type: "shield_outer",
        feature_type: "normal",
        target_card: "none"
    }, 
    {
        shape: 2,
        sprite: spr_chunv_2_4,
        cost: 225,
        cooldown: 1800,
        description: "处女座星宿：保护卡牌，并反弹伤害",
        plant_type: "shield_outer",
        feature_type: "normal",
        target_card: "none"
    }]);
    register_card("tianxie", obj_tianxie, [
    {
        shape: 0,
        sprite: spr_tianxie,
        cost: 200,
        cooldown: 420,
        description: "天蝎座精灵：发射一根穿透毒刺",
        plant_type: "normal",
        feature_type: "normal",
        target_card: "none"
    }, 
    {
        shape: 1,
        sprite: spr_tianxie_1,
        cost: 200,
        cooldown: 420,
        description: "天蝎座战将：发射一根穿透毒刺",
        plant_type: "normal",
        feature_type: "normal",
        target_card: "none"
    }, 
    {
        shape: 2,
        sprite: spr_tianxie_2,
        cost: 200,
        cooldown: 420,
        description: "天蝎座星宿：发射一根穿透毒刺",
        plant_type: "normal",
        feature_type: "normal",
        target_card: "none"
    }]);
    register_card("baiyang", obj_baiyang, [
    {
        shape: 0,
        sprite: spr_baiyang_icon,
        cost: 300,
        cooldown: 3000,
        description: "白羊座精灵：冲撞清除一行鼠军",
        plant_type: "normal",
        feature_type: "normal",
        target_card: "none",
        place_preview: spr_baiyang
    }, 
    {
        shape: 1,
        sprite: spr_baiyang_icon,
        cost: 200,
        cooldown: 3000,
        description: "白羊座战将：冲撞清除一行鼠军，且无需格子放置",
        plant_type: "coffee",
        feature_type: "normal",
        target_card: "none",
        place_preview: spr_baiyang
    }, 
    {
        shape: 2,
        sprite: spr_baiyang_icon,
        cost: 200,
        cooldown: 3000,
        description: "白羊座星宿：冲撞清除三行鼠军，且无需格子放置",
        plant_type: "coffee",
        feature_type: "normal",
        target_card: "none",
        place_preview: spr_baiyang
    }]);
    register_card("mojie", obj_mojie, [
    {
        shape: 0,
        sprite: spr_mojie,
        cost: 300,
        cooldown: 3000,
        description: "摩羯座精灵：3×3范围内持续伤害并减速",
        plant_type: "normal",
        feature_type: "normal",
        target_card: "none"
    }, 
    {
        shape: 1,
        sprite: spr_mojie_1,
        cost: 300,
        cooldown: 3000,
        description: "摩羯座战将：3×3范围内持续伤害并减速",
        plant_type: "normal",
        feature_type: "normal",
        target_card: "none"
    }, 
    {
        shape: 2,
        sprite: spr_mojie_2,
        cost: 300,
        cooldown: 3000,
        description: "摩羯座星宿：5×5范围内持续伤害并减速",
        plant_type: "normal",
        feature_type: "normal",
        target_card: "none"
    }]);
    register_card("corn_shooter", obj_corn_shooter, [
    {
        shape: 0,
        sprite: spr_corn_shooter,
        cost: 250,
        cooldown: 3000,
        description: "玉蜀黍：发射三颗玉米",
        plant_type: "normal",
        feature_type: "normal",
        target_card: "none"
    }, 
    {
        shape: 1,
        sprite: spr_corn_shooter_1,
        cost: 250,
        cooldown: 3000,
        description: "奶油玉米机枪：发射六颗玉米",
        plant_type: "normal",
        feature_type: "normal",
        target_card: "none"
    }, 
    {
        shape: 2,
        sprite: spr_corn_shooter_2,
        cost: 250,
        cooldown: 3000,
        description: "加农玉米机枪：发射六颗玉米",
        plant_type: "normal",
        feature_type: "normal",
        target_card: "none"
    }]);
    register_card("warm_birds", obj_warm_birds, [
    {
        shape: 0,
        sprite: spr_warm_birds,
        cost: 125,
        cooldown: 1800,
        description: "暖暖鸡：一次生产3朵火苗",
        plant_type: "normal",
        feature_type: "normal",
        target_card: "none"
    }, 
    {
        shape: 1,
        sprite: spr_warm_birds_1,
        cost: 125,
        cooldown: 1800,
        description: "焰羽暖暖鸡：一次生产4朵火苗",
        plant_type: "normal",
        feature_type: "normal",
        target_card: "none"
    }, 
    {
        shape: 2,
        sprite: spr_warm_birds_2,
        cost: 125,
        cooldown: 900,
        description: "日耀暖暖鸡：一次生产5朵火苗",
        plant_type: "normal",
        feature_type: "normal",
        target_card: "none"
    }]);
    // 已移除 sea_star（不需要的卡片）
    // 已移除 tanghulu（对象未创建）
    register_card("cold_drew", obj_cold_drew, [
    {
        shape: 0,
        sprite: spr_cold_drew_machine_icon,
        cost: 295,
        cooldown: 900,
        description: "冰块冷萃机：对全屏敌人发射至多4颗追踪冰块",
        plant_type: "normal",
        feature_type: "normal",
        target_card: "none",
        place_preview: spr_cold_drew_machine
    }, 
    {
        shape: 1,
        sprite: spr_cold_drew_machine_icon_1,
        cost: 295,
        cooldown: 900,
        description: "低温冷萃机：对全屏敌人发射至多5颗追踪冰块",
        plant_type: "normal",
        feature_type: "normal",
        target_card: "none",
        place_preview: spr_cold_drew_machine_1
    }, 
    {
        shape: 2,
        sprite: spr_cold_drew_machine_icon_2,
        cost: 295,
        cooldown: 900,
        description: "迅捷冷萃机：对全屏敌人发射6颗追踪冰块，可集火",
        plant_type: "normal",
        feature_type: "normal",
        target_card: "none",
        place_preview: spr_cold_drew_machine_2
    }]);
    register_card("berry_dessert", obj_berry_dessert, [
    {
        shape: 0,
        sprite: spr_berry_dessert_icon,
        cost: 260,
        cooldown: 2400,
        description: "莓果点心：为3x3范围内追踪类卡片提供增伤",
        plant_type: "normal",
        feature_type: "normal",
        target_card: "none"
    }, 
    {
        shape: 1,
        sprite: spr_berry_dessert_icon_1,
        cost: 260,
        cooldown: 2400,
        description: "薄荷莓果点心：为5x5范围内追踪类卡片提供增伤",
        plant_type: "normal",
        feature_type: "normal",
        target_card: "none"
    }, 
    {
        shape: 2,
        sprite: spr_berry_dessert_icon_2,
        cost: 260,
        cooldown: 2400,
        description: "流心莓果点心：为5x5范围内追踪类卡片提供增伤",
        plant_type: "normal",
        feature_type: "normal",
        target_card: "none"
    }]);
    register_card("grilled_lizard_pult", obj_grilled_lizard_pult, [
    {
        shape: 0,
        sprite: spr_grilled_lizard_pult,
        cost: 275,
        cooldown: 420,
        description: "烤蜥蜴投手：向前投掷配料爆弹",
        plant_type: "normal",
        feature_type: "normal",
        target_card: "none"
    }, 
    {
        shape: 1,
        sprite: spr_grilled_lizard_pult_1,
        cost: 275,
        cooldown: 420,
        description: "坚果蜥蜴投手：向前投掷配料爆弹",
        plant_type: "normal",
        feature_type: "normal",
        target_card: "none"
    }, 
    {
        shape: 2,
        sprite: spr_grilled_lizard_pult_2,
        cost: 275,
        cooldown: 420,
        description: "花椒蜥蜴投手：向前投掷2发配料爆弹",
        plant_type: "normal",
        feature_type: "normal",
        target_card: "none"
    }]);
    register_card("blueberry_tower", obj_blueberry_tower, [
    {
        shape: 0,
        sprite: spr_blueberry_tower,
        cost: 160,
        cooldown: 2100,
        description: "蓝莓信号塔塔：为本行投掷卡片增加攻击力",
        plant_type: "normal",
        feature_type: "normal",
        target_card: "none"
    }]);
    register_card("donut", obj_donut, [
    {
        shape: 0,
        sprite: spr_donut_3,
        cost: 200,
        cooldown: 420,
        description: "梦幻多拿滋：连续攻击本行鼠军，优先空军",
        plant_type: "normal",
        feature_type: "normal",
        target_card: "none",
        place_preview: spr_donut
    }, 
    {
        shape: 1,
        sprite: spr_donut_4,
        cost: 200,
        cooldown: 420,
        description: "仙女多拿滋：连续攻击本行鼠军，优先空军",
        plant_type: "normal",
        feature_type: "normal",
        target_card: "none",
        place_preview: spr_donut_1
    }, 
    {
        shape: 2,
        sprite: spr_donut_5,
        cost: 200,
        cooldown: 420,
        description: "女王多拿滋：连续攻击本行鼠军，优先空军",
        plant_type: "normal",
        feature_type: "normal",
        target_card: "none",
        place_preview: spr_donut_2
    }]);
    register_card("spoon_rabbit", obj_spoon_rabbit, [
    {
        shape: 0,
        sprite: spr_spoon_rabbit_icon,
        cost: 300,
        cooldown: 420,
        description: "勺勺兔：向前方3行投射子弹",
        plant_type: "normal",
        feature_type: "normal",
        target_card: "none",
        place_preview: spr_spoon_rabbit
    }, 
    {
        shape: 1,
        sprite: spr_spoon_rabbit_icon_1,
        cost: 300,
        cooldown: 420,
        description: "增强勺勺兔：向前方3行投射子弹",
        plant_type: "normal",
        feature_type: "normal",
        target_card: "none",
        place_preview: spr_spoon_rabbit_1
    }, 
    {
        shape: 2,
        sprite: spr_spoon_rabbit_icon_2,
        cost: 300,
        cooldown: 420,
        description: "盖世勺勺兔：向前方3行投射子弹",
        plant_type: "normal",
        feature_type: "normal",
        target_card: "none",
        place_preview: spr_spoon_rabbit_2
    }]);
    register_card("hspeed_juicer", obj_hspeed_juicer, [
    {
        shape: 0,
        sprite: spr_hspeed_juicer,
        cost: 260,
        cooldown: 2700,
        description: "加速榨汁机：为3x3范围内喷壶类卡片提供增伤",
        plant_type: "shield_outer",
        feature_type: "normal",
        target_card: "none"
    }, 
    {
        shape: 1,
        sprite: spr_hspeed_juicer_1,
        cost: 260,
        cooldown: 2700,
        description: "苹果榨汁机：为3x3范围内喷壶类卡片提供增伤",
        plant_type: "shield_outer",
        feature_type: "normal",
        target_card: "none"
    }, 
    {
        shape: 2,
        sprite: spr_hspeed_juicer_2,
        cost: 260,
        cooldown: 2700,
        description: "大菠萝榨汁机：为5x5范围内喷壶类卡片提供增伤",
        plant_type: "shield_outer",
        feature_type: "normal",
        target_card: "none"
    }]);
    }
