/// @function get_grid_position_from_world(wx, wy)
/// @description 从世界坐标获取网格位置
/// @param {real} wx 世界X坐标
/// @param {real} wy 世界Y坐标
function get_grid_position_from_world(wx, wy) {
    // 转换为相对于网格的坐标
    var rel_x = wx - global.grid_offset_x;
    var rel_y = wy - global.grid_offset_y;
    
    // 计算网格索引
    var col = floor(rel_x / global.grid_cell_size_x);
    var row = floor(rel_y / global.grid_cell_size_y);
    
    // 计算网格中心位置
    var center_x = global.grid_offset_x + col * global.grid_cell_size_x + global.grid_cell_size_x / 2;
    var center_y = global.grid_offset_y + row * global.grid_cell_size_y + global.grid_cell_size_y / 2;
    
    return {
        col: col,
        row: row,
        x: center_x,
        y: center_y
    };
}

function get_world_position_from_grid(col, row) {
   
    
    // 计算网格中心位置
    var center_x = global.grid_offset_x + col * global.grid_cell_size_x + global.grid_cell_size_x / 2;
    var center_y = global.grid_offset_y + row * global.grid_cell_size_y + global.grid_cell_size_y / 2;
    
    return {
        col: col,
        row: row,
        x: center_x,
        y: center_y
    };
}