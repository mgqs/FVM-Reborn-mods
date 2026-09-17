if global.is_paused{
	exit
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