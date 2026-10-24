// obj_ronghedapao（融合巧克力炮）Step 事件
// 与原版 obj_chocolate_cannon 同构：只负责计时、切状态、在尾段投弹；
// image_index 交给父对象按 idle_anim(10) / attack_anim(8) 自己推，本对象不碰。
if global.is_paused{
	exit
}
event_inherited();
if is_frozen || state == CARD_STATE.SLEEP{
	exit
}

var current_flash_speed = flash_speed
if is_slowdown{
	current_flash_speed *= 2
}

if (attack_timer < cycle) {
	attack_timer++;
}
else {
	attack_timer = 0;
}

// 最后 (attack_anim + 1) * flash_speed 帧进攻击状态 → 父对象把 11~19 播完
// （9 拍 = 45 帧：attack_anim 帧只有 8 拍、只推到 18；多留一拍才能让末帧 19「空炮盘」露出来）
if (attack_timer >= cycle - (attack_anim + 1) * current_flash_speed) {
	state = CARD_STATE.ATTACK;

	// 尾段按间隔投弹：第 1 发在 cycle 前 10 帧，第 2 发再错 bomb_interval 帧
	if (fired_bombs < bombs_per_attack
		&& attack_timer >= cycle - 10 + fired_bombs * bomb_interval) {
		fired_bombs++;
		event_user(1);
	}
}
else {
	state = CARD_STATE.IDLE;
	fired_bombs = 0;
}
