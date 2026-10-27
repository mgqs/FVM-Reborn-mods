/// 转职系统相关的道具注册（2026-10-25）
/// 目前只有「威望」——转职凭证的货币。这里只做「注册 + 进背包道具页」，
/// 掉落（魔塔/抽卡）与消费（商店买凭证）后续阶段再接。
/// 位置 pos_x/pos_y 见 material_init 的占用表：(0,4)(1,4) 已占 → 2026-10-25 用户定为**第六行第一个** = (0,5)
function mod_material_init()
{
    // 防御：material_init 还没跑（正常不会）就直接跳过，别让 ds_map 未创建崩掉
    if (!variable_global_exists("material_pool")) return;

    if (!ds_map_exists(global.material_pool, "prestige")) {
        register_material("prestige", {
            name: "威望",
            description: "威望：转职凭证专用货币\n在魔塔（蛋糕塔）关卡获取",
            icon: 0,
            pos_x: 0,
            pos_y: 5
        });
    }
}

/// @func tower_prestige_reward(level_id, is_first)
/// @desc 这一关通关该给多少**基础**威望（未乘难度倍率）；0 = 不是魔塔关 / 没配
///       数据源就是 maps_init 里塔关的 rewards：[{prestige,kind:"first"},{prestige,kind:"repeat"}]
///       ⚠️ 数值全部来自用户 2026-10-27 的「魔塔价格奖励建议表.xlsx」，改数只改 maps_init
function tower_prestige_reward(_level_id, _is_first){
    if (!variable_global_exists("maps_map")) return 0;
    if (!ds_map_exists(global.maps_map, "tower_cake")) return 0;
    var _ls = global.maps_map[? "tower_cake"].levels_data;
    for (var _i = 0; _i < array_length(_ls); _i++){
        if (_ls[_i].id != _level_id) continue;
        var _rs = _ls[_i].rewards;
        var _k  = _is_first ? 0 : 1;                 // 0 = 首通 / 1 = 次通
        if (array_length(_rs) <= _k) return 0;
        if (!variable_struct_exists(_rs[_k], "prestige")) return 0;
        return _rs[_k].prestige;
    }
    return 0;
}
