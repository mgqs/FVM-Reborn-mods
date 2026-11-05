/// 灼热地域（跨服章节）小怪：变异僵尸鼠
/// 行为、动画分段完全沿用本体同名鼠（对象代码照抄）。
/// 数值按《灼热地狱》总表：体力 = 表格「体力」列，speed = 表格速度 × 0.03，防爆 = 表格「防爆」列。
/// 表格里「40 / 8.57」这种两段值表示两种状态（冲撞 / 行走、钻地 / 行走、持盆 / 掉盆），
/// 这里填第一段，第二段写在对象 Step 的 move_speed 赋值里（由 tools/zhuore_spec.py 的 ms_patch 保证）。
/// 精灵在 精灵/Enemy/kuafu/zhuorediyu/xiaoguai/<key>，
/// 对象在 物体/Enemy/kuafu/zhuorediyu/xiaoguai/<key>。
function zhuore_enemy_init()
{
    // 企鹅：投掷冰冻炸弹（陆地/水面两套精灵，代码按地形自动切换）
    register_enemy("kf_zr_penguin", {
        name: "企鹅僵尸鼠",
        _obj: obj_kf_zr_penguin,
        hp: 600,
        shield: 0,
        description: "企鹅僵尸鼠：跨服·灼热地域小怪，投掷冰冻炸弹",
        speed: 0.6,
        atk: 10,
        cycle: 36,
        range: 90,
        ash_proof: true,
        spr: spr_kf_zr_penguin_land,
        feature: "land",
    });

    // 鼹鼠：钻到后方冒出来
    register_enemy("kf_zr_mole", {
        name: "僵尸鼹鼠",
        _obj: obj_kf_zr_mole,
        hp: 360,
        shield: 0,
        description: "僵尸鼹鼠：跨服·灼热地域小怪，挖掘到后方发动攻击",
        speed: 0.9,
        atk: 10,
        cycle: 36,
        range: 90,
        ash_proof: true,
        spr: spr_kf_zr_mole,
        feature: "land",
    });

    // 垃圾车：碾压卡片
    register_enemy("kf_zr_garbage", {
        name: "垃圾车僵尸鼠",
        _obj: obj_kf_zr_garbage,
        hp: 2500,
        shield: 0,
        description: "垃圾车僵尸鼠：跨服·灼热地域小怪，碾压卡片并留下垃圾",
        speed: 0.5142,
        atk: 2000,
        cycle: 1,
        range: 90,
        ash_proof: true,
        spr: spr_kf_zr_garbage,
        feature: "land",
    });

    // 捧花：带花盆护盾，花盆掉了会发怒
    register_enemy("kf_zr_flower", {
        name: "捧花僵尸鼠",
        _obj: obj_kf_zr_flower,
        hp: 600,
        shield: 1000,
        description: "捧花僵尸鼠：跨服·灼热地域小怪，花盆掉落后会发怒",
        speed: 0.36,
        atk: 10,
        cycle: 36,
        range: 90,
        ash_proof: true,
        spr: spr_kf_zr_flower_shield,
        feature: "land",
    });

    // 武士：不断召唤随从
    register_enemy("kf_zr_warrior", {
        name: "武士僵尸鼠",
        _obj: obj_kf_zr_warrior,
        hp: 2100,
        shield: 0,
        description: "武士僵尸鼠：跨服·灼热地域小怪，不断召唤随从",
        speed: 1.2,
        atk: 10,
        cycle: 36,
        range: 90,
        ash_proof: true,
        spr: spr_kf_zr_warrior,
        feature: "land",
    });

    // 火影：不断召唤随从
    register_enemy("kf_zr_naruto", {
        name: "火影忍者僵尸鼠",
        _obj: obj_kf_zr_naruto,
        hp: 3600,
        shield: 0,
        description: "火影忍者僵尸鼠：跨服·灼热地域小怪，不断召唤随从",
        speed: 1.2,
        atk: 10,
        cycle: 36,
        range: 90,
        ash_proof: true,
        spr: spr_kf_zr_naruto,
        feature: "land",
    });

    // 牙医：钻到后方冒出来
    register_enemy("kf_zr_dentist", {
        name: "牙医僵尸鼠",
        _obj: obj_kf_zr_dentist,
        hp: 960,
        shield: 0,
        description: "牙医僵尸鼠：跨服·灼热地域小怪，挖掘到后方发动攻击",
        speed: 0.9,
        atk: 10,
        cycle: 36,
        range: 90,
        ash_proof: true,
        spr: spr_kf_zr_dentist,
        feature: "land",
    });

    // 幽灵：隐身穿越卡片
    register_enemy("kf_zr_ghost", {
        name: "神风幽灵鼠",
        _obj: obj_kf_zr_ghost,
        hp: 1000,
        shield: 0,
        description: "神风幽灵鼠：跨服·灼热地域小怪，隐身穿越卡片",
        speed: 0.6,
        atk: 10,
        cycle: 36,
        range: 90,
        ash_proof: true,
        spr: spr_kf_zr_ghost,
        feature: "land",
    });

    // 纵火：投掷 3*3 炸弹
    register_enemy("kf_zr_arson", {
        name: "纵火僵尸鼠",
        _obj: obj_kf_zr_arson,
        hp: 1100,
        shield: 0,
        description: "纵火僵尸鼠：跨服·灼热地域小怪，投掷3*3炸弹",
        speed: 0.6,
        atk: 10,
        cycle: 36,
        range: 90,
        ash_proof: true,
        spr: spr_kf_zr_arson_bomb,
        feature: "land",
    });

    // 罐头：借爆炸动力跳跃
    register_enemy("kf_zr_can", {
        name: "罐头僵尸鼠",
        _obj: obj_kf_zr_can,
        hp: 1800,
        shield: 0,
        description: "罐头僵尸鼠：跨服·灼热地域小怪，借助爆炸的动力跳跃",
        speed: 0.3,
        atk: 10,
        cycle: 36,
        range: 90,
        ash_proof: true,
        spr: spr_kf_zr_can_withcan,
        feature: "land",
    });

    // 锯刀狂：钻到后方冒出来
    register_enemy("kf_zr_sawblade", {
        name: "锯刀狂僵尸鼠",
        _obj: obj_kf_zr_sawblade,
        hp: 3600,
        shield: 0,
        description: "锯刀狂僵尸鼠：跨服·灼热地域小怪，挖掘到后方发动攻击",
        speed: 0.9,
        atk: 10,
        cycle: 36,
        range: 90,
        ash_proof: true,
        spr: spr_kf_zr_sawblade,
        feature: "land",
    });

    // 非主流：跳舞躲子弹
    register_enemy("kf_zr_nonmain", {
        name: "非主流僵尸鼠",
        _obj: obj_kf_zr_nonmain,
        hp: 1200,
        shield: 0,
        description: "非主流僵尸鼠：跨服·灼热地域小怪，躲避子弹",
        speed: 0.3,
        atk: 10,
        cycle: 36,
        range: 90,
        ash_proof: true,
        spr: spr_kf_zr_nonmain,
        feature: "land",
    });

    // 魔术师：不断发射小老鼠
    register_enemy("kf_zr_magician", {
        name: "魔术师僵尸鼠",
        _obj: obj_kf_zr_magician,
        hp: 1600,
        shield: 0,
        description: "魔术师僵尸鼠：跨服·灼热地域小怪，不断发射小老鼠",
        speed: 0.6,
        atk: 10,
        cycle: 300,
        range: 90,
        ash_proof: true,
        spr: spr_kf_zr_magician,
        feature: "land",
    });
}
