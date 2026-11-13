// obj_sheshejiu Destroy：被铲除 / 被洞君顶掉时释放快照列表（否则 ds 泄漏）
if (variable_instance_exists(id, "ss_snap") && ds_exists(ss_snap, ds_type_list)){
    ds_list_destroy(ss_snap);
}
