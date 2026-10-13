// 青涩柿柿 Step 事件
// 攻击型卡牌：检测范围内敌人 → 前摇 → 落下柿子造成3×3范围伤害 → 冷却

if global.is_paused{
	alarm[0] = alarm_get(0) + 1
	alarm[1] = alarm_get(1) + 1
	exit
}
ice_timer = 0
frozen_timer = 0
event_inherited();

if (is_frozen) { exit; }

// 记录自身原始网格位置
if origin_row == -1{
	origin_row = grid_row
	origin_col = grid_col
}

// ========== 冷却计时 ==========
if state == CARD_STATE.IDLE{
	if cooldown_timer > 0{
		cooldown_timer--
		flash_speed = 6
	}
}

// ========== 扫描敌人（3×3范围） ==========
var has_enemy = false
var first_target_col = -1
var first_target_row = -1

with(obj_enemy_parent){
	if (hp <= 0) continue
	if (state == ENEMY_STATE.DEAD) continue
	// 3×3 范围：行差 <=1，列差 <= 索敌range（左右各range格）
	var _row_diff = abs(grid_row - other.grid_row)
	var _col_diff = grid_col - other.grid_col
	// 敌人在卡牌前方（右侧）及左右范围内
	if (_row_diff <= 1
		&& _col_diff >= -other.range
		&& _col_diff <= other.range
		&& can_target_on(other.target_type, target_type)){
		has_enemy = true
		first_target_col = grid_col
		first_target_row = grid_row
		break
	}
}

// ========== 状态转换 ==========
// 有敌人 + 冷却完毕 + IDLE → 进入攻击
if (has_enemy) && state == CARD_STATE.IDLE && cooldown_timer <= 0{
	state = CARD_STATE.ATTACK
	attack_hit_count = 0
}

// ========== 攻击状态（帧驱动：第 34 帧、第 49 帧各攻击一次） ==========
if state == CARD_STATE.ATTACK{
	flash_speed = 4

	// 第 1 次攻击：第 34 帧（image_index = 33）
	if attack_hit_count < 1 && image_index >= 33{
		event_user(1)
		attack_hit_count = 1
	}
	// 第 2 次攻击：第 49 帧（image_index = 48）
	else if attack_hit_count < 2 && image_index >= 48{
		event_user(1)
		attack_hit_count = 2
	}

	// 两次攻击都放完后，卡片自毁
	if attack_hit_count >= 2{
		card_destroyed(id);
		instance_destroy()
		exit
	}
}
else if state == CARD_STATE.IDLE{
	flash_speed = 6
}
