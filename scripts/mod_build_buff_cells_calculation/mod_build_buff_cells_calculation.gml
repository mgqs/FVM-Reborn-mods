function build_buff_cells(arg0, arg1, arg2, arg3)
{
    var cells = [];
    
    switch (arg2)
    {
        case "3x3":
            add_square(cells, arg0, arg1, 1, arg3);
            break;
        
        case "5x5":
            add_square(cells, arg0, arg1, 2, arg3);
            break;
        
        case "5x7":
            add_rect(cells, arg0, arg1, 2, 3, arg3);
            break;
        
        case "row":
            add_row(cells, arg1, arg3);
            break;
    }
    
    return cells;
}

function add_square(arg0, arg1, arg2, arg3, arg4)
{
    var dx = -arg3;
    
    while (dx <= arg3)
    {
        var dy = -arg3;
        
        while (dy <= arg3)
        {
            var c = arg1 + dx;
            var r = arg2 + dy;
            
            if (c >= 0 && c < global.grid_cols && r >= 0 && r < global.grid_rows)
                array_push(arg0, [c, r, arg4]);
            
            dy++;
        }
        
        dx++;
    }
}

function add_rect(arg0, arg1, arg2, arg3, arg4, arg5)
{
    var dx = -arg3;
    
    while (dx <= arg3)
    {
        var dy = -arg4;
        
        while (dy <= arg4)
        {
            var c = arg1 + dx;
            var r = arg2 + dy;
            
            if (c >= 0 && c < global.grid_cols && r >= 0 && r < global.grid_rows)
                array_push(arg0, [c, r, arg5]);
            
            dy++;
        }
        
        dx++;
    }
}

function add_row(arg0, arg1, arg2)
{
    for (var c = 0; c < global.grid_cols; c++)
        array_push(arg0, [c, arg1, arg2]);
}

function refresh_buff_cells()
{
    buff_cells = build_buff_cells(grid_col, grid_row, buff_shape, buff_value);
}
