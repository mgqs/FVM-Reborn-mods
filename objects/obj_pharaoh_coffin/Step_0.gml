if global.is_paused{
	exit
}

var grid_pos = get_grid_position_from_world(x,y)

if flash_value > 0{
	flash_value -= 10
}

timer++

if state == "appear"{
	image_index = 0
	image_alpha += 0.034
	y += y_speed
	if timer >= 6*5{
		timer = 0
		state = "anim"
	}
}
else if state == "anim"{
	image_index = floor(timer/5)
	if timer >= 24*5 - 1{
		instance_create_depth(x-30,y,-200,obj_mummy_mouse)
		timer = 0
		state = "idle"
	}
}
else if state == "idle"{
	if hp > hurt_rate * maxhp{
		image_index = 24
	}
	else{
		image_index = 25
	}
}
else if state == "death"{
	image_index = floor(timer/5) + 25
	if timer >= 8*5 - 1{
		timer = 40
		image_alpha -= 0.1
	}
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

var base_depth = -10 - (zombie_grid.row * 45) - (zombie_grid.col * 5);
depth = base_depth ; // 僵尸比植物稍微靠后一点（在护罩外侧和咖啡豆之间）

// 保持网格位置更新

grid_col = zombie_grid.col;
grid_row = zombie_grid.row;