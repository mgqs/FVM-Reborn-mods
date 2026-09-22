if (global.is_paused)
    exit;

frame_counter++;

var _total_frames = sprite_get_number(sprite_index);
var _current_frame = floor(frame_counter / flash_speed);

// 播放动画
if (_current_frame >= _total_frames)
{
    instance_destroy();
    exit;
}
image_index = _current_frame;

// 子弹出现时立即造成伤害
var _damage_frame = 0;
if (!has_damaged && _current_frame >= _damage_frame)
{
    has_damaged = true;

    var _cx = x;
    var _cy = y;
    var _rx = range_x;
    var _ry = range_y;
    var _atk = damage;
    var _shape = shape;
    var _freeze_chance = freeze_chance;
    var _freeze_duration = freeze_duration;
    var _hit_map = hit_map;

    // 对范围内所有敌人造成伤害
    with (obj_enemy_parent)
    {
        if (hp > 0 && can_target_on(other.target_type, target_type))
        {
            var dx = abs(x - _cx);
            var dy = abs(y - _cy);

            if (dx <= _rx && dy <= _ry)
            {
                var _damage = _atk;
                var _will_die = false;

                // 终转形态：叠加伤害
                if (_shape == 3 && ds_exists(_hit_map, ds_type_map))
                {
                    var _key = string(id);
                    var _hit_count = 0;
                    if (ds_map_exists(_hit_map, _key))
                        _hit_count = _hit_map[? _key];

                    _hit_count++;
                    _hit_map[? _key] = _hit_count;

                    if (_hit_count <= 5)
                    {
                        var _multipliers = [1, 1, 1.5, 2, 3];
                        _damage = floor(_atk * _multipliers[_hit_count - 1]);
                    }
                    else
                    {
                        _damage = floor(_atk * min(_hit_count, 20));
                    }

                    if (hp <= _damage)
                        _will_die = true;
                }

                if (_will_die)
                {
                    var _shouji_eff = instance_create_depth(x, y - 20, depth - 50, obj_heian_god_effect);
                    _shouji_eff.sprite_index = spr_heian_god_shouji;
                    _shouji_eff.is_one_shot = true;
                    _shouji_eff.frame_counter = 0;
                    _shouji_eff.flash_speed = 3;

                    instance_create_depth(x, y - 20, depth, obj_mouse_ash_death);
                    instance_destroy();
                }
                else
                {
                    damage_amount = _damage;
                    damage_type = other.damage_type;
                    event_user(0);

                    // 冰冻效果
                    if (_freeze_chance > 0 && irandom(99) < _freeze_chance)
                    {
                        if (variable_instance_exists(id, "frozen_timer"))
                            frozen_timer = max(frozen_timer, _freeze_duration);
                    }
                }
            }
        }
    }
}
