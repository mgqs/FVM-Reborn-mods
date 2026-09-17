if global.is_paused{
	exit
}

if flash_value > 0 {
	flash_value -= 10
}

if !appear{
	var enemy_row = irandom_range(0,global.grid_rows-1)
	var enemy_pos = {}
	enemy_pos = get_world_position_from_grid(9,3)
	x = enemy_pos.x - 90
	y = enemy_pos.y + 30
	image_alpha = 1
	timer = 0
	state = BOSS_STATE.APPEAR
	appear = true
}

// 死亡处理
if (hp <= 0 && state != BOSS_STATE.DEATH) {
	global.save_data.player.gold += 1000
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
		sprite_index = spr_machine_shark_1_idle
		if hp > maxhp * hurt_rate{
			image_index = floor(timer/5) mod 14
		}
		else{
			image_index = floor(timer/5) mod 14 + 14
		}
		if timer >= wait_time{
			timer = 0
			
			state = BOSS_STATE.DISAPPEAR
		}
		break
		
	case BOSS_STATE.APPEAR:
		sprite_index = spr_machine_shark_1_appear
		if hp > maxhp * hurt_rate{
			image_index = floor(timer/5) mod 6
		}
		else{
			image_index = floor(timer/5) mod 6 + 6
		}
		if timer == 6 * 5 - 1{
			timer = 0
			if skill_count == 0 || skill_count == 2{
				state = BOSS_STATE.SKILL1
			}
			else if skill_count == 1{
				state = BOSS_STATE.SKILL2
			}
			else if skill_count == 3{
				state = BOSS_STATE.SKILL3
			}
			skill_count ++
			if skill_count >= 4{
				skill_count = 0
			}
			break
		}
		break
	
	case BOSS_STATE.SKILL1:
		sprite_index = spr_machine_shark_2_skill_1
		if hp > maxhp * hurt_rate{
			image_index = floor(timer/5) mod 30
		}
		else{
			image_index = floor(timer/5) mod 30 + 30
		}
		if timer == 23 * 5 + 2{
			for(var i = 0 ; i < global.grid_rows ; i++){
				var m_pos = get_world_position_from_grid(9,i)
				var m_inst = instance_create_depth(m_pos.x,m_pos.y+38,-800,obj_undersea_panda_mouse)
				m_inst.grid_row = i
			}
		}
		if timer >= 30 * 5 - 1{
			jump_times = 0
			timer = 0
			state = BOSS_STATE.IDLE
		}
		break
		
	case BOSS_STATE.SKILL2:
		sprite_index = spr_machine_shark_2_skill_2
		if hp > maxhp * hurt_rate{
			image_index = floor(timer /5) mod 17
		}
		else{
			image_index = floor(timer /5) mod 17 + 17
		}
		
		if timer == 15 * 5 + 2{
			var wind_inst1 = instance_create_depth(x,y,-800,obj_machine_shark_2_wind)
			var wind_pos1 = get_world_position_from_grid(4,0)
			wind_inst1.x_move_speed = (wind_pos1.x-wind_inst1.x)/ 60
			wind_inst1.y_move_speed = (wind_pos1.y+10-wind_inst1.y)/ 60
			var wind_inst2 = instance_create_depth(x,y,-800,obj_machine_shark_2_wind)
			var wind_pos2 = get_world_position_from_grid(4,global.grid_rows-1)
			wind_inst2.x_move_speed = (wind_pos2.x-wind_inst2.x)/ 60
			wind_inst2.y_move_speed = (wind_pos2.y+10-wind_inst2.y)/ 60
		}
		
		if timer >= 17 * 5 - 1{
			jump_times = 0
			timer = 0
			state = BOSS_STATE.IDLE
			target_coord = []
		}
		break
		
	case BOSS_STATE.SKILL3:
		
		if timer <= 18 * 5 - 1{
			sprite_index = spr_machine_shark_1_skill_3_ready
			if hp > maxhp * hurt_rate{
				image_index = floor(timer /5) mod 18
			}
			else{
				image_index = floor(timer /5) mod 18 + 18
			}
		}
		else if timer <= 70 + 18 * 5 - 1{
			sprite_index = spr_machine_shark_1_skill_3
			if hp > maxhp * hurt_rate{
				image_index = floor((timer-90) /5) mod 8
			}
			else{
				image_index = floor((timer-90) /5) mod 8 + 8
			}
			x -= 15
		}
		else if timer <= 70 + 24 * 5 - 1{
			sprite_index = spr_machine_shark_1_disappear
			if hp > maxhp * hurt_rate{
				image_index = floor((timer-160) /5) mod 6
			}
			else{
				image_index = floor((timer-160) /5) mod 6 + 6
			}
		}
		else if timer <= 70 + 30 * 5 - 1{
			image_xscale = -1.8
			sprite_index = spr_machine_shark_1_appear
			if hp > maxhp * hurt_rate{
				image_index = floor((timer-190) /5) mod 6
			}
			else{
				image_index = floor((timer-190) /5) mod 6 + 6
			}
		}
		else if timer <= 140 + 30 * 5 - 1{
			sprite_index = spr_machine_shark_1_skill_3
			if hp > maxhp * hurt_rate{
				image_index = floor((timer-220) /5) mod 8
			}
			else{
				image_index = floor((timer-220) /5) mod 8 + 8
			}
			x += 15
		}
		else if timer <= 140 + 36 * 5 - 1{
			sprite_index = spr_machine_shark_1_disappear
			if hp > maxhp * hurt_rate{
				image_index = floor((timer-290) /5) mod 6
			}
			else{
				image_index = floor((timer-290) /5) mod 6 + 6
			}
		}
		else if timer <= 140 + 42 * 5 - 1{
			image_xscale = 1.8
			sprite_index = spr_machine_shark_1_appear
			if hp > maxhp * hurt_rate{
				image_index = floor((timer-320) /5) mod 6
			}
			else{
				image_index = floor((timer-320) /5) mod 6 + 6
			}
		}
		else if timer <= 210 + 42 * 5 - 1{
			sprite_index = spr_machine_shark_1_skill_3
			if hp > maxhp * hurt_rate{
				image_index = floor((timer-350) /5) mod 8
			}
			else{
				image_index = floor((timer-350) /5) mod 8 + 8
			}
			x -= 15
		}
		else if timer <= 210 + 54 * 5 - 1{
			sprite_index = spr_machine_shark_1_skill_3_return
			if hp > maxhp * hurt_rate{
				image_index = floor((timer-420) /5) mod 12
			}
			else{
				image_index = floor((timer-420) /5) mod 12 + 12
			}
		}
		
		if timer == 70 + 24 * 5{
			var new_pos = get_world_position_from_grid(0,skill_3_row[1])
			y = new_pos.y + 30
		}
		if timer == 140 + 36 * 5{
			var new_pos = get_world_position_from_grid(0,skill_3_row[2])
			y = new_pos.y + 30
		}
		if (timer >=18 * 5 && timer <= 70 + 18 * 5) || (timer >=70 + 30 * 5 && timer <= 140 + 30 * 5) || (timer >=140 + 42 * 5 && timer <= 210 + 42 * 5){
			with obj_card_parent{
				if grid_col == other.grid_col && grid_row == other.grid_row && plant_id != "player" && plant_type != "coffee" && plant_id != "soda_bubble" && !invincible{
					instance_destroy()
					if hp >= max_hp{
						obj_task_manager.card_loss++
					}
				}
			}
		}
		
		if timer >= 210+54*5-1{
			image_xscale = 1.8
			jump_times = 0
			timer = 0
			state = BOSS_STATE.DISAPPEAR
		}
		break
		
	case BOSS_STATE.DISAPPEAR:
		sprite_index = spr_machine_shark_1_disappear
		if hp > maxhp * hurt_rate{
			image_index = floor(timer/5) mod 6
		}
		else{
			image_index = floor(timer/5) mod 6 + 6
		}
		if timer == 6 * 5 - 1{
			image_alpha = 0
		}
		if timer == 180{
			var enemy_row = irandom_range(0,global.grid_rows-1)
			var enemy_pos = {}
			if skill_count == 1{
				enemy_pos = get_world_position_from_grid(1,3)
			}
			else if skill_count == 3{
				skill_3_row = []
				skill_3_row[0] = global.grid_rows-1
				skill_3_row[1] = 3
				skill_3_row[2] = 0
				enemy_pos = get_world_position_from_grid(9,skill_3_row[0])
			}
			else if skill_count == 0 || skill_count == 2{
				enemy_pos = get_world_position_from_grid(9,3)
			}
			x = enemy_pos.x - 90
			y = enemy_pos.y + 30
			if skill_count == 1{
				image_xscale = -1.8
			}
			else{
				image_xscale = 1.8
			}
			image_alpha = 1
			timer = 0
			state = BOSS_STATE.APPEAR
			break
		}
		break
	
	case BOSS_STATE.DEATH:
		sprite_index = spr_machine_shark_1_death
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

var base_depth = -10 - (zombie_grid.row * 45) - 45
depth = base_depth - 4.5; // 僵尸比植物稍微靠后一点（在护罩外侧和咖啡豆之间）

// 保持网格位置更新

grid_col = zombie_grid.col;
grid_row = zombie_grid.row;

