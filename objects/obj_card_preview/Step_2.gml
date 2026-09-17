// 用 Step_0 算好的逻辑位置检测能否放置，和放置逻辑一致
var card_shape = get_card_info_simple(card_id).shape
var card_data = deck_get_card_data(card_id,card_shape)
if card_id == "magic_chicken"{
    if global.prev_place_id != ""{
        card_shape = get_card_info_simple(global.prev_place_id).shape
        card_data = deck_get_card_data(global.prev_place_id,card_shape)
    }
}
is_valid = (can_place_at_position(logical_base_x, logical_base_y, card_data[? "plant_type"],card_data[? "feature_type"],card_data[? "target_card"]));
