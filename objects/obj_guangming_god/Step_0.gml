if global.is_paused{
	exit
}
event_inherited();
if is_frozen{
	exit
}
var current_flash_speed = flash_speed
if is_slowdown{
	current_flash_speed *= 2
}

var has_enemy = true

// 攻击逻辑
if state != CARD_STATE.SLEEP && state != CARD_STATE.AWAKE{
	if (has_enemy) {
	    if (attack_timer <= cycle - attack_anim * current_flash_speed) {
	        attack_timer++;
	    } else if (attack_timer < cycle) {
	        attack_timer++;
	        state = CARD_STATE.ATTACK;
	    } else {
	        attack_timer = 0;
	        state = CARD_STATE.IDLE;
	    }
		if (attack_timer == cycle - 8 * current_flash_speed && state == CARD_STATE.ATTACK){
			event_user(1)
	    }
	} else {
	    attack_timer = 0;
	    state = CARD_STATE.IDLE;
	}
}
if explode_cooldown > 0 {
    explode_cooldown--;
}
