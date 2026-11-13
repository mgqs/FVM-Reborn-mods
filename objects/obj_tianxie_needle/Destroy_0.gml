// obj_tianxie_needle Destroy 事件（2026-11-13 补：释放命中表，防列表泄漏）
if (ds_exists(fx_hit, ds_type_list)) ds_list_destroy(fx_hit);
