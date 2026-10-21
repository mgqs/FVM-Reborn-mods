// obj_niuyouguo（邪恶牛油果）Step 事件
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

// 索敌：右侧前方（工程里卡片统一朝右，老鼠从右进）的扇形覆盖范围
//   近处 110px 内一律算覆盖；远处按 0.75 斜率放宽（扇形半角 35.26°，tan ≈ 0.707）
var has_enemy = false
with(obj_enemy_parent){
	if can_target_on(other.target_type, target_type){
		var _dx = x - other.x
		var _dy = abs(y - other.y)
		if (_dx > -20 && _dy <= abs(_dx) * 0.75 + 110){
			has_enemy = true
			break
		}
	}
}

if (has_enemy) {
	attack_timer++;
	// 攻击段总长 = attack_anim * flash_speed 帧
	if (attack_timer >= cycle - attack_anim * current_flash_speed){
		state = CARD_STATE.ATTACK;
	}
	// 开火绑攻击动画第 15 帧（image_index 14，果实刚离手），一次齐射 = 三方向各 1 发
	if (state == CARD_STATE.ATTACK && !fired_this_attack && image_index >= 14){
		fired_this_attack = true;
		salvo_index = 1;
		salvo_timer = 0;
		event_user(1);
	}
	// 二转：同一轮动画内错 4 帧补发第二组（每方向 2 发）
	if (fired_this_attack && salvo_index < shots_per_side){
		salvo_timer++;
		if (salvo_timer >= 4){
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
