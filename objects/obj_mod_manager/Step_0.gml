external_animation_cache_step();
external_mod_import_step();
external_animation_load_step();
external_animation_debug_step();
external_mod_burn_step();
if (!instance_exists(obj_mod_battle_manager))
{
    var battle = instance_find(obj_battle, 0);
    
    if (battle != -4)
    {
        global.mod_battle_manager = instance_create_layer(0, 0, "Instances", obj_mod_battle_manager);
        global.mod_battle_manager.battle = battle;
    }
}

if (!instance_exists(obj_gods_hall_enter))
{
    if (room == room_map || room == room_menu)
        instance_create_depth(750, 56, -3, obj_gods_hall_enter);
}

// 跨服远征入口按钮
if (!instance_exists(obj_cross_server_enter))
{
    if (room == room_map || room == room_menu)
        instance_create_depth(850, 56, -3, obj_cross_server_enter);
}

// 龙渊入口按钮
if (!instance_exists(obj_longyuan_enter))
{
    if (room == room_map || room == room_menu)
        instance_create_depth(950, 56, -3, obj_longyuan_enter);
}

// 金马盛典入口按钮（图标 2026-11-18 换成 116.png：56×47，原点左上 → y 取 32 与旁边几个入口图标中线齐平）
if (!instance_exists(obj_zz_enter))
{
    if (room == room_map || room == room_menu)
        instance_create_depth(1010, 32, -3, obj_zz_enter);
}

if (!noticed && variable_global_exists("preloaded") && global.preloaded == true)
{
    if (room == room_menu)
    {
        show_notice("MOD功能加载完毕", 90);
        noticed = true;
    }
}
