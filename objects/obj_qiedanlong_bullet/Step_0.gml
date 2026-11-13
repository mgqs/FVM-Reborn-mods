/// 窃蛋龙 弹体 Step
/// 2026-11-13 第 5 版（用户口径：**蛋体本身看碰撞，爆炸只是动画，溅射单独算**）
///   · 飞行中：读精灵遮罩得到判定框，和**本行**老鼠相交 → 命中第一只，直击那只吃全额
///   · 没撞到任何鼠：飞到落点（flight_ft 满）才落地爆
///   · 爆点钉在「被打中那只的身体中心」（不再用蛋当前坐标，蛋坐标比鼠头还高半格 → 会看着炸到上一路）
///   · 3×3 溅射在爆开那一帧单独算（按被打中那只所在的格，不含已直击的那只）
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

    // ── 爆点：优先钉在「被打中那只」的身体中心 ──
    //   2026-11-13 修「中路的蛋炸到上路」：原来爆点 = 蛋当前坐标（蛋体在原点上方，
    //   判定框又是从蛋底往上算的，炸点自然比鼠头还高）。现在直接取那只 bbox 的垂直中点，
    //   再补爆炸图自己的中心偏移 egx_explode_dy。
    var _just = hitted_enemy;
    var _px = x;
    var _py = land_y;
    var _dc = floor((x - global.grid_offset_x) / global.grid_cell_size_x);
    var _dr = row;

    if (instance_exists(hitted_enemy)){
        _px = hitted_enemy.x;
        _py = (hitted_enemy.bbox_top + hitted_enemy.bbox_bottom) * 0.5;
        _dc = hitted_enemy.grid_col;
        _dr = hitted_enemy.grid_row;
    } else if (instance_exists(land_target)){
        // 半路没撞到、但落点那只还在 → 也按那只的身体中心炸（跟着走位）
        _px = land_target.x;
        _py = (land_target.bbox_top + land_target.bbox_bottom) * 0.5;
        _dc = land_target.grid_col;
        _dr = land_target.grid_row;
    }

    // 爆炸图圆心在原点上方 18/20/23 px（×1.4 → 25/28/32），补上后圆心正好压在老鼠身上
    var _exdy = (shape >= 2) ? 32 : ((shape == 1) ? 28 : 25);
    x = _px;
    y = _py + _exdy;

    // ① 直击：只有真的撞到鼠才结算，全额
    if (instance_exists(_just)){
        audio_play_sound(snd_egg_bullet, 0, 0);   // 砸蛋音
        with (_just){
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

    // ③ 溅射：以被打中那只所在的格为中心的 3×3（同勺勺兔），不含已直击的那只
    with (obj_enemy_parent){
        if (hp <= 0) continue;
        if (id == _just) continue;
        if (target_type == "obstacle") continue;
        if (abs(grid_col - _dc) > other.splash_cells) continue;
        if (abs(grid_row - _dr) > other.splash_cells) continue;
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
