function build_shield_grid()
{
    global.shield_grid = array_create(global.grid_cols);
    
    for (var c = 0; c < global.grid_cols; c++)
        global.shield_grid[c] = array_create(global.grid_rows, 0);
}

function rebuild_shield_grid()
{
    for (var c = 0; c < global.grid_cols; c++)
    {
        for (var r = 0; r < global.grid_rows; r++)
            global.shield_grid[c][r] = 0;
    }
}

function apply_shield_buff(arg0)
{
    var cells = arg0.buff_cells;
    
    for (var i = 0; i < array_length(cells); i++)
    {
        var c = cells[i][0];
        var r = cells[i][1];
        var v = cells[i][2];
        global.shield_grid[c][r] = v;
    }
}

function add_shield_area(arg0, arg1, arg2, arg3)
{
    for (var dx = -2; dx <= 2; dx++)
    {
        for (var dy = -2; dy <= 2; dy++)
        {
            var c = arg1 + dx;
            var r = arg2 + dy;
            
            if (c >= 0 && c < global.grid_cols && r >= 0 && r < global.grid_rows)
            {
                var dist = max(abs(dx), abs(dy));
                var v;
                
                if (dist <= 1)
                    v = arg3;
                else
                    v = arg3 * 0.5;
                
                array_push(arg0, [c, r, v]);
            }
        }
    }
}
