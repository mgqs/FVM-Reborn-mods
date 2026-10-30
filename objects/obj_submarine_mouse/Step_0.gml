// Inherit the parent event
if hp <= 0 && state != ENEMY_STATE.DEAD{
	timer = 0
	state = ENEMY_STATE.DEAD
	if (grid_col < 0 || grid_col >= global.grid_cols || grid_row < 0 || grid_row >= global.grid_rows){
		sprite_index = spr_submarine_mouse_land
		death_anim = 12
	}
	else{
		if global.grid_terrains[grid_row][grid_col].type == "water"{
			sprite_index = spr_submarine_mouse
			death_anim = 12
		}
		else{
			sprite_index = spr_submarine_mouse_land
			death_anim = 12
		}
	}
		
}
if (grid_col < 0 || grid_col >= global.grid_cols || grid_row < 0 || grid_row >= global.grid_rows) {
	sprite_index = spr_submarine_mouse_land
	death_anim = 12
}
else{
	// ⚠ 越障中（climb_stage == 1）不要判水陆切换：越障是父对象的 state 机在管（state 被设成 IDLE），
	//    这里再把它改成 ACTING 会同时播入水/出水动画 + 自己 `x -= move_speed`，跟越障抢控制权 → 抽动。
	if state != ENEMY_STATE.DEAD && climb_stage != 1{
		if global.grid_terrains[grid_row][grid_col].type == "water"{
			if sprite_index == spr_submarine_mouse_land{
				state = ENEMY_STATE.ACTING
				sprite_index = spr_submarine_mouse_enter
				timer = 0
				global.audio.play(snd_enter_water,0,0)
				reversed = false
			}
		
			death_anim = 12
		}
		else{
			if sprite_index == spr_submarine_mouse{
				state = ENEMY_STATE.ACTING
				sprite_index = spr_submarine_mouse_enter
				timer = 0
				global.audio.play(snd_enter_water,0,0)
				reversed = true
			}
		
			death_anim = 12
		}
	}
}

event_inherited();
if global.is_paused or is_frozen{
	exit
}
if state == ENEMY_STATE.ACTING{
	x -= move_speed
	if hp > maxhp * hurt_rate{
		if reversed{
			image_index = 8 - (floor(timer/flash_speed) mod 8)
		}
		else{
			image_index = floor(timer/flash_speed) mod 8
		}
	}
	else{
		if reversed{
			image_index = 8 - (floor(timer/flash_speed) mod 8) + 8
		}
		else{
			image_index = (floor(timer/flash_speed) mod 8) + 8
		}
	}
	if timer >= flash_speed * 8 - 1 or hp <= 0{
		state = ENEMY_STATE.NORMAL
		if reversed{
			sprite_index = spr_submarine_mouse_land
		}
		else{
			sprite_index = spr_submarine_mouse
		}
	}
}