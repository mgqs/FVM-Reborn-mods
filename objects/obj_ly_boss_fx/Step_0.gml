if (global.is_paused) exit;
if (!fx_ready) exit;  // 未启动前不播放

// 蜘蛛精预警：spr_zhizhujing_apper 循环播放 LY_SPIDER_WARN（2 秒）后自行消失
if (fx_kind == "zhizhujing_apper") {
    if (timer >= LY_SPIDER_WARN) { instance_destroy(); exit; }
}

if (fx_kind == "youshen_toxic") {
    fx_life++;
    fx_damage_timer++;
    if (fx_damage_timer >= game_get_speed(gamespeed_fps)) {
        fx_damage_timer = 0;
        longyuan_damage_3x3_direct(fx_col, fx_row, LY_YOUSHEN_MIST_DPS); // 穿护罩直伤
    }
    if (fx_life >= fx_duration) { instance_destroy(); exit; }
}

// 夜巡符咒：从第10列右向左飞到目标格 → 打开放毒雾 10 秒 → 回收消失
if (fx_kind == "youshen_scroll_live") {
    if (!variable_instance_exists(id, "fx_stage")) {
        fx_stage = 0;
        fx_mist_made = false;
    }
    if (fx_stage == 0) {
        x -= fx_speed;
        if (x <= fx_target_x) {
            x = fx_target_x;
            fx_stage = 1;
            fx_life = 0;
            fx_next_action = "施法";
            fx_loop_after = true;
            longyuan_clip_set("打开");
            timer = 0;
            fx_loop = false;
        }
    }
    else if (fx_stage == 1) {
        if (!fx_mist_made) {
            fx_mist_made = true;
            var _fog = instance_create_depth(x, y + 15, depth - 1, obj_ly_boss_fx);
            longyuan_boss_fx_start(_fog, "youshen_mist", "待机", true, 5);
            _fog.fx_kind = "youshen_toxic";
            _fog.fx_col = fx_col; _fog.fx_row = fx_row;
            _fog.fx_life = 0; _fog.fx_damage_timer = 0;
            _fog.fx_duration = LY_YOUSHEN_MIST_LIFE;
        }
        fx_life++;
        if (fx_life >= LY_YOUSHEN_MIST_LIFE) {
            fx_stage = 2;
            fx_next_action = "";
            longyuan_clip_set("消失");
            timer = 0;
            fx_loop = false;
        }
    }
}

if (fx_kind == "youshen_sleep") {
    fx_life++;
    if (fx_life >= fx_duration) {
        for (var _i = 0; _i < array_length(fx_cards); ++_i) {
            var _entry = fx_cards[_i];
            var _card = _entry.id;
            if (instance_exists(_card) && _card.state == CARD_STATE.SLEEP) _card.state = _entry.previous_state;
        }
        instance_destroy();
        exit;
    }
}

if (fx_kind == "diting_umbrella" && fx_triggered) {
    fx_trigger_timer++;
    if (fx_trigger_timer >= 3 * game_get_speed(gamespeed_fps)) {
        var _spawn = instance_create_depth(x, y, depth - 1, obj_ly_kailu);
        if (instance_exists(_spawn)) _spawn.longyuan_change_soul();
        instance_destroy();
        exit;
    }
}

if (fx_kind == "diting_soundwave_live") {
    fx_life++;
    if (fx_life >= LY_DITING_SOUNDWAVE_LIFE) { instance_destroy(); exit; }
    var _swcol = get_grid_position_from_world(x, y).col;
    // 飞行路径/驻留格上的钟被引信（不销毁音波）
    longyuan_diting_prison_fuse_cell(_swcol, fx_row);
    if (!fx_stuck) {
        // 右→左飞行，命中本行第一张卡：400 伤害并停在该位置
        var _hit_card = longyuan_card_in_cell(_swcol, fx_row);
        if (instance_exists(_hit_card)) {
            fx_stuck = true;
            x = _hit_card.x;
            longyuan_damage_plant(_hit_card, LY_DITING_SOUNDWAVE_HIT);
            fx_damage_timer = 0;
        } else {
            x += fx_direction * fx_speed;
            if (x <= global.grid_offset_x - 40) { instance_destroy(); exit; }
        }
    } else {
        // 驻留期间每秒对该格第一张卡持续造成伤害
        fx_damage_timer++;
        if (fx_damage_timer >= game_get_speed(gamespeed_fps)) {
            fx_damage_timer = 0;
            var _stay = longyuan_card_in_cell(get_grid_position_from_world(x, y).col, fx_row);
            if (instance_exists(_stay)) longyuan_damage_plant(_stay, fx_damage);
        }
    }
}

// 按本地计时器驱动当前动作的子图帧
longyuan_clip_frame(timer, fx_rate, fx_loop);

// 哼哈铃铛：飞行→变大→待机常驻；牛头敲钟后摇晃一次→飞走销毁
if (fx_kind == "hengha_bell") {
    if (!variable_instance_exists(id, "fx_bell_ring")) { fx_bell_ring = false; fx_bell_ringing = false; }
    if (!fx_bell_ringing && ly_action == "变大" && longyuan_clip_done(timer, fx_rate)) {
        longyuan_clip_set("待机");
        timer = 0;
        fx_loop = true;
    }
    if (fx_bell_ring && !fx_bell_ringing) {
        fx_bell_ringing = true;
        fx_next_action = "飞走";
        fx_loop_after = false;
        longyuan_clip_set("摇晃待机");
        timer = 0;
        fx_loop = false;
    }
}

// 非循环动作播完：切换到后续动作，或销毁
if (!fx_loop && longyuan_clip_done(timer, fx_rate)) {
    if (fx_next_action != "") {
        var _na = fx_next_action;
        fx_next_action = "";
        longyuan_clip_set(_na);
        timer = 0;
        fx_loop = fx_loop_after;
    }
    else {
        instance_destroy();
        exit;
    }
}

timer++;
