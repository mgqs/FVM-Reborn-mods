/// 水火之间（跨服章节）小怪：僵尸鼠
/// 行为代码照抄本体同名鼠（obj_rowboat_mouse / obj_dragon_boat_mouse / obj_flagship_mouse / obj_kof_submarine_mouse），只改精灵、hp、move_speed、防爆。
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
}
