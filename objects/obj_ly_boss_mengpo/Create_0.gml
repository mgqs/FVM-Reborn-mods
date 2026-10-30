event_inherited();
image_speed = 0; // 动画完全由 longyuan_clip_* 驱动

// ===== 孟婆鼠 =====
ly_kind = "mengpo";
ly_anims = longyuan_animation_table("mengpo");
mouse_id = "ly_mengpo";
hp = 300000; maxhp = 300000;

// 对象无默认精灵：创建当帧先把 sprite_index 设为出生动作，避免 Draw 时精灵为 -1
ly_action = "";
longyuan_play("出生");

atk = 5000;
wait_time = 180;        // 技能间隔（步）
ly_move_speed = 6;      // 技能3 巡场速度（像素/步）

// 技能循环：2 → 1 → 2 → 3
ly_skill_cycle = [BOSS_STATE.SKILL2, BOSS_STATE.SKILL1, BOSS_STATE.SKILL2, BOSS_STATE.SKILL3];
ly_skill_index = 0;

// ===== 运行时状态 =====
ly_phase = 0;
ly_tea_trees = [];      // 茶树 fx 实例（已按逆时针排序）
ly_tea_spawned = false;
ly_mist_fx = noone;
ly_mist_off_x = 0;      // 迷雾相对 BOSS 原点的偏移（对准身体中心）
ly_mist_off_y = 0;
ly_wind_fx = [];        // 风线实例
ly_pick_idx = 0;        // 技能3 采茶顺序
ly_path = [];           // 技能3 巡场路径（[col,row] 数组）
ly_path_idx = 0;
ly_tp_col = -1;         // 本次技能的目标落点（只在闪出结束时选一次）
ly_tp_row = -1;

// ===== 数值 =====
ly_rain_life = 20 * game_get_speed(gamespeed_fps);   // 降雨持续 20 秒
ly_wind_life = 10 * game_get_speed(gamespeed_fps);   // 风暴持续 10 秒
ly_wind_dps = 50;                                     // 风暴风眼每秒伤害
ly_wind_speed = 6;                                    // 风暴移动速度
ly_star_down = 5;                                     // 技能3 沿途降星数

// ================= 工具函数 =================

/// 星级贴图
ly_star_spr = function(_lv) {
    switch (_lv) {
        case 4: return spr_star_4;
        case 5: return spr_star_5;
        case 6: return spr_star_6;
        case 7: return spr_star_7;
        case 8: return spr_star_8;
        case 9: return spr_star_9;
        case 10: return spr_star_10;
        case 11: return spr_star_11;
        case 12: return spr_star_12;
        case 13: return spr_star_13;
        case 14: return spr_star_14;
        case 15: return spr_star_15;
        case 16: return spr_star_16;
    }
    return -1;
};

/// 该格是否有瓜皮护罩 / 处女座 / 赫拉 保护
ly_cell_protected = function(_col, _row) {
    if (_col < 0 || _col >= global.grid_cols || _row < 0 || _row >= global.grid_rows) return false;
    var _list = ds_grid_get(global.grid_plants, _col, _row);
    for (var _i = 0; _i < ds_list_size(_list); ++_i) {
        var _c = _list[| _i];
        if (!instance_exists(_c)) continue;
        if (_c.plant_id == "melon_shield" || _c.plant_id == "chunv" || _c.plant_id == "hera") return true;
    }
    return false;
};

/// 该格是否有茶树
ly_cell_has_tree = function(_col, _row) {
    var _has = false;
    with (obj_ly_boss_fx) {
        if (id != other.id && fx_kind == "mengpo_tea_tree_live" && fx_col == _col && fx_row == _row) _has = true;
    }
    return _has;
};

/// 该格是否已有蘑菇
ly_cell_has_mushroom = function(_col, _row) {
    var _has = false;
    with (obj_ly_mengpo_mushroom) {
        if (grid_col == _col && grid_row == _row) _has = true;
    }
    return _has;
};

/// 单格卡片降低 N 星（沿用克洛托降星实现）
ly_cell_star_down = function(_col, _row) {
    if (_col < 0 || _col >= global.grid_cols || _row < 0 || _row >= global.grid_rows) return;
    var _list = ds_grid_get(global.grid_plants, _col, _row);
    for (var _i = 0; _i < ds_list_size(_list); ++_i) {
        var _card = _list[| _i];
        if (!instance_exists(_card)) continue;
        with (_card) {
            if (plant_id == "player" || plant_type == "coffee") continue;
            if (current_level <= 0) continue;
            current_level = max(0, current_level - other.ly_star_down);
            var _data = get_plant_data_with_skill(plant_id, shape, current_level, skill);
            if (_data != undefined) {
                hp = ds_map_find_value(_data, "hp");
                max_hp = hp;
                cost = ds_map_find_value(_data, "cost");
                atk = ds_map_find_value(_data, "atk");
                base_atk = atk;
                range = ds_map_find_value(_data, "range");
                cooldown = ds_map_find_value(_data, "cooldown");
                cycle = ds_map_find_value(_data, "cycle");
                if (ds_map_exists(_data, "flame_produce")) flame_produce = ds_map_find_value(_data, "flame_produce");
                if (ds_map_exists(_data, "first_produce_delay")) first_produce_delay = ds_map_find_value(_data, "first_produce_delay");
            }
            var _spr = other.ly_star_spr(current_level);
            if (instance_exists(banding_star_obj)) {
                if (current_level < 4) {
                    instance_destroy(banding_star_obj);
                    banding_star_obj = noone;
                }
                else banding_star_obj.sprite_index = _spr;
            }
            else if (current_level >= 4) {
                var _st = instance_create_depth(x, y - 5, depth, obj_stars);
                _st.sprite_index = _spr;
                _st.parent_card = id;
                banding_star_obj = _st.id;
            }
        }
    }
};

/// 出场：随机把 3 根龙柱变成茶树
ly_spawn_tea_trees = function() {
    if (ly_tea_spawned) return;
    ly_tea_spawned = true;

    var _pillars = [];
    with (obj_longzhu) array_push(_pillars, id);
    // 洗牌
    for (var _i = array_length(_pillars) - 1; _i > 0; --_i) {
        var _j = irandom(_i);
        var _tmp = _pillars[_i];
        _pillars[_i] = _pillars[_j];
        _pillars[_j] = _tmp;
    }

    var _n = min(3, array_length(_pillars));
    for (var _i = 0; _i < _n; ++_i) {
        var _p = _pillars[_i];
        var _pc = _p.col, _pr = _p.row;
        var _pos = get_world_position_from_grid(_pc, _pr);
        // 与龙柱同尺寸、同绘制层级（龙柱 LONGZHU_SCALE=2，深度在卡片之后）
        var _tree = instance_create_depth(_pos.x, _pos.y, LONGZHU_PILLAR_BASE_DEPTH, obj_ly_boss_fx);
        longyuan_boss_fx_start(_tree, "mengpo_tea_tree", "生长出树枝", false, 5, "树枝待机", true);
        _tree.fx_kind = "mengpo_tea_tree_live";
        _tree.fx_col = _pc;
        _tree.fx_row = _pr;
        // 与龙柱同尺寸（龙柱 LONGZHU_SCALE=2）
        _tree.image_xscale = 2;
        _tree.image_yscale = 2;
        array_push(ly_tea_trees, _tree);
        instance_destroy(_p);
    }

    // 按屏幕视角逆时针排序（以质心为圆心，角度降序）
    var _cnt = array_length(ly_tea_trees);
    if (_cnt > 1) {
        var _cx = 0, _cy = 0;
        for (var _i = 0; _i < _cnt; ++_i) { _cx += ly_tea_trees[_i].x; _cy += ly_tea_trees[_i].y; }
        _cx /= _cnt; _cy /= _cnt;
        for (var _i = 0; _i < _cnt - 1; ++_i) {
            for (var _j = 0; _j < _cnt - 1 - _i; ++_j) {
                var _a = ly_tea_trees[_j], _b = ly_tea_trees[_j + 1];
                // point_direction 角度递增即屏幕上的逆时针，升序排列
                if (point_direction(_cx, _cy, _a.x, _a.y) > point_direction(_cx, _cy, _b.x, _b.y)) {
                    ly_tea_trees[_j] = _b;
                    ly_tea_trees[_j + 1] = _a;
                }
            }
        }
    }
};

/// 技能1 降雨效果：茶树生叶 + 3×3 降雨 + 未保护格长蘑菇并毁卡
ly_skill1_rain = function() {
    for (var _t = 0; _t < array_length(ly_tea_trees); ++_t) {
        var _tree = ly_tea_trees[_t];
        if (!instance_exists(_tree)) continue;

        // 茶树生绿叶
        with (_tree) {
            longyuan_clip_set("生出绿叶");
            timer = 0;
            fx_loop = false;
            fx_next_action = "绿叶待机";
            fx_loop_after = true;
        }

        // 3×3 降雨动画
        var _rain = instance_create_depth(_tree.x, _tree.y, -700, obj_ly_boss_fx);
        longyuan_boss_fx_start(_rain, "mengpo_rain", "下雨", true, 5);
        _rain.fx_kind = "mengpo_rain_live";
        _rain.fx_col = _tree.fx_col;
        _rain.fx_row = _tree.fx_row;
        _rain.fx_life = 0;
        _rain.fx_duration = ly_rain_life;
        _rain.image_xscale = (3 * global.grid_cell_size_x) / sprite_get_width(spr_ly_mengpo_rain);
        _rain.image_yscale = (3 * global.grid_cell_size_y) / sprite_get_height(spr_ly_mengpo_rain);
        // 精灵原点不在中心，补偿偏移让 3×3 画面正对茶树所在格
        _rain.x += (sprite_get_width(spr_ly_mengpo_rain) / 2 - sprite_get_xoffset(spr_ly_mengpo_rain)) * _rain.image_xscale;
        _rain.y += (sprite_get_height(spr_ly_mengpo_rain) / 2 - sprite_get_yoffset(spr_ly_mengpo_rain)) * _rain.image_yscale;
        _rain.image_alpha = 0.85;

        // 周围 8 格
        for (var _dx = -1; _dx <= 1; ++_dx) {
            for (var _dy = -1; _dy <= 1; ++_dy) {
                if (_dx == 0 && _dy == 0) continue;
                var _c = _tree.fx_col + _dx;
                var _r = _tree.fx_row + _dy;
                if (ly_cell_protected(_c, _r)) continue;
                if (ly_cell_has_tree(_c, _r)) continue;
                if (ly_cell_has_mushroom(_c, _r)) continue;
                // 摧毁该格卡片
                longyuan_damage_cell(_c, _r, 0, true);
                // 长蘑菇
                var _pos = get_world_position_from_grid(_c, _r);
                var _m = instance_create_depth(_pos.x, _pos.y, -10 - _r * 45 - _c * 5 - 4.5, obj_ly_mengpo_mushroom);
                _m.grid_col = _c;
                _m.grid_row = _r;
            }
        }
    }
};

/// 技能2 狂风：全屏风幕 + 4 条同向风线 + BOSS 迷雾
ly_skill2_wind = function() {
    // 全屏风幕
    var _mid = get_world_position_from_grid((global.grid_cols - 1) * 0.5, (global.grid_rows - 1) * 0.5);
    var _sw = instance_create_depth(_mid.x, _mid.y, -650, obj_ly_boss_fx);
    longyuan_boss_fx_start(_sw, "mengpo_strong_wind", "待机", true, 5);
    _sw.fx_kind = "mengpo_strong_wind_live";
    _sw.fx_life = 0;
    _sw.fx_duration = ly_wind_life;
    _sw.image_xscale = (global.grid_cols * global.grid_cell_size_x) / sprite_get_width(spr_ly_mengpo_strong_wind);
    _sw.image_yscale = (global.grid_rows * global.grid_cell_size_y) / sprite_get_height(spr_ly_mengpo_strong_wind);
    _sw.image_alpha = 0.55;

    // 随机风向：0 左 / 1 右 / 2 上 / 3 下
    var _dir = irandom(3);
    var _kind = ["mengpo_wind_left", "mengpo_wind_right", "mengpo_wind_up", "mengpo_wind_down"][_dir];
    var _dx = (_dir == 0) ? -1 : ((_dir == 1) ? 1 : 0);
    var _dy = (_dir == 2) ? -1 : ((_dir == 3) ? 1 : 0);

    // 随机 4 行（左右风）或 4 列（上下风）
    var _slots = [];
    var _max = (_dir == 0 || _dir == 1) ? global.grid_rows : global.grid_cols;
    var _take = min(4, _max);
    while (array_length(_slots) < _take) {
        var _v = irandom(_max - 1);
        if (!array_contains(_slots, _v)) array_push(_slots, _v);
    }

    for (var _i = 0; _i < array_length(_slots); ++_i) {
        var _side = _slots[_i];
        var _wx = 0, _wy = 0;
        var _pp = undefined;
        if (_dir == 0) {         // 左：从地图右侧生成
            _pp = get_world_position_from_grid(global.grid_cols - 1, _side);
            _wx = _pp.x + global.grid_cell_size_x + 80;
            _wy = _pp.y;
        }
        else if (_dir == 1) {    // 右：从地图左侧生成
            _pp = get_world_position_from_grid(0, _side);
            _wx = _pp.x - global.grid_cell_size_x - 80;
            _wy = _pp.y;
        }
        else if (_dir == 2) {    // 上：从地图下方生成
            _pp = get_world_position_from_grid(_side, global.grid_rows - 1);
            _wx = _pp.x;
            _wy = _pp.y + global.grid_cell_size_y + 80;
        }
        else {                   // 下：从地图上方生成
            _pp = get_world_position_from_grid(_side, 0);
            _wx = _pp.x;
            _wy = _pp.y - global.grid_cell_size_y - 80;
        }

        var _w = instance_create_depth(_wx, _wy, -640, obj_ly_boss_fx);
        longyuan_boss_fx_start(_w, _kind, "待机", true, 5);
        _w.fx_kind = "mengpo_wind_line";
        _w.fx_dir_x = _dx;
        _w.fx_dir_y = _dy;
        _w.fx_speed = ly_wind_speed;
        _w.fx_damage = ly_wind_dps;
        _w.fx_life = 0;
        _w.fx_duration = ly_wind_life;
        _w.fx_damage_timer = 0;
        _w.fx_hit_key = "";
        array_push(ly_wind_fx, _w);
    }

    // BOSS 迷雾保护
    var _mist = instance_create_depth(x, y, depth - 1, obj_ly_boss_fx);
    longyuan_boss_fx_start(_mist, "mengpo_wind_mist", "待机", true, 5);
    _mist.fx_kind = "mengpo_wind_mist_live";
    // 迷雾覆盖 BOSS 身体：按当前动作精灵的实际不透明包围盒缩放，并对准包围盒中心
    var _bl = sprite_get_bbox_left(sprite_index), _br = sprite_get_bbox_right(sprite_index);
    var _bt = sprite_get_bbox_top(sprite_index), _bb = sprite_get_bbox_bottom(sprite_index);
    _mist.image_xscale = ((_br - _bl + 1) * image_xscale) / sprite_get_width(spr_ly_mengpo_wind_mist);
    _mist.image_yscale = ((_bb - _bt + 1) * image_yscale) / sprite_get_height(spr_ly_mengpo_wind_mist);
    ly_mist_off_x = ((_bl + _br) / 2 - sprite_get_xoffset(sprite_index)) * image_xscale;
    ly_mist_off_y = ((_bt + _bb) / 2 - sprite_get_yoffset(sprite_index)) * image_yscale;
    _mist.x = x + ly_mist_off_x;
    _mist.y = y + ly_mist_off_y;
    // 迷雾与风暴同寿命（10 秒），由 obj_ly_boss_fx 的 fx_life/fx_duration 驱动
    _mist.fx_life = 0;
    _mist.fx_duration = ly_wind_life;
    ly_mist_fx = _mist;
};

/// BOSS 是否被油灯 / 萤火蛇照亮
ly_boss_lit = function() {
    var _min_d = 99;
    with (obj_oil_lamp) {
        var _d = (shape >= 1) ? 0 : abs(grid_row - other.grid_row) + abs(grid_col - other.grid_col);
        if (_d < _min_d) _min_d = _d;
    }
    with (obj_yinghuoshe) {
        if (hp > 0 && !is_frozen && state != CARD_STATE.SLEEP) _min_d = 0;
    }
    return _min_d <= 2;
};

/// 技能3 巡场路径
ly_build_path = function() {
    ly_path = [];
    ly_path_idx = 0;

    var _c0 = global.grid_cols - 1;
    var _r0 = grid_row;
    var _rows = global.grid_rows;
    var _c, _r;

    // 1) 沿本行向左走到尽头
    for (_c = _c0; _c >= 0; --_c) array_push(ly_path, [_c, _r0]);

    // 2) 随机上或下 2 格
    var _dv = choose(-1, 1);
    var _r1 = clamp(_r0 + _dv * 2, 0, _rows - 1);
    var _st = sign(_r1 - _r0);
    for (_r = _r0 + _st; _st != 0 && ((_st > 0 && _r <= _r1) || (_st < 0 && _r >= _r1)); _r += _st) {
        array_push(ly_path, [0, _r]);
    }

    // 3) 向右回到第9列
    for (_c = 1; _c <= _c0; ++_c) array_push(ly_path, [_c, _r1]);

    // 4) 反向走 2 格回到原点行
    var _st2 = sign(_r0 - _r1);
    for (_r = _r1 + _st2; _st2 != 0 && ((_st2 > 0 && _r <= _r0) || (_st2 < 0 && _r >= _r0)); _r += _st2) {
        array_push(ly_path, [_c0, _r]);
    }
};

// ================= 状态机 =================
ly_boss_step = function() {
    var _act;

    switch (state) {
        case BOSS_STATE.APPEAR: {
            ly_spawn_tea_trees();
            if (ly_action != "出生") longyuan_clip_set("出生");
            longyuan_clip_frame(timer, ly_anim_rate, false);
            if (longyuan_clip_done(timer, ly_anim_rate)) { timer = 0; state = BOSS_STATE.IDLE; }
            break;
        }

        case BOSS_STATE.IDLE: {
            if (ly_action != "正常待机") longyuan_clip_set("正常待机");
            longyuan_clip_frame(timer, ly_anim_rate, true);
            if (timer >= wait_time) {
                timer = 0; ly_hit = false; ly_phase = 0;
                state = ly_skill_cycle[ly_skill_index];
                ly_skill_index = (ly_skill_index + 1) mod array_length(ly_skill_cycle);
            }
            break;
        }

        // ============ 技能1：降雨 ============
        case BOSS_STATE.SKILL1: {
            if (ly_phase == 0) { // 原位置闪出
                if (ly_action != "正常闪出") longyuan_clip_set("正常闪出");
                longyuan_clip_frame(timer, ly_anim_rate, false);
                if (longyuan_clip_done(timer, ly_anim_rate)) {
                    // 闪出结束才随机落点：第7列或第0列某一行
                    var _tc = choose(7, 0);
                    if (_tc >= global.grid_cols) _tc = global.grid_cols - 1;
                    ly_tp_col = _tc;
                    ly_tp_row = irandom(global.grid_rows - 1);
                    ly_phase = 1; timer = 0;
                }
            }
            else if (ly_phase == 1) { // 落到目标格并闪进
                if (ly_action != "正常闪进") {
                    var _pos = get_world_position_from_grid(ly_tp_col, ly_tp_row);
                    x = _pos.x; y = _pos.y;
                    grid_col = ly_tp_col; grid_row = ly_tp_row;
                    longyuan_clip_set("正常闪进");
                }
                longyuan_clip_frame(timer, ly_anim_rate, false);
                if (longyuan_clip_done(timer, ly_anim_rate)) { ly_phase = 2; timer = 0; }
            }
            else if (ly_phase == 2) { // 降雨动画
                if (ly_action != "正常技能1") longyuan_clip_set("正常技能1");
                longyuan_clip_frame(timer, ly_anim_rate, false);
                if (timer == 20 * ly_anim_rate) ly_skill1_rain();
                if (longyuan_clip_done(timer, ly_anim_rate)) { timer = 0; ly_phase = 0; state = BOSS_STATE.IDLE; }
            }
            break;
        }

        // ============ 技能2：狂风 ============
        case BOSS_STATE.SKILL2: {
            if (ly_phase == 0) { // 原位置闪出
                if (ly_action != "正常闪出") longyuan_clip_set("正常闪出");
                longyuan_clip_frame(timer, ly_anim_rate, false);
                if (longyuan_clip_done(timer, ly_anim_rate)) {
                    // 闪出结束才随机落点（全图随机）
                    ly_tp_col = irandom(global.grid_cols - 1);
                    ly_tp_row = irandom(global.grid_rows - 1);
                    ly_phase = 1; timer = 0;
                }
            }
            else if (ly_phase == 1) { // 落到目标格并闪进
                if (ly_action != "正常闪进") {
                    var _pos2 = get_world_position_from_grid(ly_tp_col, ly_tp_row);
                    x = _pos2.x; y = _pos2.y;
                    grid_col = ly_tp_col; grid_row = ly_tp_row;
                    longyuan_clip_set("正常闪进");
                }
                longyuan_clip_frame(timer, ly_anim_rate, false);
                if (longyuan_clip_done(timer, ly_anim_rate)) { ly_phase = 2; timer = 0; }
            }
            else if (ly_phase == 2) { // 狂风动画
                if (ly_action != "正常技能2") longyuan_clip_set("正常技能2");
                longyuan_clip_frame(timer, ly_anim_rate, false);
                if (timer == 22 * ly_anim_rate) ly_skill2_wind();
                if (longyuan_clip_done(timer, ly_anim_rate)) {
                    timer = 0; ly_phase = 0; state = BOSS_STATE.IDLE;
                }
            }
            break;
        }

        // ============ 技能3：采茶浇地 ============
        case BOSS_STATE.SKILL3: {
            if (ly_phase == 0) { // 原位置闪出
                if (ly_action != "正常闪出") longyuan_clip_set("正常闪出");
                longyuan_clip_frame(timer, ly_anim_rate, false);
                if (longyuan_clip_done(timer, ly_anim_rate)) {
                    // 闪出结束才随机落点：第9列（最右列）某一行
                    ly_tp_col = global.grid_cols - 1;
                    ly_tp_row = irandom(global.grid_rows - 1);
                    ly_phase = 1; timer = 0;
                }
            }
            else if (ly_phase == 1) { // 落到第9列并闪进
                if (ly_action != "正常闪进") {
                    var _pos3 = get_world_position_from_grid(ly_tp_col, ly_tp_row);
                    x = _pos3.x; y = _pos3.y;
                    grid_col = ly_tp_col; grid_row = ly_tp_row;
                    longyuan_clip_set("正常闪进");
                }
                longyuan_clip_frame(timer, ly_anim_rate, false);
                if (longyuan_clip_done(timer, ly_anim_rate)) { ly_phase = 2; timer = 0; ly_pick_idx = 0; }
            }
            else if (ly_phase == 2) { // 技能3 起手
                if (ly_action != "正常技能3") longyuan_clip_set("正常技能3");
                longyuan_clip_frame(timer, ly_anim_rate, false);
                if (longyuan_clip_done(timer, ly_anim_rate)) {
                    // 重置每棵树的采茶标记
                    for (var _r2 = 0; _r2 < array_length(ly_tea_trees); ++_r2) {
                        if (instance_exists(ly_tea_trees[_r2])) ly_tea_trees[_r2].ly_pick_started = false;
                    }
                    ly_phase = 3; timer = 0; ly_pick_idx = 0;
                }
            }
            else if (ly_phase == 3) { // 技能3循环 + 茶树按逆时针顺序采茶
                if (ly_action != "正常技能3罐子循环") longyuan_clip_set("正常技能3罐子循环");
                longyuan_clip_frame(timer, ly_anim_rate, true);

                var _done_all = true;
                for (var _t = 0; _t < array_length(ly_tea_trees); ++_t) {
                    var _tree = ly_tea_trees[_t];
                    if (!instance_exists(_tree)) continue;
                    if (_t < ly_pick_idx) continue;         // 已采完
                    if (_t > ly_pick_idx) { _done_all = false; continue; }
                    // 当前这棵：开始采茶（每棵只触发一次）
                    if (!variable_instance_exists(_tree, "ly_pick_started")) _tree.ly_pick_started = false;
                    if (!_tree.ly_pick_started) {
                        _tree.ly_pick_started = true;
                        with (_tree) {
                            longyuan_clip_set("boss采茶");
                            timer = 0;
                            fx_loop = false;
                            fx_next_action = "树枝待机";
                            fx_loop_after = true;
                        }
                    }
                    // 播完采茶会自动切回「树枝待机」，据此推进下一棵
                    if (_tree.ly_pick_started && _tree.ly_action == "树枝待机") {
                        ly_pick_idx++;
                        if (ly_pick_idx < array_length(ly_tea_trees)) _done_all = false;
                    }
                    else _done_all = false;
                    break;
                }
                if (ly_pick_idx >= array_length(ly_tea_trees)) _done_all = true;

                if (_done_all) {
                    ly_build_path();
                    ly_phase = 4;
                    timer = 0;
                }
            }
            else if (ly_phase == 4) { // 原点循环倒水，沿路径巡场降 5 星
                if (ly_action != "正常技能3控制倒水") longyuan_clip_set("正常技能3控制倒水");
                longyuan_clip_frame(timer, ly_anim_rate, true);

                if (ly_path_idx < array_length(ly_path)) {
                    var _cell = ly_path[ly_path_idx];
                    var _tp = get_world_position_from_grid(_cell[0], _cell[1]);
                    var _dd = point_distance(x, y, _tp.x, _tp.y);
                    if (_dd <= ly_move_speed) {
                        x = _tp.x; y = _tp.y;
                        ly_cell_star_down(_cell[0], _cell[1]);
                        ly_path_idx++;
                    }
                    else {
                        var _ang = point_direction(x, y, _tp.x, _tp.y);
                        x += lengthdir_x(ly_move_speed, _ang);
                        y += lengthdir_y(ly_move_speed, _ang);
                    }
                }
                else {
                    ly_phase = 5; timer = 0;
                }
            }
            else if (ly_phase == 5) { // 技能3 结束
                if (ly_action != "正常技能3结束") longyuan_clip_set("正常技能3结束");
                longyuan_clip_frame(timer, ly_anim_rate, false);
                if (longyuan_clip_done(timer, ly_anim_rate)) {
                    timer = 0; ly_phase = 0; state = BOSS_STATE.IDLE;
                }
            }
            break;
        }
    }

    // ===== 迷雾跟随（与风暴同寿命）：每步执行，不随技能2动画结束而消失 =====
    if (instance_exists(ly_mist_fx)) {
        ly_mist_fx.x = x + ly_mist_off_x;
        ly_mist_fx.y = y + ly_mist_off_y;
        var _lit = ly_boss_lit();
        target_type = _lit ? "normal" : "invisible";
        // 照亮时迷雾直接消失，不再照亮时重新浮现
        ly_mist_fx.visible = !_lit;
        if (_lit && image_alpha < 1) image_alpha += 0.05;
        if (!_lit && image_alpha > 0.5) image_alpha -= 0.05;
    }
    else {
        ly_mist_fx = noone;
        if (target_type == "invisible") target_type = "normal";
        if (image_alpha < 1) image_alpha += 0.05;
    }
};
