var level_offset = mod_clotho_get_random_level(shape);
var col_offset = (shape >= 2) ? 2 : 1;
var row_offset = 1;

if (shape == 2)
    row_offset = 2;
else if (shape == 3)
    row_offset = 3;

var max_level_offset = 2;

with (obj_card_parent)
{
    var dx = abs(grid_col - other.grid_col);
    var dy = abs(grid_row - other.grid_row);
    
    if (plant_id != "clotho" && plant_id != "player" && dx <= col_offset && dy <= row_offset)
    {
        var new_level = clamp(current_level + level_offset, 0, 16 + max_level_offset);
        
        if (new_level >= 17 && array_contains(other.gold_cards, plant_id))
        {
            current_level = new_level;
            var upgrade_data = get_plant_data_with_skill(plant_id, shape, current_level, skill);
            
            if (upgrade_data != undefined)
            {
                hp = ds_map_find_value(upgrade_data, "hp");
                max_hp = hp;
                cost = ds_map_find_value(upgrade_data, "cost");
                atk = ds_map_find_value(upgrade_data, "atk");
                base_atk = atk;
                range = ds_map_find_value(upgrade_data, "range");
                cooldown = ds_map_find_value(upgrade_data, "cooldown");
                cycle = ds_map_find_value(upgrade_data, "cycle");
                
                if (ds_map_exists(upgrade_data, "flame_produce"))
                    flame_produce = ds_map_find_value(upgrade_data, "flame_produce");
                
                if (ds_map_exists(upgrade_data, "first_produce_delay"))
                    first_produce_delay = ds_map_find_value(upgrade_data, "first_produce_delay");
                
                if (instance_exists(banding_star_obj))
                    banding_star_obj.sprite_index = (new_level == 18) ? spr_star_18 : spr_star_17;
            }
        }
        else
        {
            current_level = min(new_level, 16);
            var upgrade_data = get_plant_data_with_skill(plant_id, shape, current_level, skill);
            
            if (upgrade_data != undefined)
            {
                hp = ds_map_find_value(upgrade_data, "hp");
                max_hp = hp;
                cost = ds_map_find_value(upgrade_data, "cost");
                atk = ds_map_find_value(upgrade_data, "atk");
                base_atk = atk;
                range = ds_map_find_value(upgrade_data, "range");
                cooldown = ds_map_find_value(upgrade_data, "cooldown");
                cycle = ds_map_find_value(upgrade_data, "cycle");
                
                if (ds_map_exists(upgrade_data, "flame_produce"))
                    flame_produce = ds_map_find_value(upgrade_data, "flame_produce");
                
                if (ds_map_exists(upgrade_data, "first_produce_delay"))
                    first_produce_delay = ds_map_find_value(upgrade_data, "first_produce_delay");
                
                if (instance_exists(banding_star_obj))
                {
                    if (current_level < 4)
                    {
                        instance_destroy(banding_star_obj);
                    }
                    else
                    {
                        var star_spr = -1;
                        
                        switch (current_level)
                        {
                            case 4:
                                star_spr = spr_star_4;
                                break;
                            
                            case 5:
                                star_spr = spr_star_5;
                                break;
                            
                            case 6:
                                star_spr = spr_star_6;
                                break;
                            
                            case 7:
                                star_spr = spr_star_7;
                                break;
                            
                            case 8:
                                star_spr = spr_star_8;
                                break;
                            
                            case 9:
                                star_spr = spr_star_9;
                                break;
                            
                            case 10:
                                star_spr = spr_star_10;
                                break;
                            
                            case 11:
                                star_spr = spr_star_11;
                                break;
                            
                            case 12:
                                star_spr = spr_star_12;
                                break;
                            
                            case 13:
                                star_spr = spr_star_13;
                                break;
                            
                            case 14:
                                star_spr = spr_star_14;
                                break;
                            
                            case 15:
                                star_spr = spr_star_15;
                                break;
                            
                            case 16:
                                star_spr = spr_star_16;
                                break;
                        }
                        
                        banding_star_obj.sprite_index = star_spr;
                    }
                }
                else if (current_level >= 4)
                {
                    var inst = instance_create_depth(x, y - 5, depth, obj_stars);
                    var star_spr = -1;
                    
                    switch (current_level)
                    {
                        case 4:
                            star_spr = spr_star_4;
                            break;
                        
                        case 5:
                            star_spr = spr_star_5;
                            break;
                        
                        case 6:
                            star_spr = spr_star_6;
                            break;
                        
                        case 7:
                            star_spr = spr_star_7;
                            break;
                        
                        case 8:
                            star_spr = spr_star_8;
                            break;
                        
                        case 9:
                            star_spr = spr_star_9;
                            break;
                        
                        case 10:
                            star_spr = spr_star_10;
                            break;
                        
                        case 11:
                            star_spr = spr_star_11;
                            break;
                        
                        case 12:
                            star_spr = spr_star_12;
                            break;
                        
                        case 13:
                            star_spr = spr_star_13;
                            break;
                        
                        case 14:
                            star_spr = spr_star_14;
                            break;
                        
                        case 15:
                            star_spr = spr_star_15;
                            break;
                        
                        case 16:
                            star_spr = spr_star_16;
                            break;
                    }
                    
                    inst.sprite_index = star_spr;
                    inst.parent_card = id;
                    banding_star_obj = inst.id;
                }
            }
        }
        
        var effect = instance_create_depth(x, y, depth - 1, obj_clotho_star_effect);
        
        if (level_offset < 0)
            effect.sprite_index = spr_clotho_star_drop;
        else if (other.shape == 3)
            effect.sprite_index = spr_clotho_star_up_1;
        else
            effect.sprite_index = spr_clotho_star_up;
        
        switch (abs(level_offset))
        {
            case 1:
                effect.state = 0;
                break;
            
            case 2:
                effect.state = 1;
                break;
            
            case 3:
                effect.state = 2;
                break;
            
            case 4:
                effect.state = 3;
                break;
            
            case 5:
                effect.state = 4;
                break;
        }
        
        self.shield_buffed = false;
        
        if (variable_instance_exists(self.id, "buff_cells_refreshed"))
            self.buff_cells_refreshed = false;
    }
}