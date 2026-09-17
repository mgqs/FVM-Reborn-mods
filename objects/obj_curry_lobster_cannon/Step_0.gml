if global.is_paused{
	exit
}
var current_flash_speed = flash_speed
if is_slowdown{
	current_flash_speed *= 2
}

event_inherited(); 

if shape < 1{
	drown_timer ++
	if drown_timer mod 60 == 0{
		//0转检测是否有气泡和海水
		var has_bubble = false
		var has_seawater = false
		with obj_card_parent{
			if plant_id == "soda_bubble" && grid_col == other.grid_col && grid_row == other.grid_row{
				has_bubble = true
			}
		}
		with obj_seawater{
			if col == other.grid_col && row == other.grid_row{
				has_seawater = true
			}
		}
		if !has_bubble && !has_seawater{
			hp -= 0.05*max_hp
			event_user(2)
		}
	}
}

if is_frozen || state == CARD_STATE.SLEEP{
	exit
}
//检测屏幕上是否有敌人
var has_enemy = false
if instance_exists(obj_enemy_parent){
	with obj_enemy_parent{
		if can_target_on(other.target_type,target_type) && y > 0 && hp > 0{
			has_enemy = true
		}
	}
}
//攻击逻辑
if (has_enemy) {
    if (attack_timer <= cycle - attack_anim * current_flash_speed) {
        attack_timer++;
    } else if (attack_timer <= cycle) {
        attack_timer++;
        state = CARD_STATE.ATTACK;
    } else {
		if shape == 2{
			event_user(1)
		}
        attack_timer = 0;
        state = CARD_STATE.IDLE;
    }
	if (attack_timer == cycle - 6*flash_speed){
		event_user(1);
	}
	if (attack_timer == cycle - 3*flash_speed){
		event_user(1);
	}
} else {
    // 没有符合条件的敌人，重置状态
    attack_timer = 0;
    state = CARD_STATE.IDLE;
}

