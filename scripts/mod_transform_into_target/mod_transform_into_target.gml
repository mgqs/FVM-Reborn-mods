function find_valid_position(arg0, arg1, arg2)
{
    var offsets = [[0, 0], [0, -1], [0, 1], [1, 0], [-1, 0], [-1, -1], [-1, 1], [1, -1], [1, 1]];
    var is_replace_mode = false;
    
    if (global.replace_placement)
    {
        global.replace_placement = false;
        is_replace_mode = true;
    }
    
    for (var i = 0; i < array_length(offsets); i++)
    {
        var c = arg0 + offsets[i][0];
        var r = arg1 + offsets[i][1];
        var world = get_world_position_from_grid(c, r);
        
        if (can_place_at_position(world.x, world.y, ds_map_find_value(arg2, "plant_type"), ds_map_find_value(arg2, "feature_type"), ds_map_find_value(arg2, "target_card")))
        {
            if (is_replace_mode)
                global.replace_placement = true;
            
            return 
            {
                col: c,
                row: r
            };
        }
    }
    
    if (is_replace_mode)
        global.replace_placement = true;
    
    return undefined;
}

function transform_into_target()
{
    if (target_card_id == "")
    {
        instance_destroy();
        exit;
    }
    
    var _x = x;
    var _y = y;
    var _row = grid_row;
    var _col = grid_col;
    var card_data = deck_get_card_data(target_card_id, target_shape);
    var obj_type = ds_map_find_value(card_data, "obj");
    var pos = find_valid_position(_col, _row, card_data);
    
    if (is_undefined(pos))
    {
        instance_destroy();
        exit;
    }
    
    var world = get_world_position_from_grid(pos.col, pos.row);
    var new_plant = instance_create_depth(world.x, world.y, 0, obj_type);
    new_plant.card_id = target_card_id;
    new_plant.card_shape = target_shape;
    new_plant.transform_recorded = true;
    card_created(new_plant, pos.col, pos.row);
    new_plant.depth = calculate_plant_depth(pos.col, pos.row, new_plant.plant_type);
}
