if (global.is_paused)
{
    image_speed = 0;
    exit;
}

image_speed = 1;

y += move_speed;

// 从 0 行上方飞入，落到场地底边以下即销毁。
var _floor_y = global.grid_offset_y + global.grid_rows * global.grid_cell_size_y + 200;

if (y > _floor_y)
{
    if (ds_exists(hit_counts, ds_type_map))
        ds_map_destroy(hit_counts);
    instance_destroy();
    exit;
}

hit_tick++;
if (hit_tick < global.bullet_hit_interval)
    exit;

hit_tick = 0;

if (!bullet_enemy_reachable(id))
    exit;

if (!variable_global_exists("enemy_by_type"))
    exit;

var _col_max = array_length(col_hits);

for (var _t = 0; _t < array_length(hittable_types); _t++)
{
    var _key = hittable_types[_t];
    if (!variable_struct_exists(global.enemy_by_type, _key)) continue;

    var _list = bullet_sap_type_list(id, _key);

    for (var _i = 0; _i < array_length(_list); _i++)
    {
        var _e = _list[_i];
        if (!instance_exists(_e)) continue;
        if (_e.hp <= 0) continue;

        // 列判定：只打 7~9 列（0 基 6~8）
        var _ci = _e.grid_col - col_left;
        if (_ci < 0 || _ci >= _col_max) continue;

        var _allow = col_hits[_ci];
        if (_allow <= 0) continue;

        var _done = hit_counts[? _e.id];
        if (_done == undefined) _done = 0;
        if (_done >= _allow) continue;

        if (!precise_bbox_collision(id, _e)) continue;

        var _prev_hp = _e.hp;
        var _dmg = longyuan_is_soul_bonus_target(_e) ? floor(damage * longyuan_soul_bonus_mult(obj_shennong_god)) : damage;

        with (_e)
        {
            audio_play_sound(hit_sound, 0, 0);
            damage_amount = _dmg;
            damage_type = other.damage_type;
            damage_source_object = obj_shennong_god;
            damage_source_card_id = "shennong_god";
            event_user(0);
            damage_source_card_id = "";
        }

        hit_counts[? _e.id] = _done + 1;

        if (ash_kill && _prev_hp > 0 && _e.hp <= 0)
        {
            instance_create_depth(_e.x, _e.y - 20, depth, obj_mouse_ash_death);
        }
    }
}
