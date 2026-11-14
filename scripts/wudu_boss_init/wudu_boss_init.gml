/// 巫毒研究所（跨服章节）BOSS
/// 行为代码照抄本体同名 BOSS（obj_hulk_mouse），技能参数按需求调整（见对象内注释）。
/// 注意：BOSS 的生成口是 obj_battle/Step_2 读取 global.enemy_map 的 `_obj`，
/// 所以必须 register_enemy；register_boss 只负责血条的图标与名字。
function wudu_boss_init()
{
    register_enemy("kf_wd_hulk", {
        name: "变异绿巨人",
        _obj: obj_kf_wd_hulk,
        hp: 120000,
        shield: 0,
        description: "变异绿巨人：跨服·巫毒研究所BOSS。技能全部无法削弱；技能前无蓄力（0秒），撤退后立即接下一技能。技能1：冲拳摧毁2*2。技能2：砸地摧毁十字5格。技能3：冲撞摧毁3格纵列。",
        speed: 0.3, atk: 10, cycle: 36, range: 90,
        ash_proof: true,
        spr: spr_kf_wd_hulk_idle,
        feature: "land",
    });
    register_boss("kf_wd_hulk", {
        name: "变异绿巨人",
        hp: 120000,
        icon: spr_hulk_mouse_icon,
    });
}
