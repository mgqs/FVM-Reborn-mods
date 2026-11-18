// Inherit the parent event
if global.is_paused{
	exit
}

if (hp <= 0) {
	instance_destroy()
}
event_inherited();

// 自动修复：通过通用生成器创建时 banding_target_inst 为 noone，需自动创建配对 target
//   2026-11-18 修：旧写法无条件用 (x, y) 反推格子 —— 而 y 在屏幕上方，行号是负数，
//   target 的目标点被算到地图外，蝙蝠落不下来（关卡里看不到）。现在只补缺失的落点，
//   并把落点夹进地图范围、出生点贴到落点上方 480px，配对 target 也建在落点上方。
if (banding_target_inst == noone) {
    if (target_col < 0 || target_row < 0) {
        var _grid = get_grid_position_from_world(x, y)
        target_col = clamp(_grid.col, 0, global.grid_cols - 1)
        target_row = clamp(_grid.row, 0, global.grid_rows - 1)
    }
    var _home = get_world_position_from_grid(target_col, target_row)
    x = _home.x + 10
    y = min(y, _home.y - 480)
    var _target_inst = instance_create_depth(_home.x + 10, _home.y - 290, -500, obj_bat_mouse_target)
    _target_inst.target_col = target_col
    _target_inst.target_row = target_row
    banding_target_inst = _target_inst
}

var current_move_speed = 0
if is_slowdown{
	flash_speed = 12
	current_move_speed = move_speed / 2
}
else{
	flash_speed = 6
	current_move_speed = move_speed
}

var target_y = get_world_position_from_grid(target_col,target_row).y - 30

if hp > 0 && state != ENEMY_STATE.DEAD && banding_target_inst != noone && instance_exists(banding_target_inst) && banding_target_inst.state != "appear"{
	if state == ENEMY_STATE.APPEAR{
		anim_timer++
		//x -= current_move_speed
		if anim_timer >= 120{
			if y < target_y{
				y += 15
			}
			else{
				y = target_y
				target_type = "normal"
			}
		}
		image_index = floor(anim_timer/flash_speed) mod 8
		if anim_timer >= 500{
			target_type = "normal"
			state = ENEMY_STATE.ACTING
			move_speed = 0
			anim_timer = 0
		}
	}
	if state == ENEMY_STATE.ACTING{
		anim_timer++
		image_index = floor(anim_timer/flash_speed) mod 9 + 8
		if anim_timer >= flash_speed * 9{
			target_type = "air"
			image_index = 16
			y -= 15
			with banding_target_inst{
				y -= 15
			}
			if y <= -200{
				instance_destroy()
			}
		}
		var plant_order_list = [noone,noone,noone,noone,noone]
		var plant_in_range = noone
		if anim_timer == flash_speed * 9{
			with (obj_card_parent) {
				var is_in_front = (grid_col == other.target_col && grid_row == other.target_row)
				
	            // 检查是否在攻击范围内
	            if (is_in_front) {
	                // 按铲除顺序优先选择
	                for (var i = 0; i < ds_list_size(global.shovel_order); i++) {
	                    var tar_type = ds_list_find_value(global.shovel_order, i);
                    
	                    if (plant_type == tar_type) {
	                        plant_order_list[i] = id;
	                        break;
	                    }
	                }
				
                
	                if (plant_in_range != noone) break;
	            }
	        }
		
			for(var i = 0 ; i < 4 ; i++){
				if plant_order_list[i] != noone{
					plant_in_range = plant_order_list[i]
					break
				}
			}
        
	        // 如果找到目标植物，进入攻击状态
	        if (plant_in_range != noone) {
	            if instance_exists(plant_in_range){
					with plant_in_range{
						if plant_id != "player"{
							var inst = instance_create_depth(x,y,depth+1,obj_card_stolen)
							inst.sprite_index = sprite_index
							inst.image_index = image_index
							instance_destroy()
						}
					}
				}
	        }
		}
	}
}