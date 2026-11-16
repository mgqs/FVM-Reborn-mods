
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

y += move_speed * vertical_dir;

// 单程：从上往下 / 从下往上各飞一趟，到尽头即消失（不折返）
if ((vertical_dir < 0 && y <= my_top) || (vertical_dir > 0 && y >= my_bottom))
{
    if (ds_exists(hitted_enemy, ds_type_list)) ds_list_destroy(hitted_enemy);
    instance_destroy();
    exit;
}

if (!ds_exists(hitted_enemy, ds_type_list)) exit;

hit_tick++;
if (hit_tick >= global.bullet_hit_interval)
{
	hit_tick = 0;
	var _has_col = false;
	var _cc0 = col - 1;
	if (_cc0 < 0) _cc0 = 0;
	var _cc1 = col + 1;
	if (_cc1 > global.grid_cols - 1) _cc1 = global.grid_cols - 1;
	for (var _cc = _cc0; _cc <= _cc1; _cc++) {
		if (global.enemy_col_n[_cc] > 0) { _has_col = true; break; }
	}
	if (_has_col) {
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
