if global.is_paused{
	exit
}

if flash_value > 0 {
	flash_value -= 10
}

if !appear{
	image_angle = 0
	skill_group = skill_group_list[irandom_range(0,array_length(skill_group_list)-1)]
	//skill_group = array_shuffle(skill_group)
	var enemy_row = irandom_range(0,global.grid_rows-1)
	var enemy_pos = {}
	skill_choose = skill_group[skill_count]
	skill_count ++
	skill_change_style = irandom_range(0,1)
	if skill_choose == 0{
		enemy_row = 1
		enemy_pos = get_world_position_from_grid(9,enemy_row)
	}
	else if skill_choose == 1{
		enemy_row = 1
		enemy_pos = get_world_position_from_grid(9,enemy_row)
	}
	else if skill_choose == 2{
		enemy_row = 0
		enemy_pos = get_world_position_from_grid(11,enemy_row)
	}
	else if skill_choose == 3{
		enemy_row = global.grid_rows-1
		enemy_pos = get_world_position_from_grid(11,enemy_row)
	}
	x = enemy_pos.x - 90
	y = enemy_pos.y + 30
	
	move_time = 250
	wait_time = 120
	if skill_choose == 0{
		move_time = 250
		x += 20
	}
	else if skill_choose == 1{
		move_time = 250
		x += 20
	}
	else if skill_choose == 2{
		move_time = 75
		wait_time = 0
	}
	else if skill_choose == 3{
		move_time = 75
	}
	
	image_alpha = 1
	timer = 0
	state = BOSS_STATE.APPEAR
	appear = true
}

// 死亡处理
if (hp <= 0 && state != BOSS_STATE.DEATH) {
	global.save_data.player.gold += 2000
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
		sprite_index = spr_mouse_train_2_head_idle
		if hp > maxhp * hurt_rate{
			image_index = floor(timer/5) mod 2
		}
		else{
			image_index = floor(timer/5) mod 2 + 2
		}
		if timer >= wait_time{
			timer = 0
			if skill_choose == 0 {
				state = BOSS_STATE.SKILL1
			}
			else if skill_choose == 1{
				state = BOSS_STATE.SKILL2
			}
			else if skill_choose == 2{
				state = BOSS_STATE.SKILL3
			}
			else if skill_choose == 3{
				state = BOSS_STATE.SKILL4
			}
		}
		break
		
	case BOSS_STATE.APPEAR:
		if timer <= 5 * 9 - 1{
			if train_dir == 0{
				sprite_index = spr_mouse_train_2_head_appear1
			}
			else{
				sprite_index = spr_mouse_train_2_head_appear2
			}
			if hp > maxhp * hurt_rate{
				image_index = floor(timer/5) mod 9
			}
			else{
				image_index = floor(timer/5) mod 9 + 9
			}
		}
		else{
			sprite_index = spr_mouse_train_2_head_idle
			if is_reversed{
				image_xscale = -1.8
			}
			if hp > maxhp * hurt_rate{
				image_index = floor(timer/5) mod 2
			}
			else{
				image_index = floor(timer/5) mod 2 + 2
			}
		}
		
		if train_dir == 0{
			x -= 4
		}
		else{
			x += 4
		}
		if skill_choose == 0{
			if timer mod 45 == 44 && jump_times < 4{
				if !is_reversed{
					create_train_body_order(1,0,move_time-45*(jump_times+1))
				}
				else{
					create_train_body_pos(1,1,x-210*(jump_times+1),y,move_time-45*(jump_times+1))
				}
				jump_times++
			}
		}
		else if skill_choose == 1{
			if timer mod 45 == 44 && jump_times < 4{
				if !is_reversed{
					create_train_body_order(1,0,move_time-45*(jump_times+1))
				}
				else{
					create_train_body_pos(1,1,x-210*(jump_times+1),y,move_time-45*(jump_times+1))
				}
				jump_times++
			}
		}
		else if skill_choose == 2{
			if timer mod 45 == 44 && jump_times < 4{
				create_train_body_order(1,0,240)
				jump_times++
			}
		}
		else if skill_choose == 3{
			if timer == 44{
				create_train_body_order(1,0,move_time-45*(jump_times+1))
			}
		}
		
		if timer == move_time{
			if skill_choose == 0 && !is_reversed{
				timer = 0
				move_time = 250
				var enemy_pos = get_world_position_from_grid(0,5)
				x = enemy_pos.x - 90 + 40
				y = enemy_pos.y + 30
				is_reversed = true
				train_dir = 1
				jump_times = 0
			}
			else if skill_choose == 1 && !is_reversed{
				timer = 0
				move_time = 250
				var enemy_pos = get_world_position_from_grid(0,5)
				x = enemy_pos.x - 90 + 40
				y = enemy_pos.y + 30
				is_reversed = true
				train_dir = 1
				jump_times = 0
			}
			else{
				skill_2_times = 0
				is_reversed = false
				timer = 0
				state = BOSS_STATE.IDLE
				jump_times = 0
			}
		}
		break
	
	case BOSS_STATE.SKILL1:
		sprite_index = spr_mouse_train_2_head_idle
		if hp > maxhp * hurt_rate{
			image_index = floor(timer/5) mod 2
		}
		else{
			image_index = floor(timer/5) mod 2 + 2
		}
		if timer == 1{
			with obj_mouse_train_3_body{
				state = BOSS_STATE.SKILL1
				timer = 1
			}
		}
		
		if timer == 14 * 5 + 2{
			for(var i = 0 ; i < 4 ; i++){
				for(var j = 0 ; j < 4 ; j++){
					var mouse_pos1 = get_world_position_from_grid(1+i*2,j*2)
					var inst1 = instance_create_depth(mouse_pos1.x,mouse_pos1.y+38,-800,obj_machine_iron_pan_mouse)
					inst1.grid_row = j*2
				}
			}
		}
		
		if timer >= 27*5 -1{
			//skill_1_damage = [0,0,0,0,0,0,0,0]
			move_time = 50
			jump_times = 0
			timer = 0
			state = BOSS_STATE.DISAPPEAR
			disappear_time = 300
		}
		break
	
		
	case BOSS_STATE.SKILL2:
		
		sprite_index = spr_mouse_train_2_head_idle
		if hp > maxhp * hurt_rate{
			image_index = floor(timer/5) mod 2
		}
		else{
			image_index = floor(timer/5) mod 2 + 2
		}
		
		if timer == 1{
			with obj_mouse_train_3_body{
				state = BOSS_STATE.SKILL2
				timer = 1
			}
		}
		
		if timer == 1{
			var mouse_pos1 = get_world_position_from_grid(2,1)
			var inst1 = instance_create_depth(mouse_pos1.x,mouse_pos1.y+38,-800,obj_mouse_train_3_explode)
			inst1.grid_row = 1
			var mouse_pos2 = get_world_position_from_grid(6,1)
			var inst2 = instance_create_depth(mouse_pos2.x,mouse_pos2.y+38,-800,obj_mouse_train_3_explode)
			inst2.grid_row = 1
			var mouse_pos3 = get_world_position_from_grid(2,5)
			var inst3 = instance_create_depth(mouse_pos3.x,mouse_pos3.y+38,-800,obj_mouse_train_3_explode)
			inst3.grid_row = 5
			var mouse_pos4 = get_world_position_from_grid(6,5)
			var inst4 = instance_create_depth(mouse_pos4.x,mouse_pos4.y+38,-800,obj_mouse_train_3_explode)
			inst4.grid_row = 5
			
			inst1.maxhp *= (1 + ((maxhp-200000)/200000)*0.5)
			inst1.hp = inst1.maxhp
			inst2.maxhp *= (1 + ((maxhp-200000)/200000)*0.5)
			inst2.hp = inst2.maxhp
			inst3.maxhp *= (1 + ((maxhp-200000)/200000)*0.5)
			inst3.hp = inst3.maxhp
			inst4.maxhp *= (1 + ((maxhp-200000)/200000)*0.5)
			inst4.hp = inst4.maxhp
		}
		
		if timer >= 10{
			move_time = 50
			jump_times = 0
			timer = 0
			state = BOSS_STATE.DISAPPEAR
			disappear_time = 300
		}
		break
		
	case BOSS_STATE.SKILL3:
		
		skill_timer ++
		
		if skill_timer <= 240{
			if train_dir == 0{
				image_xscale = 1.8
			}
			else{
				image_xscale = -1.8
			}
			sprite_index = spr_mouse_train_2_head_idle
			if hp > maxhp * hurt_rate{
				image_index = floor(skill_timer/5) mod 2
			}
			else{
				image_index = floor(skill_timer/5) mod 2 + 2
			}
		}
		else if skill_timer <= 240 + 9 * 5 - 1{
			image_xscale = 1.8
			if train_dir == 0{
				sprite_index = spr_mouse_train_2_head_disappear1
			}
			else{
				sprite_index = spr_mouse_train_2_head_disappear2
			}
			if hp > maxhp * hurt_rate{
				image_index = floor((skill_timer-240)/5) mod 9
			}
			else{
				image_index = floor((skill_timer-240)/5) mod 9 + 9
			}
		}
		else if skill_timer <= 240 + 18 * 5 - 1{
			if train_dir == 0{
				sprite_index = spr_mouse_train_2_head_appear1
			}
			else{
				sprite_index = spr_mouse_train_2_head_appear2
			}
			if hp > maxhp * hurt_rate{
				image_index = floor((skill_timer-285)/5) mod 9
			}
			else{
				image_index = floor((skill_timer-285)/5) mod 9 + 9
			}
		}
		if train_dir == 0{
			x -= 4
		}
		else{
			x += 4
		}
		
		if skill_timer mod 45 == 44 && t_amount < 4{
			if train_dir == 0{
				create_train_body_pos(1,0,x+210*(t_amount+1),y,240)
			}
			else{
				create_train_body_pos(1,1,x-210*(t_amount+1),y,240)
			}
			t_amount++
		}
		
		if timer == 1 && grid_row == 0{
			var mucus_pos = get_world_position_from_grid(8,0)
			var inst = instance_create_depth(mucus_pos.x,mucus_pos.y,0,obj_mouse_train_3_butter)
			inst.target_col = 8
			inst.target_row = 0
		}
		
		if array_get_index(skill_3_col,grid_col) == -1 && grid_col >= 1 && grid_col <= 8{
			var mucus_pos = get_world_position_from_grid(grid_col,grid_row)
			var inst = instance_create_depth(mucus_pos.x,mucus_pos.y,0,obj_mouse_train_3_butter)
			inst.target_col = grid_col
			inst.target_row = grid_row
			array_push(skill_3_col,grid_col)
		}
		
		if skill_timer == 240 + 9 * 5{
			if train_dir == 0{
				train_dir = 1
				var new_pos = get_world_position_from_grid(-2,jump_times*2)
				x = new_pos.x
				y = new_pos.y + 38
			}
			else{
				train_dir = 0
				var new_pos = get_world_position_from_grid(11,jump_times*2)
				x = new_pos.x
				y = new_pos.y + 38
			}
		}
		if skill_timer == 240{
			jump_times ++
		}
		if skill_timer == 240 + 18 * 5{
			skill_timer = 0
			t_amount = 0
			skill_3_col = []
		}
		
		if jump_times >= 4{
			skill_3_col = []
			skill_timer = 0
			move_time = 50
			jump_times = 0
			t_amount = 0
			timer = 0
			state = BOSS_STATE.DISAPPEAR
			disappear_time = 300
		}
		break
		
	case BOSS_STATE.SKILL4:
		skill_timer ++
		
		if skill_timer <= 120{
			if train_dir == 0{
				image_xscale = 1.8
			}
			else{
				image_xscale = -1.8
			}
			sprite_index = spr_mouse_train_3_head_skill_1
			if hp > maxhp * hurt_rate{
				image_index = floor(skill_timer/5) mod 8
			}
			else{
				image_index = floor(skill_timer/5) mod 8
			}
		}
		else if skill_timer <= 120 + 9 * 5 - 1{
			image_xscale = 1.8
			if train_dir == 0{
				sprite_index = spr_mouse_train_2_head_disappear1
			}
			else{
				sprite_index = spr_mouse_train_2_head_disappear2
			}
			if hp > maxhp * hurt_rate{
				image_index = floor((skill_timer-120)/5) mod 9
			}
			else{
				image_index = floor((skill_timer-120)/5) mod 9 + 9
			}
		}
		else if skill_timer <= 120 + 18 * 5 - 1{
			if train_dir == 0{
				sprite_index = spr_mouse_train_2_head_appear1
			}
			else{
				sprite_index = spr_mouse_train_2_head_appear2
			}
			if hp > maxhp * hurt_rate{
				image_index = floor((skill_timer-165)/5) mod 9
			}
			else{
				image_index = floor((skill_timer-165)/5) mod 9 + 9
			}
		}
		if train_dir == 0{
			x -= 8
		}
		else{
			x += 8
		}
		
		if skill_timer == 120 + 9 * 5{
			if train_dir == 0{
				train_dir = 1
				var new_pos = get_world_position_from_grid(-2,skill_4_erase_row[jump_times-1])
				x = new_pos.x
				y = new_pos.y + 38
			}
			else{
				train_dir = 0
				var new_pos = get_world_position_from_grid(11,skill_4_erase_row[jump_times-1])
				x = new_pos.x
				y = new_pos.y + 38
			}
		}
		if skill_timer == 120{
			jump_times ++
		}
		if skill_timer == 120 + 18 * 5{
			skill_timer = 0
		}
		
		
		if timer == 1{
			with obj_mouse_train_3_body{
				train_dir = 1
				state = BOSS_STATE.DISAPPEAR
				timer = 1
			}
			skill_4_erase_row[0] = 4 + (skill_turn mod 2)
			skill_4_erase_row[1] = 2 + (skill_turn mod 2)
			skill_4_erase_row[2] = 0 + (skill_turn mod 2)
		}
		
		if grid_col > 0{
			with obj_card_parent{
				if grid_col == other.grid_col && grid_row == other.grid_row &&
				plant_id != "player" && plant_type != "coffee" && !invincible && plant_id != "cotton_candy"{
					if hp >= max_hp{
						obj_task_manager.card_loss++
					}
					instance_destroy()
				}
			}
		}
		
		if jump_times >= 4{
			skill_timer = 0
			move_time = 50
			jump_times = 0
			timer = 0
			state = BOSS_STATE.DISAPPEAR
			disappear_time = 180
		}
		break
		
	case BOSS_STATE.DISAPPEAR:
		if timer <= move_time - 9 * 5{
			sprite_index = spr_mouse_train_2_head_idle
			if hp > maxhp * hurt_rate{
				image_index = floor(timer/5) mod 2
			}
			else{
				image_index = floor(timer/5) mod 2 + 2
			}
		}
		else{
			image_xscale = 1.8
			if train_dir == 0{
				sprite_index = spr_mouse_train_2_head_disappear1
			}
			else{
				sprite_index = spr_mouse_train_2_head_disappear2
			}
			if hp > maxhp * hurt_rate{
				image_index = floor((timer+5*9-move_time)/5) mod 9
			}
			else{
				image_index = floor((timer+5*9-move_time)/5) mod 9 + 9
			}
		}
		
		if train_dir == 0{
			x -= 4
		}
		else{
			x += 4
		}
		
		if timer == move_time{
			image_alpha = 0
			train_dir = 0
		}
		if timer == move_time+disappear_time{
			clear_train_body()
			image_angle = 0
			if skill_count >= array_length(skill_group){
				skill_group = skill_group_list[irandom_range(0,array_length(skill_group_list)-1)]
				//skill_group = array_shuffle(skill_group)
				skill_count = 0
				skill_turn ++
			}
			var enemy_row = irandom_range(0,global.grid_rows-1)
			var enemy_pos = {}
			skill_choose = skill_group[skill_count]
			skill_count ++
			skill_change_style = irandom_range(0,1)
			if skill_choose == 0{
				enemy_row = 1
				enemy_pos = get_world_position_from_grid(9,enemy_row)
			}
			else if skill_choose == 1{
				enemy_row = 1
				enemy_pos = get_world_position_from_grid(9,enemy_row)
			}
			else if skill_choose == 2{
				enemy_row = 0
				enemy_pos = get_world_position_from_grid(11,enemy_row)
			}
			else if skill_choose == 3{
				enemy_row = global.grid_rows-1
				enemy_pos = get_world_position_from_grid(11,enemy_row)
			}
			x = enemy_pos.x - 90
			y = enemy_pos.y + 30
			
			move_time = 250
			wait_time = 120
			if skill_choose == 0{
				move_time = 250
				x += 20
			}
			else if skill_choose == 1{
				move_time = 250
				x += 20
			}
			else if skill_choose == 2{
				move_time = 75
				wait_time = 0
			}
			else if skill_choose == 3{
				move_time = 75
			}
			
			image_alpha = 1
			timer = 0
			state = BOSS_STATE.APPEAR
			break
		}
		break
	
	case BOSS_STATE.DEATH:
		sprite_index = spr_mouse_train_2_head_death
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

var base_depth = -400
depth = base_depth - 4.5; // 僵尸比植物稍微靠后一点（在护罩外侧和咖啡豆之间）

// 保持网格位置更新

grid_col = zombie_grid.col;
grid_row = zombie_grid.row;

