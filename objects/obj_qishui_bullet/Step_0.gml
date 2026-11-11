/// 弹珠汽水 弹体 Step
/// 直线弹按 move_speed 横飞；弹射弹按 move_x/move_y 飞向目标
if (global.is_paused) exit;

// ── 推进 ──
if (is_bounce){
    // 弹射弹：朝「命中时记下的目标」飞过去（原来 move_x/move_y 恒 0、又直接出生在目标身上，
    //   看起来就是瞬移；现在从上一只的位置起飞，飞到身边才结算）
    if (instance_exists(bounce_target) && bounce_target.hp > 0){
        var _dx = bounce_target.x - x;
        var _dy = bounce_target.y - 20 - y;
        var _l  = point_distance(0, 0, _dx, _dy);
        if (_l > 4){
            move_x = (_dx / _l) * move_speed;
            move_y = (_dy / _l) * move_speed;
        }
    }
    x += move_x;
    y += move_y;

    bounce_life++;
    if (bounce_life > 120){
        instance_destroy();
        exit;
    }
} else {
    x += move_speed;
}

// ── 出屏 ──
if (x > combat_right_x() + 300 || x < combat_left_x() - 300 || y < -200 || y > 1200){
    instance_destroy();
    exit;
}

// ── 命中节流 ──
hit_tick++;
if (hit_tick < global.bullet_hit_interval) exit;
hit_tick = 0;

if (!bullet_enemy_reachable(id)) exit;

for (var _i = 0; _i < array_length(hittable_types); _i++){
    var _key = hittable_types[_i];
    if (_key == "obstacle") continue;   // 汽水弹不打障碍

    _sap_gen = -1;
    var _list = bullet_sap_type_list(id, _key);

    for (var _j = 0; _j < array_length(_list); _j++){
        var _e = _list[_j];
        if (!instance_exists(_e) || _e.hp <= 0) continue;
        if (_e.id == skip_enemy) continue;   // 刚弹射离开的那只，别回头再打一次

        // 直线弹只打本行；弹射弹不限行
        if (!is_bounce && _e.grid_row != row) continue;

        if (!precise_bbox_collision(id, _e)) continue;

        hitted_enemy = _e.id;
        has_hit = true;

        // 先存坐标：下面的碎冰分支可能把这只老鼠直接销毁
        hit_x   = _e.x;
        hit_y   = _e.y;
        hit_col = _e.grid_col;
        hit_row = _e.grid_row;

        with (_e){
            damage_amount = other.damage;
            damage_type = other.damage_type;
            damage_source_object = obj_qishui;
            damage_source_card_id = "qishui";
            if (variable_instance_exists(id, "ly_dig_hittable")) ly_dig_hittable = true;
            event_user(0);
            damage_source_card_id = "";

            // 1 转起：命中减速
            if (other.slow_frames > 0){
                if (ice_timer < other.slow_frames) ice_timer = other.slow_frames;
            }

            // 2 转：击杀碎冰
            if (other.ice_death && hp <= 0){
                var _ash = instance_create_depth(x, y - 20, depth, obj_mouse_ash_death);
                _ash.sprite_index = spr_mouse_ice_death;
                instance_destroy();
            }
        }

        instance_destroy();
        exit;
    }
}
