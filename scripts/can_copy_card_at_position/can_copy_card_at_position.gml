/// @function can_copy_card_at_position(x, y, plant_type, feature_type, card_id, base_target_card)
/// @description Copy placement check that prevents a copied target card from stacking on itself.
/// @param {real} x X coordinate
/// @param {real} y Y coordinate
/// @param {string} plant_type Plant type of the card being copied
/// @param {string} feature_type Feature type of the card being copied
/// @param {string} card_id Plant ID of the card being copied (for dedup check)
/// @param {string} base_target_card Target card (base requirement) of the card being copied
function can_copy_card_at_position(_x, _y, _plant_type, _feature_type, _card_id, _base_target_card) {
    // Normalize base target: undefined 缺省值统一成 "none"（nullish 合并一步到位）
    var _actual_base = _base_target_card ?? "none";

    // 复制仙笛马时，目标格已有仙笛马则跳过。
    if (_card_id == "xiandima" && !global.replace_placement) {
        var _xiandima_grid_pos = get_grid_position_from_world(_x, _y);
        var _xiandima_plant_list = ds_grid_get(global.grid_plants, _xiandima_grid_pos.col, _xiandima_grid_pos.row);
        for (var i = 0; i < ds_list_size(_xiandima_plant_list); i++) {
            var _plant = ds_list_find_value(_xiandima_plant_list, i);
            if (instance_exists(_plant)
                && variable_instance_exists(_plant, "plant_id")
                && _plant.plant_id == "xiandima") {
                return false;
            }
        }
    }

    if (!can_place_at_position(_x, _y, _plant_type, _feature_type, _actual_base, _card_id))
        return false;

    var _grid_pos = get_grid_position_from_world(_x, _y);
    var _plant_list = ds_grid_get(global.grid_plants, _grid_pos.col, _grid_pos.row);

    for (var i = 0; i < ds_list_size(_plant_list); i++) {
        var _plant = ds_list_find_value(_plant_list, i);
        if (instance_exists(_plant)
            && variable_instance_exists(_plant, "plant_id")
            && _plant.plant_id == _card_id
            && _feature_type != "upgrade") {
            return false;
        }
    }

    return true;
}
