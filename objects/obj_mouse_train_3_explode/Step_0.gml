if global.is_paused{
	exit
}

var grid_pos = get_grid_position_from_world(x,y)

if flash_value > 0{
	flash_value -= 10
}

timer++

if hp <= 0 && state != "death"{
	state = "death"
	timer = 0
}

if state == "appear"{
	image_index = floor(timer/5) mod 68
	if timer >= 68*5 - 1{
		var inst = instance_create_depth(x,y,-800,obj_coke_bomb_explode)
		inst.sprite_index = spr_mouse_train_3_body_skill_3_effect
		
		with obj_card_parent{
			if abs(grid_col - other.grid_col) <= 1 && abs(grid_row - other.grid_row) <= 1 &&
			plant_id != "player" && plant_type != "coffee" && !invincible && plant_id != "cotton_candy"{
				if hp >= max_hp{
					obj_task_manager.card_loss++
				}
				instance_destroy()
			}
		}
		
		instance_destroy()
	}
}
else if state == "death"{
	sprite_index = spr_mouse_train_3_body_skill_3_death
	image_index = floor(timer/5) mod 18
	if timer >= 18*5 - 1{
		instance_destroy()
	}
}


var zombie_grid = get_grid_position_from_world(x, y);

// 更新僵尸的网格位置和深度

var base_depth = -410
depth = base_depth ; // 僵尸比植物稍微靠后一点（在护罩外侧和咖啡豆之间）

// 保持网格位置更新

grid_col = zombie_grid.col;
grid_row = zombie_grid.row;