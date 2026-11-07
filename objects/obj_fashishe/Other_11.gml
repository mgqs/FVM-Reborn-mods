// obj_fashishe 用户事件1：开一轮（每轮 fashishe_per_row 发，由 Step 一发一发延迟出膛）
//   二转三行：每发三行同时各出一颗。
var _rows = [grid_row];
if (shape >= 2)
{
    _rows = [];
    if (grid_row > 0)                    array_push(_rows, grid_row - 1);
    array_push(_rows, grid_row);
    if (grid_row < global.grid_rows - 1) array_push(_rows, grid_row + 1);
}

fashishe_burst_rows  = _rows;
fashishe_burst_left  = fashishe_per_row;
fashishe_burst_timer = 0;
