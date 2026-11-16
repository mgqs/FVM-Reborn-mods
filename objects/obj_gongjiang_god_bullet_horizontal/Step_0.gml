
if (global.is_paused)
{
    image_speed = 0;
    exit;
}

image_speed = 1;

life_frames++;
if (life_frames >= max_life_frames)
{
    if (ds_exists(hitted_enemy, ds_type_list)) ds_list_destroy(hitted_enemy);
    instance_destroy();
    exit;
}

var _tx, _ty;
if (phase == 1)
{
    _tx = wp1_x;
    _ty = wp1_y;
}
else if (phase == 2)
{
    _tx = wp2_x;
    _ty = wp2_y;
}
else if (phase == 3)
{
    _tx = start_x;
    _ty = start_y;
}
else
{
    if (ds_exists(hitted_enemy, ds_type_list)) ds_list_destroy(hitted_enemy);
    instance_destroy();
    exit;
}

var _dx = _tx - x;
var _dy = _ty - y;
var _dist = sqrt(_dx * _dx + _dy * _dy);

if (_dist <= move_speed)
{
    x = _tx;
    y = _ty;

    if (phase == 3)
    {
        if (ds_exists(hitted_enemy, ds_type_list)) ds_list_destroy(hitted_enemy);
        instance_destroy();
        exit;
    }

    // 走到第 1 个路径点转第 2 段；两段重合时直接返航（拐点不播特效）
    if (phase == 1 && !(wp1_x == wp2_x && wp1_y == wp2_y))
        phase = 2;
    else
        phase = 3;
}
else
{
    x += (_dx / _dist) * move_speed;
    y += (_dy / _dist) * move_speed;
}

if (!ds_exists(hitted_enemy, ds_type_list)) exit;

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
            if (_e.hp > 0
                && precise_bbox_collision(id, _e))
            {
                if (ds_list_find_index(hitted_enemy, _e.id) == -1)
                {
                    var _hp_before = _e.hp;

                    with (_e)
                    {
                        damage_amount = other.damage;
                        damage_type = other.damage_type;
                        event_user(0);
                    }

                    if (!ds_exists(hitted_enemy, ds_type_list)) break;
                    ds_list_add(hitted_enemy, _e.id);

                    // 河豚毒素 = 定身：掷中即 stun_timer（BOSS 由敌人父对象清零）
                    if (pin_chance > 0 && instance_exists(_e) && _e.hp > 0 && !_e.is_boss && random(1) < pin_chance)
                    {
                        _e.stun_timer = max(_e.stun_timer, pin_duration);
                        _e.stun_hide_icon = true;   // 河豚毒素自带毒雾，不画默认眩晕星星

                        // 毒雾固定用绿骷髅，压在老鼠头顶（M4 可调：dy 高度 / scale 大小）
                        var _pfx = instance_create_depth(_e.x, _e.y - 95 * _e.image_yscale,
                            _e.depth - 10, obj_gongjiang_god_effect);
                        _pfx.sprite_index = spr_gongjiang_god_effect_1_1;
                        _pfx.effect_kind = "poison";
                        _pfx.image_xscale = 1.4;
                        _pfx.image_yscale = 1.4;
                    }

                    var _is_kill = (!instance_exists(_e) || _e.hp <= 0 || _hp_before <= damage);
                    if (_is_kill)
                    {
                        if (instance_exists(_e))
                            _e.ash_death = true;
                        var _fx = instance_create_depth(_e.x, _e.y, _e.depth - 10, obj_gongjiang_god_effect);
                        _fx.sprite_index = spr_gongjiang_god_effect_death;
                        _fx.effect_kind = "kill";
                    }
                }
            }
        }

        if (!ds_exists(hitted_enemy, ds_type_list)) break;
    }
}
	}
}

if (x > 2200 || y > 1200 || x < -200 || y < -200)
{
    if (ds_exists(hitted_enemy, ds_type_list)) ds_list_destroy(hitted_enemy);
    instance_destroy();
}
