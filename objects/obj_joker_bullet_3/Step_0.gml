// obj_joker_bullet_3 Step（终转）：命中不消失 → 直击 + 就地 3x3 溅射（倍率读 splash_ratio）→ 继续飞
if (global.is_paused)
{
    image_speed = 0;
    exit;
}

image_speed = 1;
x += move_speed;

if (x > 2200 || y > 1200 || x < 0 || y < 0)
{
    instance_destroy();
    exit;
}

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
            if (_e.hp <= 0) continue;
            if (row != _e.grid_row) continue;
            if (ds_list_find_index(hit_log, _e) >= 0) continue;
            if (!precise_bbox_collision(id, _e)) continue;

            ds_list_add(hit_log, _e);
            splash_cx = _e.x;          // 先记落点，直击可能把这只打死
            splash_excl = _e.id;

            if (_e.hp <= damage)
            {
                // 终转同样出「死亡蝙蝠」灰烬（只播一遍，不循环）
                instance_create_depth(_e.x, _e.y - 20, _e.depth, obj_joker_bat_ash);
                instance_destroy(_e);
            }
            else
            {
                with (_e)
                {
                    audio_play_sound(hit_sound, 0, false);
                    damage_amount = other.damage;
                    damage_type = other.damage_type;
                    event_user(0);
                }
            }

            // 每命中一只就地溅射（倍率读 splash_ratio），被直击的那只不再吃
            with (obj_enemy_parent)
            {
                if (hp <= 0) continue;
                if (id == other.splash_excl) continue;
                if (abs(grid_row - other.row) > 1) continue;
                if (abs(x - other.splash_cx) > global.grid_cell_size_x * 1.5) continue;
                if (target_type != "normal" && target_type != "air" && target_type != "underground" && target_type != "diver") continue;
                // 只有「地精站在地面」（type 仍写 underground）才排除；普通地鼠 / 牙医鼠这类
                //   underground 敌人本来就在地下，照常吃溅射
                if (is_walking_dijing(id)) continue;

                damage_amount = other.damage * other.splash_ratio;   // 溅射倍率走 custom["溅射比例"]（终转 = 1）
                damage_type   = other.damage_type;
                if (variable_instance_exists(id, "ly_dig_hittable")) ly_dig_hittable = true;
                event_user(0);
            }
        }
    }
}
	}
}
