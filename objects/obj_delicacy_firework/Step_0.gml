if global.is_paused{
	exit
}
event_inherited(); 
var current_flash_speed = flash_speed
if is_slowdown{
	current_flash_speed *= 2
}



//攻击逻辑
if (attack_timer <= idle_anim * current_flash_speed - 1){
	attack_timer++;
}
if (attack_timer == idle_anim * current_flash_speed - 1){
	event_user(1); // 发射子弹
}


