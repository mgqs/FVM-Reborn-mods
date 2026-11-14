/// 水火之间（跨服章节）BOSS
/// 行为代码照抄本体同名 BOSS（obj_iron_man_mouse），技能参数按需求调整（见对象内注释）。
/// 注意：BOSS 的生成口是 obj_battle/Step_2 读取 global.enemy_map 的 `_obj`，
/// 所以必须 register_enemy；register_boss 只负责血条的图标与名字。
function shuihuo_boss_init()
{
    register_enemy("kf_sh_iron_man", {
        name: "变异钢铁侠",
        _obj: obj_kf_sh_iron_man,
        hp: 90000,
        shield: 0,
        description: "变异钢铁侠：跨服·水火之间BOSS。技能1：摧毁2列。技能2：激光升级为十字范围摧毁。技能3：从第一个技能起就可能发射导弹，每次4枚。",
        speed: 0.3, atk: 10, cycle: 36, range: 90,
        ash_proof: true,
        spr: spr_kf_sh_iron_man_idle,
        feature: "land",
    });
    register_boss("kf_sh_iron_man", {
        name: "变异钢铁侠",
        hp: 90000,
        icon: spr_iron_man_mouse_icon,
    });
}
