/// 每个动作使用SWF标签对应的闭区间，不依赖move_anim等固定偏移。
function longyuan_play(_action, _once = false) {
    if (ly_action == _action) return;
    if (!variable_struct_exists(ly_anims, _action)) {
        show_debug_message("龙渊缺少动作: " + ly_kind + "/" + _action);
        return;
    }
    ly_action = _action;
    ly_frame = 0;
    ly_done = false;
    ly_hit = false;
    ly_once = _once;
    var _clip = ly_anims[$ _action];
    sprite_index = _clip[0];
    image_index = _clip[1] - 1;
}

function longyuan_animate() {
    if (ly_action == "") return;
    var _clip = ly_anims[$ ly_action];
    var _count = _clip[2] - _clip[1] + 1;
    ly_frame += 10 / game_get_speed(gamespeed_fps) / (is_slowdown ? 2 : 1);
    ly_done = ly_frame >= _count;
    image_index = _clip[1] - 1 + (ly_once ? min(floor(ly_frame), _count - 1) : floor(ly_frame) mod _count);
}

function longyuan_variant(_normal, _hurt) {
    return hp <= maxhp * hurt_rate ? _hurt : _normal;
}

function longyuan_is_night() {
    if (variable_global_exists("level_file") && variable_struct_exists(global.level_file, "level_time_feature")) {
        return global.level_file.level_time_feature == "night";
    }
    if (variable_global_exists("level_id")) {
        var _level = string(global.level_id);
        return string_pos("night", _level) > 0 || string_pos("_ye", _level) > 0;
    }
    return false;
}

function longyuan_apply_soul_damage_reduction() {
    damage_amount *= 0.4;
}

function longyuan_air_speed_multiplier() {
    var _multiplier = 1;
    with (obj_ly_dongfeng) {
        if (hp > 0 && ly_wind_active && ly_fan && !is_frozen && !is_stun && !is_scare) _multiplier = 2;
    }
    return _multiplier;
}

function longyuan_card_in_cell(_col, _row) {
    if (_col < 0 || _col >= global.grid_cols || _row < 0 || _row >= global.grid_rows) return noone;
    var _list = ds_grid_get(global.grid_plants, _col, _row);
    for (var _i = 0; _i < ds_list_size(_list); ++_i) {
        var _card = _list[| _i];
        if (instance_exists(_card) && _card.hp > 0 && _card.plant_id != "player" && _card.plant_type != "coffee") return _card;
    }
    return noone;
}

function longyuan_destroy_card(_card) {
    if (!instance_exists(_card) || _card.hp <= 0 || _card.invincible) return;
    var _pos = {x: _card.x, y: _card.y};
    with (_card) {
        no_revive_record = true;
        is_shoveled = true;
        instance_destroy();
    }
    var _effect = instance_create_depth(_pos.x, _pos.y, -800, obj_coke_bomb_explode);
    _effect.sprite_index = spr_coke_bomb_explode;
}

function longyuan_damage_plant_piercing(_plant, _damage) {
    if (!instance_exists(_plant) || _plant.hp <= 0 || _plant.invincible) return;
    with (_plant) {
        hp -= _damage;
        event_user(2);
    }
}

function longyuan_find_plant(_heavy_only = false) {
    var _best = noone, _priority = 999, _distance = 1000000000;
    with (obj_card_parent) {
        if (hp <= 0 || plant_id == "player" || plant_type == "coffee") continue;
        var _dx = x - other.x;
        var _in_front = other.attack_range > 0
            ? (_dx > 0 && _dx <= other.attack_range)
            : (_dx < 0 && -_dx <= -other.attack_range);
        if (grid_row != other.grid_row || !_in_front) continue;
        if (_heavy_only && plant_id != "chocolate_bread" && !(variable_instance_exists(id, "blocks_vault") && blocks_vault)) continue;
        if (feature_type == "dwarf" && !other.giant_type) continue;
        var _order = ds_list_find_index(global.eat_order, plant_type);
        if (_order < 0) continue;
        if (_order < _priority || (_order == _priority && _dx < _distance)) {
            _best = id; _priority = _order; _distance = _dx;
        }
    }
    return _best;
}

function longyuan_damage_plant(_plant, _damage) {
    if (!instance_exists(_plant) || _plant.hp <= 0 || _plant.invincible) return;
    with (_plant) { hp -= _damage; event_user(2); }
}

/// BOSS 范围伤害：对本体所在行的指定列造成 atk 伤害（网格火焰等）
function ly_damage_col(_col) {
    var _row = grid_row;
    var _list = ds_grid_get(global.grid_plants, _col, _row);
    var _count = ds_list_size(_list);
    for (var _i = 0; _i < _count; ++_i) {
        longyuan_damage_plant(_list[| _i], atk);
    }
}

/// BOSS 范围伤害：对指定行的所有植物造成 atk 伤害（音波、迷雾、下雨、火轮等）
function ly_damage_row(_row) {
    for (var _c = 0; _c < global.grid_cols; ++_c) {
        var _list = ds_grid_get(global.grid_plants, _c, _row);
        var _count = ds_list_size(_list);
        for (var _i = 0; _i < _count; ++_i) {
            longyuan_damage_plant(_list[| _i], atk);
        }
    }
}

/// BOSS 寻敌列：返回本行最靠左（最前）的有植物列；本行无植物则返回最右列
function ly_target_col() {
    for (var _c = 0; _c < global.grid_cols; ++_c) {
        if (ds_list_size(ds_grid_get(global.grid_plants, _c, grid_row)) != 0) return _c;
    }
    return global.grid_cols - 1;
}

/// ===== 龙渊 BOSS 动作剪辑控制 =====
/// BOSS 使用「单只大精灵 + 子图区间」表示动作，下面三个函数负责按 ly_anims 表驱动。
/// 切换当前动作：写入 ly_action、切换 sprite_index 并复位到动作首帧，返回该动作帧数。
function longyuan_clip_set(_action) {
    ly_action = _action;
    ly_frame = 0;
    ly_done = false;
    ly_hit = false;
    if (!variable_struct_exists(ly_anims, _action)) {
        show_debug_message("龙渊BOSS缺少动作: " + ly_kind + "/" + _action);
        return 0;
    }
    var _clip = ly_anims[$ _action];
    sprite_index = _clip[0];
    image_index = _clip[1] - 1;
    return _clip[2] - _clip[1] + 1;
}

/// 动作总帧数（swf 标签闭区间长度）
function longyuan_clip_length(_action) {
    if (!variable_struct_exists(ly_anims, _action)) return 0;
    var _clip = ly_anims[$ _action];
    return _clip[2] - _clip[1] + 1;
}

/// 按本地计时器 _t 驱动当前动作帧。_rate = 每帧停留步数，_loop = 是否循环。
function longyuan_clip_frame(_t, _rate = 5, _loop = true) {
    var _n = longyuan_clip_length(ly_action);
    if (_n <= 0) return;
    var _clip = ly_anims[$ ly_action];
    var _f = floor(max(0, _t) / max(1, _rate));
    _f = _loop ? (_f mod _n) : min(_f, _n - 1);
    ly_frame = _f;
    image_index = _clip[1] - 1 + _f;
}

/// 非循环动作是否已播完
function longyuan_clip_done(_t, _rate = 5) {
    var _n = longyuan_clip_length(ly_action);
    if (_n <= 0) return true;
    return _t >= _n * max(1, _rate);
}

/// 桥头米线本体及连接线均可设置此标记；线段也可直接注册在global.longyuan_bridge_lines。
function longyuan_bridge_contact(_x1, _y1, _x2, _y2, _row) {
    var _found = noone;
    with (obj_card_parent) {
        if (hp > 0 && grid_row == _row && variable_instance_exists(id, "longyuan_bridge_connected") && longyuan_bridge_connected
            && x >= min(_x1, _x2) - 20 && x <= max(_x1, _x2) + 20) _found = id;
    }
    if (_found != noone) return _found;
    if (variable_global_exists("longyuan_bridge_lines")) {
        var _lines = global.longyuan_bridge_lines;
        for (var _i = 0; _i < array_length(_lines); ++_i) {
            var _l = _lines[_i];
            if (!instance_exists(_l.owner) || _l.owner.hp <= 0) continue;
            if (collision_line(_l.x1, _l.y1, _l.x2, _l.y2, id, false, false) != noone
                || (_row == _l.owner.grid_row && min(_x1, _x2) <= max(_l.x1, _l.x2) && max(_x1, _x2) >= min(_l.x1, _l.x2))) return _l.owner;
        }
    }
    return noone;
}

/// 创建并启动龙渊 BOSS 特效实例（按动作表驱动）
function longyuan_boss_fx_start(_inst, _kind, _action, _loop = false, _rate = 5, _next = "", _next_loop = true) {
    with (_inst) {
        ly_kind = _kind;
        ly_anims = longyuan_animation_table(_kind);
        fx_kind = _kind;
        fx_rate = _rate;
        fx_loop = _loop;
        fx_loop_after = _next_loop;
        fx_next_action = _next;
        timer = 0;
        longyuan_clip_set(_action);
        fx_ready = true;
    }
}
