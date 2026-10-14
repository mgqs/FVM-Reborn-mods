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

function longyuan_find_plant(_heavy_only = false) {
    var _best = noone, _priority = 999, _distance = 1000000000;
    with (obj_card_parent) {
        if (hp <= 0 || plant_id == "player" || plant_type == "coffee") continue;
        var _dx = other.attack_range > 0 ? other.x - x : x - other.x;
        if (grid_row != other.grid_row || _dx < 0 || _dx > abs(other.attack_range)) continue;
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
