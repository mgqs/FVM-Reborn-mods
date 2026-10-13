if global.is_paused{
	exit
}
timer ++
image_index = min(floor(timer / 2), 14)

// 毒雾先出来，稍后才单独毒一下（延迟 10 帧 ≈ 0.17s）
if not has_damaged && timer >= 10{
	has_damaged = true
	var _x = x;
	var _y = y;
	var _range = 200;
	with (obj_enemy_parent) {
		if (hp > 0 && point_distance(x, y, _x, _y) < _range && grid_row >= other.grid_row-1 && grid_row <= other.grid_row+1 and can_hit(other.target_type, target_type)) {
			// 对敌人造成毒气伤害
			damage_amount = other.damage;
			damage_type = other.damage_type;
			event_user(0);
		}
	}
}

// 毒雾残留 30 帧（0.5s）后淡出，36 帧销毁
if timer > 30{
	disabled = true
	image_alpha = (36-timer)/6
	if timer > 36{
		instance_destroy()
	}
}
