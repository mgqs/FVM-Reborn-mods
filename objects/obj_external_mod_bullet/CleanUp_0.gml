// Clean Up also runs when leaving a room, unlike Destroy alone.
if (ds_exists(hit_ids, ds_type_list)) ds_list_destroy(hit_ids);
if (ds_exists(bounce_ids, ds_type_list)) ds_list_destroy(bounce_ids);
if (ds_exists(amplify_ids, ds_type_list)) ds_list_destroy(amplify_ids);
if (ds_exists(hit_cooldowns, ds_type_map)) ds_map_destroy(hit_cooldowns);
