if global.is_paused{
	exit
}
if hp <= 0 && state != ENEMY_STATE.DEAD{
	timer = 0
	sprite_index = spr_seahorse_mouse
	state = ENEMY_STATE.DEAD
}
// Inherit the parent event
event_inherited();

if is_scare || is_stun || is_frozen{
	exit
}
if hp > 0 && state != ENEMY_STATE.DEAD{
	if state == ENEMY_STATE.ATTACK{
		timer = 0
		state = ENEMY_STATE.ACTING
		sprite_index = spr_seahorse_mouse_jump
	}
	if state == ENEMY_STATE.ACTING{
		
		if hp > maxhp * hurt_rate{
			image_index = floor(timer/flash_speed) mod 28
		}
		else{
			image_index = floor(timer/flash_speed) mod 28 + 28
		}
		if timer >= 22 * flash_speed && timer <= 28 * flash_speed{
			if instance_exists(target_plant){
				if array_get_index(block_list,target_plant.plant_id) != -1{
					x -= 0
				}
				else{
					if is_slowdown{
						x -= 1.8
					}
					else{
						x -= 3.6
					}
				}
			}
			else{
				if is_slowdown{
					x -= 1.8
				}
				else{
					x -= 3.6
				}
			}
		}
		if timer >= 28 * flash_speed - 1{
			timer = 0
			state = ENEMY_STATE.NORMAL
			sprite_index = spr_seahorse_mouse
		}
	}
}