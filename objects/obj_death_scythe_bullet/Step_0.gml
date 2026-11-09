if (global.is_paused)
{
    image_speed = 0;
    move_speed = 0;
    exit;
}

image_speed = 2;
move_speed = 2;
t += move_speed;

if (t < 0)
    t += 360;

total_deg += move_speed;

if (total_deg >= 360)
{
    instance_destroy();
    exit;
}

if (t >= 360)
    t -= 360;

var max_width = 1100;
var nx = (1 - dcos(t)) / 2;
var px = max_width * nx;
var py = -644.28 * power(nx, 1.75) * dsin(t);
x = start_x + px;
y = start_y + py;
hit_tick++;
if (hit_tick >= global.bullet_hit_interval)
{
    hit_tick = 0;
    if (bullet_enemy_reachable(id)) {
        if (variable_global_exists("enemy_by_type"))
        {
            for (var _ti = 0; _ti < array_length(hittable_types); _ti++)
            {
                var _key = hittable_types[_ti];
                if (!variable_struct_exists(global.enemy_by_type, _key)) continue;
                var _elist = bullet_sap_type_list(id, _key);
                for (var _ei = 0; _ei < array_length(_elist); _ei++)
                {
                    var _e = _elist[_ei];
                    if (!instance_exists(_e)) continue;
                    if (ds_list_find_index(hitted_enemy, _e.id) == -1 && !disabled
                        && _e.hp > 0
                        && precise_bbox_collision(id, _e))
                    {
                        with (_e)
                        {
                            damage_amount = other.damage;
                            damage_type = other.damage_type;
                            if (other.slow_timer > 0)
                                ice_timer = max(ice_timer, other.slow_timer);
                            event_user(0);
                        }
                        ds_list_add(hitted_enemy, _e.id);
                    }
                }
            }
        }
    }
}