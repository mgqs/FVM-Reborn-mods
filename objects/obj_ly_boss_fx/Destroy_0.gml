// 无常献宝封印：到期或被清理时恢复被停用的武器/宝石实例
if (variable_instance_exists(id, "fx_kind") && fx_kind == "wuchang_seal") {
    if (variable_instance_exists(id, "fx_sealed") && ds_exists(fx_sealed, ds_type_list)) {
        for (var _i = 0; _i < ds_list_size(fx_sealed); _i++) {
            instance_activate_object(fx_sealed[| _i]);
        }
        ds_list_destroy(fx_sealed);
    }
}
