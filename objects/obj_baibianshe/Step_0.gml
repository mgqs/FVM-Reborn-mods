if (global.is_paused)
    exit;

event_inherited();

// ── 二转：放下来就一起占 3 格（2026-11-08 用户口径）──
//   「从变 3 个变成放 3 个」：本格 + 同列上一格 + 同列下一格各放一只百变蛇，
//   之后玩家种下一张卡时**每只各变 1 张**（不是一只变 3 张）。
//   上下格被占 / 顶底没有那一行 → 行号 clamp 到最边行后，由 baibianshe_free_cell 由近到远找最近可放格，
//   只有周围半径 2 格内实在没地方才放弃那一只（2026-11-12 用户口径，不再「只放 2 只」）。
//   等自己被 card_created 登记进网格后再动手（否则 grid_col / grid_row 还是初始值）。
if (shape == 2 && !tb_siblings_done)
{
    if (grid_col >= 0 && grid_col < global.grid_cols && grid_row >= 0 && grid_row < global.grid_rows
        && ds_list_find_index(ds_grid_get(global.grid_plants, grid_col, grid_row), id) != -1)
    {
        tb_siblings_done = true;

        // 2026-11-12 修（用户口径，按九宫格标数看，5 = 本格）：
        //      1 2 3
        //      4 5 6
        //      7 8 9
        //   ① 先占 2 / 8（两只都在 = 竖排）；
        //   ② 某一侧被挡 → 替补落在**被挡那一侧同一行的左右**（2 挡 → 1/3，8 挡 → 7/9）；
        //   ③ 2 和 8 都被挡 → 横着放（4/6）；
        //   ④ 3×3 九个格都满 → 才用远距离兜底。
        //   排布算法只有一份：scripts/baibianshe_preview_cell → baibianshe_layout_cells（预览同源）。
        var _used = {};
        _used[$ string(grid_col) + "_" + string(grid_row)] = true;

        // 🔴 兄弟（分身）一律只找**空位**，不能继承玩家的「替换放置」开关 ——
        //   否则 can_place_at_position 会判「已占格也能放」，三只直接叠在别人身上
        var _prev_replace = global.replace_placement;
        global.replace_placement = false;

        var _cells = baibianshe_layout_cells(grid_col, grid_row, _used);
        for (var _ci = 0; _ci < array_length(_cells); _ci++)
        {
            var _cell = _cells[_ci];
            var _w = get_world_position_from_grid(_cell[0], _cell[1]);
            var _sib = external_mod_spawn(_w.x, _w.y, depth, "baibianshe", shape, current_level,
                                          variable_instance_exists(id, "skill") ? skill : 0);
            if (!instance_exists(_sib)) continue;
            _sib.tb_siblings_done = true;   // 🔴 先立旗：否则兄弟会在自己的 Step 里继续往下生
            card_created(_sib, _cell[0], _cell[1]);
        }

        global.replace_placement = _prev_replace;
    }
}

// 2026-11-03：待机中 —— 帧循环（f0~f14）全交给父对象，这里什么都不做
//   变身触发写在 scripts/mod_on_card_placed（只有玩家从手牌放下下一张卡才拨 tb_waiting）
if (tb_waiting)
    exit;

if (!copied && !is_derivative && image_index >= tb_anim_end)
{
    copied = true;
    // 自己按普通卡占格（plant_type = normal）——出卡判定会把自己这一格算成「已占」，
    //   所以先把引用从网格列表里摘掉（只移除引用，不触发回收/死亡效果），本帧末尾再销毁实例。
    card_destroyed(id);
    // 每只百变蛇只变 1 张 —— 二转的「3 张」由**放下来时的 3 只蛇**各变 1 张凑成（见 Step 顶部）
    var _copy_count = 1;

    var _valid_target = card_is_copy_src(target_card);
    var card_save_data = false;

    if (_valid_target)
        card_save_data = get_card_info_simple(target_card);

    if (card_save_data != false)
    {
        var card_slot_data = deck_get_card_data(target_card, target_shape);

        // 目标卡资料存成实例变量：下面 pick_cells / place_one 两个方法都要用
        copy_card_id      = target_card;
        copy_card_shape   = target_shape;
        copy_plant_type   = ds_map_find_value(card_slot_data, "plant_type");
        copy_feature_type = ds_map_find_value(card_slot_data, "feature_type");
        copy_base_target  = ds_map_find_value(card_slot_data, "target_card");

        // 落点：就放自己这一格（被占则顺延到最近可放格）
        var _pref = [[grid_col, grid_row]];

        var prev_replace = global.replace_placement;
        global.replace_placement = false;

        var target_cells = baibianshe_pick_cells(_copy_count, _pref);

        // 凑不满就在控制台报一声（多半是真没地方放，不是逻辑挂了）
        if (array_length(target_cells) < _copy_count)
            show_debug_message("[百变蛇] 只找到 " + string(array_length(target_cells)) + "/" + string(_copy_count) + " 个可放格（形态 " + string(shape) + "）");

        for (var i = 0; i < array_length(target_cells); i++)
            baibianshe_place_one(target_cells[i][0], target_cells[i][1]);

        global.replace_placement = prev_replace;
    }
}

// 变身段播完 → 收场（复制在上一段同帧做完；is_derivative 之类没复制的也在这里走掉）
if (image_index >= tb_anim_end)
    instance_destroy();
