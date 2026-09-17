if global.is_paused{
	exit
}

var grid_pos = get_grid_position_from_world(x,y)
if global.grid_terrains[grid_pos.row][grid_pos.col].type == "water"{
	sprite_index = spr_mario_pipeline_water
}
else if global.grid_terrains[grid_pos.row][grid_pos.col].type == "normal"{
	sprite_index = spr_mario_pipeline_land
}

if global.grid_terrains[grid_pos.row][grid_pos.col].type != "obstacle"{
	current_grid_type = global.grid_terrains[grid_pos.row][grid_pos.col].type
	global.grid_terrains[grid_pos.row][grid_pos.col].type = "obstacle"
}

if flash_value > 0{
	flash_value -= 10
}

timer++

if state == "appear"{
	image_index = floor(timer/5)
	if timer >= 6*5{
		timer = 0
		state = "anim_wait"
	}
}
else if state == "anim_wait"{
	if timer >= anim_wait{
		timer = 0
		state = "anim"
	}
}
else if state == "anim"{
	image_index = floor(timer/5) + 5
	if timer >= 10*5{
		timer = 0
		state = "idle"
	}
}
else if state == "idle"{
	if hp > hurt_rate * maxhp{
		image_index = 16
	}
	else{
		image_index = 17
	}
}

if hp <= 0{
	image_alpha -= 0.1
}

if image_alpha <= 0 && hp <= 0{
	instance_destroy()
}


var zombie_grid = get_grid_position_from_world(x, y);

// 更新僵尸的网格位置和深度

var base_depth = -10 - (zombie_grid.row * 45) - (zombie_grid.col * 5);
depth = base_depth - 4.5; // 僵尸比植物稍微靠后一点（在护罩外侧和咖啡豆之间）

// 保持网格位置更新

grid_col = zombie_grid.col;
grid_row = zombie_grid.row;