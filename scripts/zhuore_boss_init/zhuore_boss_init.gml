/// 灼热地域（跨服章节）BOSS：变异僵尸 BOSS
/// 行为、动画分段完全沿用本体同名 BOSS（对象代码照抄），技能参数按需求调整。
/// 注意：BOSS 的生成口是 obj_battle/Step_2 读取 global.enemy_map 的 `_obj`，
/// 所以必须 register_enemy；register_boss 只负责血条的图标与名字。
function zhuore_boss_init()
{
    register_enemy("kf_zrb_mary", {
        name: "变异玛丽",
        _obj: obj_kf_zrb_mary,
        hp: 30000,
        shield: 0,
        description: "变异玛丽：跨服·灼热地域BOSS。技能1：在后排同时摧毁2行、每行4格卡片。技能2：回旋镖。技能3：催眠10秒。",
        speed: 0.3, atk: 10, cycle: 36, range: 90,
        ash_proof: true,
        spr: spr_kf_zrb_mary,
        feature: "land",
    });
    register_boss("kf_zrb_mary", {
        name: "变异玛丽",
        hp: 30000,
        icon: spr_blonde_mary_icon,
    });

    register_enemy("kf_zrb_shi", {
        name: "变异屎者",
        _obj: obj_kf_zrb_shi,
        hp: 30000,
        shield: 0,
        description: "变异屎者：跨服·灼热地域BOSS。技能1：一次召唤10只幽灵。技能2：投掷权杖（权杖血量1万）。技能3：每次吞噬8格美食。技能4：便便爆炸范围3*3。",
        speed: 0.3, atk: 10, cycle: 36, range: 90,
        ash_proof: true,
        spr: spr_kf_zrb_shi,
        feature: "land",
    });
    register_boss("kf_zrb_shi", {
        name: "变异屎者",
        hp: 30000,
        icon: spr_hells_messenger_icon,
    });

    register_enemy("kf_zrb_jack", {
        name: "变异杰克",
        _obj: obj_kf_zrb_jack,
        hp: 60000,
        shield: 0,
        description: "变异杰克：跨服·灼热地域BOSS。技能1：锤击范围3*3。技能2：滚石速度更快、血量更高。技能3：陨石每次随机砸10格。技能4：一次召唤6只火老鼠。",
        speed: 0.3, atk: 10, cycle: 36, range: 90,
        ash_proof: true,
        spr: spr_kf_zrb_jack,
        feature: "land",
    });
    register_boss("kf_zrb_jack", {
        name: "变异杰克",
        hp: 60000,
        icon: spr_irritable_jack_icon,
    });

    register_enemy("kf_zrb_vajra", {
        name: "变异金刚",
        _obj: obj_kf_zrb_vajra,
        hp: 80000,
        shield: 0,
        description: "变异金刚：跨服·灼热地域BOSS。技能1：踩踏后留下3*3冰冻区，5秒内补种进去的卡片会被冻住。技能2：一次发射10坨岩浆。技能3：电刺防爆，出现4秒后放电。技能4：分裂为变异皮特与变异朱莉。",
        speed: 0.3, atk: 10, cycle: 36, range: 90,
        ash_proof: true,
        spr: spr_kf_zrb_vajra,
        feature: "land",
    });
    register_boss("kf_zrb_vajra", {
        name: "变异金刚",
        hp: 80000,
        icon: spr_hot_vajra_icon,
    });

    register_enemy("kf_zrb_cap", {
        name: "变异美队",
        _obj: obj_kf_zrb_cap,
        hp: 90000,
        shield: 0,
        description: "变异美队：跨服·灼热地域BOSS。技能1：飞盾回旋。技能2：肘击摧毁2*2卡片。技能3：敬礼彩虹铺满整列，彩虹变为变异特种鼠，同时第9列整列掉落空中航母。",
        speed: 0.3, atk: 10, cycle: 36, range: 90,
        ash_proof: true,
        spr: spr_kf_zrb_cap,
        feature: "land",
    });
    register_boss("kf_zrb_cap", {
        name: "变异美队",
        hp: 90000,
        icon: spr_captain_america_mouse_icon,
    });
}
