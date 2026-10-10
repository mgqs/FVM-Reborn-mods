var damage_multiplier = 1;

if shape >= 2 {
    var same_card_count = 1;
    with (obj_guangming_god) {  // 改成你的卡片对象名
        if (id != other.id && shape >= 2) {
            same_card_count++;
        }
    }
    if same_card_count > 4 {
        same_card_count = 4;
    }
    damage_multiplier = same_card_count;

    // 卡片数量超过1时，生成buff特效
    if same_card_count > 1 {
      var fx = instance_create_depth(x-65, y-185, depth-100, obj_light_buff)
		fx.parent_card = id;  // 绑定父卡片
    }
} else {
    damage_multiplier = 1;
}


if shape == 3 {
    // 7行 × 5列 范围（7行，5列）
    // 向上调整偏移，解决向下偏移问题
    var start_pos_x = x - 2 * global.grid_cell_size_x
    var start_pos_y = y - 3.8 * global.grid_cell_size_y  // 从 -3 改为 -4，向上多一行

    for(var i = 0; i < 7; i++) {
        for(var j = 0; j < 5; j++) {
            var world_x = start_pos_x + j * global.grid_cell_size_x + global.grid_cell_size_x/2
            var world_y = start_pos_y + i * global.grid_cell_size_y + global.grid_cell_size_y/2
            var grid_pos = get_grid_position_from_world(world_x, world_y)

            if grid_pos.row >= 0 && grid_pos.row < global.grid_rows && grid_pos.col >= 0 && grid_pos.col < global.grid_cols {
                var inst = instance_create_depth(world_x, world_y, 0, obj_light_atk_invisible)
                inst.damage = atk* damage_multiplier
                inst.max_time = 60
                inst.target_type = target_type
                inst.grid_col = grid_pos.col
                inst.grid_row = grid_pos.row
            }
        }
    }

    var fx = instance_create_depth(x+13, y-32, 0, obj_light_atk_effect_1)
    fx.damage = 0
    fx.max_time = 60
    fx.visible = true
}
else {
    // 5×5 范围
    var start_pos_x = x - 2.4 * global.grid_cell_size_x
    var start_pos_y = y - 2.9 * global.grid_cell_size_y

    for(var i = 0; i < 5; i++) {
        for(var j = 0; j < 5; j++) {
            var world_x = start_pos_x + j * global.grid_cell_size_x + global.grid_cell_size_x/2
            var world_y = start_pos_y + i * global.grid_cell_size_y + global.grid_cell_size_y/2
            var grid_pos = get_grid_position_from_world(world_x, world_y)

            if grid_pos.row >= 0 && grid_pos.row < global.grid_rows && grid_pos.col >= 0 && grid_pos.col < global.grid_cols {
                var inst = instance_create_depth(world_x, world_y, 0, obj_light_atk_invisible)
                inst.damage = atk* damage_multiplier
                inst.max_time = 60
                inst.target_type = target_type
                inst.grid_col = grid_pos.col
                inst.grid_row = grid_pos.row
            }
        }
    }

    var fx = instance_create_depth(x+13, y-32, 0, obj_light_atk_effect)
    fx.damage = 0
    fx.max_time = 60
    fx.visible = true
}
