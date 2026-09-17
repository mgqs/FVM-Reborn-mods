if global.is_paused{
	exit
}
event_inherited(); 
var current_flash_speed = flash_speed
if is_slowdown{
	current_flash_speed *= 2
}

explode_timer --

//攻击逻辑
if (explode_timer <= 0) {
	invincible = true
	if (attack_timer <= attack_anim * current_flash_speed - 1) {
	    attack_timer++;
		state = CARD_STATE.ATTACK;
	}
	if (attack_timer == attack_anim * current_flash_speed - 1){
	    event_user(1); // 发射子弹
	}
}
else{
	state = CARD_STATE.IDLE
	attack_timer = 0
}

