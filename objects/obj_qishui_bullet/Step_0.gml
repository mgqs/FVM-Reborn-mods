/// 弹珠汽水 弹体 Step
/// 直线弹按 move_speed 横飞；弹射弹按 move_x/move_y 飞向目标
if (global.is_paused) exit;

// ── 推进 ──
if (is_bounce){
    // 目标没了 → 直接消失（普通子弹打中就该没了，不留淡出残留）
    if (!instance_exists(bounce_target) || bounce_target.hp <= 0){
        instance_destroy();
        exit;
    }

    // 抛物线跳过去（色拉那种弧线，不是直线贴脸）
    if (bounce_t < bounce_total){
        bounce_t++;
        var _p  = bounce_t / bounce_total;
        var _tx = bounce_target.x;
        // 2026-11-13 用户口径：弹到**头上**再结算，不是贴身上
        var _ty = (bounce_target.sprite_index != -1)
            ? bounce_target.bbox_top + 10
            : bounce_target.y - 20;
        x = lerp(bs_x, _tx, _p);
        y = lerp(bs_y, _ty, _p) - sin(_p * pi) * bounce_arc;
    } else {
        // 2026-11-13 修「气泡卡在走动老鼠头上」：
        //   老鼠在走，而 lerp 的目标点是**起飞那一刻**的坐标，飞到了人也走了 → 气泡停在半空不动。
        //   到点后把位置贴到目标**当前的头顶**，并跳过节流让本帧就结算。
        x = bounce_target.x;
        y = (bounce_target.sprite_index != -1)
            ? bounce_target.bbox_top + 10
            : bounce_target.y - 20;
        hit_tick = global.bullet_hit_interval;
    }

    bounce_life++;
    if (bounce_life > 180){
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
        // 弹射链上已经打过的（chain_ids）也不再结算 —— 否则气泡停在原地会连着打好几次
        if (array_get_index(chain_ids, _e.id) != -1) continue;

        // 直线弹只打本行；弹射弹只打「这一跳指定的那一只」（不然飞过去路上会撞别的，看着像穿透）
        if (!is_bounce && _e.grid_row != row) continue;
        if (is_bounce && _e.id != bounce_target) continue;

        // 直线段照旧用 bbox 判定；弹射段**到点即命中**（目标一直在走，bbox 判定会漏 → 气泡黏在头上不动）
        if (!(is_bounce && bounce_t >= bounce_total) && !precise_bbox_collision(id, _e)) continue;

        hitted_enemy = _e.id;
        has_hit = true;
        audio_play_sound(snd_hit1, 0, 0);     // 2026-11-12 补：命中音

        // 先存坐标：下面的碎冰分支可能把这只老鼠直接销毁
        hit_x   = _e.x;
        hit_y   = _e.y;
        hit_col = _e.grid_col;
        hit_row = _e.grid_row;

        var _just = _e.id;
        array_push(chain_ids, _just);   // 记下来，弹射时别再回头打它

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

        // ── 弹射：同一颗子弹原地切「弹射态」，抛物线跳到下一只 ──
        //   2026-11-13：旧写法在 Destroy 里 instance_create 新弹，实测打完第一只气泡就没了；
        //   现在不销毁、不复用新实例，按色拉那种弧线跳到 3×3 / 5×5 内最近的另一只（直射 2 倍 / 弹射原值）
        if (chain_left > 0){
            var _next     = noone;
            var _best_dis = 999999;

            with (obj_enemy_parent){
                if (hp <= 0) continue;
                if (target_type == "obstacle") continue;
                if (abs(grid_col - other.hit_col) > other.bounce_cells) continue;
                if (abs(grid_row - other.hit_row) > other.bounce_cells) continue;
                if (!can_target_on(other.target_type, target_type)) continue;

                var _already = false;
                for (var _ci = 0; _ci < array_length(other.chain_ids); _ci++){
                    if (id == other.chain_ids[_ci]){ _already = true; break; }
                }
                if (_already) continue;

                var _dis = point_distance(other.hit_x, other.hit_y, x, y);
                if (_dis < _best_dis){
                    _best_dis = _dis;
                    _next     = id;
                }
            }

            if (_next != noone){
                chain_left--;
                // 弹射段 = 攻击表原值（直射段才是 2 倍）
                damage        = base_atk * bounce_mult;
                is_bounce     = true;
                bounce_target = _next;
                skip_enemy    = _just;
                sprite_index  = spr_qishui_bullet_2;   // 弹射段换小圆弹
                image_index   = 0;
                bs_x = x;
                bs_y = y;
                bounce_t      = 0;
                bounce_total  = clamp(round(point_distance(x, y, _next.x, _next.y) / 9), 12, 30);
                bounce_life   = 0;
                hit_tick      = 0;
                has_hit       = false;
                hitted_enemy  = noone;
                exit;   // 不销毁，抛物线跳过去
            }

            // 范围内没有可弹射的别的老鼠 → 当普通子弹处理：**命中即消失**，不进入弹射态
            instance_destroy();
            exit;
        }

        instance_destroy();
        exit;
    }
}
