// obj_zhuzhuliaoliji_bullet Destroy 事件（2026-11-13 补：释放过火表，防列表泄漏）
if (ds_exists(brazier_list, ds_type_list)) ds_list_destroy(brazier_list);
