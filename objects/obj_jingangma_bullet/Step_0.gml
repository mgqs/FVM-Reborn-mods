/// 金刚马 弹体 Step（音波：追踪 → 命中即穿透继续飞）
if (global.is_paused){
    image_speed = 0;
    exit;
}

image_speed = 1;
timer++;

if (timer > max_life || x > combat_right_x() + 300 || x < combat_left_x() - 300
    || y > 1200 || y < -200){
    if (ds_exists(hitted_enemy, ds_type_list)) ds_list_destroy(hitted_enemy);
    instance_destroy();
    exit;
}

// ── 追踪：还没命中过就朝目标修正方向 ──
if (!has_hit){
    if (homing_target_ok(target_id)){
        var _dx = target_id.x - x;
        var _dy = (target_id.y - 30) - y;
        var _len = point_distance(0, 0, _dx, _dy);
        if (_len > move_speed * 2){
            move_x = (_dx / _len) * move_speed;
            move_y = (_dy / _len) * move_speed;
        }
        else{
            // 已经贴到目标身上 → 放弃追踪，保持方向穿过去
            target_id = noone;
        }
    }
    else{
        target_id = noone;
    }
    image_angle = point_direction(0, 0, move_x, move_y);
}

x += move_x;
y += move_y;

// ── 穿透命中判定 ──
hit_tick++;
if (hit_tick < global.bullet_hit_interval) exit;
hit_tick = 0;

if (!bullet_enemy_reachable(id)) exit;
if (!variable_global_exists("enemy_by_type")) exit;

for (var _t = 0; _t < array_length(hittable_types); _t++){
    var _key = hittable_types[_t];
    if (!variable_struct_exists(global.enemy_by_type, _key)) continue;

    var _sap_gen = -1;   // 子弹在移动，让空间查询缓存失效
    var _list = bullet_sap_type_list(id, _key);

    for (var _i = 0; _i < array_length(_list); _i++){
        var _e = _list[_i];
        if (!instance_exists(_e)) continue;
        if (_e.hp <= 0) continue;
        if (_key == "underground" && !is_digging_dijing(_e)) continue;
        if (ds_list_find_index(hitted_enemy, _e.id) != -1) continue;
        if (!precise_bbox_collision(id, _e)) continue;

        // 目标无敌 → 记下来跳过，不消耗命中
        if (variable_instance_exists(_e, "invincible") && _e.invincible){
            ds_list_add(hitted_enemy, _e.id);
            continue;
        }

        // 魂系：无视鬼火减伤，并吃 1.5 倍伤害
        var _is_soul = longyuan_is_soul_bonus_target(_e);
        var _dmg = damage;
        if (_is_soul) _dmg = floor(damage * 1.5);

        // 二转秒杀平民鼠（非 BOSS、非精英、非无敌、非魂系豁免）
        if (kill_normal && !_is_soul){
            var _is_boss = (variable_instance_exists(_e, "is_boss") && _e.is_boss);
            if (!_is_boss && variable_global_exists("boss_list")
                && ds_exists(global.boss_list, ds_type_map)
                && variable_instance_exists(_e, "mouse_id")
                && ds_map_exists(global.boss_list, _e.mouse_id)){
                _is_boss = true;
            }
            var _no_ash = (variable_instance_exists(_e, "immune_to_ash") && _e.immune_to_ash);
            var _is_sub = (string_pos("submarine", object_get_name(_e.object_index)) > 0);
            if (!_is_boss && !_no_ash && !_is_sub) _dmg = _e.hp;
        }

        has_hit = true;

        with (_e){
            damage_amount          = _dmg;
            damage_type            = other.damage_type;
            damage_source_object   = obj_jingangma;
            damage_source_card_id  = "jingangma";
            if (variable_instance_exists(id, "ly_dig_hittable")) ly_dig_hittable = true;
            event_user(0);
            damage_source_card_id = "";

            // 定身（BOSS 免疫）
            if (!is_boss && other.stun_chance > 0 && irandom(99) < other.stun_chance){
                if (stun_timer < other.stun_frames) stun_timer = other.stun_frames;
            }
        }

        ds_list_add(hitted_enemy, _e.id);
    }
}
