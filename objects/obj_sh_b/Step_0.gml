if (global.is_paused)
    exit;

timer++;
image_index = floor(timer / 5);

if (!instance_exists(banding_card_obj) || banding_card_obj.state != CARD_STATE.ATTACK)
    event_user(7);

// 类型过滤碰撞检测
if (variable_global_exists("enemy_by_type"))
{
    for (var _t = 0; _t < array_length(hittable_types); _t++)
    {
        var _key = hittable_types[_t];
        if (!variable_struct_exists(global.enemy_by_type, _key)) continue;
        var _list = global.enemy_by_type[$ _key];
        for (var _i = 0; _i < array_length(_list); _i++)
        {
            var _e = _list[_i];
            if (!instance_exists(_e)) continue;
            if (ds_list_find_index(hitted_enemy, _e.id) == -1
                && _e.hp > 0
                && abs(row - _e.grid_row) <= 1
                && bbox_right >= _e.bbox_left && bbox_left <= _e.bbox_right
                && bbox_bottom >= _e.bbox_top && bbox_top <= _e.bbox_bottom)
            {
                with (_e)
                {
                    audio_play_sound(hit_sound, 0, 0);
                    damage_amount = other.damage;
                    damage_type = other.damage_type;
                    event_user(0);
                }

                ds_list_add(hitted_enemy, _e.id);
            }
        }
    }
}
