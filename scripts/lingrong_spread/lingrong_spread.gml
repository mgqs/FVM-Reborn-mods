/// ============================================================
/// 灵榕神（无敌猫猫软糖 / shape 2）3×3 展开
/// ------------------------------------------------------------
/// 放下时以本体为中心生成一个 3×3 的软糖块（共 9 张，本体占中心格）。
/// 规则：
///   · 8 个方向各尝试生成一张；
///   · 某个方向的相邻格若被越界 / 蛛网 / 青苹果封住，或该格已有
///     lingrong_god / cotton_candy / soda_bubble / wooden_plate 这四种卡片，
///     就沿这个方向继续往外走一格，直到找到可用的格子（其余卡片一律放行）；
///   · 走到地图边界还没找到就放弃该方向（不会绕到另一侧）。
/// ============================================================

/// @function lingrong_cell_blocked(_col, _row)
/// @description 该格是否「不能再放软糖」。两层判据：
///              ① 越界 / 蛛网封格 / 青苹果封格；
///              ② 该格已有 lingrong_god / cotton_candy / soda_bubble / wooden_plate
///                 这四种卡片（与 shape1 的 _blocked_ids 同口径）。
///              其余卡片（含玩家、其它任意卡）一律放行，软糖会与它们同格叠放。
///              这里不判地形：软糖可放在水面、岩浆、陆地、障碍上。
function lingrong_cell_blocked(_col, _row) {
    if (_col < 0 || _col >= global.grid_cols || _row < 0 || _row >= global.grid_rows) return true;

    // 蜘蛛精蛛网封格（与 can_place_at_position 同口径）
    if (variable_global_exists("longyuan_web_cells")
        && global.longyuan_web_cells[_row * global.grid_cols + _col]) return true;

    // 傲慢龙柱的青苹果封格
    var _apple_n = instance_number(obj_longzhu_green_apple);
    for (var _ai = 0; _ai < _apple_n; _ai++) {
        var _apple = instance_find(obj_longzhu_green_apple, _ai);
        if (!instance_exists(_apple)) continue;
        if (_apple.hp > 0 && _apple.col == _col && _apple.row == _row) return true;
    }

    // 只拦这四种卡：它们会和软糖抢同一点位 / 视觉上叠成一团，所以必须往外扩。
    // 其余卡片放行 —— 这是原本 _blocked_ids 的语义，别改成「有任意卡片就扩」。
    var _blocked_ids = ["lingrong_god", "cotton_candy", "soda_bubble", "wooden_plate"];
    var _list = ds_grid_get(global.grid_plants, _col, _row);
    for (var _i = 0; _i < ds_list_size(_list); _i++) {
        var _plant = ds_list_find_value(_list, _i);
        if (!instance_exists(_plant)) continue;
        if (variable_instance_exists(_plant, "plant_id") && array_get_index(_blocked_ids, _plant.plant_id) != -1) return true;
    }

    return false;
}

/// @function lingrong_spread_cell(_col, _row, _dc, _dr)
/// @description 从中心格 (_col,_row) 出发，沿方向 (_dc,_dr) 由近到远找一个可放软糖的格子。
///              第一圈就是 3×3 的相邻格；被占则往外扩一格（第二圈），以此类推。
/// @returns {array} [col, row]，找不到返回 undefined
function lingrong_spread_cell(_col, _row, _dc, _dr) {
    var _max_ring = max(global.grid_cols, global.grid_rows);
    for (var _k = 1; _k <= _max_ring; _k++) {
        var _c = _col + _dc * _k;
        var _r = _row + _dr * _k;
        // 越界：这个方向已经到底，别再往外走
        if (_c < 0 || _c >= global.grid_cols || _r < 0 || _r >= global.grid_rows) return undefined;
        if (!lingrong_cell_blocked(_c, _r)) return [_c, _r];
    }
    return undefined;
}
