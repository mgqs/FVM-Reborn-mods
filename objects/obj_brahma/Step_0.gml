if (global.is_paused)
    exit;

event_inherited();

if (!copied && !is_derivative && image_index >= 14)
{
    copied = true;
    var _blacklist = ["brahma", "magic_chicken", "ice_cream"];
    var _copy_count = 2;
    
    if (shape == 2)
        _copy_count = 3;
    else if (shape == 3)
        _copy_count = 5;
    
    var _valid_target = target_card != "" && array_get_index(_blacklist, target_card) == -1;
    var card_save_data = false;
    
    if (_valid_target)
        card_save_data = get_card_info_simple(target_card);
    
    if (card_save_data != false)
    {
        var card_slot_data = deck_get_card_data(target_card, card_save_data.shape);
        var _copy_obj = ds_map_find_value(card_slot_data, "obj");
        var _copy_plant_type = ds_map_find_value(card_slot_data, "plant_type");
        var _copy_feature_type = ds_map_find_value(card_slot_data, "feature_type");
        var _copy_target_card = ds_map_find_value(card_slot_data, "target_card");
        var target_cells = [];
        var found_count = 0;
        var prev_replace = global.replace_placement;
        global.replace_placement = false;
        var max_dist = max(global.grid_cols, global.grid_rows);
        
        for (var d = 1; d <= max_dist; d++)
        {
            var candidates = [];
            var dr = -d;
            
            while (dr <= d)
            {
                var dc_abs = d - abs(dr);
                
                if (dc_abs == 0)
                {
                    var col = grid_col;
                    var row = grid_row + dr;
                    
                    if (row >= 0 && row < global.grid_rows)
                    {
                        if (!(row == grid_row && col == grid_col))
                        {
                            var priority = (col == grid_col) ? 0 : ((row == grid_row) ? 1 : 2);
                            array_push(candidates, 
                            {
                                col: col,
                                row: row,
                                priority: priority
                            });
                        }
                    }
                }
                else
                {
                    for (var s = -1; s <= 1; s += 2)
                    {
                        var col = grid_col + (s * dc_abs);
                        var row = grid_row + dr;
                        
                        if (row >= 0 && row < global.grid_rows && col >= 0 && col < global.grid_cols)
                        {
                            if (!(row == grid_row && col == grid_col))
                            {
                                var priority = (col == grid_col) ? 0 : ((row == grid_row) ? 1 : 2);
                                array_push(candidates, 
                                {
                                    col: col,
                                    row: row,
                                    priority: priority
                                });
                            }
                        }
                    }
                }
                
                dr++;
            }
            
            array_sort(candidates, function(arg0, arg1)
            {
                if (arg0.priority != arg1.priority)
                    return arg0.priority - arg1.priority;
                
                if (arg0.row != arg1.row)
                    return arg0.row - arg1.row;
                
                return arg0.col - arg1.col;
            });
            
            for (var i = 0; i < array_length(candidates); i++)
            {
                var cand = candidates[i];
                var xx = x + ((cand.col - grid_col) * global.grid_cell_size_x);
                var yy = y + ((cand.row - grid_row) * global.grid_cell_size_y);
                
                if (can_place_at_position(xx, yy, _copy_plant_type, _copy_feature_type, _copy_target_card))
                {
                    target_cells[found_count] = [cand.col, cand.row];
                    found_count++;
                    
                    if (found_count >= _copy_count)
                        break;
                }
            }
            
            if (found_count >= _copy_count)
                break;
        }
        
        for (var i = 0; i < found_count; i++)
        {
            var cell = target_cells[i];
            var col = cell[0];
            var row = cell[1];
            var inst_x = x + ((col - grid_col) * global.grid_cell_size_x);
            var inst_y = y + ((row - grid_row) * global.grid_cell_size_y);
            var new_card = instance_create_depth_define(inst_x, inst_y, 0, _copy_obj);
            card_created(new_card, col, row);
        }
        
        global.replace_placement = prev_replace;
    }
}

if (shape >= 1 && !exploded && image_index >= 22)
{
    exploded = true;
    audio_play_sound(snd_coke_bomb_explode, 0, false);
    event_user(1);
}

if (image_index >= idle_anim)
    instance_destroy();
