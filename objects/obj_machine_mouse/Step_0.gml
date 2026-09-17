// Inherit the parent event

if hp > maxhp - helmet_hp{
	sprite_index = spr_machine_mouse
}
else{
	sprite_index = spr_machine_mouse
}

event_inherited();
if global.is_paused or is_frozen{
	exit
}
if state == ENEMY_STATE.ATTACK && not acted{
	state = ENEMY_STATE.ACTING
	timer = 0
	acted = true
}
if state == ENEMY_STATE.ACTING{
	if hp > maxhp * hurt_rate{
		image_index = floor(timer/flash_speed) mod 4 + move_anim * 2
	}
	else{
		image_index = floor(timer/flash_speed) mod 4 + 3 + move_anim * 2
	}
	if timer >= 60{
		can_explode = true
		instance_destroy()
	}
	if hp <= 0{
		state = ENEMY_STATE.NORMAL
	}
}