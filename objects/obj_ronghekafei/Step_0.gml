// obj_ronghekafei（融合咖啡杯）Step 事件
// 与原版 obj_coffee_cup 同构：只负责计时、切状态，开火时点跟动画帧走；
// image_index 交给父对象按 idle_anim(11) / attack_anim(4 或 10) 自己推，本对象不碰。
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

// 检测自身右方是否有敌人（射程一整行，三形态同口径）
var has_enemy = false
with(obj_enemy_parent){
	if (grid_row == other.grid_row && grid_col >= other.grid_col && can_target_on(other.target_type, target_type)){
		has_enemy = true
		break
	}
}

// 攻击窗 = (attack_anim + 1) * flash_speed：0转 / 2转 = 55 帧（把 12~22 共 11 帧播完）；1转 = 25 帧（12~16）
// ⚠️ 窗口不能占满一整个 cycle：最高技能等级 cycle 只有 54 帧（减速时同样比例），
//    窗口 >= cycle 时 attack_timer 永远落在窗口里，fired_shots 不重置、卡片只打一轮就再也不打了
var _window = min((attack_anim + 1) * current_flash_speed, cycle - current_flash_speed)
if state != CARD_STATE.SLEEP{
	if (has_enemy){
		if (attack_timer < cycle) {
			attack_timer++;
		}
		else {
			attack_timer = 0;
		}
		if (attack_timer >= cycle - _window){
			state = CARD_STATE.ATTACK;
			// 开火不放在窗口开头，而是等父对象把动画推到「后坐帧」才出弹：
			// 0转 / 2转 在 16 / 18 / 20 三张 A 帧各出一发；1转 在末帧 16 出唯一一发。
			// 否则会出现「杯子还没动、子弹已经飞出去」的怪观感。
			if (fired_shots < shots_per_attack && image_index == shot_frames[fired_shots]){
				fired_shots++;
				event_user(1);
			}
		}
		else {
			state = CARD_STATE.IDLE;
			fired_shots = 0;
		}
	}
	else {
		// 没有符合条件的敌人，重置状态
		attack_timer = 0;
		state = CARD_STATE.IDLE;
		fired_shots = 0;
	}
}
