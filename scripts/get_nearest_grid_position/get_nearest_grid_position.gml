/// @function get_nearest_grid_position(x, y)
/// @description 获取最近的网格位置
/// @param {real} x X坐标
/// @param {real} y Y坐标
function get_nearest_grid_position(x, y) {
    //var grid_size_y = global.grid_cell_size_y;
	//var grid_size_x = global.grid_cell_size_x;
    //var grid_x = global.grid_offset_x + round((x - global.grid_offset_x) / grid_size_x) * grid_size_x;
    //var grid_y = global.grid_offset_y + round((y - global.grid_offset_y) / grid_size_y) * grid_size_y;
    //return {x: grid_x + grid_size_x / 2, y: grid_y + grid_size_y / 2};
	
    var grid_size_x = global.grid_cell_size_x;
    var grid_size_y = global.grid_cell_size_y;
    
    // 计算相对于网格区域的坐标
    var rel_x = x - global.grid_offset_x;
    var rel_y = y - global.grid_offset_y;
    
    // 计算最近的网格索引（基于中心点对齐）
    var index_x = round(rel_x / grid_size_x - 0.5);
    var index_y = round(rel_y / grid_size_y - 0.5);
    
    // 计算网格中心坐标
    var grid_x = global.grid_offset_x + (index_x + 0.5) * grid_size_x;
    var grid_y = global.grid_offset_y + (index_y + 0.5) * grid_size_y;
    
    return {x: grid_x, y: grid_y};
}
