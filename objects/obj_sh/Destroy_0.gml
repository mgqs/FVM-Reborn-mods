event_inherited();

if (variable_global_exists("mod_obj_sh_count"))
    global.mod_obj_sh_count = max(0, global.mod_obj_sh_count - 1);