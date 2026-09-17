// Inherit the parent event
if global.is_paused{
	exit
}

if hp <=0 && state != ENEMY_STATE.DEAD{
	state = ENEMY_STATE.DEAD
	timer = 0
}

if state == ENEMY_STATE.ATTACK{
	timer = 0
	state = ENEMY_STATE.ACTING
}

if state == ENEMY_STATE.ACTING{
	if instance_exists(target_plant){
		with target_plant{
			if plant_id != "player"{
				if !invincible{
					hp -= 2000
					event_user(2)
				}
			}
			else{
				hp = 10
				event_user(2)
			}
		}
	}
	image_index = floor(timer/5) mod 5 + 10
	if timer == 25-1{
		hp -= maxhp
	}
}

event_inherited();

