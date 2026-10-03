event_inherited();

if (instance_exists(heian_effect_obj))
    instance_destroy(heian_effect_obj);

if (ds_exists(hit_map, ds_type_map))
    ds_map_destroy(hit_map);
