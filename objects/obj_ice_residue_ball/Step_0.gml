if global.is_paused{
	exit
}

var grid_pos = get_grid_position_from_world(x,y)

if flash_value > 0{
	flash_value -= 10
}

timer++

if state == "appear"{
	image_index = floor(timer/5) mod 8
	if timer >= 8*5 - 1{
		timer = 0
		state = "anim"
	}
}
else if state == "anim"{
	if hp > hurt_rate * maxhp{
		image_index = floor(timer/5) mod 70 + 8
	}
	else{
		image_index = floor(timer/5) mod 69 + 78
	}
	//image_angle += 2
	x -= 0.3
}
else if state == "death"{
	image_index = floor(timer/5) + 147
	if timer >= 13*5 - 2{
		timer = 62
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

with (obj_card_parent) {
	var dx = x - other.x;
	var dy = y - other.y;
	var is_in_front = false
	if other.attack_range > 0{
		is_in_front = (dx < 0 && dx > -other.attack_range);
	}
	else{
		is_in_front = (dx > 0 && dx < -other.attack_range);
	}
				
    // 检查是否在攻击范围内
    if (is_in_front && zombie_grid.row == grid_row && !invincible && plant_type != "coffee") {
		if plant_id != "player"{
			if hp >= max_hp{
				obj_task_manager.card_loss++
			}
	        instance_destroy()
		}
		else{
			hp = 10
			event_user(2)
		}
    }
}

// 更新僵尸的网格位置和深度

var base_depth = -10 - (zombie_grid.row * 45) - (zombie_grid.col * 5);
depth = base_depth ; // 僵尸比植物稍微靠后一点（在护罩外侧和咖啡豆之间）

// 保持网格位置更新

grid_col = zombie_grid.col;
grid_row = zombie_grid.row;