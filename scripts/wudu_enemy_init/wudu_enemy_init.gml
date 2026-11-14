/// 巫毒研究所（跨服章节）小怪：僵尸鼠
/// 行为代码照抄本体同名鼠（obj_garbage_track_mouse），只改精灵、hp、move_speed、防爆。
/// 数值口径：speed = 表格速度 × 0.03；两段速度（前进 / 后退）写在对象 Step 的 move_speed 赋值里。
function wudu_enemy_init()
{
    // 垃圾车僵尸鼠：碾压卡片并留下垃圾
    register_enemy("kf_wd_garbage", {
        name: "垃圾车僵尸鼠",
        _obj: obj_kf_wd_garbage,
        hp: 2500,
        shield: 0,
        description: "垃圾车僵尸鼠：跨服·巫毒研究所小怪，碾压卡片并留下垃圾",
        speed: 0.6,
        atk: 2000,
        cycle: 1,
        range: 90,
        ash_proof: true,
        spr: spr_kf_wd_garbage,
        feature: "land",
    });
}
