// 恢复被本锁链禁止铲除的卡片并清理列表
if (variable_instance_exists(id, "locked_cards") && ds_exists(locked_cards, ds_type_list)) {
    for (var _i = 0; _i < ds_list_size(locked_cards); _i++) {
        var _p = locked_cards[| _i];
        if (instance_exists(_p) && variable_instance_exists(_p, "can_shovel_remove")) {
            _p.can_shovel_remove = true;
        }
    }
    ds_list_destroy(locked_cards);
}
