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
