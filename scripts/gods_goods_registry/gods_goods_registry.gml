function gods_goods_registry_init()
{
    global.gods_goods_map = ds_map_create();
}

function register_gods_goods(arg0, arg1)
{
    ds_map_set(global.gods_goods_map, arg0, arg1);
}
