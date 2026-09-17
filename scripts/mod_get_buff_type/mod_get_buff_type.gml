function mod_get_buff_type(arg0)
{
    if (ds_map_exists(global.plant_buff_map, arg0))
        return ds_map_find_value(global.plant_buff_map, arg0);
    
    return "normal";
}
