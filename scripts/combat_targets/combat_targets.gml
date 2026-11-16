/// Row buckets only narrow candidates. Callers retain their own range, type,
/// health and priority rules; homing and ray-based attacks are not row queries.
/// Arrays/structs are GC-managed: this index does not own DS handles.
function combat_targets_state() {
    static state = {step: 0, enemies: {step: -1, count: -1, rows: {}, dirty: true},
        cards: {step: -1, count: -1, rows: {}, dirty: true}};
    return state;
}

function combat_targets_begin_step() {
    combat_targets_state().step++;
}

function combat_targets_invalidate(_object) {
    var _state = combat_targets_state();
    if (_object == obj_enemy_parent || object_is_ancestor(_object, obj_enemy_parent)) _state.enemies.dirty = true;
    if (_object == obj_card_parent || object_is_ancestor(_object, obj_card_parent)) _state.cards.dirty = true;
}

/// Use for direct logical row changes, including teleports/knockback. Coordinate
/// conversion also calls this before its result is assigned to grid_row.
/// 行桶与跨帧缓存里存的是「实例 id」，随时可能是刚被别的子弹打死的实例。
/// GM 会把过期 id 当对象索引解析，`with (过期 id)` 直接抛
/// "Unable to find instance for object index"（且行号报 -1，看上去像崩在函数入口）。
/// instance_exists 对对象索引恒为 true → 必须和 object_exists 一起判才排得干净
/// （写法同 precise_bbox_collision 的 bullet_sap_type_list）。
function combat_target_alive(_inst) {
    if (!instance_exists(_inst)) return false;
    if (object_exists(_inst)) return false;
    // 🔴 2026-11-16：**对象池回收后的敌人 id 依然存在**。
    //   obj_pool_release 用 instance_change(obj_pool_holder) 把死掉的老鼠换成占位对象丢到
    //   (-100000,-100000)，id 不销毁、grid_row / target_type / hp 这些变量全都留着 ——
    //   上面两条判据都会放行，于是索敌会选中「尸体」，跨帧缓存里也一直存着它，
    //   下一次对它取属性 / with 就报 "Unable to find instance for object index"。
    //   obj_ronghehuopen_ice_ctrl 早就按这个口径处理过（见其 Step_2 注释），这里统一。
    if (_inst.object_index == obj_pool_holder) return false;
    return true;
}

function combat_targets_row_value(_inst, _row) {
    if (is_struct(_inst)) return _row;
    if (instance_exists(_inst) && (!variable_instance_exists(_inst, "grid_row") || _inst.grid_row != _row)) {
        combat_targets_invalidate(_inst.object_index);
    }
    return _row;
}

function combat_targets_row(_object, _row) {
    var _state = combat_targets_state();
    var _cache = (_object == obj_enemy_parent) ? _state.enemies : _state.cards;
    var _count = instance_number(_object);
    if (_cache.dirty || _cache.step != _state.step || _cache.count != _count) {
        var _rows = {};
        // Keep native with-order, including across child objects. Equal-distance
        // targeting and the enemy's last-card-per-layer rule depend on it.
        with (_object) {
            var _key = string(grid_row);
            if (!variable_struct_exists(_rows, _key)) _rows[$ _key] = [];
            array_push(_rows[$ _key], id);
        }
        _cache.rows = _rows;
        _cache.count = _count;
        _cache.step = _state.step;
        _cache.dirty = false;
    }
    var _key = string(_row);
    return variable_struct_exists(_cache.rows, _key) ? _cache.rows[$ _key] : [];
}

/// These queries deliberately do not add an hp check: legacy cards which can
/// start their animation against dying enemies must retain that behaviour.
function combat_enemy_in_rows(_card, _first_row, _last_row, _first_col, _last_col, _type) {
    // Boolean queries need any valid target, not the first instance. Revalidate
    // the previous one live before rebuilding/scanning a row on the next frame.
    if (variable_instance_exists(_card, "combat_row_target")) {
        // 🔴 with(已销毁实例的 id) 会直接抛 "Unable to find any instance for object index"：
        //   上一帧缓存的目标这一帧被别的子弹打死了（obj_xiao_long_bao 实测 id 101063）。
        //   instance_exists 只对实例 id 可靠，对对象索引恒为 true → 两个一起判才排得干净
        //   （同 precise_bbox_collision 的 bullet_sap_type_list）。
        var _cached = _card.combat_row_target;
        if (combat_target_alive(_cached)) {
            with (_cached) {
                if ((object_index == obj_enemy_parent || object_is_ancestor(object_index, obj_enemy_parent))
                    && grid_row >= _first_row && grid_row <= _last_row
                    && grid_col >= _first_col && grid_col <= _last_col
                    && can_target_on(_type, target_type)) return true;
            }
        }
    }
    for (var _row = _first_row; _row <= _last_row; _row++) {
        var _candidates = combat_targets_row(obj_enemy_parent, _row);
        for (var _i = 0; _i < array_length(_candidates); _i++) {
            // 行桶是「本 step 首次调用时」建的快照：建完之后同一 step 里被打死的敌人
            // 仍留在数组里，直接 with 会抛 Unable to find any instance
            if (!combat_target_alive(_candidates[_i])) continue;
            with (_candidates[_i]) {
                if (grid_row == _row && grid_col >= _first_col && grid_col <= _last_col
                    && can_target_on(_type, target_type)) {
                    _card.combat_row_target = id;
                    return true;
                }
            }
        }
    }
    _card.combat_row_target = noone;
    return false;
}

function combat_enemy_nearest_in_row(_card, _type) {
    var _row = _card.grid_row;
    var _col = _card.grid_col;
    var _last_col = global.grid_cols + 1;
    var _candidates = combat_targets_row(obj_enemy_parent, _row);
    var _best = noone;
    var _distance = 10000;
    for (var _i = 0; _i < array_length(_candidates); _i++) {
        if (!combat_target_alive(_candidates[_i])) continue;
        with (_candidates[_i]) {
            if (grid_row != _row || grid_col < _col || grid_col > _last_col
                || !can_target_on(_type, target_type)) continue;
            var _delta = grid_col - _col;
            if (_delta < _distance) { _distance = _delta; _best = id; }
        }
    }
    return _best;
}

function combat_enemy_find_plant(_enemy) {
    var _candidates = combat_targets_row(obj_card_parent, _enemy.grid_row);
    var _order = [noone, noone, noone, noone];
    var _ladder_hosts = [];
    if (_enemy.can_use_ladder) with (obj_ladder) array_push(_ladder_hosts, host_plant);
    for (var _i = 0; _i < array_length(_candidates); _i++) {
        var _plant = _candidates[_i];
        if (!combat_target_alive(_plant) || _plant.grid_row != _enemy.grid_row) continue;
        if (_enemy.mouse_id == "longyuan_gaoqiao" && _plant.plant_id != "chocolate_bread"
            && _plant.plant_id != "pineapple_explosive_bread" && _plant.plant_id != "mianbao"
            && _plant.plant_id != "lightning_baguette") continue;
        var _dx = _plant.x - _enemy.x;
        var _in_front = _enemy.attack_range > 0 ? (_dx < 0 && _dx > -_enemy.attack_range)
            : (_dx > 0 && _dx < -_enemy.attack_range);
        if (!_in_front || (_plant.feature_type == "dwarf" && !_enemy.giant_type)
            || array_contains(_ladder_hosts, _plant)) continue;
        var _priority = ds_list_find_index(global.eat_order, _plant.plant_type);
        if (_priority >= 0 && _priority < 4) _order[_priority] = _plant;
    }
    for (var _i = 0; _i < 4; _i++) if (_order[_i] != noone) return _order[_i];
    return noone;
}
