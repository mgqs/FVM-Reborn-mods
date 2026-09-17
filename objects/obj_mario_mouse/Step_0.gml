if global.is_paused{
	exit
}

if flash_value > 0 {
	flash_value -= 10
}

// 死亡处理
if (hp <= 0 && state != BOSS_STATE.DEATH) {
	global.save_data.player.gold += 500
    timer = 0;
    state = BOSS_STATE.DEATH;
    target_plant = noone;  // 清除攻击目标
	with obj_battle{
		if boss_count <= 1 && current_wave >= total_wave - 1{
			timer_pause = true
		}
	}
}

switch state{
	case BOSS_STATE.IDLE:
		sprite_index = spr_mario_mouse_idle
		if hp > maxhp * hurt_rate{
			image_index = floor(timer/5) mod 8
		}
		else{
			image_index = floor(timer/5) mod 8 + 8
		}
		if timer >= wait_time{
			timer = 0
			var i = irandom_range(1,100)
			if i <= 50{
				state = BOSS_STATE.SKILL1
			}
			else{
				state = BOSS_STATE.SKILL2
			}
		}
		break
		
	case BOSS_STATE.APPEAR:
		sprite_index = spr_mario_mouse_appear
		if hp > maxhp * hurt_rate{
			image_index = floor(timer/5) mod 13
		}
		else{
			image_index = floor(timer/5) mod 13 + 13
		}
		if timer == 13 * 5 - 1{
			timer = 0
			state = BOSS_STATE.IDLE
			break
		}
		break
	
	case BOSS_STATE.SKILL1:
		sprite_index = spr_mario_mouse_skill_1
		if hp > maxhp * hurt_rate{
			image_index = floor(timer/5) mod 8
		}
		else{
			image_index = floor(timer/5) mod 8 + 8
		}
		if timer == 3*60{
			var cave_pos = get_world_position_from_grid(8,grid_row)
			var erase_col = 8
			var erase_row = grid_row
			with obj_card_parent{
				if(grid_col == erase_col && grid_row == erase_row && plant_id != "player"){
					if hp >= max_hp{
						obj_task_manager.card_loss++
					}
					instance_destroy()
				}
			}
			cave = instance_create_depth(cave_pos.x+8,cave_pos.y+15,depth,obj_mario_cave)
			pipe_row = global.row_feature[cave_pos.row]
		}
		if timer == 4 * 60{
			var pipeline_col = irandom_range(3,6)
			var pipeline_row = irandom_range(0,global.grid_rows - 1)
			for(var i = 0 ; i < 100 ; i++){
				pipeline_row = irandom_range(0,global.grid_rows - 1)
				if global.row_feature[pipeline_row] == pipe_row break
			}
			var pipeline_pos = get_world_position_from_grid(pipeline_col,pipeline_row)
			var erase_col = pipeline_col
			var erase_row = pipeline_row
			with obj_card_parent{
				if(grid_col == erase_col && grid_row == erase_row && plant_id != "player"){
					if hp >= max_hp{
						obj_task_manager.card_loss++
					}
					instance_destroy()
				}
			}
			pipeline = instance_create_depth(pipeline_pos.x+8,pipeline_pos.y+15,depth,obj_mario_pipeline)
			cave.banding_pipeline_obj = pipeline
			pipeline.banding_cave_obj = cave
		}
		if timer >= 5*60{
			timer = 0
			state = BOSS_STATE.DISAPPEAR
		}
		break
		
	case BOSS_STATE.SKILL2:
		sprite_index = spr_mario_mouse_skill_2
		if hp > maxhp * hurt_rate{
			image_index = floor(timer/5) mod 14
		}
		else{
			image_index = floor(timer/5) mod 14 + 14
		}
		if timer >= 4 * 5 + 70* jump_times && timer <= 10 * 5 + 70 * jump_times{
			if jump_times == 0{
				x -= 7.6
			}
			else{
				x -= global.grid_cell_size_x * 2 / 30
			}
		}
		if timer == 10 * 5 + 70 * jump_times + 1{
			jump_times++
			var erase_col = 9-jump_times*2
			var erase_row = grid_row
			with obj_card_parent{
				if(grid_col == erase_col && grid_row == erase_row && plant_id != "player"){
					if hp >= max_hp{
						obj_task_manager.card_loss++
					}
					instance_destroy()
				}
			}
		}
		if jump_times >= 3{
			jump_times = 0
			timer = 0
			state = BOSS_STATE.DISAPPEAR
		}
		break
		
	case BOSS_STATE.DISAPPEAR:
		sprite_index = spr_mario_mouse_dig_down
		if hp > maxhp * hurt_rate{
			image_index = floor(timer/5) mod 18
		}
		else{
			image_index = floor(timer/5) mod 18 + 18
		}
		if timer == 18 * 5 - 1{
			image_alpha = 0
		}
		if timer == 210{
			var enemy_row = irandom_range(0,global.grid_rows-1)
			var enemy_pos = get_world_position_from_grid(10,enemy_row)
			x = enemy_pos.x - 80
			y = enemy_pos.y + 30
			image_alpha = 1
			timer = 0
			state = BOSS_STATE.APPEAR
			break
		}
		break
	
	case BOSS_STATE.DEATH:
		sprite_index = spr_mario_mouse_death
		image_index = floor(timer/5) mod image_number
		if timer >= image_number * 5{
			image_alpha -= 0.1
			image_index = image_number - 1
		}
		break
}


timer ++

// 透明度处理
if (image_alpha <= 0 && state == BOSS_STATE.DEATH) {
    instance_destroy();
}


var zombie_grid = get_grid_position_from_world(x, y);

// 更新僵尸的网格位置和深度

var base_depth = -10 - (zombie_grid.row * 45) - (zombie_grid.col * 5);
depth = base_depth - 4.5; // 僵尸比植物稍微靠后一点（在护罩外侧和咖啡豆之间）

// 保持网格位置更新

grid_col = zombie_grid.col;
grid_row = zombie_grid.row;

