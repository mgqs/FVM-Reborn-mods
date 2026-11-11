/// 窃蛋龙 弹体 Step：抛物飞行 → 命中或落地爆炸
if (global.is_paused) exit;

// ── 碎裂动画阶段（炸开后只播动画） ──
if (has_splashed){
    image_index += 0.3;
    if (image_index >= 16) instance_destroy();
    exit;
}

// ── 飞行 ──
x += move_speed;
y -= cvspeed;
cvspeed -= cgravity;
image_angle -= 5;

image_index += 0.2;
if (image_index >= 4.99) image_index = 0;

// ── 出界 ──
if (x > combat_right_x() + 300 || x < combat_left_x() - 300 || y < -400 || y > 1400){
    instance_destroy();
    exit;
}

// ── 命中判定 ──
if (!hit_enemy){
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
                    if (_e.grid_row != row) continue;
                    if (!precise_bbox_collision(id, _e)) continue;

                    hit_enemy    = true;
                    hitted_enemy = _e.id;
                    break;
                }
                if (hit_enemy) break;
            }
        }
    }

    // ── 落到落点高度就炸（打上下行时按目标行算，不再等它自己掉到卡片那一层） ──
    //   必须「已经开始下落」才算：出膛点偏上，落点比出膛点高的行（上一行）一出生就满足 y >= land_y
    if (!hit_enemy && cvspeed < 0 && y >= land_y){
        hit_enemy = true;
        hitted_enemy = noone;
    }
}

// ── 爆炸 ──
if (hit_enemy && !has_splashed){
    has_splashed = true;
    image_index  = 5;

    var _cx = x;
    var _cy = y;

    with (obj_enemy_parent){
        if (hp <= 0) exit;
        if (target_type == "obstacle") exit;
        if (abs(grid_row - other.row) > other.splash_cells) exit;
        if (abs(x - _cx) > global.grid_cell_size_x * (other.splash_cells + 0.5)) exit;
        if (!can_target_on(other.target_type, target_type)) exit;

        damage_amount        = other.damage * other.splash_ratio;
        damage_type          = other.damage_type;
        damage_source_object = obj_qiedanlong;
        damage_source_card_id = "qiedanlong";
        if (variable_instance_exists(id, "ly_dig_hittable")) ly_dig_hittable = true;
        event_user(0);
        damage_source_card_id = "";
    }
}
