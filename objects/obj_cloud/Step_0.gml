if global.is_paused{
	exit
}

x -= 0.25

var grid_pos = get_grid_position_from_world(x,y)
col = grid_pos.col
row = grid_pos.row

var target_pos = get_world_position_from_grid(1,0)

if x > target_pos.x{
	if !is_hole && image_alpha < 1{
		image_alpha += 0.1
	}
}
else{
	image_alpha -= 0.1
	if image_alpha <= 0{
		instance_destroy()
	}
}

if is_hole && col > 1{
	with obj_card_parent{
		if grid_col == other.col && grid_row == other.row &&
		plant_id != "player" && plant_type != "coffee"{
			if hp >= max_hp{
				obj_task_manager.card_loss++
			}
			var inst = instance_create_depth(x,y,depth,obj_drop_death_effect)
			inst.sprite_index = sprite_index
			inst.image_index = image_index
			instance_destroy()
		}
	}
	// 棉花糖空缺只吞卡片，不伤老鼠：
	// 老鼠经过空洞不掉血、不被销毁（原先这里还有一段 with obj_enemy_parent{ instance_destroy() }，已按需求移除）。
	// 卡片侧的判定保持不变，空缺仍会吃掉同格的非咖啡/非玩家卡片。
}