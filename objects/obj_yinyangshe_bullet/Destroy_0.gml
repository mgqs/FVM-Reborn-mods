// obj_yinyangshe_bullet Destroy 事件
// 两条 ds_list 必须自己释放（子弹每帧都在生成销毁，漏了内存会一直涨）
if (ds_exists(hitted, ds_type_list)) ds_list_destroy(hitted);
if (ds_exists(brazier_list, ds_type_list)) ds_list_destroy(brazier_list);
