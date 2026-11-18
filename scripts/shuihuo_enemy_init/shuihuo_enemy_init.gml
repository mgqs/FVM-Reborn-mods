/// 水火之间（跨服章节）小怪：僵尸鼠
/// 行为代码照抄本体同名鼠（obj_rowboat_mouse / obj_dragon_boat_mouse / obj_flagship_mouse / obj_kof_submarine_mouse / obj_submarine_mouse / obj_assault_mouse / obj_ninja_mouse / obj_minion_mouse / obj_snail_mouse），只改精灵、hp、move_speed、防爆。
/// 数值口径：speed = 表格速度 × 0.03；两段速度（前进 / 后退）写在对象 Step 的 move_speed 赋值里。
function shuihuo_enemy_init()
{
    // 划艇僵尸鼠：碾压碰到的卡片
    register_enemy("kf_sh_rowboat", {
        name: "划艇僵尸鼠",
        _obj: obj_kf_sh_rowboat,
        hp: 2400,
        shield: 0,
        description: "划艇僵尸鼠：跨服·水火之间小怪，快进慢退，碾压碰到的卡片",
        speed: 0.45,
        atk: 2000,
        cycle: 1,
        range: 120,
        ash_proof: true,
        spr: spr_kf_sh_rowboat,
        feature: "water",
    });

    // 龙舟僵尸鼠：碾压碰到的卡片
    register_enemy("kf_sh_dragon_boat", {
        name: "龙舟僵尸鼠",
        _obj: obj_kf_sh_dragon_boat,
        hp: 5400,
        shield: 0,
        description: "龙舟僵尸鼠：跨服·水火之间小怪，快进慢退，碾压碰到的卡片",
        speed: 0.6,
        atk: 2000,
        cycle: 1,
        range: 120,
        ash_proof: true,
        spr: spr_kf_sh_dragon_boat,
        feature: "water",
    });

    // 旗舰僵尸鼠：碾压碰到的卡片
    register_enemy("kf_sh_flagship", {
        name: "旗舰僵尸鼠",
        _obj: obj_kf_sh_flagship,
        hp: 18000,
        shield: 0,
        description: "旗舰僵尸鼠：跨服·水火之间小怪，快进慢退，碾压碰到的卡片",
        speed: 0.6,
        atk: 2000,
        cycle: 1,
        range: 120,
        ash_proof: true,
        spr: spr_kf_sh_flagship,
        feature: "water",
    });

    // 拳皇潜艇僵尸鼠：装甲完整且不攻击时潜水
    register_enemy("kf_sh_kof_submarine", {
        name: "拳皇潜艇僵尸鼠",
        _obj: obj_kf_sh_kof_submarine,
        hp: 22500,
        shield: 0,
        description: "拳皇潜艇僵尸鼠：跨服·水火之间小怪，装甲完整且不攻击时潜水",
        speed: 0.6,
        atk: 20,
        cycle: 36,
        range: 120,
        ash_proof: true,
        spr: spr_kf_sh_kof_submarine_land,
        feature: "water",
    });

    // 打击潜艇僵尸鼠：入水出水时潜行突进
    register_enemy("kf_sh_submarine", {
        name: "打击潜艇僵尸鼠",
        _obj: obj_kf_sh_submarine,
        hp: 4500,
        shield: 0,
        description: "打击潜艇僵尸鼠：跨服·水火之间小怪，水陆两栖，入水出水时潜行突进",
        speed: 0.6,
        atk: 20,
        cycle: 36,
        range: 120,
        ash_proof: true,
        spr: spr_kf_sh_submarine,
        feature: "water",
    });

    // 突袭僵尸鼠：头盔打掉后暴怒加速
    register_enemy("kf_sh_assault", {
        name: "突袭僵尸鼠",
        _obj: obj_kf_sh_assault,
        hp: 720,
        shield: 0,
        description: "突袭僵尸鼠：跨服·水火之间小怪，从水里突然出现，头盔打掉后暴怒加速",
        speed: 0.36,
        atk: 10,
        cycle: 36,
        range: 90,
        ash_proof: true,
        spr: spr_kf_sh_assault,
        feature: "water",
    });

    // 忍者首领僵尸鼠：冲撞卡片并不断召唤僵尸小喽啰
    register_enemy("kf_sh_ninja", {
        name: "忍者首领僵尸鼠",
        _obj: obj_kf_sh_ninja,
        hp: 860,
        shield: 0,
        description: "忍者首领僵尸鼠：跨服·水火之间小怪，冲撞卡片并不断召唤僵尸小喽啰",
        speed: 0.257,
        atk: 10,
        cycle: 36,
        range: 90,
        ash_proof: true,
        spr: spr_kf_sh_ninja,
        feature: "land",
    });

    // 僵尸小喽啰鼠：由忍者首领僵尸鼠召唤
    register_enemy("kf_sh_minion", {
        name: "僵尸小喽啰鼠",
        _obj: obj_kf_sh_minion,
        hp: 100,
        shield: 0,
        description: "僵尸小喽啰鼠：跨服·水火之间小怪，由忍者首领僵尸鼠召唤",
        speed: 0.257,
        atk: 10,
        cycle: 36,
        range: 90,
        ash_proof: false,
        spr: spr_kf_sh_minion,
        feature: "land",
    });

    // 蜗牛僵尸鼠：碾压卡片并留下润滑黏液
    register_enemy("kf_sh_snail", {
        name: "蜗牛僵尸鼠",
        _obj: obj_kf_sh_snail,
        hp: 5400,
        shield: 0,
        description: "蜗牛僵尸鼠：跨服·水火之间小怪，碾压卡片并留下润滑黏液",
        speed: 0.3,
        atk: 2000,
        cycle: 1,
        range: 90,
        ash_proof: true,
        spr: spr_kf_sh_snail,
        feature: "land",
    });
}
