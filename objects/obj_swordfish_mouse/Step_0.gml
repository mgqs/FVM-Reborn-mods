if global.is_paused{
	exit
}
if hp <= 0 && state != ENEMY_STATE.DEAD{
	timer = 0
	sprite_index = spr_swordfish_mouse
	state = ENEMY_STATE.DEAD
}

// Inherit the parent event
event_inherited();
if is_frozen || is_stun || scare_timer > 0{
	exit
}

if hp > 0 && state != ENEMY_STATE.DEAD{
	if grid_col <= 8 && (state == ENEMY_STATE.NORMAL || state == ENEMY_STATE.ATTACK){
		timer = 0
		state = ENEMY_STATE.APPEAR
		sprite_index = spr_swordfish_mouse_ready
	}
	if state == ENEMY_STATE.APPEAR{
		
		if hp > maxhp * hurt_rate{
			image_index = floor(timer/flash_speed) mod 29
		}
		else{
			image_index = floor(timer/flash_speed) mod 29 + 29
		}
		if timer >= 29 * flash_speed - 1{
			timer = 0
			state = ENEMY_STATE.ACTING
			sprite_index = spr_swordfish_mouse_dash
		}
	}
	if state == ENEMY_STATE.ACTING{
		
		if hp > maxhp * hurt_rate{
			image_index = floor(timer/flash_speed) mod 12
		}
		else{
			image_index = floor(timer/flash_speed) mod 12 + 12
		}
		if is_slowdown{
			x -= 0.9
		}
		else{
			x -= 1.8
		}
		with obj_card_parent{
			if grid_col == other.grid_col && grid_row == other.grid_row &&
			plant_id != "player" && plant_type != "coffee" && !invincible && plant_id != "cotton_candy" && plant_id != "soda_bubble"{
				if array_get_index(other.block_list,plant_id)  == -1{
					if hp >= max_hp{
						obj_task_manager.card_loss++
					}
					instance_destroy()
				}
				else{
					hp -= 300
					event_user(2)
					other.timer = 0
					other.state = ENEMY_STATE.DIG
					sprite_index = spr_swordfish_mouse_stun
				}
			}
		}
	}
	if state == ENEMY_STATE.DIG{
		sprite_index = spr_swordfish_mouse_stun
		if hp > maxhp * hurt_rate{
			image_index = floor(timer/flash_speed) mod 30
		}
		else{
			image_index = floor(timer/flash_speed) mod 30 + 30
		}
		if timer >= 30 * flash_speed - 1{
			timer = 0
			state = ENEMY_STATE.NORMAL
			sprite_index = spr_swordfish_mouse
		}
	}
}