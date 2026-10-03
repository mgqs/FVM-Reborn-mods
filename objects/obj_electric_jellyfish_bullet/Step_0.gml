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

var zombie_grid = get_grid_position_from_world(x,y)

var base_depth = -10 - (zombie_grid.row * 45) - 45;
depth = base_depth ; // 僵尸比植物稍微靠后一点（在护罩外侧和咖啡豆之间）

// 保持网格位置更新

grid_col = zombie_grid.col;
grid_row = zombie_grid.row;

if flash_value > 0{
	flash_value -= 10
}

timer++

if state == "appear"{
	image_index = floor(timer/5) mod 4
	if timer >= 4 * 5 - 1{
		state = "move"
		timer = 0
	}
}
else if state == "move"{
	image_index = floor(timer/5) mod 3 + 4
	x += x_move_speed
	y += y_move_speed
	if timer >= 90{
		state = "idle"
		timer = 0
	}
}
else if state == "idle"{
	image_index = floor(timer/5) mod 3 + 4
	with obj_flame{
		is_collected = false
		is_capture = true
		speed = 8
		if global.is_paused{
			speed = 0
		}
		direction = point_direction(x,y,other.x,other.y-25)
		if (abs(x - other.x)<=10 && abs(y - other.y+25)<=10){
			instance_destroy()
		}
	}
	if timer >= 60*60{
		hp = 0
		state = "death"
		timer = 0
	}
}
else if state == "death"{
	image_index = floor(timer/5) mod 3 + 7
	if timer >= 3 * 5 - 1{
		instance_destroy()
	}
}

if hp <= 0 && state != "death"{
	state = "death"
	timer = 0
}