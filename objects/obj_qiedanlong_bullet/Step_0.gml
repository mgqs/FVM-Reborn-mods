/// 窃蛋龙 弹体 Step
/// 2026-11-13 第 3 版（用户口径：**蛋体本身看碰撞，爆炸只是动画，溅射单独算**）
///   · 飞行中：蛋底一个 44×52 的小方框和本行老鼠相交 → 命中，只打第一只，直击那只吃**全额伤害**
///   · 没撞到任何鼠：飞到落点（flight_ft 满）才落地爆
///   · 爆开只播动画、**不再借爆炸结算直击**；3×3 溅射在爆开那一帧单独算（不含已直击的那只）
///   判定框写死在代码里，不依赖精灵 bbox —— 改了 .yy 但 GM 没重开也不会串味
if (global.is_paused) exit;

// ── 碎裂动画阶段（炸开后只播动画） ──
if (has_splashed){
    image_index += 0.3;
    if (image_index >= 16) instance_destroy();
    exit;
}

// ── 飞行（抛物线，帧数/落点由发射时算好） ──
flight_t++;
x += move_speed;
y -= cvspeed;
cvspeed -= cgravity;

image_index += 0.2;
if (image_index >= 4.99) image_index = 0;

// ── 出界兜底 ──
if (x > combat_right_x() + 300 || x < combat_left_x() - 300 || y < -400 || y > 1400){
    instance_destroy();
    exit;
}

// ── 蛋体碰撞（只认本行、只打第一只）──
//   判定框 = 精灵遮罩（Create 里换算好的 egg_b*，已按 image 缩放）
if (!hit_enemy){
    var _bl = x + egg_bl;
    var _br = x + egg_br;
    var _bt = y + egg_bt;
    var _bb = y + egg_bb;
    var _hit_id = noone;

    with (obj_enemy_parent){
        if (hp <= 0) continue;
        if (target_type == "obstacle") continue;
        if (grid_row != other.row) continue;
        if (!can_target_on(other.target_type, target_type)) continue;
        if (bbox_right < _bl || bbox_left > _br || bbox_bottom < _bt || bbox_top > _bb) continue;

        _hit_id = id;
        break;
    }

    if (_hit_id != noone){
        hit_enemy    = true;
        hitted_enemy = _hit_id;
    }
}

// ── 爆炸：撞到鼠 或 飞满帧数落地 ──
if (hit_enemy || flight_t >= flight_ft){
    has_splashed = true;
    image_index  = 5;

    // ① 直击：只有真的撞到鼠才结算，全额
    if (instance_exists(hitted_enemy)){
        audio_play_sound(snd_egg_bullet, 0, 0);   // 砸蛋音
        with (hitted_enemy){
            damage_amount         = other.damage;
            damage_type           = other.damage_type;
            damage_source_object  = obj_qiedanlong;
            damage_source_card_id = "qiedanlong";
            if (variable_instance_exists(id, "ly_dig_hittable")) ly_dig_hittable = true;
            event_user(0);
            damage_source_card_id = "";
        }
    }

    // ② 爆炸音（动画归动画，伤害不从爆炸出）
    audio_play_sound(snd_spoon_rabbit, 0, 0);

    // ③ 溅射：3×3、攻击力 ×35%，不含已经吃了直击的那只
    var _cx = x;
    var _cy = y;
    var _just = hitted_enemy;

    with (obj_enemy_parent){
        if (hp <= 0) continue;
        if (id == _just) continue;
        if (target_type == "obstacle") continue;
        if (abs(grid_row - other.row) > other.splash_cells) continue;
        if (abs(x - _cx) > global.grid_cell_size_x * (other.splash_cells + 0.5)) continue;
        if (!can_target_on(other.target_type, target_type)) continue;

        damage_amount         = other.damage * other.splash_ratio;
        damage_type           = other.damage_type;
        damage_source_object  = obj_qiedanlong;
        damage_source_card_id = "qiedanlong";
        if (variable_instance_exists(id, "ly_dig_hittable")) ly_dig_hittable = true;
        event_user(0);
        damage_source_card_id = "";
    }
}
