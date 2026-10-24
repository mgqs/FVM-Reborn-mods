// obj_rongheshuanggu（融合双菇）Step 事件
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

// ===== 索敌：本行右侧，分别统计「对陆」与「对空」两路有没有人 =====
has_land = false
has_air = false
with(obj_enemy_parent){
	if (grid_row == other.grid_row && grid_col >= other.grid_col && grid_col <= (global.grid_cols + 1) && can_target_on(other.target_type,target_type)){
		if (target_type == "air"){
			other.has_air = true
		}
		else{
			other.has_land = true
		}
		if (other.has_land && other.has_air) break
	}
}

var has_enemy = has_land || has_air

if (has_enemy) {
	var _kind_now = (has_land && has_air) ? 2 : (has_air ? 1 : 0)
	var _len_now
	if (_kind_now == 2) _len_now = 7
	else if (_kind_now == 1) _len_now = 28 - air_start_frame + 1
	else _len_now = 6

	attack_timer++;

	if (!in_attack && attack_timer >= cycle - _len_now * current_flash_speed){
		in_attack = true
		atk_kind = _kind_now
		if (atk_kind == 2){
			atk_start_frame = 29; atk_fire_frame = 33; atk_end_frame = 35; atk_len = 7
			salvo_total = max(shots_land, shots_air)
		}
		else if (atk_kind == 1){
			atk_start_frame = air_start_frame; atk_fire_frame = 23; atk_end_frame = 28
			atk_len = atk_end_frame - atk_start_frame + 1
			salvo_total = shots_air
		}
		else{
			atk_start_frame = 12; atk_fire_frame = 16; atk_end_frame = 17; atk_len = 6
			salvo_total = shots_land
		}
		// 一次攻击里要打完 salvo_total 组：按「开火帧到动画末」的余量均分间隔，限制在 3~6 帧
		var _room = (atk_end_frame - atk_fire_frame) * current_flash_speed
		salvo_gap = 5
		if (salvo_total > 1){
			salvo_gap = clamp(floor(_room / (salvo_total - 1)), 3, 6)
		}
		atk_t = 0
		image_index = atk_start_frame
		fired_this_attack = false
		salvo_index = 0
		salvo_timer = 0
		state = CARD_STATE.ATTACK
	}

	if (in_attack){
		// 自己推动画帧（父对象这一段被 attack_anim = 0 挡住）
		atk_t++
		image_index = atk_start_frame + floor(atk_t / current_flash_speed)
		if (image_index > atk_end_frame) image_index = atk_end_frame

		if (!fired_this_attack && image_index >= atk_fire_frame){
			fired_this_attack = true
			salvo_index = 0
			salvo_timer = 0
			event_user(1)
		}
		if (fired_this_attack && salvo_index + 1 < salvo_total){
			salvo_timer++
			if (salvo_timer >= salvo_gap){
				salvo_timer = 0
				salvo_index++
				event_user(1)
			}
		}

		if (attack_timer > cycle){
			attack_timer = 0
			in_attack = false
			fired_this_attack = false
			salvo_index = 0
			salvo_timer = 0
			state = CARD_STATE.IDLE
		}
	}
} else {
	attack_timer = 0
	in_attack = false
	fired_this_attack = false
	salvo_index = 0
	salvo_timer = 0
	state = CARD_STATE.IDLE
}
