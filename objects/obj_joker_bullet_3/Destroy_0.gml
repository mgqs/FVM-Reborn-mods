/// 终转弹 Destroy：溅射已在命中时逐只结算（见 Step），这里只回收命中记账
if (ds_exists(hit_log, ds_type_list))
    ds_list_destroy(hit_log);
