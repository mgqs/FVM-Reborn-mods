// 卡片销毁时，清理所有未完成的子弹
if (ds_exists(laipishe_bullets, ds_type_list))
{
    for (var i = 0; i < ds_list_size(laipishe_bullets); i++)
    {
        var _b = ds_list_find_value(laipishe_bullets, i);
        if (instance_exists(_b))
            instance_destroy(_b);
    }
    ds_list_destroy(laipishe_bullets);
}
