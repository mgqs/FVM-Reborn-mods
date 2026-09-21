if (!instance_exists(obj_battle))
    instance_destroy();

if (global.buff_dirty)
{
    reset_aurora_grid();
    rebuild_buff_grid();
    global.buff_apply_id++;
    global.buff_dirty = false;
    show_debug_message("buff地图更新");
}

if (!shield_replaced)
{
    if (global.save_data.equipped_items.secondary_weapon.id == "master_shield")
    {
        if (instance_exists(obj_player_shield))
        {
            var target_item = obj_player_shield;
            var new_shield = instance_create_depth(target_item.x, target_item.y, target_item.depth, obj_master_shield);
            new_shield.parent_player = target_item.parent_player;
            new_shield.grid_row = target_item.grid_row;
            new_shield.grid_col = target_item.grid_col;
            instance_destroy(obj_player_shield);
            shield_replaced = true;
        }
    }
    else
    {
        shield_replaced = true;
    }
}

if (buff_timer > 0)
{
    buff_timer--;
}
else
{
    with (obj_card_parent)
    {
        if (self.plant_id != "player")
        {
            var just_initialized = false;
            
            if (!variable_instance_exists(self.id, "base_atk"))
            {
                var upgrade_data = get_plant_data_with_skill(self.plant_id, self.shape, self.current_level, self.skill);
                self.base_atk = (upgrade_data != undefined) ? ds_map_find_value(upgrade_data, "atk") : self.atk;
                just_initialized = true;
            }
            
            if (!variable_instance_exists(self.id, "base_cycle"))
            {
                var upgrade_data = get_plant_data_with_skill(self.plant_id, self.shape, self.current_level, self.skill);
                self.base_cycle = (upgrade_data != undefined) ? ds_map_find_value(upgrade_data, "cycle") : self.cycle;
                just_initialized = true;
            }
            
            if (!variable_instance_exists(self.id, "buff_type"))
            {
                self.buff_type = mod_get_buff_type(self.plant_id);
                just_initialized = true;
            }
            
            if (!variable_instance_exists(self.id, "buff_applied_id"))
            {
                self.buff_applied_id = -1;
                just_initialized = true;
            }
            
            if (!variable_instance_exists(self.id, "buffer_type"))
            {
                if (!variable_instance_exists(self.id, "shield_buffed"))
                {
                    var shield_buff = global.shield_grid[self.grid_col][self.grid_row] + 1;
                    self.base_atk *= shield_buff;
                    self.shield_buffed = true;
                    just_initialized = true;
                }
                else if (!self.shield_buffed)
                {
                    var shield_buff = global.shield_grid[self.grid_col][self.grid_row] + 1;
                    self.base_atk *= shield_buff;
                    self.shield_buffed = true;
                    just_initialized = true;
                }
            }
            
            if (just_initialized || self.buff_applied_id != global.buff_apply_id)
            {
                if (!is_undefined(self.buff_type))
                {
                    switch (self.buff_type)
                    {
                        case "thrower":
                            var grid_thrower = ds_map_find_value(global.buff_grid, "thrower");
                            var buff_au = get_aurora_buff(self.grid_col, self.grid_row);
                            self.atk = self.base_atk * max(grid_thrower[self.grid_col][self.grid_row], buff_au);
                            break;
                        
                        case "tracker":
                            var grid_tracker = ds_map_find_value(global.buff_grid, "tracker");
                            self.atk = self.base_atk * grid_tracker[self.grid_col][self.grid_row];
                            break;
                        
                        case "sprayer":
                            var grid_sprayer = ds_map_find_value(global.buff_grid, "sprayer");
                            self.atk = self.base_atk * grid_sprayer[self.grid_col][self.grid_row];
                            break;
                        
                        case "five_dir":
                            var grid_five_dir = ds_map_find_value(global.buff_grid, "five_dir");
                            var stack_five_dir = ds_map_find_value(global.buff_stack_grid, "five_dir");
                            var fd_normal = grid_five_dir[self.grid_col][self.grid_row];
                            var fd_stack = stack_five_dir[self.grid_col][self.grid_row];
                            self.atk = self.base_atk * max(fd_normal, fd_stack);
                            break;
                        
                        case "multi_dir":
                            var grid_multi_dir = ds_map_find_value(global.buff_grid, "multi_dir");
                            var stack_multi_dir = ds_map_find_value(global.buff_stack_grid, "multi_dir");
                            var md_normal = grid_multi_dir[self.grid_col][self.grid_row];
                            var md_stack = stack_multi_dir[self.grid_col][self.grid_row];
                            self.atk = self.base_atk * max(md_normal, md_stack);
                            break;
                        
                        default:
                            self.atk = self.base_atk;
                            break;
                    }
                }
                
                self.buff_applied_id = global.buff_apply_id;
            }
        }
    }
    
    buff_timer = 5;
}

if (record_timer > 0)
{
    record_timer--;
}
else
{
    with (obj_card_parent)
    {
        if (plant_id != "player")
        {
            if (!variable_instance_exists(id, "transform_recorded"))
            {
                mod_on_card_placed(self.plant_id, self.shape);
                self.transform_recorded = true;
            }
        }
    }
    
    record_timer = 5;
}

if (global.debug)
{
    if (keyboard_check_pressed(vk_numpad1))
    {
        var grid_pos = get_grid_position_from_world(mouse_x, mouse_y);
        var inst = instance_create_depth(grid_pos.x, grid_pos.y + 38, 0, obj_infected_frog_prince_mouse);
        inst.grid_row = grid_pos.row;
        inst.grid_col = grid_pos.col;
        inst.frozen_timer = 0;
    }
    
    if (keyboard_check_pressed(vk_numpad2))
    {
        var grid_pos = get_grid_position_from_world(mouse_x, mouse_y);
        var inst = instance_create_depth(grid_pos.x, grid_pos.y + 38, 0, obj_infected_duck_mouse);
        inst.grid_row = grid_pos.row;
        inst.grid_col = grid_pos.col;
        inst.frozen_timer = 0;
    }
    
    if (keyboard_check_pressed(vk_numpad3))
    {
        var grid_pos = get_grid_position_from_world(mouse_x, mouse_y);
        var inst = instance_create_depth(grid_pos.x, grid_pos.y + 38, 0, obj_infected_submarine_mouse);
        inst.grid_row = grid_pos.row;
        inst.grid_col = grid_pos.col;
        inst.frozen_timer = 0;
    }
    
    if (keyboard_check_pressed(vk_numpad4))
    {
        var grid_pos = get_grid_position_from_world(mouse_x, mouse_y);
        var inst = instance_create_depth(grid_pos.x, grid_pos.y + 38, 0, obj_infected_normal_mouse);
        inst.grid_row = grid_pos.row;
        inst.grid_col = grid_pos.col;
        inst.frozen_timer = 0;
    }
    
    if (keyboard_check_pressed(vk_numpad5))
    {
        var grid_pos = get_grid_position_from_world(mouse_x, mouse_y);
        var inst = instance_create_depth(grid_pos.x, grid_pos.y + 38, 0, obj_infected_football_fan_mouse);
        inst.grid_row = grid_pos.row;
        inst.grid_col = grid_pos.col;
        inst.frozen_timer = 0;
    }
    
    if (keyboard_check_pressed(vk_numpad6))
    {
        var grid_pos = get_grid_position_from_world(mouse_x, mouse_y);
        var inst = instance_create_depth(grid_pos.x, grid_pos.y + 38, 0, obj_infected_iron_pan_mouse);
        inst.grid_row = grid_pos.row;
        inst.grid_col = grid_pos.col;
        inst.frozen_timer = 0;
    }
    
    if (keyboard_check_pressed(vk_numpad7))
    {
        var grid_pos = get_grid_position_from_world(mouse_x, mouse_y);
        var inst = instance_create_depth(grid_pos.x, grid_pos.y + 38, 0, obj_infected_mario_mouse);
        inst.grid_row = grid_pos.row;
        inst.grid_col = grid_pos.col;
        inst.frozen_timer = 0;
        obj_battle.boss_count += 1;
    }
}

if (global.level_id == "ancient_castle_1" && !event_created)
{
    var obstacle_pos_list = [[0, 0, 0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 1, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0, 0, 0, 0]];
    
    for (var i = 0; i < array_length(obstacle_pos_list); i++)
    {
        for (var j = 0; j < array_length(obstacle_pos_list[i]); j++)
        {
            if (obstacle_pos_list[i][j] == 1)
            {
                var obs_pos = get_world_position_from_grid(j, i);
                var inst = instance_create_depth(obs_pos.x, obs_pos.y - 35, -1200, obj_obstacle);
                inst.row = i;
            }
        }
    }
    
    event_created = true;
}

if (global.level_id == "ancient_castle_2" && !event_created)
{
    var obstacle_pos_list = [[0, 0, 0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 1, 0, 1, 0, 0, 0], [0, 0, 0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0, 0, 0, 0]];
    
    for (var i = 0; i < array_length(obstacle_pos_list); i++)
    {
        for (var j = 0; j < array_length(obstacle_pos_list[i]); j++)
        {
            if (obstacle_pos_list[i][j] == 1)
            {
                var obs_pos = get_world_position_from_grid(j, i);
                var inst = instance_create_depth(obs_pos.x, obs_pos.y - 35, -1200, obj_obstacle);
                inst.row = i;
            }
        }
    }
    
    event_created = true;
}

if (global.level_id == "ancient_castle_3" && !event_created)
{
    var obstacle_pos_list = [[0, 0, 0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 1, 0, 0, 0], [0, 0, 0, 0, 1, 0, 0, 0, 0], [0, 0, 0, 1, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0, 0, 0, 0]];
    
    for (var i = 0; i < array_length(obstacle_pos_list); i++)
    {
        for (var j = 0; j < array_length(obstacle_pos_list[i]); j++)
        {
            if (obstacle_pos_list[i][j] == 1)
            {
                var obs_pos = get_world_position_from_grid(j, i);
                var inst = instance_create_depth(obs_pos.x, obs_pos.y - 35, -1200, obj_obstacle);
                inst.row = i;
            }
        }
    }
    
    event_created = true;
}

if (global.level_id == "ancient_castle_4" && !event_created)
{
    var obstacle_pos_list = [[0, 0, 0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 1, 0, 1, 0, 0, 0], [0, 0, 0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 1, 0, 1, 0, 0, 0], [0, 0, 0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0, 0, 0, 0]];
    
    for (var i = 0; i < array_length(obstacle_pos_list); i++)
    {
        for (var j = 0; j < array_length(obstacle_pos_list[i]); j++)
        {
            if (obstacle_pos_list[i][j] == 1)
            {
                var obs_pos = get_world_position_from_grid(j, i);
                var inst = instance_create_depth(obs_pos.x, obs_pos.y - 35, -1200, obj_obstacle);
                inst.row = i;
            }
        }
    }
    
    event_created = true;
}

if (global.level_id == "ancient_castle_5" && !event_created)
{
    var obstacle_pos_list = [[0, 0, 0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 1, 0, 1, 0, 0, 0], [0, 0, 0, 0, 1, 0, 0, 0, 0], [0, 0, 0, 1, 0, 1, 0, 0, 0], [0, 0, 0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0, 0, 0, 0]];
    
    for (var i = 0; i < array_length(obstacle_pos_list); i++)
    {
        for (var j = 0; j < array_length(obstacle_pos_list[i]); j++)
        {
            if (obstacle_pos_list[i][j] == 1)
            {
                var obs_pos = get_world_position_from_grid(j, i);
                var inst = instance_create_depth(obs_pos.x, obs_pos.y - 35, -1200, obj_obstacle);
                inst.row = i;
            }
        }
    }
    
    event_created = true;
}

if (global.level_id == "ancient_castle_6" && !event_created)
{
    var obstacle_pos_list = [[0, 0, 0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 1, 0, 1, 0, 0, 0], [0, 0, 0, 1, 0, 1, 0, 0, 0], [0, 0, 0, 1, 0, 1, 0, 0, 0], [0, 0, 0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0, 0, 0, 0]];
    
    for (var i = 0; i < array_length(obstacle_pos_list); i++)
    {
        for (var j = 0; j < array_length(obstacle_pos_list[i]); j++)
        {
            if (obstacle_pos_list[i][j] == 1)
            {
                var obs_pos = get_world_position_from_grid(j, i);
                var inst = instance_create_depth(obs_pos.x, obs_pos.y - 35, -1200, obj_obstacle);
                inst.row = i;
            }
        }
    }
    
    event_created = true;
}

if (global.level_id == "ancient_castle_7" && !event_created)
{
    var obstacle_pos_list = [[1, 0, 0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 1, 0, 1, 0, 0, 0], [0, 0, 0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 1, 0, 1, 0, 0, 0], [0, 0, 0, 0, 0, 0, 0, 0, 0], [1, 0, 0, 0, 0, 0, 0, 0, 0]];
    
    for (var i = 0; i < array_length(obstacle_pos_list); i++)
    {
        for (var j = 0; j < array_length(obstacle_pos_list[i]); j++)
        {
            if (obstacle_pos_list[i][j] == 1)
            {
                var obs_pos = get_world_position_from_grid(j, i);
                var inst = instance_create_depth(obs_pos.x, obs_pos.y - 35, -1200, obj_obstacle);
                inst.row = i;
            }
        }
    }
    
    event_created = true;
}
