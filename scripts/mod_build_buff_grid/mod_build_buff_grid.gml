/// DS handles outlive their instance unless explicitly destroyed. Reset each
/// handle immediately so a repeated cleanup cannot destroy a recycled ID.
function mod_battle_buff_grid_clear()
{
    static names = ["buff_grid", "buff_stack_grid", "buff_stack_count"];
    for (var i = 0; i < array_length(names); i++)
    {
        var key = names[i];
        if (!variable_global_exists(key)) continue;
        var handle = variable_global_get(key);
        if (ds_exists(handle, ds_type_map)) ds_map_destroy(handle);
        variable_global_set(key, -1);
    }
}

function mod_battle_resources_clear()
{
    mod_battle_buff_grid_clear();
    if (variable_global_exists("buff_sources"))
    {
        if (ds_exists(global.buff_sources, ds_type_list)) ds_list_destroy(global.buff_sources);
        global.buff_sources = -1;
    }
}

/// Room cleanup may dispose of the manager before a source's Destroy callback.
function mod_buff_source_remove(source)
{
    if (!variable_global_exists("buff_sources") || !ds_exists(global.buff_sources, ds_type_list)) return;
    var index = ds_list_find_index(global.buff_sources, source);
    if (index != -1) ds_list_delete(global.buff_sources, index);
}

function build_buff_grid()
{
    mod_battle_buff_grid_clear();
    global.buff_grid = ds_map_create();
    // 增幅通道（与 scripts/buff_target 的 buff_channel_order 一致）
    //   喷壶三档：sprayer 旋喷 / sprayer_coffee 咖啡（本行） / sprayer_attach 附加（汽水）
    var types = ["thrower", "sprayer", "sprayer_coffee", "sprayer_attach",
                 "five_dir", "multi_dir",
                 "track_berry", "track_spice", "track_feast", "track_feast4",
                 "fixed_track", "production"];
    
    for (var t = 0; t < array_length(types); t++)
    {
        var type = types[t];
        var grid = array_create(global.grid_cols);
        
        for (var c = 0; c < global.grid_cols; c++)
            grid[c] = array_create(global.grid_rows, 1);
        
        ds_map_set(global.buff_grid, type, grid);
    }
    
    global.buff_stack_grid = ds_map_create();
    global.buff_stack_count = ds_map_create();
    
    for (var t = 0; t < array_length(types); t++)
    {
        var type = types[t];
        var stack_grid = array_create(global.grid_cols);
        var stack_count = array_create(global.grid_cols);
        
        for (var c = 0; c < global.grid_cols; c++)
        {
            stack_grid[c] = array_create(global.grid_rows, 0);
            stack_count[c] = array_create(global.grid_rows, 0);
        }
        
        ds_map_set(global.buff_stack_grid, type, stack_grid);
        ds_map_set(global.buff_stack_count, type, stack_count);
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
        
        var stack_grid = ds_map_find_value(global.buff_stack_grid, type);
        var stack_count = ds_map_find_value(global.buff_stack_count, type);
        
        if (stack_grid != undefined && stack_count != undefined)
        {
            for (var c = 0; c < global.grid_cols; c++)
            {
                for (var r = 0; r < global.grid_rows; r++)
                {
                    stack_grid[c][r] = 0;
                    stack_count[c][r] = 0;
                }
            }
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

    // ── 多通道输出（2026-11-14）──────────────────────────────────────────
    //   源卡自带 buff_outputs（[{type, cells}, …]）就只为这些通道铺格子，然后收工；
    //   没带的卡继续走下面的单通道老逻辑，行为不变。
    //   例：魔杖蛇 = sprayer 5×5 + sprayer_attach 5×5 + sprayer_coffee 本行
    if (variable_instance_exists(arg0, "buff_outputs") && !is_undefined(arg0.buff_outputs))
    {
        var _outs = arg0.buff_outputs;
        for (var _o = 0; _o < array_length(_outs); _o++)
        {
            var _og = ds_map_find_value(global.buff_grid, _outs[_o].type);
            if (_og == undefined) continue;

            var _oc = _outs[_o].cells;
            for (var _n = 0; _n < array_length(_oc); _n++)
            {
                var _nc = _oc[_n][0];
                var _nr = _oc[_n][1];
                var _nv = _oc[_n][2];
                if (_nc < 0 || _nr < 0) continue;
                if (_nc >= array_length(_og) || _nr >= array_length(_og[0])) continue;
                if (_nv > _og[_nc][_nr]) _og[_nc][_nr] = _nv;
            }
        }
        exit;
    }

    var type = arg0.buffer_type;
    var grid = ds_map_find_value(global.buff_grid, type);
    var cells = arg0.buff_cells;
    
    var stacking = variable_instance_exists(arg0, "buff_stacking") && arg0.buff_stacking;
    var max_stacks = stacking ? arg0.buff_max_stacks : 1;
    
    var stack_grid = undefined;
    var stack_count = undefined;
    
    if (stacking)
    {
        stack_grid = ds_map_find_value(global.buff_stack_grid, type);
        stack_count = ds_map_find_value(global.buff_stack_count, type);
    }
    
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

        if (stacking && stack_grid != undefined && stack_count != undefined)
        {
            if (stack_count[c][r] < max_stacks)
            {
                stack_grid[c][r] += v;
                stack_count[c][r]++;
            }
        }
        else
        {
            if (v > grid[c][r])
                grid[c][r] = v;
        }

        
        if (variable_instance_exists(arg0, "buffer_type_2") && !is_undefined(arg0.buffer_type_2))
        {
            var type2 = arg0.buffer_type_2;
            var grid2 = ds_map_find_value(global.buff_grid, type2);
            
            if (grid2 != undefined && c < array_length(grid2) && r < array_length(grid2[0]))
            {
                if (stacking)
                {
                    var stack_grid2 = ds_map_find_value(global.buff_stack_grid, type2);
                    var stack_count2 = ds_map_find_value(global.buff_stack_count, type2);
                    
                    if (stack_grid2 != undefined && stack_count2 != undefined && stack_count2[c][r] < max_stacks)
                    {
                        stack_grid2[c][r] += v;
                        stack_count2[c][r]++;
                    }
                }
                else
                {
                    if (v > grid2[c][r])
                        grid2[c][r] = v;
                }
            }
        }
    }
}
