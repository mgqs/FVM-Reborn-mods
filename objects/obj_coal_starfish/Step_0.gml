if global.is_paused{
	exit
}
event_inherited(); 

if shape < 1{
	drown_timer ++
	if drown_timer mod 60 == 0{
		//0转检测是否有气泡和海水
		var has_bubble = false
		var has_seawater = false
		with obj_card_parent{
			if plant_id == "soda_bubble" && grid_col == other.grid_col && grid_row == other.grid_row{
				has_bubble = true
			}
		}
		with obj_seawater{
			if col == other.grid_col && row == other.grid_row{
				has_seawater = true
			}
		}
		if !has_bubble && !has_seawater{
			hp -= 0.05*max_hp
			event_user(2)
		}
	}
}

if is_frozen || state == CARD_STATE.SLEEP{
	exit
}
var current_flash_speed = flash_speed
if is_slowdown{
	current_flash_speed *= 2
}
//检测自身右方是否有敌人
var has_enemy = false
with(obj_enemy_parent){
	if ((grid_row == other.grid_row || grid_col >= other.grid_col && grid_col <= (global.grid_cols + 1))&& can_target_on(other.target_type,target_type)){
		has_enemy = true
		break
	}
}

//攻击逻辑
if (has_enemy) {
    var _was_attack = (state == CARD_STATE.ATTACK);

    if (attack_timer <= cycle - attack_anim * current_flash_speed) {
        attack_timer++;
    } else if (attack_timer <= cycle) {
        attack_timer++;
        state = CARD_STATE.ATTACK;
    } else {
        attack_timer = 0;
        state = CARD_STATE.IDLE;
    }

    // 🔴 2026-10-30 修「第一次攻击打两轮」：
    //   父对象每 flash_speed 帧才推一次 image_index（中间几帧是**冻结**的），
    //   旧写法在 attack_timer == 1 就把 fired_this_attack 清零，
    //   而此时 image_index 可能还停在上一轮的 21（动画没来得及跳回起点）→ 当帧立刻又打一轮。
    //   改成「只在真正进入攻击段的那一帧重置」，并把动画拉到攻击段首帧，保证一次攻击只发一次。
    if (!_was_attack && state == CARD_STATE.ATTACK) {
        fired_this_attack = false;
        image_index = idle_anim + 1;
    }

    // 出弹绑在动画帧上（2026-10-30 用户口径）：
    //   第 21 帧蓄力到最满、第 22 帧（image_index 21）爆发的同时打出子弹。
    if (state == CARD_STATE.ATTACK && !fired_this_attack && image_index >= 21) {
        fired_this_attack = true;
        // 二转两组钳子同时打出
        var _shots = (shape >= 2) ? 2 : 1;
        for (var _k = 0; _k < _shots; _k++) {
            event_user(1);
            global.audio.play(snd_shot, 0, 0);
        }
    }
} else {
    // 没有符合条件的敌人，重置状态
    attack_timer = 0;
    fired_this_attack = false;
    state = CARD_STATE.IDLE;
}


