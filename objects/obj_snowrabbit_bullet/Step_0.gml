/// 雪球兔 弹体 Step：从上方砸向目标点，命中或落地都结算
if (global.is_paused) exit;

// ── 错帧等待 ──
if (fall_delay > 0){
    fall_delay--;
    exit;
}

// ── 目标还活着就更新落点 ──
if (instance_exists(target_id) && target_id.hp > 0){
    tx = target_id.x;
    ty = target_id.y;
}

// ── 加速下落 ──
fall_t++;
fall_speed_y = min(18, move_speed + fall_t * 1.2);

var _dx = tx - x;
var _dy = ty - y;
var _len = point_distance(x, y, tx, ty);

if (_len > 1){
    var _vx = (_dx / _len) * fall_speed_y;
    var _vy = (_dy / _len) * fall_speed_y;
    x += _vx;
    y += _vy;
    // 雪球滚动角度
    image_angle += 8;
}

// ── 命中判定 ──
if (!has_hit){
    hit_tick++;
    if (hit_tick >= global.bullet_hit_interval){
        hit_tick = 0;

        if (bullet_enemy_reachable(id)){
            for (var _i = 0; _i < array_length(hittable_types); _i++){
                var _key = hittable_types[_i];
                if (_key == "obstacle") continue;

                _sap_gen = -1;
                var _list = bullet_sap_type_list(id, _key);

                for (var _j = 0; _j < array_length(_list); _j++){
                    var _e = _list[_j];
                    if (!instance_exists(_e) || _e.hp <= 0) continue;
                    if (!precise_bbox_collision(id, _e)) continue;

                    has_hit      = true;
                    hitted_enemy = _e.id;

                    with (_e){
                        damage_amount        = other.damage;
                        damage_type          = other.damage_type;
                        damage_source_object = obj_snowrabbit;
                        damage_source_card_id = "snowrabbit";
                        if (variable_instance_exists(id, "ly_dig_hittable")) ly_dig_hittable = true;
                        event_user(0);
                        damage_source_card_id = "";
                    }

                    instance_destroy();
                    exit;
                }
            }
        }
    }

    // ── 到达落点 ──
    if (_len <= 6){
        has_hit = true;
        hitted_enemy = noone;
        instance_destroy();
        exit;
    }
}

// ── 出界兜底 ──
if (y > global.grid_offset_y + global.grid_rows * global.grid_cell_size_y + 400 || x > combat_right_x() + 300 || x < combat_left_x() - 300){
    instance_destroy();
}
