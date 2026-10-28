/// @function can_plant_at_position(x, y, plant_type,feature_type,target_card)
/// @description 检查是否可以在指定位置种植植物
/// @param {real} x X坐标
/// @param {real} y Y坐标
/// @param {string} plant_type 植物类型
/// @param {string} feature_type 植物特性
/// @param {string} target_card 底座卡片
/// @param {string} card_id 正在放置的卡牌 ID（可选）
function can_place_at_position(x, y, plant_type,feature_type,target_card,card_id = "") {
    // 海克斯模式：开局首抽（选一张或直接放弃）处理完之前，任何卡都不能落位
    if (hex_place_locked()) return false;
    // 海克斯「牢大的祝福」：除咖啡杯系以外的攻击类卡片一律不许落位
    if (hex_batch2_coffee_block(card_id)) return false;
    if (card_id == "kuileima" && !global.replace_placement) {
        for (var p = 0; p < instance_number(obj_kuileima); p++) {
            var existing = instance_find(obj_kuileima,p);
            if (instance_exists(existing) && existing.hp > 0) return false;
        }
    }
    // 海克斯「大火爆炒」：场上美食数量不能超过上限（0 = 不限制）
    var _max_cards = hex_enemy_max_cards();
    if (_max_cards > 0) {
        var _on_field = 0;
        with (obj_card_parent) { if (self.plant_id != "player") _on_field += 1; }
        if (_on_field >= _max_cards) return false;
    }

    // 获取网格位置
    var grid_pos = get_grid_position_from_world(x, y);
    var col = grid_pos.col;
    var row = grid_pos.row;
    
    // 检查是否在网格范围内
    if (col < 0 || col >= global.grid_cols || row < 0 || row >= global.grid_rows) {
        return false;
    }
    // 蜘蛛精蛛网封格：该格存在 spr_zhizhujing_wang（obj_ly_web）时无法放置卡片
    if (variable_global_exists("longyuan_web_cells") && global.longyuan_web_cells[row * global.grid_cols + col]) {
        return false;
    }
    // 傲慢龙柱的青苹果封格：该格有 obj_longzhu_green_apple 存活时无法放置卡片
    var _target_col = col;
    var _target_row = row;
    var _green_apple_block = false;
    var _apple_n = instance_number(obj_longzhu_green_apple);
    for (var _ai = 0; _ai < _apple_n; ++_ai) {
        var _apple = instance_find(obj_longzhu_green_apple, _ai);
        if (!instance_exists(_apple)) continue;
        if (_apple.hp > 0 && _apple.col == _target_col && _apple.row == _target_row) {
            _green_apple_block = true;
            break;
        }
    }
    if (_green_apple_block) return false;

	//调试相关
	if global.debug{
		return true
	}
	// 检查是否有障碍
	// 海洋女神所有形态可放置在障碍地形上，仍继续检查占格和底座规则。
	if !hex_terrain_free() && global.grid_terrains[row][col].type == "obstacle" && plant_type != "coffee" && feature_type != "haiyang_obstacle"{
		return false
	}
    
    // 获取该网格的植物列表
    var plant_list = ds_grid_get(global.grid_plants, col, row);

    // 同一格最多放一张海洋女神和一张战旗马，二者可以互相叠放。
    if ((card_id == "haiyang_god" || card_id == "zhanqima") && !global.replace_placement)
    {
        for (var i = 0; i < ds_list_size(plant_list); i++)
        {
            var plant = ds_list_find_value(plant_list, i);
            if (!instance_exists(plant) || !variable_instance_exists(plant, "plant_id")) continue;
            if (plant.plant_id == card_id) return false;
        }

        // 对方已存在且自身尚不存在时，允许叠放；上面的完整扫描确保不会超过各一张。
        for (var i = 0; i < ds_list_size(plant_list); i++)
        {
            var plant = ds_list_find_value(plant_list, i);
            if (instance_exists(plant) && variable_instance_exists(plant, "plant_id")
                && (plant.plant_id == "haiyang_god" || plant.plant_id == "zhanqima"))
                return true;
        }
    }

    // 海洋女神的悬浮形态不占用普通植物槽，但同一格仍只能存在一张海洋女神。
    if (feature_type == "haiyang_obstacle" && !global.replace_placement)
    {
        for (var i = 0; i < ds_list_size(plant_list); i++)
        {
            var plant = ds_list_find_value(plant_list, i);
            if (instance_exists(plant) && variable_instance_exists(plant, "plant_id")
                && plant.plant_id == "haiyang_god")
                return false;
        }
    }
    
    // 不占格卡可与其他卡叠放，但同一格不能重复放置自身。
    if ((card_id == "chunsun" || card_id == "xiandima") && !global.replace_placement)
    {
        for (var i = 0; i < ds_list_size(plant_list); i++)
        {
            var plant = ds_list_find_value(plant_list, i);
            if (!instance_exists(plant) || !variable_instance_exists(plant, "plant_id")) continue;
            if (plant.plant_id == card_id) return false;
        }
        return true;
    }

    // 根据植物类型检查是否可以种植
	if target_card != "none"{
		var same = false
		//检查是否有同类
		for (var i = 0; i < ds_list_size(plant_list); i++) {
		    var plant = ds_list_find_value(plant_list, i);
            if (!instance_exists(plant)) continue;
			if (plant.plant_type == plant_type && !global.replace_placement && feature_type != "upgrade") {
		        same = true
		    }
	                    
		}
		//检查是否有底座卡片
		for (var i = 0; i < ds_list_size(plant_list); i++) {
	        var plant = ds_list_find_value(plant_list, i);
                    if (!instance_exists(plant)) continue;
	        if (instance_exists(plant) && variable_instance_exists(plant, "plant_id") && plant.plant_id == target_card && !same) {
				
				return true;
				
	       }
	    }
		return false
	}
    // 海克斯「万物皆可炸」：任意地形可放置。
    // 放在底座规则之后短路，保证「需要底座」的卡仍然必须先满足底座关系；
    // 唯一保留的硬约束是玩家角色所在的格子不能放卡。
    if (hex_terrain_free() && !global.replace_placement) {
        for (var _tfi = 0; _tfi < ds_list_size(plant_list); _tfi++) {
            var _tfp = ds_list_find_value(plant_list, _tfi);
            if (!instance_exists(_tfp)) continue;
            if (variable_instance_exists(_tfp, "plant_id") && _tfp.plant_id == "player") return false;
        }
        return true;
    }

    switch (plant_type) {
        case "lilypad":
            // 莲叶花盆只能种在水上且该网格必须为空
			if global.grid_terrains[row][col].type == "water"{
	            if (ds_list_size(plant_list) == 0) {
	                // 空地上
	                //return (global.grid_terrain[# col, row] == "grass");
					return true
	            } else {
	                // 检查是否有同类
	                for (var i = 0; i < ds_list_size(plant_list); i++) {
	                    var plant = ds_list_find_value(plant_list, i);
                    	if (!instance_exists(plant)) continue;
	                    if ((plant.plant_type == "lilypad" && !global.replace_placement) || (plant.plant_type != "lilypad" && plant.feature_type == "water")) {
	                        return false;
	                    }
	                }
	                return true;
	            }
			}
			else{
				return false
			}
        case "coffee":
            if (ds_list_size(plant_list) == 0) {
                // 空地上
                //return (global.grid_terrain[# col, row] == "grass");
				return true
            } else {
                // 检查是否有同类
				if global.replace_placement{
						return true
					}
                for (var i = 0; i < ds_list_size(plant_list); i++) {
                    var plant = ds_list_find_value(plant_list, i);
                    if (!instance_exists(plant)) continue;
                    if (plant.plant_type == "coffee") {
                        //return false;
                    }
                }
                return true;
            }
            
        case "shield_outer":
            // 护罩植物只能种在普通植物或莲叶上
            if global.grid_terrains[row][col].type != "water"{
				if feature_type == "water"{
					return false
				}
	            if (ds_list_size(plant_list) == 0) {
	                // 空地上
	                //return (global.grid_terrain[# col, row] == "grass");
					return true
	            } else {
	                // 检查是否有同类
					if global.replace_placement{
						return true
					}
	                for (var i = 0; i < ds_list_size(plant_list); i++) {
	                    var plant = ds_list_find_value(plant_list, i);
                    	if (!instance_exists(plant)) continue;
	                    if (plant.plant_type == "shield_outer") {
	                        return false;
	                    }
	                }
	                return true;
	            }
			}
			else if global.grid_terrains[row][col].type == "water"{
				// 检查是否有同类
					var has_same = false
					if feature_type == "dwarf"{
						return false;
					}
					if feature_type == "water"{
						for (var i = 0; i < ds_list_size(plant_list); i++) {
		                    var plant = ds_list_find_value(plant_list, i);
                    		if (!instance_exists(plant)) continue;
							if (plant.plant_type == "shield_outer" && !global.replace_placement) {
		                        has_same = true
		                    }
	                    
		                }
						for (var i = 0; i < ds_list_size(plant_list); i++) {
		                    var plant = ds_list_find_value(plant_list, i);
                    		if (!instance_exists(plant)) continue;
		                    if (plant.plant_type == "lilypad" || has_same) {
		                        return false;
		                    }
						}
						return true
					}
					else if feature_type == "amphi"{
						for (var i = 0; i < ds_list_size(plant_list); i++) {
		                    var plant = ds_list_find_value(plant_list, i);
                    		if (!instance_exists(plant)) continue;
							if (plant.plant_type == "shield_outer" && !global.replace_placement) {
		                        return false
		                    }
	                    
		                }
						return true
					}
					else{
		                for (var i = 0; i < ds_list_size(plant_list); i++) {
		                    var plant = ds_list_find_value(plant_list, i);
                    		if (!instance_exists(plant)) continue;
							if (plant.plant_type == "shield_outer" && !global.replace_placement) {
		                        has_same = true
		                    }
	                    
		                }
						for (var i = 0; i < ds_list_size(plant_list); i++) {
		                    var plant = ds_list_find_value(plant_list, i);
                    		if (!instance_exists(plant)) continue;
		                    if (plant.plant_type == "lilypad" && !has_same) {
		                        return true;
		                    }
						}
						return false
                }
				
			}
            return false;
            
        case "shegengbao":
            // 蛇羹煲：不占格的一次性回收卡，只能种在有可回收卡片的格子上
            for (var i = 0; i < ds_list_size(plant_list); i++) {
                var plant = ds_list_find_value(plant_list, i);
                if (!instance_exists(plant)) continue;
                if (variable_instance_exists(plant, "plant_id") && plant.plant_id == "player") continue;
                if (variable_instance_exists(plant, "can_shovel_remove") && !plant.can_shovel_remove) continue;
                return true;
            }
            return false;

        case "gridless":
            // 悬浮卡不占用普通植物槽；海洋女神和战旗马数量由前置规则统一限制。
            return true;

        case "normal":
				for (var i = 0; i < ds_list_size(plant_list); i++) {
	            var plant = ds_list_find_value(plant_list, i);
                    if (!instance_exists(plant)) continue;
	            if (instance_exists(plant) && variable_instance_exists(plant, "plant_id") && plant.plant_id == "player") {
	                return false;
	            }
	        }
            // 普通植物只能种在空地上或莲叶上
			if global.grid_terrains[row][col].type != "water"{
				if feature_type == "water"{
					return false
				}
	            if (ds_list_size(plant_list) == 0) {
	                // 空地上
	                //return (global.grid_terrain[# col, row] == "grass");
					return true
	            } else {
	                // 检查是否有同类
					if global.replace_placement{
						return true
					}
	                for (var i = 0; i < ds_list_size(plant_list); i++) {
	                    var plant = ds_list_find_value(plant_list, i);
                    	if (!instance_exists(plant)) continue;
	                    if (plant.plant_type == "normal" 
						&& !((feature_type=="bun"&&plant.feature_type=="king_bun")||(feature_type=="king_bun"&&plant.feature_type=="king_bun"))
						&& !((feature_type=="tbun"&&plant.feature_type=="king_tbun")||(feature_type=="king_tbun"&&plant.feature_type=="king_tbun"))) {
	                        return false;
	                    }
	                }
	                return true;
	            }
			}
			else if global.grid_terrains[row][col].type == "water"{
				// 检查是否有同类
					var has_same = false
					if feature_type == "dwarf"{
						return false;
					}
					if feature_type == "water"{
						for (var i = 0; i < ds_list_size(plant_list); i++) {
		                    var plant = ds_list_find_value(plant_list, i);
                    		if (!instance_exists(plant)) continue;
							if (plant.plant_type == "normal" && !global.replace_placement) {
		                        has_same = true
		                    }
	                    
		                }
						for (var i = 0; i < ds_list_size(plant_list); i++) {
		                    var plant = ds_list_find_value(plant_list, i);
                    		if (!instance_exists(plant)) continue;
		                    if (plant.plant_type == "lilypad" || has_same) {
		                        return false;
		                    }
						}
						return true
					}
					else if feature_type == "amphi"{
						for (var i = 0; i < ds_list_size(plant_list); i++) {
		                    var plant = ds_list_find_value(plant_list, i);
                    		if (!instance_exists(plant)) continue;
							if (plant.plant_type == "normal" && !global.replace_placement) {
		                        return false
		                    }
	                    
		                }
						return true
					}
					else{
		                for (var i = 0; i < ds_list_size(plant_list); i++) {
		                    var plant = ds_list_find_value(plant_list, i);
                    		if (!instance_exists(plant)) continue;
							if (plant.plant_type == "normal" && !global.replace_placement
							&& !((feature_type=="bun"&&plant.feature_type=="king_bun")||(feature_type=="king_bun"&&plant.feature_type=="king_bun"))
							&& !((feature_type=="tbun"&&plant.feature_type=="king_tbun")||(feature_type=="king_tbun"&&plant.feature_type=="king_tbun"))) {
		                        has_same = true
		                    }
	                    
		                }
						for (var i = 0; i < ds_list_size(plant_list); i++) {
		                    var plant = ds_list_find_value(plant_list, i);
                    		if (!instance_exists(plant)) continue;
		                    if (plant.plant_type == "lilypad" && !has_same) {
		                        return true;
		                    }
						}
						return false
                }
				
			}
            
        default:
            // 其他植物类型
            return ds_list_size(plant_list) == 0;
    }
}
