// 赖皮蛇海胆子弹 - 步事件
// 向右飞到最右列，再返回卡片位置销毁
if (global.is_paused)
    exit;

life_frames++;
if (life_frames >= max_life_frames)
{
    instance_destroy();
    exit;
}

// 属主卡片不存在则安全销毁
if (!instance_exists(owner_card))
{
    instance_destroy();
    exit;
}

// 计算当前段目标位置
var _target_pos;
if (flying_out)
    _target_pos = get_world_position_from_grid(right_col, start_row);
else
    _target_pos = get_world_position_from_grid(start_col, start_row);

var _dx = _target_pos.x - x;
var _dy = _target_pos.y - y;
var _dist = sqrt(_dx * _dx + _dy * _dy);

if (_dist <= move_speed)
{
    x = _target_pos.x;
    y = _target_pos.y;
    if (flying_out)
    {
        // 到达最右列，掉头返回
        flying_out = false;
    }
    else
    {
        // 回到卡片位置，销毁
        instance_destroy();
        exit;
    }
}
else
{
    x += (_dx / _dist) * move_speed;
    y += (_dy / _dist) * move_speed;
}

// 命中检测 - 遍历可攻击的敌人类型
if (!ds_exists(hitted_enemy, ds_type_list))
    exit;

if (variable_global_exists("enemy_by_type"))
{
    for (var _t = 0; _t < array_length(hittable_types); _t++)
    {
        var _key = hittable_types[_t];
        if (!variable_struct_exists(global.enemy_by_type, _key))
            continue;

        var _list = global.enemy_by_type[$ _key];
        for (var _i = 0; _i < array_length(_list); _i++)
        {
            var _e = _list[_i];
            if (!instance_exists(_e))
                continue;
            if (_e.hp > 0 && precise_bbox_collision(id, _e))
            {
                if (ds_list_find_index(hitted_enemy, _e.id) == -1)
                {
                    // 记录命中前的生命值，用于判断是否击杀
                    var _hp_before = _e.hp;

                    with (_e)
                    {
                        damage_amount = other.damage;
                        damage_type = other.damage_type;
                        event_user(0);
                    }

                    if (!ds_exists(hitted_enemy, ds_type_list))
                        break;

                    ds_list_add(hitted_enemy, _e.id);

                    // 判断是否由本发子弹击杀目标
                    var _is_kill = false;
                    if (!instance_exists(_e) || _e.hp <= 0 || _hp_before <= damage)
                        _is_kill = true;

                    if (_is_kill)
                    {
                        // 生成击杀特效，根据形态选择对应精灵
                        var _kill_fx = instance_create_depth(_e.x, _e.y, _e.depth - 10, obj_laipishe_effect);
                        if (bullet_shape == 0)
                            _kill_fx.sprite_index = spr_laipishe_effect;
                        else if (bullet_shape == 1)
                            _kill_fx.sprite_index = spr_laipishe_effect_1;
                        else
                            _kill_fx.sprite_index = spr_laipishe_effect_2;
                    }
                }
            }
        }

        if (!ds_exists(hitted_enemy, ds_type_list))
            break;
    }
}