/// @function deck_get_card_data(card_id, shape)
/// @desc 根据ID和形态获取卡牌数据
function deck_get_card_data(card_id, shape) {
    // 首先找到卡牌
    for(var i = 0; i < ds_list_size(global.player_deck); i += 2) {
        if (global.player_deck[| i] == card_id) {
            var card_data = global.player_deck[| i+1];
            var shapes_list = card_data[? "shapes"];
            
            // 在形态列表中查找指定形态
            for(var j = 0; j < ds_list_size(shapes_list); j++) {
                var shape_data = shapes_list[| j];
                if (shape_data[? "shape"] == shape) {
                    return shape_data;
                }
            }
            
            // 如果未找到指定形态，返回第一个形态作为默认
            if (ds_list_size(shapes_list) > 0) {
                return shapes_list[| 0];
            }
            
            return noone;
        }
    }
    return noone;
}