if global.is_paused{
	exit
}
timer++
var target_pos = get_world_position_from_grid(target_col,target_row)
y += 5
if y >= target_pos.y{
	// 变异：导弹摧毁整行卡片
	with obj_card_parent{
		if grid_row == other.target_row && plant_id != "player" && plant_type != "coffee" && !invincible && plant_id != "cotton_candy"{
			if hp >= max_hp{
				obj_task_manager.card_loss++
			}
			instance_destroy()
		}
	}
	var effect = instance_create_depth(x-15,y+15,-200,obj_wine_bottle_bomb_explode)
	// 加大传播层级，让爆炸特效铺满整行
	effect.interval = global.grid_cols + 1
	effect.sprite_index = spr_kuafu_boss_julie_bomb_fx
	effect.max_time = 45
	effect.is_parent = true
	effect.row = target_row
	effect.col = clamp(target_col,0,global.grid_cols-1)
	instance_destroy()
}