function mod_weapons_init()
{
    register_weapon("zeus_bolt", 
    {
        sprite: spr_zeus_bolt,
        icon: spr_zeus_bolt_icon,
        obj: obj_zeus_bolt,
        slot: "main_weapon",
        allowed_gems: ["zeus_shadow_gem", "zeus_power_gem", "zeus_anger_gem"],
        atk: 65,
        bullet_amount: 2,
        bullet_style: 0,
        splash_ratio: 0,
        cycle: 120,
        description: "宙斯神弩：发射两个追踪飞镖攻击敌人",
        name: "宙斯神弩",
        atk_impact: [78, 91, 104, 117, 130, 143, 156, 169, 182, 195, 227, 240, 253, 266, 279, 292],
        bullet_amount_impact: [2, 2, 2, 3, 3, 3, 4, 4, 4, 5, 5, 5, 6, 6, 6, 7],
        bullet_style_impact: [0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 2, 2, 3, 3, 4, 4],
        splash_ratio_impact: [15, 16, 18, 20, 23, 26, 29, 32, 35, 40, 45, 50, 55, 65, 75, 90]
    });
    register_weapon("master_shield", 
    {
        sprite: spr_master_shield,
        icon: spr_master_shield_icon,
        obj: obj_player_shield,
        slot: "secondary_weapon",
        allowed_gems: ["divine_blessing_gem", "divine_forbidden_gem", "divine_holy_gem", "divine_protect_gem"],
        hp_increase: 800,
        description: "主宰之盾：增加800生命值",
        name: "主宰之盾"
    });
    register_weapon("hades_scythe", 
    {
        sprite: spr_hades_scythe_icon,
        icon: spr_hades_scythe_icon,
        obj: obj_hades_scythe_enter,
        slot: "super_weapon",
        allowed_gems: ["ghost_strike_gem", "ghost_spark_gem", "ghost_pact_gem"],
        atk: 230,
        cycle: 900,
        ghost_shape: 0,
        bullet_shape: 0,
        bullet_amount: 1,
        description: "冥王战镰：∞形轨迹发射旋转镰刀",
        name: "冥王战镰",
        atk_impact: [356, 414, 471, 529, 609, 690, 782, 908, 1035, 1161, 1380, 1495, 1575, 1656, 1736, 1897],
        cycle_impact: [807, 780, 753, 726, 690, 654, 618, 564, 510, 480, 390, 375, 360, 345, 330, 300],
        bullet_amount_impact: [1, 1, 1, 1, 2, 2, 2, 2, 3, 3, 3, 3, 4, 4, 4, 5],
        bullet_shape_impact: [0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 2, 2, 3, 3, 4, 4],
        ghost_shape_impact: [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 2, 2]
    });
    register_gem("zeus_shadow_gem", 
    {
        name: "天神之影",
        description: "天神之影：增加宙斯神弩子弹溅射\n[专属宝石]：宙斯神弩",
        icon: spr_zeus_shadow_gem_icon,
        slot: "main_weapon",
        obj: obj_zeus_shadow_gem,
        allowed_weapons: ["zeus_bolt"],
        max_level: 15
    });
    register_gem("zeus_power_gem", 
    {
        name: "天神之力",
        description: "天神之力：增加宙斯神弩子弹伤害\n[专属宝石]：宙斯神弩",
        icon: spr_zeus_power_gem_icon,
        slot: "main_weapon",
        obj: obj_zeus_power_gem,
        allowed_weapons: ["zeus_bolt"],
        max_level: 15
    });
    register_gem("zeus_anger_gem", 
    {
        name: "天神之怒",
        description: "天神之怒：增加宙斯神弩子弹数量\n[专属宝石]：宙斯神弩",
        icon: spr_zeus_anger_gem_icon,
        slot: "main_weapon",
        obj: obj_zeus_anger_gem,
        allowed_weapons: ["zeus_bolt"],
        max_level: 15
    });
    register_gem("ghost_strike_gem", 
    {
        name: "亡灵强袭",
        description: "亡灵强袭：增加冥王战镰伤害\n[专属宝石]：冥王战镰",
        icon: spr_ghost_strike_gem_icon,
        slot: "super_weapon",
        obj: obj_ghost_strike_gem,
        allowed_weapons: ["hades_scythe"],
        max_level: 15
    });
    register_gem("ghost_spark_gem", 
    {
        name: "亡灵星火",
        description: "亡灵星火：增加冥王战镰攻速\n[专属宝石]：冥王战镰",
        icon: spr_ghost_spark_gem_icon,
        slot: "super_weapon",
        obj: obj_ghost_spark_gem,
        allowed_weapons: ["hades_scythe"],
        max_level: 15
    });
    register_gem("ghost_pact_gem", 
    {
        name: "亡灵契约",
        description: "亡灵契约：增加冥王战镰子弹\n[专属宝石]：冥王战镰",
        icon: spr_ghost_pact_gem_icon,
        slot: "super_weapon",
        obj: obj_ghost_pact_gem,
        allowed_weapons: ["hades_scythe"],
        max_level: 15
    });
    register_gem("divine_blessing_gem", 
    {
        name: "神佑之眼",
        description: "神佑之眼：生产火苗\n[专属宝石]：主宰之盾",
        icon: spr_divine_blessing_gem_icon,
        slot: "secondary_weapon",
        first_produce_delay: 1,
        cycle: [15, 15, 15, 14, 14, 14, 13, 13, 12, 11, 10, 10, 10, 10, 10, 10],
        flame_value: [20, 30, 40, 50, 60, 75, 90, 105, 120, 135, 150, 170, 190, 210, 230, 260],
        obj: obj_divine_blessing_gem,
        allowed_weapons: ["master_shield"],
        max_level: 15
    });
    register_gem("divine_protect_gem", 
    {
        name: "神护之眼",
        description: "神护之眼：为周围卡片增加攻击力\n[专属宝石]：主宰之盾",
        icon: spr_divine_protect_gem_icon,
        slot: "secondary_weapon",
        max_level: 15,
        atk_ratio: [0.07, 0.08, 0.09, 0.11, 0.14, 0.17, 0.2, 0.23, 0.26, 0.29, 0.32, 0.35, 0.38, 0.42, 0.46, 0.5],
        obj: obj_divine_protect_gem,
        allowed_weapons: ["master_shield"]
    });
    register_gem("divine_holy_gem", 
    {
        name: "神圣之眼",
        description: "神圣之眼：伤害并减速5x5范围内的敌人\n[专属宝石]：主宰之盾",
        icon: spr_divine_holy_gem_icon,
        slot: "secondary_weapon",
        max_level: 15,
        atk: [150, 200, 250, 300, 350, 400, 450, 500, 550, 600, 650, 700, 750, 800, 850, 1000],
        ice_timer: [180, 180, 180, 210, 210, 210, 240, 240, 240, 270, 270, 270, 300, 300, 300, 360],
        obj: obj_divine_holy_gem,
        allowed_weapons: ["master_shield"]
    });
}
