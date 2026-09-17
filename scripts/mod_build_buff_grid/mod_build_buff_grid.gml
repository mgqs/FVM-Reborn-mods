function build_buff_grid()
{
    global.buff_grid = ds_map_create();
    var types = ["tracker", "thrower", "sprayer"];
    
    for (var t = 0; t < array_length(types); t++)
    {
        var type = types[t];
        var grid = array_create(global.grid_cols);
        
        for (var c = 0; c < global.grid_cols; c++)
            grid[c] = array_create(global.grid_rows, 1);
        
        ds_map_set(global.buff_grid, type, grid);
    }
}

function rebuild_buff_grid()
{
    var keys = ds_map_keys_to_array(global.buff_grid);
    
    for (var k = 0; k < array_length(keys); k++)
    {
        var type = keys[k];
        var grid = ds_map_find_value(global.buff_grid, type);
        
        for (var c = 0; c < global.grid_cols; c++)
        {
            for (var r = 0; r < global.grid_rows; r++)
                grid[c][r] = 1;
        }
    }
    
    for (var i = 0; i < ds_list_size(global.buff_sources); i++)
    {
        var inst = ds_list_find_value(global.buff_sources, i);
        
        if (!instance_exists(inst))
            continue;
        
        apply_buff(inst);
        apply_aurora(inst);
    }
}

function apply_buff(arg0)
{
    if (arg0.plant_id == "aurora" && arg0.shape >= 3)
        exit;
    
    var type = arg0.buffer_type;
    var grid = ds_map_find_value(global.buff_grid, type);
    var cells = arg0.buff_cells;
    
    for (var i = 0; i < array_length(cells); i++)
    {
        var c = cells[i][0];
        var r = cells[i][1];
        var v = cells[i][2];
        
        if (c < 0 || r < 0)
        {
            show_debug_message("INVALID GRID: " + string(arg0.id) + " col=" + string(c) + " row=" + string(r));
            exit;
        }
        
        if (c >= array_length(grid) || r >= array_length(grid[0]))
            exit;
        
        if (v > grid[c][r])
            grid[c][r] = v;
    }
}
