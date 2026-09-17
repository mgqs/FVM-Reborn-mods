function build_buff_aurora()
{
    global.aurora_main = array_create(global.grid_cols);
    global.aurora_side = array_create(global.grid_cols);
    
    for (var c = 0; c < global.grid_cols; c++)
    {
        global.aurora_main[c] = array_create(global.grid_rows, 1);
        global.aurora_side[c] = array_create(global.grid_rows, 0);
    }
}

function reset_aurora_grid()
{
    for (var c = 0; c < global.grid_cols; c++)
    {
        for (var r = 0; r < global.grid_rows; r++)
        {
            global.aurora_main[c][r] = 1;
            global.aurora_side[c][r] = 0;
        }
    }
}

function apply_aurora(arg0)
{
    if (arg0.plant_id != "aurora")
        exit;
    
    if (arg0.shape < 3)
        exit;
    
    var row = arg0.grid_row;
    var main = arg0.buff_value;
    var side = (arg0.buff_value - 1) * 0.2;
    
    for (var c = 0; c < global.grid_cols; c++)
    {
        if (main > global.aurora_main[c][row])
            global.aurora_main[c][row] = main;
    }
    
    for (var c = 0; c < global.grid_cols; c++)
    {
        if ((row - 1) >= 0)
            global.aurora_side[c][row - 1] = min(global.aurora_side[c][row - 1] + side, side * 2);
        
        if ((row + 1) < global.grid_rows)
            global.aurora_side[c][row + 1] = min(global.aurora_side[c][row + 1] + side, side * 2);
    }
}

function get_aurora_buff(arg0, arg1)
{
    var main = global.aurora_main[arg0][arg1];
    var side = global.aurora_side[arg0][arg1];
    
    if (main > 1)
        return main + side;
    else
        return 1 + side;
}
