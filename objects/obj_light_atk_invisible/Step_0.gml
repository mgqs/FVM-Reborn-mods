if global.is_paused {
    exit
}

// 每帧获取当前所在的格子
var my_grid = get_grid_position_from_world(x, y)

if timer < max_time {
    timer++
} else {
    can_destroy = true
}

if timer mod 3 == 0 && !can_destroy {
    if timer <= 20 {
        image_index = floor(timer/5) mod 4
    } else {
        image_index = floor(timer/5) mod 7 + 3
    }

    with (obj_enemy_parent) {
        // 直接使用 my_grid 判断
        if (my_grid.col == grid_col && my_grid.row == grid_row && can_hit(other.target_type, target_type)) {
            damage_amount = other.damage
            damage_type = "throw"
            event_user(0)
            if hp <= 0 {
                if special_ash {
                    var inst = instance_create_depth(x, y-20, depth, obj_mouse_ash_death)
                    inst.special_ash = true
                    inst.sprite_index = sprite_index
                    inst.image_index = image_index
                } else {
                    instance_create_depth(x, y-20, depth, obj_mouse_ash_death)
                }
                instance_destroy()
            }
        }
    }
}

if can_destroy {
    image_index = floor(timer/5) mod 3 + 10
    timer++
    if timer >= max_time + 15 {
        instance_destroy()
    }
}
