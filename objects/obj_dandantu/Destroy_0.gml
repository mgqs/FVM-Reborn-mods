event_inherited();

if (!has_exploded)
{
    has_exploded = true;

    if (stored_damage > 0)
    {
        var _rows = action_rows;
        var _start_row = grid_row;
        if (_rows == 3)
            _start_row = grid_row - 1;

        for (var r = 0; r < _rows; r++)
        {
            var _target_row = _start_row + r;
            if (_target_row >= 0 && _target_row < global.grid_rows)
            {
                var _world_pos = get_world_position_from_grid(0, _target_row);
                var _bullet = instance_create_depth(_world_pos.x - 200, _world_pos.y, depth - 50, obj_dandantu_bullet);
                _bullet.damage = stored_damage;
                _bullet.row = _target_row;
                _bullet.shape_bullet = shape;

                if (shape == 0)
                    _bullet.sprite_index = spr_dandantu_bullet;
                else if (shape == 1)
                    _bullet.sprite_index = spr_dandantu_bullet_1;
                else if (shape == 2)
                    _bullet.sprite_index = spr_dandantu_bullet_2;
            }
        }

        audio_play_sound(snd_coke_bomb_explode, 0, false);
    }
}

if (ds_exists(counted_bullets, ds_type_list))
    ds_list_destroy(counted_bullets);
