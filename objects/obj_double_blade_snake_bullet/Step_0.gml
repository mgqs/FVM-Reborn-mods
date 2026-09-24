if (global.is_paused)
    exit;

x += move_speed;

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
            with (_e)
            {
                if (hp > 0 && other.row == grid_row
                    && ds_list_find_index(other.hitted_enemy, id) == -1
                    && other.bbox_right >= bbox_left && other.bbox_left <= bbox_right
                    && other.bbox_bottom >= bbox_top && other.bbox_top <= bbox_bottom)
                {
                    ds_list_add(other.hitted_enemy, id);

                    var _threshold = other.execute_threshold;
                    var _multiplier = other.elite_multiplier;
                    var _damage = other.damage;

                    var _immune = false;
                    if (variable_instance_exists(id, "immune_to_ash"))
                        _immune = immune_to_ash;

                    var _is_elite = false;
                    if (variable_instance_exists(id, "is_elite"))
                        _is_elite = is_elite;

                    var _hp_ratio = 1.0;
                    if (maxhp > 0)
                        _hp_ratio = hp / maxhp;

                    if (!_immune && _hp_ratio <= _threshold)
                    {
                        var _fx = instance_create_depth(x, y - 20, depth - 100, obj_shuangrenshe_zhansha_effect);
                        _fx.sprite_index = spr_shuangrenshe_zhansha;

                        if (_is_elite)
                        {
                            damage_amount = floor(_damage * _multiplier);
                            damage_type = "pierce";
                            event_user(0);
                        }
                        else
                        {
                            hp = 0;
                            instance_create_depth(x, y - 20, depth, obj_mouse_ash_death);
                            instance_destroy();
                        }
                    }
                    else
                    {
                        damage_amount = _damage;
                        damage_type = "pierce";
                        event_user(0);
                    }

                    audio_play_sound(hit_sound, 0, 0);
                }
            }
        }
    }
}

if (x > 2000 || y > 1000 || x < 200 || y < 100)
    instance_destroy();
