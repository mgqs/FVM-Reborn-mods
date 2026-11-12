// obj_rig_bullet Destroy 事件（2026-11-13 补：释放命中表，防列表泄漏）
if (ds_exists(hitted_enemy, ds_type_list)) ds_list_destroy(hitted_enemy);
