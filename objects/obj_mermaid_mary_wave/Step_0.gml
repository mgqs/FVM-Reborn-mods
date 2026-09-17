if global.is_paused{
	exit
}

var zombie_grid = get_grid_position_from_world(x,y)

var base_depth = -10 - (zombie_grid.row * 45) - (zombie_grid.col * 5);
depth = base_depth ; // 僵尸比植物稍微靠后一点（在护罩外侧和咖啡豆之间）

// 保持网格位置更新

grid_col = zombie_grid.col;
grid_row = zombie_grid.row;

if flash_value > 0{
	flash_value -= 10
}

timer++

if state == "appear"{
	x -= move_speed
	if timer <= 4 * 5 - 1{
		image_index = floor(timer /5) mod 4
	}
	else{
		image_index = floor((timer-20) /5) mod 9 + 4
		if grid_col <= 0{
			hp = 0
		}
	}
	with obj_card_parent{
		if grid_col == other.grid_col && grid_row == other.grid_row &&
		plant_id != "player" && plant_type != "coffee" && !invincible && plant_id != "cotton_candy" && plant_id != "soda_bubble"{
			if hp >= max_hp{
				obj_task_manager.card_loss++
			}
			other.hp = 0
			instance_destroy()
		}
	}
}
else if state == "death"{
	image_index = floor(timer/5) mod 6 + 13
	if timer >= 6 * 5 - 1{
		instance_destroy()
	}
}

if hp <= 0 && state != "death"{
	state = "death"
	timer = 0
}