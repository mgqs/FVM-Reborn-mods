if global.is_paused{
	exit
}

timer ++
switch (state) {
    case "idle":
        image_index = floor(timer / flash_speed) mod idle_anim
        break;
            
    case "awake":
        image_index = floor(timer / flash_speed) mod awake_anim + idle_anim
        break;
	case "attack":
        image_index = floor(timer / flash_speed) mod attack_anim + awake_anim + idle_anim
        break;
		
}

with obj_enemy_parent{
	// 龙渊 BOSS 不参与最左侧“猫”的唤醒/击杀机制（不吃猫的碰撞与清理）
	if (object_index == obj_ly_boss_parent || object_is_ancestor(object_index, obj_ly_boss_parent)) continue;
	// 马面技能三召唤的食灵不触发第 0 列的猫
	if (object_index == obj_ly_hengha_spirit) continue;
	// 符咒魂鼠（符咒转化的随从）现在正常触发猫（2026-10-27 按需求解除豁免）。
	// 傀儡马（kuileima）的巫毒代理：只是承接攻击伤害的隐身载体，位置吸附在卡片所在格，
	// 卡片放在第 0 列时代理落在第 0 列中心，与第 -1 列的猫相距 117px（正好在 120px 半径内）。
	// 它既不该唤醒猫，也不该被猫撞掉（撞掉后卡片下一帧立刻重建，表现为猫被白白放出去、
	// 代理被反复撞飞的循环）。鼠标ID会被 decoy_sync_identity 同步成真实老鼠的ID，
	// 无法靠 ignore_list 豁免，只能按对象类型整类跳过（2026-11-12）
	if (object_index == obj_kuileima_decoy) continue;
	if abs(x - other.x) <= 120{
		if other.state == "idle" && other.row == grid_row && hp > 0 && (array_get_index(other.ignore_list,mouse_id) == -1)&& (array_get_index(other.target_ignore,mouse_id) == -1){
			other.state = "awake"
			other.timer = 0
		}
		if other.state != "idle" && other.row == grid_row && hp > 0  && (array_get_index(other.ignore_list,mouse_id) == -1){
			// 爆炸/冲撞类（金牛烟花、猫眼宝石等 can_loss=false 的猫）：
			// 只有魂系鼠与 BOSS 挡得住冲撞，其余敌人一律撞死（判据统一走 crash_immune_enemy）
			if (!other.can_loss && crash_immune_enemy(id)) continue;
			
			var inst = instance_create_depth(x,y,depth,obj_knock_back_effect)
			inst.sprite_index = sprite_index
			inst.image_index = image_index
			instance_destroy()
			
		}
	}
}

if state == "awake"{
	attack_timer ++
	if attack_timer > flash_speed * awake_anim{
		state = "attack"
		flash_speed = 4
		timer = 0
	}
}
if state == "attack"{
	x += move_speed
	if x > 2200 || x < -200{
		instance_destroy()
	}
}