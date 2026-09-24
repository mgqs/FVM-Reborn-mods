if global.is_paused {
    exit
}

if ice_timer > 0 {
    ice_timer--
    is_slowdown = true
} else {
    is_slowdown = false
}
if frozen_timer > 0 {
    frozen_timer--
    is_frozen = true
} else {
    is_frozen = false
}
if is_frozen {
    exit
}

if (!cleared) {
    cleared = true

    var grid_pos = get_grid_position_from_world(x, y)
    var center_col = grid_pos.col
    var center_row = grid_pos.row

    var half_range = 1
    if (shape == 2) half_range = 2

    var start_row = max(0, center_row - half_range)
    var end_row = min(global.grid_rows - 1, center_row + half_range)
    var start_col = max(0, center_col - half_range)
    var end_col = min(global.grid_cols - 1, center_col + half_range)

    var clear_list = []
    with (obj_enemy_parent) {
        if (target_type == "obstacle" && instance_exists(id)) {
            if (grid_row >= start_row && grid_row <= end_row &&
                grid_col >= start_col && grid_col <= end_col) {
                array_push(clear_list, id)
            }
        }
    }

    for (var i = 0; i < array_length(clear_list); i++) {
        if (instance_exists(clear_list[i])) {
            instance_destroy(clear_list[i])
        }
    }
}

var current_flash_speed = flash_speed
if is_slowdown {
    current_flash_speed *= 2
}

if timer < current_flash_speed - 1 {
    timer++
} else {
    if anim_frame < idle_anim {
        anim_frame++
        image_index = anim_frame
    } else {
        anim_frame = 0
        image_index = 0
    }
    timer = 0
}

if hp <= 0 {
    instance_destroy()
}

if flash_value > 0 {
    flash_value -= 10
}

var grid_pos = get_grid_position_from_world(x, y)
grid_col = grid_pos.col
grid_row = grid_pos.row
depth = calculate_plant_depth(grid_col, grid_row, plant_type)
if instance_exists(banding_star_obj) {
    banding_star_obj.depth = depth - 1
}
