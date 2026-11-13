// obj_yuansushe_bullet Destroy 事件：释放命中记录（每发子弹一个 ds_list，不释放会一直涨）
if (ds_exists(hitted, ds_type_list))
    ds_list_destroy(hitted);
