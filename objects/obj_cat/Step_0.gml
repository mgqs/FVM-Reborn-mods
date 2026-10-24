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
	// 符咒鼠的符咒转化产生的符咒魂鼠不触发猫
	if (object_index == obj_ly_fuzhou_minion) continue;
	if abs(x - other.x) <= 120{
		if other.state == "idle" && other.row == grid_row && hp > 0 && (array_get_index(other.ignore_list,mouse_id) == -1)&& (array_get_index(other.target_ignore,mouse_id) == -1){
			other.state = "awake"
			other.timer = 0
		}
		if other.state != "idle" && other.row == grid_row && hp > 0  && (array_get_index(other.ignore_list,mouse_id) == -1){
			// 爆炸/冲撞类（金牛烟花等 can_loss=false 的猫）无法秒杀魂系或防爆敌人
			if (!other.can_loss && (longyuan_is_soul_enemy(id) || (variable_instance_exists(id, "immune_to_ash") && immune_to_ash))) continue;
			
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