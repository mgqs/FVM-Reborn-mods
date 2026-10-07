if (global.is_paused)
    exit;

grid_row = parent_player.grid_row;
grid_col = parent_player.grid_col;
depth = parent_player.depth - 1;
origin_x = parent_player.x;
origin_y = parent_player.y;
timer++;

if (parent_player.state == 0)
{
    anim_timer++;
    
    if (anim_timer >= 6)
    {
        anim_timer = 0;
        t += (t_speed * t_dir);
        
        if (t >= 1)
        {
            t = 1;
            t_dir = -1;
        }
        
        if (t <= -1)
        {
            t = -1;
            t_dir = 1;
        }
        
        var x_param = t;
        var y_param = (0.5 * t * t) - 1;
        x = origin_x + x_param;
        y = origin_y + y_param;
    }
}
else if (parent_player.state == 1)
{
    anim_timer = 0;
    x = origin_x;
    y = origin_y;
    t = 0;
    t_dir = 1;
}

if (divine_blessing_gem)
{
    if (!first_produce)
    {
        if ((timer % first_produce_delay) == 0)
        {
            var base = 25;
            var count = flame_produce div base;
            var remain = flame_produce % base;
            
            for (var i = 0; i < count; i++)
            {
                var f_inst = instance_create_depth(x, y - 50, -1300, obj_flame);
                f_inst.value = base;
            }
            
            if (remain > 0)
            {
                var f_inst = instance_create_depth(x, y - 50, -1300, obj_flame);
                f_inst.value = remain;
            }
            
            first_produce = true;
        }
    }
    else if ((timer % cycle) == 0)
    {
        var base = 25;
        var count = flame_produce div base;
        var remain = flame_produce % base;
        
        for (var i = 0; i < count; i++)
        {
            var f_inst = instance_create_depth(x, y - 50, -1300, obj_flame);
            f_inst.value = base;
        }
        
        if (remain > 0)
        {
            var f_inst = instance_create_depth(x, y - 50, -1300, obj_flame);
            f_inst.value = remain;
        }
    }
}

if (divine_protect_gem && !buff_cells_refreshed)
{
    add_shield_area(buff_cells, grid_col, grid_row, buff_value);
    apply_shield_buff(id);
    buff_cells_refreshed = true;
}

if (divine_holy_gem)
{
    if ((timer % 150) == 0)
    {
        with (obj_enemy_parent)
        {
            var row_diff = self.grid_row - other.grid_row;
            var col_diff = self.grid_col - other.grid_col;
            
            if (!variable_instance_exists(id, "divine_holy_gem_debuffed"))
                self.divine_holy_gem_debuffed = false;
            
            if (row_diff >= -2 && row_diff <= 2 && col_diff >= -2 && col_diff <= 2 && !self.divine_holy_gem_debuffed)
            {
                self.hp -= other.reflect_damage;
                self.ice_timer += other.ice_timer;
                self.divine_holy_gem_debuffed = true;
            }
        }
    }
}

