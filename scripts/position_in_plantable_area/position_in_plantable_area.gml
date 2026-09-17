/// @function position_in_plantable_area(x, y)
/// @description 检查位置是否在可种植区域
/// @param {real} x X坐标
/// @param {real} y Y坐标
function position_in_plantable_area(x, y) {
    // 实现逻辑：检查位置是否在草地网格上且没有其他植物
    // 示例实现：
    var grid_x = floor((x - global.grid_offset_x) / global.grid_cell_size_x);
    var grid_y = floor((y - global.grid_offset_y) / global.grid_cell_size_y);
    
    if (grid_x < 0 || grid_x >= global.grid_cols || 
        grid_y < 0 || grid_y >= global.grid_rows) {
        return false;
    }
    
    // 检查是否有其他植物
    var plant_at_pos = instance_position(
        global.grid_offset_x + grid_x * global.grid_cell_size_x + global.grid_cell_size_x / 2,
        global.grid_offset_y + grid_y * global.grid_cell_size_y + global.grid_cell_size_y / 2,
        obj_small_fire
    );
    
    return plant_at_pos == noone;
}