// 柿子攻击效果对象 - Step 事件
// 下落 → 命中 → 造成伤害 → 播放效果 → 销毁

if global.is_paused{
	exit
}

if !has_dealt_damage{
	// 下落阶段
	y += fall_speed
	fall_speed += 1  // 加速下落

	// 到达目标位置
	if y >= target_y{
		y = target_y
		has_dealt_damage = true
		land_timer = 0

		// ========== 造成 3×3 范围伤害 ==========
		// 获取目标网格位置
		var _grid_pos = get_grid_position_from_world(target_x, target_y)
		var _center_col = _grid_pos.col
		var _center_row = _grid_pos.row

		// 遍历范围内的敌人
		with(obj_enemy_parent){
			if (hp <= 0) continue
			if (state == ENEMY_STATE.DEAD) continue
			// 3×3 范围判定
			var _col_diff = abs(grid_col - _center_col)
			var _row_diff = abs(grid_row - _center_row)
			if _col_diff <= other.hit_radius && _row_diff <= other.hit_radius{
				// 目标类型判定
				if can_hit(other.target_type, target_type){
					// 造成伤害
					damage_amount = other.damage
					damage_type = "physical"
					event_user(0)
				}
			}
		}

		// 播放命中音效（暂用面粉袋攻击音效）
		audio_play_sound(snd_flour_sack, 0, false)

		// 屏幕震动
		if global.screen_shake{
			Camera_Shock(3, 10)
		}
	}
}
else{
	// 落地后短暂显示效果然后销毁
	land_timer++
	image_alpha = 1 - (land_timer / land_max_time)
	if land_timer >= land_max_time{
		instance_destroy()
	}
}
