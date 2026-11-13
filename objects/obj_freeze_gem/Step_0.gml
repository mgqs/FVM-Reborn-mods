if global.is_paused{
	exit
}
if global.debug{
	cooldown_timer = 0
}
if cooldown_timer > 0{
	cooldown_timer--
	// 冷却读完的那一帧：在人物处闪一次（gem_cooldown_hint）
	if cooldown_timer <= 0 gem_cooldown_flash_create()
}