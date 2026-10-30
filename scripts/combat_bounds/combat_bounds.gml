/// ============================================================
/// 战斗域边界（列 / 行）
/// ------------------------------------------------------------
/// ⚠ 列号有两套写法，差 1，必须分清：
///   · 策划 / 玩家口径（1 起算）：左上角为原点，从左往右是「第 1 列 … 第 9 列」，
///     地图外的出生点列叫「第 10 列」。
///   · 代码口径（0 起算，即 grid_col / 本文件所有参数）：第 1 列 = col 0，
///     第 9 列 = col 8，第 10 列 = col 9 = global.grid_cols。
///
/// 工程里同时存在两套列范围，**不能混用**：
///   · 地图域：col 0 .. global.grid_cols-1（= 第 1~9 列）→ 可放卡区、grid_plants、
///     grid_terrains、can_place_at_position、卡槽绘制。**保持 9 列不变**。
///   · 战斗域：col 0 .. global.grid_cols（= 第 1~10 列）→ 敌人出生就在
///     (9 + x_offset) 列（obj_battle/Create_0），即第 10 列，
///     所以卡片索敌 / 子弹存活必须用这一套上界，否则刚出生的老鼠完全打不到。
///
/// 用法约定：
///   索敌 / 命中 / 子弹存活 → combat_col_in() / combat_cell_in() / combat_right_x()
///   放置 / 地形索引 / 绘制 → 仍用 global.grid_cols 或 combat_map_col_in()
/// ============================================================

/// @function combat_min_col()
/// @description 战斗域最小列索引（含）
function combat_min_col() {
    return 0;
}

/// @function combat_max_col()
/// @description 战斗域最大列索引（含）：col 9 = 策划口径的「第 10 列」（场外出生点列）
function combat_max_col() {
    return global.grid_cols;
}

/// @function combat_col_in(_col)
/// @description 列是否落在战斗域内（含第 10 列）
function combat_col_in(_col) {
    return _col >= combat_min_col() && _col <= combat_max_col();
}

/// @function combat_row_in(_row)
/// @description 行是否落在战斗域内（行数没有扩展，与地图一致）
function combat_row_in(_row) {
    return _row >= 0 && _row < global.grid_rows;
}

/// @function combat_cell_in(_col, _row)
/// @description 格子是否落在战斗域内
function combat_cell_in(_col, _row) {
    return combat_col_in(_col) && combat_row_in(_row);
}

/// @function combat_map_col_in(_col)
/// @description 列是否落在地图可放置区内（col 0 .. grid_cols-1，即策划口径的第 1~9 列）。
///              用于「只有前 9 列生效」的逻辑，例如御风马只击退场地内的老鼠，
///              第 10 列（col 9）及以后只扣血不击退。
function combat_map_col_in(_col) {
    return _col >= combat_min_col() && _col < global.grid_cols;
}

/// @function combat_left_x()
/// @description 战斗域左边界世界坐标（地图左沿）
function combat_left_x() {
    return global.grid_offset_x;
}

/// @function combat_right_x()
/// @description 战斗域右边界世界坐标 = 第 10 列的右沿
function combat_right_x() {
    return global.grid_offset_x + (global.grid_cols + 1) * global.grid_cell_size_x;
}

/// @function combat_last_col_x()
/// @description 第 10 列（战斗域最右列）的左沿世界坐标，也等于地图可放置区的右沿。
///              要表达「只打场外 / 只打第 10 列及以后」时用它比较敌人 x，
///              比比较 grid_col 更稳（grid_col 在敌人 Create 帧是占位值 99，空中单位会是 -1）。
function combat_last_col_x() {
    return global.grid_offset_x + global.grid_cols * global.grid_cell_size_x;
}
