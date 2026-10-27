var grid_pos = get_grid_position_from_world(x,y)
if current_grid_type != ""{
	global.grid_terrains[grid_pos.row][grid_pos.col].type = current_grid_type
}

// 海克斯「爱打洞的老鼠」：清除鼠洞返还火苗与金币（未启用时内部直接返回）
hex_batch2_hole_refund();
