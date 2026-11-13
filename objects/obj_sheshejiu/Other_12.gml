// obj_sheshejiu 用户事件 2（Other_12）：持续时间到点 → **按当初的加减数反向复原**
//   2026-11-13 用户口径：不看现在多少星，当初 +2 现在就 -2（撞到 0 / 16 会夹住）；
//   中途被时光机 / 命运女神改过也照样按加减数复原，不强行回到原星级。
//   复原时播对应的星光特效（当初升星 → 现在降星特效，反之亦然）。
for (var _i = 0; _i < ds_list_size(ss_snap); _i++){
    var _e = ss_snap[| _i];

    // 实例 id 可能被复用（旧卡被铲掉后新卡占了同一个 id），所以 pid / 列 / 行 必须一起对上才复原
    if (!instance_exists(_e.inst)) continue;
    if (!variable_instance_exists(_e.inst, "plant_id")) continue;
    if (_e.inst.plant_id != _e.pid) continue;
    if (_e.inst.grid_col != _e.col || _e.inst.grid_row != _e.row) continue;
    if (_e.off == 0) continue;

    var _cur  = _e.inst.current_level;
    var _want = clamp(_cur - _e.off, 0, 16);
    if (_want == _cur) continue;

    mod_set_card_level(_e.inst, _want);

    // ── 复原特效：方向与当初相反 ──
    var _eff = instance_create_depth(_e.inst.x, _e.inst.y, _e.inst.depth - 1, obj_clotho_star_effect);
    if (instance_exists(_eff)){
        if (_e.off > 0)             _eff.sprite_index = spr_clotho_star_drop;   // 当初升星 → 现在降
        else if (shape >= 2)        _eff.sprite_index = spr_clotho_star_up_1;
        else                        _eff.sprite_index = spr_clotho_star_up;
        _eff.state = clamp(abs(_e.off) - 1, 0, 4);
    }
}
