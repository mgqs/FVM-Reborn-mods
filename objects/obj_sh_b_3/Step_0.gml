if (global.is_paused)
    exit;

timer++;
image_index = floor(timer / 5);

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
            if (ds_exists(hitted_enemy, ds_type_list) && ds_list_find_index(hitted_enemy, _e.id) == -1
                && _e.hp > 0
                && abs(row - _e.grid_row) <= 1
                && _e.grid_col >= 0)
            {
                var _hit_id = _e.id;
                with (_e)
                {
                    audio_play_sound(hit_sound, 0, 0);

                    if (random(100) < 20)
                    {
                        if (stun_timer < 120)
                            stun_timer = 120;
                    }

                    var is_crit = false;

                    if (random(100) < 20)
                    {
                        is_crit = true;
                        instance_create_depth(x, y - 30, depth + 10, obj_sh_b_3_e);
                    }

                    var final_damage = other.damage;

                    if (is_crit)
                        final_damage *= 2;

                    if (hp > final_damage)
                    {
                        damage_amount = final_damage;
                        damage_type = other.damage_type;
                        event_user(0);
                    }
                    else
                    {
                        if (special_ash)
                        {
                            var inst = instance_create_depth(x, y - 20, depth, obj_mouse_ash_death);
                            inst.special_ash = true;
                            inst.sprite_index = sprite_index;
                            inst.image_index = image_index;
                        }
                        else
                        {
                            instance_create_depth(x, y - 20, depth, obj_mouse_ash_death);
                        }

                        instance_destroy();
                    }
                }

                if (ds_exists(hitted_enemy, ds_type_list))
                    ds_list_add(hitted_enemy, _hit_id);
            }
        }
    }
}

if (!instance_exists(banding_card_obj) || banding_card_obj.state != CARD_STATE.ATTACK)
    event_user(7);
