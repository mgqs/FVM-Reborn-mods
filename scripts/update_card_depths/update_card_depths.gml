/// @function update_plant_depths(col, row)
/// @description 更新指定网格中所有植物的深度偏移
/// @param {real} col 网格列
/// @param {real} row 网格行
function update_card_depths(col, row) {
    var plant_list = ds_grid_get(global.grid_plants, col, row);
    
    for (var i = 0; i < ds_list_size(plant_list); i++) {
        var plant = ds_list_find_value(plant_list, i);
        plant.depth_offset = i * 5; // 每层植物偏移5像素
    }
}