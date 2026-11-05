// Inherit the parent event
if global.is_paused{
	exit
}

if hp <=0 && state != ENEMY_STATE.DEAD{
	state = ENEMY_STATE.DEAD
	timer = 0
}

if state == ENEMY_STATE.DEAD{
	image_alpha -= 0.1
	if image_alpha <= 0{
		instance_destroy()
	}
}

if state == ENEMY_STATE.ATTACK && hp > 0{
	timer = 0
	state = ENEMY_STATE.ACTING
}

event_inherited();

// 灼热地域·杰克技能4召唤的火老鼠：到达第 0 列（最左一列）就烧尽消失。
// 它被召出在地图最右侧，若这一行没有卡片可啃会一路左移，
// 越过左边界会触发父类「老鼠跑掉」的失败判定，所以在进入第 0 列时直接收掉。
// 正在啃食（ACTING 且目标还活着）时不处理，保证它对第 0 列的卡片仍能造成伤害。
if (hp > 0 && grid_col <= 0 && !(state == ENEMY_STATE.ACTING && instance_exists(target_plant))){
	var _fx = instance_create_depth(x-15,y+15,-800,obj_wine_bottle_bomb_explode)
	_fx.interval = 0
	_fx.sprite_index = spr_julie_incendiary_bomb_effect
	_fx.max_time = 45
	_fx.is_parent = true
	_fx.row = grid_row
	_fx.col = grid_col
	instance_destroy()
}

if state == ENEMY_STATE.ACTING && hp > 0 && state != ENEMY_STATE.DEAD{
	if instance_exists(target_plant){
		with target_plant{
			if plant_id != "player"{
				if !invincible && plant_id != "cotton_candy"{
					hp -= 2000
					event_user(2)
				}
			}
			else{
				hp = 10
				event_user(2)
			}
			var effect = instance_create_depth(x-15,y+15,-800,obj_wine_bottle_bomb_explode)
			effect.interval = 0
			effect.sprite_index = spr_julie_incendiary_bomb_effect
			effect.max_time = 45
			effect.is_parent = true
			effect.row = grid_row
			effect.col = grid_col
		}
	}
	instance_destroy()
}

