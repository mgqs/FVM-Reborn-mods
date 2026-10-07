function mod_register_plant_lite(arg0, arg1, arg2 = true)
{
    var is_god = arg2;

    if (ds_map_exists(global.plant_registry, arg0))
    {
        show_debug_message("mod植物已注册: " + arg0);
        return false;
    }
    
    var plant_data = ds_map_create();
    ds_map_set(plant_data, "shapes", ds_map_create());
    
    for (var i = 0; i < array_length(arg1); i++)
    {
        var shape_info = arg1[i];
        var shape = shape_info.shape;
        var shape_data = ds_map_create();
        ds_map_set(shape_data, "name", shape_info.name);
        ds_map_set(shape_data, "description", shape_info.description);
        ds_map_set(shape_data, "base_hp", shape_info.hp[0]);
        ds_map_set(shape_data, "base_cost", shape_info.cost[0]);
        ds_map_set(shape_data, "base_atk", shape_info.atk[0]);
        ds_map_set(shape_data, "base_range", shape_info.range[0]);
        ds_map_set(shape_data, "base_cooldown", shape_info.cooldown[0]);
        ds_map_set(shape_data, "base_cycle", shape_info.cycle[0]);
        var upgrades = ds_map_create();
        ds_map_set(shape_data, "upgrades", upgrades);
        var base_upgrade = ds_map_create();
        ds_map_add(base_upgrade, "level", 0);
        ds_map_add(base_upgrade, "hp", shape_info.hp[0]);
        ds_map_add(base_upgrade, "cost", shape_info.cost[0]);
        ds_map_add(base_upgrade, "atk", shape_info.atk[0]);
        ds_map_add(base_upgrade, "range", shape_info.range[0]);
        ds_map_add(base_upgrade, "cooldown", shape_info.cooldown[0]);
        ds_map_add(base_upgrade, "cycle", shape_info.cycle[0]);
        
        if (struct_exists(shape_info, "flame_produce"))
            ds_map_add(base_upgrade, "flame_produce", shape_info.flame_produce[0]);
        
        if (struct_exists(shape_info, "first_produce_delay"))
            ds_map_add(base_upgrade, "first_produce_delay", shape_info.first_produce_delay[0]);
        
        ds_map_add(upgrades, "0", base_upgrade);
        ds_map_add(ds_map_find_value(plant_data, "shapes"), string(shape), shape_data);
    }
    
    ds_map_add(global.plant_registry, arg0, plant_data);
    
    var max_level = is_god ? 18 : 16;
    for (var i = 1; i <= max_level; i++)
        add_plant_upgrade_lite(arg0, i, arg1);
    
    return true;
}
