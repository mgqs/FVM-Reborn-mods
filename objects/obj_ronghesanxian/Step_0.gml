// obj_ronghesanxian（融合三线）Step 事件
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

// 索敌：本行 + 上下各一行（前方三行），全程宽度
// 与基础卡 obj_triple_wine_rack 完全同口径（只打陆地鼠，靠 can_target_on 判类型）
var has_enemy = false
with(obj_enemy_parent){
	if (grid_row >= other.grid_row-1 && grid_row <= other.grid_row+1 && grid_col >= other.grid_col && grid_col <= (global.grid_cols + 1) && can_target_on(other.target_type,target_type)){
		has_enemy = true
		break
	}
}

if (has_enemy) {
	attack_timer++;
	// 攻击段总长 = attack_anim * flash_speed 帧
	if (attack_timer >= cycle - attack_anim * current_flash_speed){
		state = CARD_STATE.ATTACK;
	}
	// 开火时机绑在攻击动画第 17 帧（image_index 16，此时花嘴已伸出），
	// 一次齐射 = 三行各 1 发；一次攻击动画内按 shots_per_row 分次齐射、错 5 帧
	// （0 转 2 次 → 每行 2 发；1 转 / 2 转 3 次 → 每行 3 发）
	// 用 fired_this_attack 兜住：image_index 会在 16~19 之间停留多个 flash_speed 帧
	if (state == CARD_STATE.ATTACK && !fired_this_attack && image_index >= 16){
		fired_this_attack = true;
		salvo_index = 1;
		salvo_timer = 0;
		event_user(1);
	}
	if (fired_this_attack && salvo_index < shots_per_row){
		salvo_timer++;
		if (salvo_timer >= 5){
			salvo_timer = 0;
			salvo_index++;
			event_user(1);
		}
	}
	if (attack_timer > cycle){
		attack_timer = 0;
		fired_this_attack = false;
		salvo_index = 0;
		salvo_timer = 0;
		state = CARD_STATE.IDLE;
	}
} else {
	// 没有符合条件的敌人，重置状态
	attack_timer = 0;
	fired_this_attack = false;
	salvo_index = 0;
	salvo_timer = 0;
	state = CARD_STATE.IDLE;
}
