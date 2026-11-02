// obj_eightcake_burn_cell Step 事件
if (global.is_paused) exit;

// 格子坐标：调用方锁死就用它的（蛋糕传落点格），否则按自身坐标反算
if (!lock_grid)
{
    var _gp = get_grid_position_from_world(x, y);
    grid_col = _gp.col;
    grid_row = _gp.row;
}

t++;

// 帧推进：把 frame_start~frame_end 均匀铺到 life 帧上
if (life > 1)
{
    var _span = frame_end - frame_start + 1;
    image_index = frame_start + floor((t mod life) / life * _span);
    if (image_index > frame_end) image_index = frame_end;
}

if (t <= life && variable_global_exists("enemy_by_type"))
{
    // 判定范围 = 这一格：横向按身体 bbox 与格子相交（跨在格子边上的老鼠也能烧到），纵向按行号严格相等
    var _cell_x = get_world_position_from_grid(grid_col, grid_row).x;
    var _half_w = global.grid_cell_size_x * 0.5;
    for (var _t = 0; _t < array_length(hittable_types); _t++)
    {
        var _key = hittable_types[_t];
        if (!variable_struct_exists(global.enemy_by_type, _key)) continue;
        var _list = global.enemy_by_type[$ _key];
        for (var _i = 0; _i < array_length(_list); _i++)
        {
            var _e = _list[_i];
            if (!instance_exists(_e) || _e.hp <= 0) continue;
            if (is_digging_dijing(_e)) continue;
            if (_e.grid_row != grid_row) continue;
            if (_e.bbox_right < _cell_x - _half_w || _e.bbox_left > _cell_x + _half_w) continue;
            if (ds_list_find_index(burned, _e.id) != -1) continue;
            ds_list_add(burned, _e.id);

            with (_e)
            {
                if (object_index == obj_enemy_parent || object_is_ancestor(object_index, obj_enemy_parent))
                {
                    damage_amount = other.damage;
                    damage_type = other.damage_type;
                    event_user(0);
                }
                else
                {
                    hp -= other.damage;
                }

                if (hp <= 0)
                {
                    // 烧死一律出灰烬（带 special_ash 的沿用原贴图）
                    if (special_ash)
                    {
                        var _ash = instance_create_depth(x, y - 20, depth, obj_mouse_ash_death);
                        _ash.special_ash = true;
                        _ash.sprite_index = sprite_index;
                        _ash.image_index = image_index;
                    }
                    else
                    {
                        instance_create_depth(x, y - 20, depth, obj_mouse_ash_death);
                    }
                    instance_destroy();
                }
            }
        }
    }
}

// 生命结束后再留 4 帧收尾（末帧火苗散掉）
if (t > life + 4)
{
    if (ds_exists(burned, ds_type_list)) ds_list_destroy(burned);
    instance_destroy();
}
