function gods_goods_registry_init()
{
    global.gods_goods_map = ds_map_create();
}

function register_gods_goods(arg0, arg1)
{
    ds_map_set(global.gods_goods_map, arg0, arg1);
}

/// @function fusion_recipe0_frame(card_id)
/// @desc 本体食谱在 spr_fusion_recipe0 里的帧号。顺序与融合页 obj_craft_bg 的 fusion_demo 一致：
///       大炮 / 海星 / 鱿鱼 / 栗子 / 煮蛋 / 火盆 / 三线 / 双菇 / 咖啡杯
function fusion_recipe0_frame(card_id)
{
    var _order = ["ronghedapao", "ronghehaixing", "youyu_god", "lizi_god", "ronghedan_god",
                  "ronghehuopen", "ronghesanxian", "rongheshuanggu", "ronghekafei"];
    var _i = array_get_index(_order, card_id);
    return (_i == -1) ? 0 : _i;
}
