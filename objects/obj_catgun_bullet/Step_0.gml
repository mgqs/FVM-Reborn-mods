if global.is_paused {
    exit;
}
if burnt == 1{
	sprite_index = spr_fire_bullet
}
timer++;
image_index = (floor(timer / 3)) mod 4;

x += move_speed;

hit_tick++;
if (hit_tick >= global.bullet_hit_interval)
{
	hit_tick = 0;
	if (bullet_enemy_reachable(id)) {
if (variable_global_exists("enemy_by_type"))
{
    for (var _t = 0; _t < array_length(hittable_types); _t++)
    {
        var _key = hittable_types[_t];
        if (!variable_struct_exists(global.enemy_by_type, _key)) continue;
        var _list = bullet_sap_type_list(id, _key);
        for (var _i = 0; _i < array_length(_list); _i++)
        {
            var _e = _list[_i];
            if (!instance_exists(_e)) continue;
            if (_e.hp > 0 && row == _e.grid_row
    && precise_bbox_collision(id, _e))
            {
                var _damage = damage
                // 一次命中必须换一次行（2026-11-20 用户报「打好几次才换行」）：
                // 换行要靠 enemy 的 y 在 30 帧内走完一格，这 30 帧里 grid_row 每帧都被
                // obj_enemy_parent/Step_0:28 按 y 重算，所以「还没走完」时挨的下一发会
                // 拿旧行重新掷方向 —— 来回抵消，看起来就像「打了好几发都不换行」。
                // 因此 frightened 期间不再重新决定方向；同时只挑「同地形」的相邻行，
                // 避免把陆鼠推进水里（原逻辑上下都不同地形时干脆不换行）。
                with (_e)
                {
                    if scare_timer <= 0
                    {
                        scare_timer = 30
                        left_move_flashs = 30

                        var _up_ok   = (grid_row > 0);
                        var _down_ok = (grid_row < global.grid_rows - 1);
                        if (_up_ok)
                            _up_ok = (global.row_feature[grid_row - 1] == global.row_feature[grid_row]);
                        if (_down_ok)
                            _down_ok = (global.row_feature[grid_row + 1] == global.row_feature[grid_row]);

                        var _dir = 0;      // 1 = 下移，-1 = 上移
                        if (_up_ok && _down_ok)      _dir = (irandom_range(1,100) > 50) ? 1 : -1;
                        else if (_down_ok)           _dir = 1;
                        else if (_up_ok)             _dir = -1;

                        if _dir != 0
                        {
                            y_move = _dir * global.grid_cell_size_y / left_move_flashs;
                            grid_row += _dir;
                        }
                    }
                }
                instance_destroy()
                exit
            }
        }
    }
}
	}
}

if x > 2200 or y > 1200 or x < 0 or y < 0 {
    instance_destroy();
}