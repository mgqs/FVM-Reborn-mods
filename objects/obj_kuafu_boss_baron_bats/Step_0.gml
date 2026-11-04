if global.is_paused{
	exit
}

// Register to global enemy type registry
if (!enemy_registered || enemy_registered_type != target_type) {
	if (enemy_registered) {
		var _old_list = global.enemy_by_type[$ enemy_registered_type];
		var _old_idx = array_get_index(_old_list, id);
		if (_old_idx != -1) array_delete(_old_list, _old_idx, 1);
	}
	if (!variable_global_exists("enemy_by_type")) {
		global.enemy_by_type = {};
	}
	var _reg_key = target_type;
	if (!variable_struct_exists(global.enemy_by_type, _reg_key)) {
		global.enemy_by_type[$ _reg_key] = [];
	}
	array_push(global.enemy_by_type[$ _reg_key], id);
	enemy_registered = true;
	enemy_registered_type = target_type;
}

var grid_pos = get_grid_position_from_world(x,y)

if flash_value > 0{
	flash_value -= 10
}

timer++

if state == "appear"{
	image_index = floor(timer/5) mod 6
	image_alpha += 0.1
	image_xscale += 0.09
	image_yscale += 0.09
	if timer >= 10{
		image_alpha = 1
		image_xscale = 1.8
		image_yscale = 1.8
		timer = 0
		state = "move"
		
	}
}
else if state == "move"{
	image_index = floor(timer/5) mod 6
	x += x_speed
	y += y_speed
	if timer >= 120{
		timer = 0
		state = "idle"
		
	}
}
else if state == "idle"{
	image_index = floor(timer/5) mod 6 + 6
	if timer == 180{
		with obj_card_parent{
			if((abs(grid_col - other.grid_col) + abs(grid_row - other.grid_row)) <= 0 && plant_id != "player" &&  plant_type != "coffee"){
				if hp >= max_hp{
					obj_task_manager.card_loss++
				}
				instance_destroy()
			}
		}
		hp = 0
	}
}
else if state == "death"{
	image_alpha -= 0.1
}

if hp <= 0 && state != "death"{
	state = "death"
	timer = 0
}

if image_alpha <= 0 && hp <= 0{
	instance_destroy()
}


var zombie_grid = get_grid_position_from_world(x, y);

// 更新僵尸的网格位置和深度

var base_depth = -10 - (zombie_grid.row * 45) - (8 * 5);
depth = base_depth ; // 僵尸比植物稍微靠后一点（在护罩外侧和咖啡豆之间）

// 保持网格位置更新

grid_col = zombie_grid.col;
grid_row = zombie_grid.row;