// obj_sheshejiu 用户事件 2（Other_12）：持续时间到点 → 把记录过的卡写回原星级
//   实例 id 可能被复用（旧卡被铲掉后新卡占了同一个 id），所以 pid / 列 / 行 必须一起对上才复原
for (var _i = 0; _i < ds_list_size(ss_snap); _i++){
    var _e = ss_snap[| _i];

    if (!instance_exists(_e.inst)) continue;
    if (!variable_instance_exists(_e.inst, "plant_id")) continue;
    if (_e.inst.plant_id != _e.pid) continue;
    if (_e.inst.grid_col != _e.col || _e.inst.grid_row != _e.row) continue;

    mod_set_card_level(_e.inst, _e.lv);
}
