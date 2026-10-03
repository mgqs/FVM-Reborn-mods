// 用户事件1 - 释放柿子攻击
// 生成 persimmon_count 个柿子，竖向分布，每个造成 3×3 范围伤害

var _cast_id = current_time + irandom(999999)  // 唯一施法批次ID

// 计算每个柿子的目标行（考虑边界平移）
var _target_rows = []
var _min_row = 999
var _max_row = -999

// 先计算原始行位置
for (var i = 0; i < persimmon_count; i++){
	var _row = grid_row + vertical_offsets[i]
	array_push(_target_rows, _row)
	if _row < _min_row _min_row = _row
	if _row > _max_row _max_row = _row
}

// 边界规则：整体平移到合法区域，不得裁剪分身
var _shift = 0
if _min_row < 0{
	_shift = -_min_row  // 向下平移
}
else if _max_row >= global.grid_rows{
	_shift = global.grid_rows - 1 - _max_row  // 向上平移
}

// 应用平移
for (var i = 0; i < array_length(_target_rows); i++){
	_target_rows[i] += _shift
}

// 生成每个柿子
for (var j = 0; j < persimmon_count; j++){
	var _target_row = _target_rows[j]
	// 目标列：找本行最近的敌人所在列，没有则用当前列
	var _target_col = grid_col
	var _nearest_dist = 9999

	with(obj_enemy_parent){
		if (hp <= 0) continue
		if (state == ENEMY_STATE.DEAD) continue
		if (grid_row != _target_row) continue
		if (!can_target_on(other.target_type, target_type)) continue
		// 在前方范围内
		var _col_diff = grid_col - other.grid_col
		if (_col_diff >= -other.range && _col_diff <= other.range){
			var _dist = abs(grid_col - other.grid_col)
			if _dist < _nearest_dist{
				_nearest_dist = _dist
				_target_col = grid_col
			}
		}
	}

	// 计算目标世界坐标
	var _target_pos = get_world_position_from_grid(_target_col, _target_row)

	// 创建柿子对象
	var _persimmon = instance_create_depth(x, y - 200, depth - 100, obj_qingse_shishi_persimmon)
	_persimmon.target_x = _target_pos.x
	_persimmon.target_y = _target_pos.y
	_persimmon.damage = atk
	_persimmon.hit_radius = hit_radius
	_persimmon.target_type = target_type
	_persimmon.cast_id = _cast_id
	_persimmon.clone_index = j
	_persimmon.owner = id
}

// 播放攻击音效（暂用面粉袋音效占位）
audio_play_sound(snd_flour_sack_find, 0, false)
