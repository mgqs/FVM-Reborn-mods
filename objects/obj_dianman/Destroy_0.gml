for (var _i = 0; _i < array_length(fx_list); _i++){
    if (instance_exists(fx_list[_i])) instance_destroy(fx_list[_i]);
}
event_inherited();
