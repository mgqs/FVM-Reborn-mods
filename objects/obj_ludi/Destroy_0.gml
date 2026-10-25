/// 陆地下沉完毕 → 清除该格所有非承载卡片，并生成 obj_lava
/// 地形保持 normal（岩浆只是视觉+灼烧，玩家仍可在该格放卡）
if (col >= 0 && row >= 0 && col < global.grid_cols && row < global.grid_rows) {
	// 清除该格所有非承载卡片（cotton_candy/lingrong_god 等由 clear_cell 白名单保留）
	longyuan_bridge_clear_cell(col, row);

	// 生成岩浆
	var _pos = get_world_position_from_grid(col, row);
	var _lava = instance_create_depth(_pos.x, _pos.y - 35, -1200, obj_lava);
	_lava.row = row;
	_lava.col = col;
	_lava.depth = calculate_plant_depth(col, row, "coffee");

	// 标记岩浆格（障碍物生成逻辑用）
	var _idx = row * global.grid_cols + col;
	if (variable_global_exists("longyuan_bridge_lava_cells")) {
		global.longyuan_bridge_lava_cells[_idx] = true;
	}
}
