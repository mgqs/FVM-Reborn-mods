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

if (fx_kind == "youshen_mist_visual") {
    fx_life++;
    if (fx_life >= LY_YOUSHEN_MIST_LIFE) { instance_destroy(); exit; }
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
            timer = 0;
        }
    }
    else if (fx_stage == 1) {
        if (!fx_mist_made) {
            fx_mist_made = true;
            for (var _dx = -1; _dx <= 1; ++_dx) {
                for (var _dy = -1; _dy <= 1; ++_dy) {
                    var _cell = get_world_position_from_grid(fx_col + _dx, fx_row + _dy);
                    if (fx_col + _dx < 0 || fx_col + _dx >= global.grid_cols || fx_row + _dy < 0 || fx_row + _dy >= global.grid_rows) continue;
                    var _fog = instance_create_depth(_cell.x, _cell.y + 15, depth - 1, obj_ly_boss_fx);
                    longyuan_boss_fx_start(_fog, "youshen_mist", "待机", true, 5);
                    _fog.fx_kind = (_dx == 0 && _dy == 0) ? "youshen_toxic" : "youshen_mist_visual";
                    _fog.fx_col = fx_col; _fog.fx_row = fx_row;
                    _fog.fx_life = 0; _fog.fx_damage_timer = 0;
                    _fog.fx_duration = LY_YOUSHEN_MIST_LIFE;
                }
            }
        }
        fx_life++;
        if (fx_life >= LY_YOUSHEN_MIST_LIFE) {
            instance_destroy();
            exit;
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
    x += fx_direction * fx_speed;
    if (x <= global.grid_offset_x - 40) { instance_destroy(); exit; }
    // 音波经过整行时按秒对本行所有卡片造成一次伤害。
    fx_damage_timer++;
    if (fx_damage_timer >= game_get_speed(gamespeed_fps)) {
        fx_damage_timer = 0;
        for (var _col = 0; _col < global.grid_cols; ++_col) {
            longyuan_damage_cell(_col, fx_row, fx_damage);
        }
    }
}

// ===== 孟婆鼠：降雨 / 茶树 =====
if (fx_kind == "mengpo_rain_live") {
    fx_life++;
    if (fx_life >= fx_duration) { instance_destroy(); exit; }
}

// 孟婆鼠技能2 全屏风幕：持续 10 秒后消失
if (fx_kind == "mengpo_strong_wind_live") {
    fx_life++;
    if (fx_life >= fx_duration) { instance_destroy(); exit; }
}

// 孟婆鼠技能2 BOSS 迷雾：与风暴同寿命，持续 10 秒后消失
if (fx_kind == "mengpo_wind_mist_live") {
    fx_life++;
    if (fx_life >= fx_duration) { instance_destroy(); exit; }
}

if (fx_kind == "mengpo_wind_hit_live") {
    fx_life++;
    if (fx_life >= 30) { instance_destroy(); exit; }
}

// 孟婆鼠技能2 风线：沿风向推进，遇到茶树/卡片停留并持续造成风眼伤害
if (fx_kind == "mengpo_wind_line") {
    fx_life++;
    if (fx_life >= fx_duration) { instance_destroy(); exit; }

    var _wg = get_grid_position_from_world(x, y);
    var _wcol = _wg.col, _wrow = _wg.row;
    var _wkey = string(_wcol) + "," + string(_wrow);
    var _blocked = false;

    // 茶树阻挡
    with (obj_ly_boss_fx) {
        if (id != other.id && fx_kind == "mengpo_tea_tree_live" && fx_col == _wcol && fx_row == _wrow) _blocked = true;
    }
    // 卡片阻挡
    if (!_blocked && _wcol >= 0 && _wcol < global.grid_cols && _wrow >= 0 && _wrow < global.grid_rows) {
        var _wcards = ds_grid_get(global.grid_plants, _wcol, _wrow);
        for (var _wi = 0; _wi < ds_list_size(_wcards); ++_wi) {
            var _wc = _wcards[| _wi];
            if (instance_exists(_wc) && _wc.plant_id != "player" && _wc.plant_type != "coffee") { _blocked = true; break; }
        }
    }

    if (_blocked) {
        // 风眼：每秒 50 伤害
        fx_damage_timer++;
        if (fx_damage_timer >= game_get_speed(gamespeed_fps)) {
            fx_damage_timer = 0;
            longyuan_damage_cell(_wcol, _wrow, fx_damage);
        }
        // 首次进入该格播放命中动画
        if (fx_hit_key != _wkey) {
            fx_hit_key = _wkey;
            var _hpos = get_world_position_from_grid(_wcol, _wrow);
            var _hit = instance_create_depth(_hpos.x, _hpos.y, depth - 1, obj_ly_boss_fx);
            longyuan_boss_fx_start(_hit, "mengpo_wind_hit", "待机", true, 5);
            _hit.fx_kind = "mengpo_wind_hit_live";
            _hit.fx_life = 0;
        }
    }
    else {
        fx_damage_timer = 0;
        fx_hit_key = "";
        x += fx_dir_x * fx_speed;
        y += fx_dir_y * fx_speed;
        if (x < global.grid_offset_x - 160
            || x > global.grid_offset_x + global.grid_cols * global.grid_cell_size_x + 160
            || y < global.grid_offset_y - 160
            || y > global.grid_offset_y + global.grid_rows * global.grid_cell_size_y + 160) {
            instance_destroy();
            exit;
        }
    }
}

// 哼哈铃铛：自管完整生命周期（0 飞行 → 1 变大 → 2 待机 → 3 攻击待机/4 待机2 → 5 飞走）
// 放在通用 clip_frame 之前，避免通用“非循环动作播完”逻辑干扰钟的状态
if (fx_kind == "hengha_bell") {
    if (!variable_instance_exists(id, "fx_bell_stage")) {
        fx_bell_stage = 0;
        fx_bell_stage2 = false;   // 马面技能3 要求切「待机2」
        fx_bell_leave = false;    // 离场：播「飞走」后销毁
        fx_bell_ring = false;     // 牛头敲钟标记
        fx_bell_ringing = false;
    }

    // 马面技能3：切「待机2」（钟尚未落地时先不动，落地后再切；已被敲过也切）
    if (fx_bell_stage2 && fx_bell_stage >= 1 && fx_bell_stage <= 3) {
        fx_bell_stage = 4;
        longyuan_clip_set("待机2");
        timer = 0;
    }
    // 牛头敲钟：切「攻击待机」（未落地的钟先记下，落地后再生效）
    if (fx_bell_ring && !fx_bell_ringing && fx_bell_stage >= 1) {
        fx_bell_ringing = true;
        if (fx_bell_stage <= 2) {
            fx_bell_stage = 3;
            longyuan_clip_set("攻击待机");
            timer = 0;
        }
    }
    // 离场：切「飞走」，播完销毁（不再永久留在场上）
    if (fx_bell_leave && fx_bell_stage != 5) {
        fx_bell_stage = 5;
        longyuan_clip_set("飞走");
        timer = 0;
    }

    switch (fx_bell_stage) {
        case 0: {
            // 飞行：朝目标格直线飞行；900 步仍未到则直接吸附到目标，避免卡在半空
            var _tx = x, _ty = y;
            if (variable_instance_exists(id, "fx_target_x")) {
                // 优先使用创建时记录的像素坐标（网格坐标可能尚未赋值）
                _tx = fx_target_x;
                _ty = fx_target_y;
            }
            else if (variable_instance_exists(id, "fx_target_col") && fx_target_col >= 0) {
                var _tp = get_world_position_from_grid(fx_target_col, fx_target_row);
                _tx = _tp.x; _ty = _tp.y;
            }
            var _dd = point_distance(x, y, _tx, _ty);
            if (_dd > 4 && timer < 900) {
                var _dir = point_direction(x, y, _tx, _ty);
                x += lengthdir_x(6, _dir);
                y += lengthdir_y(6, _dir);
            } else {
                x = _tx; y = _ty;
                fx_target_col = -1;
                fx_bell_stage = 1;
                longyuan_clip_set("变大");
                timer = 0;
            }
            break;
        }
        case 1: {
            if (longyuan_clip_done(timer, fx_rate)) {
                fx_bell_stage = 2;
                longyuan_clip_set("待机");
                timer = 0;
            }
            break;
        }
        case 5: {
            if (longyuan_clip_done(timer, fx_rate)) { instance_destroy(); exit; }
            break;
        }
    }

    // 钟的动画始终由自己的计时器推进，且始终循环
    longyuan_clip_frame(timer, fx_rate, !(fx_bell_stage == 1 || fx_bell_stage == 5));
    timer++;
    exit;
}

// ===== 无常鼠 =====
// 拘魂锁链投掷：从BOSS飞到本行第2列后消失
if (fx_kind == "wuchang_chain_throw") {
    x -= fx_speed;
    if (x <= fx_target_x) { instance_destroy(); exit; }
}

// 勾魂魂勾：顺时针沿最外圈路径点移动一周，摧毁沿途格子卡片，回到(1,9)后通知BOSS回收
if (fx_kind == "wuchang_fire_wheel_live") {
    if (fx_path_idx < array_length(fx_path)) {
        var _wp = fx_path[fx_path_idx];
        var _tp = get_world_position_from_grid(_wp[1], _wp[0]);
        var _dir = point_direction(x, y, _tp.x, _tp.y);
        var _dd = point_distance(x, y, _tp.x, _tp.y);
        if (_dd <= fx_speed) { x = _tp.x; y = _tp.y; fx_path_idx++; }
        else { x += lengthdir_x(fx_speed, _dir); y += lengthdir_y(fx_speed, _dir); }
        var _g = get_grid_position_from_world(x, y);
        var _key = string(_g.col) + "," + string(_g.row);
        if (_key != fx_last_cell) {
            fx_last_cell = _key;
            // 直接摧毁，不播放爆炸特效
            var _cards = ds_grid_get(global.grid_plants, _g.col, _g.row);
            for (var _ci = ds_list_size(_cards) - 1; _ci >= 0; _ci--) {
                var _cd = _cards[| _ci];
                if (!instance_exists(_cd) || _cd.plant_id == "player" || _cd.plant_type == "coffee") continue;
                longyuan_destroy_card(_cd, true);
            }
        }
    }
    else {
        if (instance_exists(fx_owner)) fx_owner.ly_wheel_done = true;
        instance_destroy();
        exit;
    }
}

// 招魂法杖：沿对角线飞行，沿途格子秒杀非承载卡并生成符咒魂鼠
if (fx_kind == "wuchang_soul_banner_live") {
    var _dir = point_direction(x, y, fx_target_x, fx_target_y);
    var _dd = point_distance(x, y, fx_target_x, fx_target_y);
    if (_dd <= fx_speed) { x = fx_target_x; y = fx_target_y; }
    else { x += lengthdir_x(fx_speed, _dir); y += lengthdir_y(fx_speed, _dir); }
    var _g = get_grid_position_from_world(x, y);
    var _key = string(_g.col) + "," + string(_g.row);
    if (_key != fx_last_cell && _g.col >= 0 && _g.col < global.grid_cols && _g.row >= 0 && _g.row < global.grid_rows) {
        fx_last_cell = _key;
        var _kill = 0;
        var _l = ds_grid_get(global.grid_plants, _g.col, _g.row);
        for (var _i = 0; _i < ds_list_size(_l); _i++) {
            var _p = _l[| _i];
            if (instance_exists(_p) && _p.plant_id != "player" && _p.plant_id != "lingrong_god" && _p.plant_id != "cotton_candy" && _p.plant_type != "coffee") _kill++;
        }
        if (_kill > 0) {
            longyuan_bridge_clear_cell(_g.col, _g.row);
            var _cp = get_world_position_from_grid(_g.col, _g.row);
            instance_create_depth(_cp.x, _cp.y, depth, obj_ly_fuzhou_minion);
        }
    }
    if (x == fx_target_x && y == fx_target_y) { instance_destroy(); exit; }
}

// 献宝元宝：飞行 → 落地（摧毁该格卡片+锁链连接BOSS与玩家）→ 2秒后将玩家拉来并爆炸
if (fx_kind == "wuchang_yuanbao") {
    if (fx_stage == 0) {
        // 飞行：落地之前一直循环 spr_yuanbao_fly
        var _dir = point_direction(x, y, fx_target_x, fx_target_y);
        var _dd = point_distance(x, y, fx_target_x, fx_target_y);
        if (_dd <= fx_speed) { x = fx_target_x; y = fx_target_y; }
        else { x += lengthdir_x(fx_speed, _dir); y += lengthdir_y(fx_speed, _dir); }
        longyuan_clip_frame(timer, fx_rate, true);
        if (x == fx_target_x && y == fx_target_y) {
            fx_stage = 1; fx_life = 0; timer = 0;
            longyuan_clip_set("待机");
            longyuan_damage_cell(fx_col, fx_row, 0, true); // 落地瞬间摧毁该格卡片
            // 从BOSS身上出现蓝色锁链一直连接至元宝
            if (instance_exists(fx_owner)) {
                var _x1 = fx_owner.x, _y1 = fx_owner.y - 40;
                var _n = max(2, ceil(point_distance(_x1, _y1, x, y) / 32));
                var _ang = point_direction(_x1, _y1, x, y);
                for (var _i = 1; _i <= _n; _i++) {
                    var _lk = instance_create_depth(lerp(_x1, x, _i / _n), lerp(_y1, y, _i / _n), depth, obj_ly_boss_fx);
                    longyuan_boss_fx_start(_lk, "wuchang_chain1_blue", "待机", true, 5);
                    _lk.fx_kind = "wuchang_chain_link"; _lk.fx_owner = fx_owner;
                    _lk.image_angle = _ang;
                }
            }
            // 从元宝位置出现红色锁链连接至人物角色
            var _pl = instance_find(obj_player_character, 0);
            if (instance_exists(_pl)) {
                var _n = max(2, ceil(point_distance(x, y, _pl.x, _pl.y) / 32));
                var _ang = point_direction(x, y, _pl.x, _pl.y);
                for (var _i = 1; _i < _n; _i++) {
                    var _lk = instance_create_depth(lerp(x, _pl.x, _i / _n), lerp(y, _pl.y, _i / _n), depth, obj_ly_boss_fx);
                    longyuan_boss_fx_start(_lk, "wuchang_chain1_red", "动画", true, 5);
                    _lk.fx_kind = "wuchang_chain_link"; _lk.fx_owner = fx_owner;
                    _lk.image_angle = _ang;
                }
            }
        }
    }
    else if (fx_stage == 1) {
        // 落地待机：元宝一直播放 spr_yuanbao_idel，2秒后引爆
        fx_life++;
        longyuan_clip_frame(timer, fx_rate, true);
        if (fx_life >= LY_WUCHANG_YUANBAO_WAIT) {
            fx_stage = 2; timer = 0;
            longyuan_clip_set("爆炸");
            var _pl = instance_find(obj_player_character, 0);
            if (instance_exists(_pl)) {
                // 将人物移动至元宝所在位置
                card_destroyed(_pl);
                card_created(_pl, fx_col, fx_row);
                _pl.x = x; _pl.y = y;
                // 扣除玩家一半血量
                _pl.hp = max(1, _pl.hp div 2);
                _pl.hurt_time = LY_WUCHANG_SEAL_DUR;
                _pl.flash_value = 100;
                // 封印25秒：禁用玩家所有武器及宝石、吸收场上火苗、人物身上持续播放 chain2_red
                var _seal = instance_create_depth(_pl.x, _pl.y - 40, depth - 1, obj_ly_boss_fx);
                longyuan_boss_fx_start(_seal, "wuchang_chain2_red", "循环", true, 5);
                _seal.fx_kind = "wuchang_seal";
                _seal.fx_life = 0; _seal.fx_duration = LY_WUCHANG_SEAL_DUR;
                _seal.fx_target = _pl;
                _seal.fx_sealed = ds_list_create();
                with (all) {
                    if (id == _seal.id) continue;
                    if (variable_instance_exists(id, "parent_player") && parent_player == _pl) {
                        ds_list_add(_seal.fx_sealed, id);
                    }
                }
                // 先收集再停用，避免在 with(all) 迭代中停用导致跳过实例
                for (var _si = 0; _si < ds_list_size(_seal.fx_sealed); _si++) {
                    instance_deactivate_object(_seal.fx_sealed[| _si]);
                }
            }
            // 清除连接锁链
            with (obj_ly_boss_fx) {
                if (fx_kind == "wuchang_chain_link") instance_destroy();
            }
        }
    }
    else {
        // 爆炸（spr_yuanbao_baozha）播完销毁
        longyuan_clip_frame(timer, fx_rate, false);
        if (longyuan_clip_done(timer, fx_rate)) { instance_destroy(); exit; }
    }
    timer++;
    exit;
}

// 献宝封印：25秒内跟随人物播放 chain2_red，持续吸收场上火苗；销毁时（Destroy事件）恢复武器
if (fx_kind == "wuchang_seal") {
    fx_life++;
    var _pl = fx_target;
    if (!instance_exists(_pl)) { instance_destroy(); exit; }
    x = _pl.x; y = _pl.y - 40;
    with (obj_flame) instance_destroy(); // 吸收场上生成的火苗
    if (fx_life >= fx_duration) { instance_destroy(); exit; }
    longyuan_clip_frame(timer, fx_rate, true);
    timer++;
    exit;
}

// 按本地计时器驱动当前动作的子图帧
longyuan_clip_frame(timer, fx_rate, fx_loop);

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
