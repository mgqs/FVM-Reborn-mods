if global.is_paused {
    exit
}

remove_timer++

if remove_timer == 1 {
    with obj_card_parent {
        if grid_row == other.grid_row && grid_col == other.grid_col && plant_id == "lingrong_god" && id != other.id {
            instance_destroy()
        }
    }
}

// 地形决定精灵与帧布局：
//   water   → *_water  ：1~5 变身（image_index 0~4）、6~14 待机循环（5~13），共 14 帧
//   nowater → *_nowater：1~4 变身（0~3）、5~16 待机循环（4~15），共 16 帧
// 地形变化时重播一次变身动画（两套精灵尺寸不同，硬切会跳）。
var _in_water = false;
if (grid_row >= 0 && grid_col >= 0 && grid_row < global.grid_rows && grid_col < global.grid_cols) {
    var terrain_type = global.grid_terrains[grid_row][grid_col].type
    _in_water = (terrain_type == "water") && !on_lava
    if (terrain_type == "water" || on_lava) {
        plant_type = "lilypad"
    } else {
        plant_type = "coffee"
    }
}

var _want_spr = lingrong_god_sprite(_in_water, shape)
if (_want_spr != sprite_index) {
    sprite_index = _want_spr
    if (_in_water) {
        f_place_end  = 4
        f_idle_start = 5
        f_idle_end   = 13
    } else {
        f_place_end  = 3
        f_idle_start = 4
        f_idle_end   = 15
    }
    idle_anim   = f_idle_end
    anim_frame  = 0
    anim_timer  = 0
    placed      = false
    image_index = 0
}

event_inherited()

depth = calculate_plant_depth(grid_col, grid_row, "lilypad") + 2

with obj_cloud {
    if is_hole && col > 1 &&
       ((other.shape == 0 && row == other.grid_row && abs(col - other.grid_col) <= 1) ||
        (other.shape >= 1 && abs(row - other.grid_row) <= 1 && abs(col - other.grid_col) <= 1)) {
        is_hole = false
        image_alpha = 1
    }
}

var current_flash_speed = flash_speed
if is_slowdown {
    current_flash_speed *= 2
}

if anim_timer < current_flash_speed - 1 {
    anim_timer++
} else {
    anim_timer = 0
    if !placed {
        if anim_frame < f_place_end {
            anim_frame++
            image_index = anim_frame
        } else {
            placed = true
            anim_frame = f_idle_start
            image_index = anim_frame
        }
    } else {
        if anim_frame < f_idle_end {
            anim_frame++
            image_index = anim_frame
        } else {
            anim_frame = f_idle_start
            image_index = anim_frame
        }
    }
}

if !spawn_init && !is_clone {
    spawn_init = true

    var _blocked_ids = ["lingrong_god", "cotton_candy", "soda_bubble", "wooden_plate"]

    if shape == 1 {
        var current_replace = global.replace_placement
        global.replace_placement = false

        var dirs = [-1, 1]
        for (var i = 0; i < 2; i++) {
            var dy = dirs[i] * global.grid_cell_size_y
            if can_place_at_position(x, y + dy, "coffee", "normal", "none") {
                var grid_pos = get_grid_position_from_world(x, y + dy)
                var _can_spawn = true
                var _plant_list = ds_grid_get(global.grid_plants, grid_pos.col, grid_pos.row)
                for (var _i = 0; _i < ds_list_size(_plant_list); _i++) {
                    var _plant = ds_list_find_value(_plant_list, _i)
                    if !instance_exists(_plant) continue
                    if variable_instance_exists(_plant, "plant_id") && array_get_index(_blocked_ids, _plant.plant_id) != -1 {
                        _can_spawn = false
                        break
                    }
                }
                if _can_spawn {
                    var clone = instance_create_depth(x, y + dy, depth + 5 * dirs[i], obj_lingrong_god)
                    clone.is_clone = true
                    clone.shape = 1
                    card_created(clone, grid_pos.col, grid_pos.row)
                }
            }
        }

        global.replace_placement = current_replace
    }

    if shape == 2 {
        var current_replace = global.replace_placement
        global.replace_placement = false

        // 以本体为中心展开 3×3（本体占中心格，另外 8 个方向各一张，合计 9 张）。
        // 某个方向的相邻格若被越界 / 蛛网 / 青苹果封住，或该格已有 lingrong_god /
        // cotton_candy / soda_bubble / wooden_plate 这四种卡片，就沿这个方向往外扩一格；
        // 其余卡片一律放行（软糖与之同格叠放）。走到地图边界还没找到就放弃该方向。
        // 这里不复用 can_place_at_position：它把「已有卡片的格子」也判成可放置
        // （coffee 分支对非空格直接 return true），无法表达「有指定四卡就外扩」。
        if (grid_col < 0 || grid_row < 0) {
            // 正常不会发生（放置时 card_created 已写好坐标），防御性回退一帧
            spawn_init = false
        } else {
            var _dirs = [[0,-1], [0,1], [-1,0], [1,0], [-1,-1], [1,-1], [-1,1], [1,1]];
            for (var _d = 0; _d < array_length(_dirs); _d++) {
                var _cell = lingrong_spread_cell(grid_col, grid_row, _dirs[_d][0], _dirs[_d][1]);
                if (_cell == undefined) continue;
                var _wp = get_world_position_from_grid(_cell[0], _cell[1]);
                var clone = instance_create_depth(_wp.x, _wp.y, depth, obj_lingrong_god);
                clone.is_clone = true;
                clone.shape = 2;
                clone.hp = hp;
                clone.max_hp = max_hp;
                clone.atk = atk;
                card_created(clone, _cell[0], _cell[1]);
            }
        }

        global.replace_placement = current_replace
    }
}
