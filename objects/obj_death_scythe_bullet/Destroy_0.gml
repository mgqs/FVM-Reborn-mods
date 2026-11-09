if (variable_instance_exists(id, "hitted_enemy") && ds_exists(hitted_enemy, ds_type_list))
    ds_list_destroy(hitted_enemy);
if (variable_instance_exists(id, "brazier_list") && ds_exists(brazier_list, ds_type_list))
    ds_list_destroy(brazier_list);