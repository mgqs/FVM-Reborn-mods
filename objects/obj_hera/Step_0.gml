if (global.is_paused)
    exit;

if (hp <= (0.33 * max_hp))
    sprite_index = sprite_list[2];
else if (hp <= (0.66 * max_hp))
    sprite_index = sprite_list[1];
else
    sprite_index = sprite_list[0];

event_inherited();

if (!spawn_init)
{
    spawn_init = true;
    
    if (shape >= 2)
    {
        with (obj_card_parent)
        {
            if (id != other.id && grid_row == other.grid_row && grid_col == other.grid_col)
            {
                hp += 1000;
                instance_create_depth(x, y + 30, depth - 4, obj_card_heal_effect);
            }
        }
    }
    
    if (shape == 3 && !is_clone)
    {
        var candidates = ds_priority_create();
        
        for (var r = 0; r < global.grid_rows; r++)
        {
            for (var c = 0; c < global.grid_cols; c++)
            {
                if (r == grid_row && c == grid_col)
                    continue;
                
                var check_x = global.grid_offset_x + (c * global.grid_cell_size_x) + (global.grid_cell_size_x / 2);
                var check_y = global.grid_offset_y + (r * global.grid_cell_size_y) + (global.grid_cell_size_y / 2);
                var can_plant = can_place_at_position(check_x, check_y, "shield_outer", "normal", "none");
                
                if (can_plant)
                {
                    var dist = abs(r - grid_row) + abs(c - grid_col);
                    
                    if (c == grid_col && (r == (grid_row - 1) || r == (grid_row + 1)))
                        dist -= 0.5;
                    
                    ds_priority_add(candidates, [r, c], dist);
                }
            }
        }
        
        for (var clones_made = 0; !ds_priority_empty(candidates) && clones_made < 2; clones_made++)
        {
            var best_cell = ds_priority_delete_min(candidates);
            var target_r = best_cell[0];
            var target_c = best_cell[1];
            var spawn_x = x + ((target_c - grid_col) * global.grid_cell_size_x);
            var spawn_y = y + ((target_r - grid_row) * global.grid_cell_size_y);
            var clone = instance_create_depth(spawn_x, spawn_y, depth, obj_hera);
            clone.is_clone = true;
            clone.shape = 3;
            clone.grid_row = target_r;
            clone.grid_col = target_c;
            clone.hp = hp;
            clone.atk = atk;
            var plant_list = ds_grid_get(global.grid_plants, target_c, target_r);
            ds_list_add(plant_list, clone.id);
        }
        
        ds_priority_destroy(candidates);
    }
}

if (current_hp > hp)
{
    bleed_damage = current_hp - hp;
    event_user(1);
}

current_hp = hp;

if (frozen_timer > 0)
    exit;
