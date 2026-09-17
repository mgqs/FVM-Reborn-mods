if global.is_paused{
	exit
}
event_inherited();
// 生产逻辑
var current_flash_speed = flash_speed
if is_slowdown{
	current_flash_speed *= 2
}
if (first_produce == 0) {
    if (attack_timer <= first_produce_delay) {
        attack_timer++;
    } else if (attack_timer <= first_produce_delay + attack_anim * current_flash_speed) {
        attack_timer++;
        state = CARD_STATE.ATTACK;
    } 
	if (attack_timer == first_produce_delay + attack_anim * current_flash_speed - 1){
		instance_destroy()
	}
	if (attack_timer == first_produce_delay + 6 * current_flash_speed )
	||(attack_timer == first_produce_delay + 10 * current_flash_speed )
	||(attack_timer == first_produce_delay + 14 * current_flash_speed )
	{
		event_user(1)
	}
} else {
    if (attack_timer <= cycle - attack_anim * current_flash_speed) {
        attack_timer++;
    } else if (attack_timer <= cycle) {
        attack_timer++;
        state = CARD_STATE.ATTACK;
    } else {
        // 生产火苗（调用子类特定方法）
        event_user(1);  // 用户事件1用于生产
        
        attack_timer = 0;
        state = CARD_STATE.IDLE;
    }
}


