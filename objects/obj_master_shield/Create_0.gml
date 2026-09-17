image_xscale = 1.6;
image_yscale = 1.6;
image_speed = 0;
parent_player = -4;
grid_col = 0;
grid_row = 0;
timer = 0;
state = 0;
weapon_id = "master_shield";
divine_blessing_gem = false;
divine_protect_gem = false;
divine_holy_gem = false;
hp_modified_card_list = [];
atk_modified_card_list = [];
origin_x = x;
origin_y = y;
t = 0;
t_speed = 0.5;
t_dir = 1;
anim_timer = 0;

if (get_gem_index("divine_blessing_gem") != -1)
{
    var gem_info = get_gem_info("divine_blessing_gem");
    var gem_level = get_gem_level("divine_blessing_gem");
    cycle = gem_info.cycle[gem_level] * 60;
    flame_produce = gem_info.flame_value[gem_level];
    first_produce_delay = gem_info.first_produce_delay * 60;
    first_produce = false;
    divine_blessing_gem = true;
}

if (get_gem_index("divine_protect_gem") != -1)
{
    divine_protect_gem = true;
    var gem_info = get_gem_info("divine_protect_gem");
    var gem_level = get_gem_level("divine_protect_gem");
    
    if (gem_level > 15)
        gem_level = 15;
    
    buff_value = gem_info.atk_ratio[gem_level];
}

if (get_gem_index("divine_holy_gem") != -1)
{
    divine_holy_gem = true;
    var gem_info = get_gem_info("divine_holy_gem");
    var gem_level = get_gem_level("divine_holy_gem");
    
    if (gem_level > 15)
        gem_level = 15;
    
    reflect_damage = gem_info.atk[gem_level];
    ice_timer = gem_info.ice_timer[gem_level];
}

rebuild_shield_grid();

if (divine_protect_gem)
{
    buff_cells = [];
    buff_cells_refreshed = false;
}

show_debug_message("主宰之盾初始化完毕");

