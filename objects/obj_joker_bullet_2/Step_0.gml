if (global.is_paused)
{
    image_speed = 0;
    exit;
}

image_speed = 1;
x += move_speed;

if (x > 2200 || y > 1200 || x < 0 || y < 0)
    instance_destroy();

hit_tick++;
if (hit_tick >= global.bullet_hit_interval)
{
	hit_tick = 0;
	if (bullet_enemy_reachable(id)) {
if (variable_global_exists("enemy_by_type"))
{
    // 恶作剧神 四级优先（本卡专属，不通用）：空 → 地下 → 潜水 → 陆地。
    //   本行前方（含身旁 40px）有更高优先级的目标时只打那一类，清掉后自动降到下一级；
    //   能打谁仍由 hittable_types 决定，这里只决定「先打谁」。
    var _pick = "";
    var _prio = ["air", "underground", "diver", "normal"];
    if (variable_global_exists("enemy_by_type")){
        for (var _pt = 0; _pt < array_length(_prio); _pt++){
            var _pk = _prio[_pt];
            if (!variable_struct_exists(global.enemy_by_type, _pk)) continue;
            // 全表扫：bullet_sap_type_list() 只返 ±128px 内的敌人，空军在更前面时会被地面鼠抢先
            var _pl = global.enemy_by_type[$ _pk];
            for (var _pi = 0; _pi < array_length(_pl); _pi++){
                var _pe = _pl[_pi];
                if (!instance_exists(_pe)) continue;
                if (object_exists(_pe)) continue;
                if (_pe.hp <= 0) continue;
                if (_pe.target_type != _pk) continue;                  // 类型表按 target_type 维护，双保险
                if (variable_instance_exists(_pe, "grid_row") && _pe.grid_row != row) continue;
                if (_pe.x < x - 40) continue;
                _pick = _pk;
                break;
            }
            if (_pick != "") break;
        }
    }
    for (var _t = 0; _t < array_length(hittable_types); _t++)
    {
        var _key = hittable_types[_t];
        if (_pick != "" && _key != _pick) continue;
        if (!variable_struct_exists(global.enemy_by_type, _key)) continue;
        var _list = bullet_sap_type_list(id, _key);
        for (var _i = 0; _i < array_length(_list); _i++)
        {
            var _e = _list[_i];
            if (!instance_exists(_e)) continue;
            if (_e.hp > 0 && row == _e.grid_row
    && precise_bbox_collision(id, _e))
            {
                hitted_enemy = _e.id;
                if (_e.hp <= damage)
                {
                    // 三转起：击杀出「死亡蝙蝠」灰烬（只播一遍，不循环）
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
                instance_create_depth(x, y, depth, obj_joker_bullet_effect_23);
                instance_destroy();
                exit;
            }
        }
    }
}
	}
}
