if (global.is_paused)
    exit;

if (!is_exploding && !has_exploded && hp <= 0)
{
    is_exploding = true;
    anim_frame = explode_start;
    anim_timer = 0;
}
if (is_exploding && hp <= 0)
    hp = 1;

event_inherited();

if (has_exploded)
    exit;

if (is_frozen || state == 4)
    exit;

if (!ds_exists(counted_bullets, ds_type_list))
    exit;

if (is_exploding)
{
    anim_timer++;
    if (anim_timer >= flash_speed)
    {
        anim_timer = 0;
        anim_frame++;
    }

    if (anim_frame > explode_end)
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

        if (ds_exists(counted_bullets, ds_type_list))
            ds_list_destroy(counted_bullets);

        instance_destroy();
    }
    else
    {
        image_index = anim_frame;
    }
}
else
{
    var _ratio = stored_damage / storage_cap;
    var _new_stage = 0;
    if (_ratio >= 0.7)
        _new_stage = 2;
    else if (_ratio >= 0.2)
        _new_stage = 1;

    var _seg_start = small_start;
    var _seg_end = small_end;
    if (_new_stage == 1)
    {
        _seg_start = mid_start;
        _seg_end = mid_end;
    }
    else if (_new_stage == 2)
    {
        _seg_start = big_start;
        _seg_end = big_end;
    }

    if (_new_stage != grow_stage)
    {
        grow_stage = _new_stage;
        anim_frame = _seg_start;
        anim_timer = 0;
    }

    anim_timer++;
    if (anim_timer >= flash_speed)
    {
        anim_timer = 0;
        anim_frame++;
        if (anim_frame > _seg_end || anim_frame < _seg_start)
            anim_frame = _seg_start;
    }
    image_index = anim_frame;

    if (storage_ratio > 0)
    {
        with (obj_bullet_parent)
        {
            if (!variable_instance_exists(id, "damage"))
                continue;
            if (damage <= 0)
                continue;
            if (!variable_instance_exists(id, "damage_type") || damage_type != "normal")
                continue;
            if (!variable_instance_exists(id, "target_type") || target_type != "normal")
                continue;
            if (!variable_instance_exists(id, "row"))
                continue;

            if (abs(row - other.grid_row) > 1)
                continue;

            if (abs(x - other.x) > global.grid_cell_size_x * 1.5)
                continue;

            if (ds_list_find_index(other.counted_bullets, id) == -1)
            {
                var _dmg = damage * other.storage_ratio / 100;
                other.stored_damage = min(other.stored_damage + _dmg, other.storage_cap);
                ds_list_add(other.counted_bullets, id);
            }
        }

        for (var i = ds_list_size(counted_bullets) - 1; i >= 0; i--)
        {
            if (!instance_exists(ds_list_find_value(counted_bullets, i)))
                ds_list_delete(counted_bullets, i);
        }
    }

    if (is_slowdown)
    {
        slowdown_tick++;
        if (slowdown_tick >= 2)
        {
            slowdown_tick = 0;
            storage_timer--;
        }
    }
    else
    {
        storage_timer--;
    }

    if (storage_timer <= 0)
    {
        is_exploding = true;
        anim_frame = explode_start;
        anim_timer = 0;
    }
}
